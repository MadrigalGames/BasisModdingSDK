// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

const ClientPtr = basis.host.ClientPtr;

const SceneNodePtr = basis.math.SceneNodePtr;
const Vec3 = basis.math.Vec3;
const Mat43 = basis.math.Mat43;
const Quaternion = basis.math.Quaternion;
const TransformInterpolator = basis.math.TransformInterpolator;

const PhysicsScenePtr = basis.physics.PhysicsScenePtr;

//----------------------------------------------------
// TODO: Turn these into hot values when we have support for them.

const gCameraCatchUpSpeed = 0.06666666;

const gCameraWiderFOVCatchUpSpeed = 0.05;
const gCameraNarrowerFOVCatchUpSpeed = 0.5;
const gAdjustFovWithSpeed = true;

const gCameraDefaultFov = 0.25 * std.math.pi;
const gCameraDefaultHaulingFov = 0.28 * std.math.pi;

const gCameraMaxFov = 0.40 * std.math.pi;

const gCameraMinFovSpeed = 4.0;
const gCameraMaxFovSpeed = 27.77777;

const gOrbitHMouseSensitivity = 0.05;
const gOrbitVMouseSensitivity = 0.05;

const gOrbitHGamepadSensitivity = 0.03;
const gOrbitVGamepadSensitivity = 0.02;

const gOrbitTargetOffset = 0.02;
const gOrbitAimAcceleration = true;

const gBlendToDrivingSpeed = 0.02;
const gBlendToOrbitSpeed = 0.04;

const gBlendToNonHaulingSpeed = 0.015;
const gBlendToHaulingSpeed = 0.015;

const gCollisionSphereRadius = 1.0;
const gCollisionReturnSpeed = 0.05;

const gCollisionAABBScale = 1.4;

const gPrintDrivingCameraVectors = false;

//----------------------------------------------------

pub const VehicleCameraController = struct {
    const Self = @This();
    const DEFAULT_ORBIT_DISTANCE = 25.0;
    const FAR_PLANE = 1600.0;

    pub const VehicleCameraMode = enum {
        Driving,
        Orbit,
    };

    const DrivingModeData = struct {
        wantedLocalPosition: Vec3 = .Zero,
        wantedLocalLookAtPos: Vec3 = .Zero,
        cameraTargetDistance: f32 = 0.0,
        firstUpdateAfterSettingParameters: bool = true,
        fovSpeed: f32 = 0.0,
        fov: f32 = 0.0,
        lastCollisionDistance: f32 = -1.0,
        wantedWorldPosition: Vec3 = .Zero,
        wantedWorldLookAtPos: Vec3 = .Zero,
        currentPosition: Vec3 = .Zero,
        currentLookAtPosition: Vec3 = .Zero,
        interpolator: TransformInterpolator = .{},
    };

    const OrbitModeData = struct {
        lookAtPosition: Vec3 = .Zero, // This is an offset from the vehicle position, in world space.
        horizontalRotation: f32 = 0.0,
        verticalRotation: f32 = 0.0,
        fov: f32 = 0.0,
        lastCollisionDistance: f32 = -1.0,
        vehicleNode: SceneNodePtr = .Null,
        verticalTiltNode: SceneNodePtr = .Null,
        cameraNode: SceneNodePtr = .Null,
        interpolator: TransformInterpolator = .{},
    };

    client: ClientPtr,
    physicsScene: PhysicsScenePtr,

    vehicleWorldMatrix: Mat43 = .Identity,

    enabled: bool = false,
    vehicleCameraMode: VehicleCameraMode = .Driving,
    haulingEnabled: bool = false,

    // When this is 0.0 we are fully in driving mode. When, 1.0, fully in orbit mode.
    cameraModeBlendFactor: f32 = 0.0,
    cameraModeBlendFactorInterpolator: basis.math.FloatInterpolator = .{},

    // When this is 0.0 we are fully in normal mode. When, 1.0, fully in hauling mode.
    haulingBlendFactor: f32 = 0.0,
    haulingBlendFactorInterpolator: basis.math.FloatInterpolator = .{},

    cameraPosition: Vec3 = .Zero,
    cameraOrientation: Quaternion = .Identity,
    cameraFov: f32 = basis.math.Pi * 0.25,

    drivingCameraEnabled: bool = true,

    drivingModeData: [2]DrivingModeData,
    orbitModeData: [2]OrbitModeData,

    usingGamepad: bool = false,

    invertYMouse: bool = false,
    invertYGamepad: bool = false,

    ignoreCameraCollisionsTagFlag: u32 = 0,

    //----------------------------------------------------

    pub fn init(client: ClientPtr, invertYMouse: bool, invertYGamepad: bool, ignoreCameraCollisionsTagFlag: u32) Self {
        return Self{
            .client = client,
            .physicsScene = client.getPrimaryPhysicsScene(),
            .drivingModeData = [_]DrivingModeData{ DrivingModeData{}, DrivingModeData{} },
            .orbitModeData = [_]OrbitModeData{ OrbitModeData{}, OrbitModeData{} },
            .invertYMouse = invertYMouse,
            .invertYGamepad = invertYGamepad,
            .ignoreCameraCollisionsTagFlag = ignoreCameraCollisionsTagFlag,
        };
    }

    pub fn postInit(self: *Self) void {
        for (0..2) |i| {
            self.orbitModeData[i].vehicleNode = SceneNodePtr.initNew();
            self.orbitModeData[i].verticalTiltNode = self.orbitModeData[i].vehicleNode.createChildNode();
            self.orbitModeData[i].cameraNode = self.orbitModeData[i].verticalTiltNode.createChildNode();
            self.orbitModeData[i].cameraNode.setPosition(Vec3.init(0.0, 0.0, -DEFAULT_ORBIT_DISTANCE));

            self.drivingModeData[i].fov = gCameraDefaultFov;

            if (i == 0) {
                self.orbitModeData[i].fov = gCameraDefaultFov;
            } else {
                self.orbitModeData[i].fov = gCameraDefaultHaulingFov;
            }
        }
    }

    pub fn deinit(self: *Self) void {
        if (self.enabled) {
            self.disable();
        }

        for (0..2) |i| {
            self.orbitModeData[i].vehicleNode.destroyAllChildNodes();
            self.orbitModeData[i].vehicleNode.deinit();

            self.orbitModeData[i].cameraNode = SceneNodePtr.Null;
            self.orbitModeData[i].verticalTiltNode = SceneNodePtr.Null;
            self.orbitModeData[i].vehicleNode = SceneNodePtr.Null;
        }
    }

    //----------------------------------------------------

    pub fn enable(self: *Self) void {
        const mode = if (self.drivingCameraEnabled)
            VehicleCameraMode.Driving
        else
            VehicleCameraMode.Orbit;

        basis.assert(@src(), !self.enabled);

        self.orbitModeData[0].verticalRotation = 0.35;
        self.orbitModeData[1].verticalRotation = 0.35;

        self.vehicleCameraMode = mode;
        self.cameraModeBlendFactor = if (mode == VehicleCameraMode.Driving) 0.0 else 1.0;

        self.enabled = true;
    }

    pub fn disable(self: *Self) void {
        basis.assert(@src(), self.enabled);
        self.enabled = false;
    }

    pub fn toggleMode(self: *Self) void {
        if (self.vehicleCameraMode == VehicleCameraMode.Driving) {
            self.vehicleCameraMode = VehicleCameraMode.Orbit;
        } else {
            self.vehicleCameraMode = VehicleCameraMode.Driving;
        }
    }

    pub fn setHaulingCamera(self: *Self, enabled: bool, blendBetweenModes: bool) void {
        self.haulingEnabled = enabled;

        if (!blendBetweenModes) {
            self.haulingBlendFactor = if (enabled) 1.0 else 0.0;
        }
    }

    pub fn tick(
        self: *Self,
        vehiclePosition: Vec3,
        vehicleOrientation: Quaternion,
        vehicleLinearVelocity: Vec3,
        vehicleAngularVelocity: Vec3,
        orbitModeHorizontalDelta: f32,
        orbitModeVerticalDelta: f32,
    ) void {
        self.usingGamepad = basis.input.getGameInputMode() == basis.input.GameInputMode.Gamepad;

        const invertY = (self.usingGamepad and self.invertYGamepad) or (!self.usingGamepad and self.invertYMouse);
        const verticalDelta = if (invertY) -orbitModeVerticalDelta else orbitModeVerticalDelta;

        // Update the camera mode blend factor.
        if (self.vehicleCameraMode == VehicleCameraMode.Driving) {
            self.cameraModeBlendFactor = std.math.clamp(self.cameraModeBlendFactor - gBlendToDrivingSpeed, 0.0, 1.0);
        } else {
            self.cameraModeBlendFactor = std.math.clamp(self.cameraModeBlendFactor + gBlendToOrbitSpeed, 0.0, 1.0);
        }
        self.cameraModeBlendFactorInterpolator.pushFloat(self.cameraModeBlendFactor);

        // Update the hauling blend factor.
        if (self.haulingEnabled) {
            self.haulingBlendFactor = std.math.clamp(self.haulingBlendFactor + gBlendToHaulingSpeed, 0.0, 1.0);
        } else {
            self.haulingBlendFactor = std.math.clamp(self.haulingBlendFactor - gBlendToNonHaulingSpeed, 0.0, 1.0);
        }
        self.haulingBlendFactorInterpolator.pushFloat(self.haulingBlendFactor);

        self.vehicleWorldMatrix = Mat43.fromOrientationPosition(vehicleOrientation, vehiclePosition);

        {
            var i: usize = 0;
            while (i < 2) : (i += 1) {
                // Check if we are fully in normal or hauling mode, as opposed to blending between them.
                const fullyNormal = (self.haulingBlendFactor == 0.0);
                const fullyHauling = (self.haulingBlendFactor == 1.0);

                // Check if we are fully in driving or orbit camera mode, as opposed to blending between them.
                const fullyDriving = (self.cameraModeBlendFactor == 0.0);
                const fullyOrbit = (self.cameraModeBlendFactor == 1.0);

                // See if we should check camera collisions.
                // (No point in doing normal mode collisions if we are fully in hauling mode and vice versa).
                const checkCameraModeCollisions = (i == 0 and !fullyHauling) or (i == 1 and !fullyNormal);

                self.tickDrivingCamera(
                    &self.drivingModeData[i],
                    vehiclePosition,
                    vehicleOrientation,
                    vehicleLinearVelocity,
                    vehicleAngularVelocity,
                    checkCameraModeCollisions and !fullyOrbit,
                );

                self.tickOrbitCamera(
                    &self.orbitModeData[i],
                    vehiclePosition,
                    vehicleOrientation,
                    vehicleLinearVelocity,
                    vehicleAngularVelocity,
                    orbitModeHorizontalDelta,
                    verticalDelta,
                    checkCameraModeCollisions and !fullyDriving,
                );
            }
        }
    }

    pub fn update(self: *Self, deltaTime: f32) void {
        _ = deltaTime;

        if (self.enabled) {
            const interpolationFactor = self.client.getInterpolationFactor32();

            var pos = Vec3.Zero;
            var ori = Quaternion.Identity;
            var fov: f32 = 0.0;

            if (self.haulingBlendFactor == 0.0) {
                // Fully blended to normal (non-hauling mode).

                self.getBlendedCameraTransform(&pos, &ori, &fov, interpolationFactor, false);
            } else if (self.haulingBlendFactor == 1.0) {
                // Fully blended to hauling mode.

                self.getBlendedCameraTransform(&pos, &ori, &fov, interpolationFactor, true);
            } else {
                // Blending between hauling and non-hauling modes.

                var nonHaulingPos = Vec3.Zero;
                var nonHaulingOri = Quaternion.Identity;
                var nonHaulingFov: f32 = 0.0;
                self.getBlendedCameraTransform(&nonHaulingPos, &nonHaulingOri, &nonHaulingFov, interpolationFactor, false);

                var haulingPos = Vec3.Zero;
                var haulingOri = Quaternion.Identity;
                var haulingFov: f32 = 0.0;
                self.getBlendedCameraTransform(&haulingPos, &haulingOri, &haulingFov, interpolationFactor, true);

                const interpolatedHaulingBlendFactor = self.haulingBlendFactorInterpolator.getInterpolatedFloat(interpolationFactor);
                pos = Vec3.smoothStep(interpolatedHaulingBlendFactor, nonHaulingPos, haulingPos);
                ori = Quaternion.slerp(basis.math.smoothStep(interpolatedHaulingBlendFactor, 0.0, 1.0), nonHaulingOri, haulingOri);
                fov = basis.math.smoothStep(interpolatedHaulingBlendFactor, nonHaulingFov, haulingFov);
            }

            self.cameraPosition = pos;
            self.cameraOrientation = ori;
            self.cameraFov = fov;
        }
    }

    pub fn setParameters(
        self: *Self,
        drivingCameraEnabled: bool,
        drivingModeInitialPosition: Vec3,
        drivingModeLookAtPosition: Vec3,
        orbitModeDistance: f32,
        orbitModeLookAtPosition: Vec3,
        orbitCameraSidewaysOffset: f32,
        drivingModeInitialPositionHauling: Vec3,
        drivingModeLookAtPositionHauling: Vec3,
        orbitModeDistanceHauling: f32,
        orbitModeLookAtPositionHauling: Vec3,
        orbitCameraSidewaysOffsetHauling: f32,
    ) void {
        self.drivingCameraEnabled = drivingCameraEnabled;

        if (self.vehicleCameraMode == VehicleCameraMode.Driving and !self.drivingCameraEnabled) {
            self.vehicleCameraMode = VehicleCameraMode.Orbit;
        }

        // Normal (non-hauling):

        self.drivingModeData[0].wantedLocalPosition = drivingModeInitialPosition;
        self.drivingModeData[0].wantedLocalLookAtPos = drivingModeLookAtPosition;
        self.drivingModeData[0].cameraTargetDistance = self.drivingModeData[0].wantedLocalLookAtPos.sub(self.drivingModeData[0].wantedLocalPosition).length();
        self.drivingModeData[0].firstUpdateAfterSettingParameters = true;

        self.orbitModeData[0].cameraNode.setPosition(Vec3.init(orbitCameraSidewaysOffset, 0.0, -orbitModeDistance));
        self.orbitModeData[0].lookAtPosition = orbitModeLookAtPosition;

        // Hauling:

        self.drivingModeData[1].wantedLocalPosition = drivingModeInitialPositionHauling;
        self.drivingModeData[1].wantedLocalLookAtPos = drivingModeLookAtPositionHauling;
        self.drivingModeData[1].cameraTargetDistance = self.drivingModeData[1].wantedLocalLookAtPos.sub(self.drivingModeData[1].wantedLocalPosition).length();
        self.drivingModeData[1].firstUpdateAfterSettingParameters = true;

        self.orbitModeData[1].cameraNode.setPosition(Vec3.init(orbitCameraSidewaysOffsetHauling, 0.0, -orbitModeDistanceHauling));
        self.orbitModeData[1].lookAtPosition = orbitModeLookAtPositionHauling;
    }

    pub fn switchOrbitSide(self: *Self) void {
        var i: usize = 0;
        while (i < 2) : (i += 1) {
            var pos = self.orbitModeData[i].cameraNode.getPosition();

            if (!basis.math.floatsAlmostEqual(pos.x, 0.0)) {
                pos.x = -pos.x;
                self.orbitModeData[i].cameraNode.setPosition(pos);
            }
        }
    }

    //----------------------------------------------------

    fn tickDrivingCamera(
        self: *Self,
        data: *DrivingModeData,
        vehiclePosition: Vec3,
        vehicleOrientation: Quaternion,
        vehicleLinearVelocity: Vec3,
        vehicleAngularVelocity: Vec3,
        checkCollisions: bool,
    ) void {
        const horizontalVelocity = Vec3.init(vehicleLinearVelocity.x, 0.0, vehicleLinearVelocity.z);
        const horizontalSpeed = horizontalVelocity.length();

        _ = vehicleOrientation;
        _ = vehicleAngularVelocity;

        // We adjust the FOV with the horizontal speed of the vehicle, but to avoid
        // jerking the camera FOV as the speed changes rapidly we maintain a "fov speed"
        // member which smoothly follows the speed changes. The catch-up speed
        // values specify how tightly it follows the actual speed.
        // 1.0 = Follow the actual speed closely, while lower values make changes smoother.
        // We have separate values for wider and narrower FOVs, since it usually
        // should take a while to make the FOV wider while it is a good idea to quickly
        // let it fall back to a narrower value (eg. if the car suddenly stops).

        if (!basis.math.floatsAlmostEqual(horizontalSpeed, data.fovSpeed)) {
            if (horizontalSpeed > data.fovSpeed) {
                const diff = horizontalSpeed - data.fovSpeed;
                data.fovSpeed += gCameraWiderFOVCatchUpSpeed * diff;
            } else if (horizontalSpeed < data.fovSpeed) {
                const diff = data.fovSpeed - horizontalSpeed;
                data.fovSpeed -= gCameraNarrowerFOVCatchUpSpeed * diff;
            }
        }

        var fovAdjustment: f32 = 0.0;
        if (gAdjustFovWithSpeed) {
            // Make the camera FOV larger as the speed increases.

            fovAdjustment = basis.math.smoothStep(basis.math.remapFloat(data.fovSpeed, gCameraMinFovSpeed, gCameraMaxFovSpeed, 0.0, 1.0), 0.0, 1.0);

            const fovFactor = basis.math.remapFloat(data.fovSpeed, gCameraMinFovSpeed, gCameraMaxFovSpeed, 0.0, 1.0);
            data.fov = basis.math.smoothStep(fovFactor, gCameraDefaultFov, gCameraMaxFov);
        } else {
            data.fov = gCameraDefaultFov;
        }

        data.wantedWorldPosition = self.vehicleWorldMatrix.transformPoint(data.wantedLocalPosition);
        data.wantedWorldLookAtPos = self.vehicleWorldMatrix.transformPoint(data.wantedLocalLookAtPos);

        if (gAdjustFovWithSpeed) {
            // As the FOV increases, move the camera closer to the vehicle to compensate.
            const camForward = (data.wantedWorldLookAtPos.sub(data.wantedWorldPosition)).normalized();

            data.wantedWorldPosition = data.wantedWorldPosition.add(
                camForward.multiplyFloat(
                    //data.cameraTargetDistance * 0.95 * fovAdjustment, // 0.95 since we never want to move all the way to the camera target.
                    data.cameraTargetDistance * 0.75 * fovAdjustment,
                ),
            );
        }

        // Don't let the camera Y position go below the vehicle's Y position.
        data.wantedWorldPosition.y = @max(data.wantedWorldPosition.y, vehiclePosition.y);

        if (data.firstUpdateAfterSettingParameters) {
            data.firstUpdateAfterSettingParameters = false;

            data.interpolator.clear();

            data.currentPosition = data.wantedWorldPosition;
            data.currentLookAtPosition = data.wantedWorldLookAtPos;
        } else {
            data.currentPosition = Vec3.lerp(gCameraCatchUpSpeed, data.currentPosition, data.wantedWorldPosition);
            data.currentLookAtPosition = Vec3.lerp(gCameraCatchUpSpeed, data.currentLookAtPosition, data.wantedWorldLookAtPos);
        }

        // Calculate the orientation based on the camera position and camera look at position.

        var currentOrientation: Quaternion = Quaternion.Identity;

        if (!basis.math.vec3sAlmostEqual(data.currentPosition, data.currentLookAtPosition)) {
            var m: Mat43 = undefined;
            m.lookAtSafe(data.currentPosition, data.currentLookAtPosition, basis.math.Vec3.UnitY);
            currentOrientation.fromRotationMatrix(m);
        }

        if (checkCollisions) {
            // Check for camera collisions with the environment and move towards the look-at position if needed.

            var sweepDir = data.currentPosition.sub(data.currentLookAtPosition);
            const originalDistance = sweepDir.normalizeAndReturnPrevLength();

            if (data.lastCollisionDistance >= 0.0 and data.lastCollisionDistance < originalDistance) {
                // We use a simple form of smoothing, using the distance left to move as an error multiplier.
                const distanceError = (originalDistance - data.lastCollisionDistance);
                data.lastCollisionDistance += (gCollisionReturnSpeed * distanceError);
            } else {
                data.lastCollisionDistance = originalDistance;
            }

            if (self.sweepForCollisions(data.currentPosition, data.currentLookAtPosition, sweepDir, originalDistance)) |hit| {
                var distance: f32 = hit.distance;

                if (data.lastCollisionDistance < distance) {
                    distance = data.lastCollisionDistance;
                } else {
                    data.lastCollisionDistance = distance;
                }

                data.currentPosition = data.currentLookAtPosition.add(sweepDir.multiplyFloat(distance));
                //basis.printf("adjusted: {d}\n", .{distance});
            } else {
                data.currentPosition = data.currentLookAtPosition.add(sweepDir.multiplyFloat(data.lastCollisionDistance));
            }
        } else {
            data.lastCollisionDistance = -1.0;
        }

        data.interpolator.pushTransform(data.currentPosition, currentOrientation);

        if (gPrintDrivingCameraVectors) {
            basis.printf("Camera - pos: [{d}, {d}, {d}], lookat: [{d}, {d}, {d}]\n", .{
                data.currentPosition.x,
                data.currentPosition.y,
                data.currentPosition.z,
                data.currentLookAtPosition.x,
                data.currentLookAtPosition.y,
                data.currentLookAtPosition.z,
            });
        }
    }

    fn tickOrbitCamera(
        self: *Self,
        data: *OrbitModeData,
        vehiclePosition: Vec3,
        vehicleOrientation: Quaternion,
        vehicleLinearVelocity: Vec3,
        vehicleAngularVelocity: Vec3,
        orbitModeHorizontalDelta: f32,
        orbitModeVerticalDelta: f32,
        checkCollisions: bool,
    ) void {
        _ = vehicleAngularVelocity;
        _ = vehicleOrientation;

        var orbitModeHorizontalDeltaWithAcceleration = orbitModeHorizontalDelta;
        var orbitModeVerticalDeltaWithAcceleration = orbitModeVerticalDelta;

        if (gOrbitAimAcceleration and self.usingGamepad) {
            self.doAimAcceleration(&orbitModeHorizontalDeltaWithAcceleration, &orbitModeVerticalDeltaWithAcceleration);
        }

        const hSensitivity: f32 = if (self.usingGamepad) gOrbitHGamepadSensitivity else gOrbitHMouseSensitivity;
        const vSensitivity: f32 = if (self.usingGamepad) gOrbitVGamepadSensitivity else gOrbitVMouseSensitivity;

        // Apply the rotations:

        if (self.vehicleCameraMode == VehicleCameraMode.Orbit) {
            if (orbitModeHorizontalDeltaWithAcceleration != 0.0) {
                data.horizontalRotation += orbitModeHorizontalDeltaWithAcceleration * hSensitivity;
                if (data.horizontalRotation < 0.0) data.horizontalRotation += basis.math.TwoPi;
                if (data.horizontalRotation > basis.math.TwoPi) data.horizontalRotation -= basis.math.TwoPi;
            }

            data.verticalRotation = std.math.clamp(data.verticalRotation - orbitModeVerticalDeltaWithAcceleration * vSensitivity, 0.0, 1.0);
        } else {
            // We have fully blended to the driving camera, keep the horizontalRotation aligned with the vehicle orientation
            // so that we get a nice transition back to the orbit camera later.
            if (self.cameraModeBlendFactor == 0.0) {
                const vehicleFormward = self.vehicleWorldMatrix.getZ();
                data.horizontalRotation = std.math.atan2(vehicleFormward.x, vehicleFormward.z);
            }
        }

        // Move the vehicle node along with the vehicle:

        const cameraTarget = vehiclePosition.add(vehicleLinearVelocity.multiplyFloat(gOrbitTargetOffset).add(data.lookAtPosition));

        data.vehicleNode.setPositionInSpace(cameraTarget, basis.math.CoordinateSpace.Parent, true);

        // Rotate the nodes:

        // The up/down value is normalized (0..1). 0 means no rotation while 1 means
        // 90 degrees rotation (looking at the avatar from straight above).

        const lowestAngle = -std.math.degreesToRadians(20.0);
        //const highestAngle = basis.math.Pi / 2.0; // This allows rotating the camera so that it looks straight down.
        const highestAngle = std.math.degreesToRadians(70.0);
        const upDownRotation = basis.math.remapFloat(data.verticalRotation, 0.0, 1.0, lowestAngle, highestAngle);

        var leftRightOrientation: Quaternion = undefined;
        leftRightOrientation.setRotationY(data.horizontalRotation);

        var upDownOrientation: Quaternion = undefined;
        upDownOrientation.setRotationX(upDownRotation);

        data.vehicleNode.setOrientationInSpace(leftRightOrientation, basis.math.CoordinateSpace.Parent, true);
        data.verticalTiltNode.setOrientationInSpace(upDownOrientation, basis.math.CoordinateSpace.Parent, true);

        // Calculate the world space transform of the camera node and push to the interpolator:

        var currentPosition = data.cameraNode.getPositionInSpace(basis.math.CoordinateSpace.World);
        const currentOrientation = data.cameraNode.getOrientationInSpace(basis.math.CoordinateSpace.World);

        if (checkCollisions) {
            // The verticalTiltNode is the node the camera looks at.
            // Check for camera collisions with the environment and move towards the verticalTiltNode if needed.

            const lookAtPos = data.verticalTiltNode.getPositionInSpace(basis.math.CoordinateSpace.World);
            var sweepDir = currentPosition.sub(lookAtPos);
            const originalDistance = sweepDir.normalizeAndReturnPrevLength();

            if (data.lastCollisionDistance >= 0.0 and data.lastCollisionDistance < originalDistance) {
                // We use a simple form of smoothing, using the distance left to move as an error multiplier.
                const distanceError = (originalDistance - data.lastCollisionDistance);
                data.lastCollisionDistance += (gCollisionReturnSpeed * distanceError);
            } else {
                data.lastCollisionDistance = originalDistance;
            }

            if (self.sweepForCollisions(currentPosition, lookAtPos, sweepDir, originalDistance)) |hit| {
                var distance: f32 = hit.distance;

                if (data.lastCollisionDistance < distance) {
                    distance = data.lastCollisionDistance;
                } else {
                    data.lastCollisionDistance = distance;
                }

                currentPosition = lookAtPos.add(sweepDir.multiplyFloat(distance));
                //basis.printf("adjusted: {d}\n", .{distance});
            } else {
                currentPosition = lookAtPos.add(sweepDir.multiplyFloat(data.lastCollisionDistance));
            }
        } else {
            data.lastCollisionDistance = -1.0;
        }

        data.interpolator.pushTransform(currentPosition, currentOrientation);
    }

    fn getBlendedCameraTransform(
        self: *const Self,
        position: *Vec3,
        rotation: *Quaternion,
        fov: *f32,
        interpolationFactor: f32,
        hauling: bool,
    ) void {
        // Blend the camera transforms:

        var drivingPos = Vec3.Zero;
        var drivingOri = Quaternion.Identity;

        var orbitPos = Vec3.Zero;
        var orbitOri = Quaternion.Identity;

        const dataIndex: usize = if (hauling) 1 else 0;

        const camModeBlendFactor = self.cameraModeBlendFactorInterpolator.getInterpolatedFloat(interpolationFactor);

        self.drivingModeData[dataIndex].interpolator.getInterpolatedTransform(interpolationFactor, &drivingPos, &drivingOri);
        self.orbitModeData[dataIndex].interpolator.getInterpolatedTransform(interpolationFactor, &orbitPos, &orbitOri);

        position.* = Vec3.smoothStep(camModeBlendFactor, drivingPos, orbitPos);
        rotation.* = Quaternion.slerp(basis.math.smoothStep(camModeBlendFactor, 0.0, 1.0), drivingOri, orbitOri);

        // Blend the FOVs:

        fov.* = basis.math.smoothStep(camModeBlendFactor, self.drivingModeData[dataIndex].fov, self.orbitModeData[dataIndex].fov);
    }

    fn doAimAcceleration(self: *Self, horizontal: *f32, vertical: *f32) void {
        _ = self;
        _ = horizontal;
        _ = vertical;

        // TODO: Port this over from the C++ version.
    }

    fn sweepForCollisions(self: *const Self, currentPosition: Vec3, currentLookAtPosition: Vec3, sweepDir: Vec3, originalDistance: f32) ?basis.physics.RayCastResult {
        const blockingActors: u32 = basis.physics.physics_actor.PhysicsActorType.RigidBodyStatic.asUint() |
            basis.physics.physics_actor.PhysicsActorType.HeightField.asUint();

        const MAX_HIT_COUNT = 8;
        var hitResults: [MAX_HIT_COUNT]basis.physics.RayCastResult = undefined;

        const hitCount = self.physicsScene.sphereSweepEx(gCollisionSphereRadius, currentLookAtPosition, sweepDir, 100.0, hitResults[0..], blockingActors);

        if (hitCount > 0) {
            // Check if any of the returned hits are valid.
            // A hit is considered valid the camera is inside the AABB of the hit.
            // This allows the camera to move behind tall slim objects like trees and electric poles.

            var validHit: ?basis.physics.RayCastResult = null;

            var i: usize = 0;
            while (i < hitCount) : (i += 1) {
                if (hitResults[i].distance >= originalDistance)
                    continue;

                if (hitResults[i].physicsActorCppPtr == 0)
                    continue;

                // Check if we should ignore this hit.
                const go = hitResults[i].getGameObject();
                if (!go.isNull()) {
                    if (go.getGameTag() & self.ignoreCameraCollisionsTagFlag != 0)
                        continue;
                }

                var actor = hitResults[i].getPhysicsActor();

                var hitObjectBounds = actor.getWorldBounds();

                // We scale the collision AABB a bit to make it more likely we hit it.
                // We seem to get a bit nicer results this way.
                hitObjectBounds.scale(gCollisionAABBScale);

                //hitObjectBounds.debugDraw();

                if (hitObjectBounds.containsVec3(currentPosition)) {
                    validHit = hitResults[i];
                    break;
                }
            }

            return validHit;
        }

        return null;
    }
};
