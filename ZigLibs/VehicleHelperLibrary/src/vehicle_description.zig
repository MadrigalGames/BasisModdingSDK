// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const vhl = @import("vhl.zig");

const vehicles = basis.physics.vehicles;

const VehicleControllerType = basis.physics.vehicle_controller.VehicleControllerType;
const VehicleControllerDescription = basis.physics.vehicle_controller.VehicleControllerDescription;
const DiffType = basis.physics.vehicle_controller.DiffType;

const JsonResourcePtr = basis.resources.JsonResourcePtr;

const Vec3 = basis.math.Vec3;

pub const VehicleDescription = struct {
    const Self = @This();

    pub const UpdateCallback = basis.delegate.VoidDelegate0();

    const WheelStringList = basis.BoundedArray(basis.String, vehicles.MaxWheelCount);
    const WheelVec3List = basis.BoundedArray(Vec3, vehicles.MaxWheelCount);

    //----------------------------------------------------

    allocator: std.mem.Allocator,
    updateCallbackList: basis.ArrayList(UpdateCallback),
    jsonResource: JsonResourcePtr,

    vehicleControllerType: VehicleControllerType = VehicleControllerType.Type4W,
    vehicleControllerDesc: VehicleControllerDescription = VehicleControllerDescription{},

    autoGearBoxParameters: basis.String,

    wheelRenderMaterials: WheelStringList = WheelStringList{ .len = 0 },
    wheelRenderMeshes: WheelStringList = WheelStringList{ .len = 0 },

    detachedWheelGameObjectTypes: WheelStringList = WheelStringList{ .len = 0 },
    detachedWheelLocalOffsets: WheelVec3List = WheelVec3List{ .len = 0 },

    drivingCameraEnabled: bool = true,

    // Camera parameters when not hauling:
    drivingCameraInitPosition: Vec3 = Vec3.Zero,
    drivingCameraLookAtPosition: Vec3 = Vec3.Zero,
    orbitCameraDistance: f32 = 0.0,
    orbitCameraLookAtPosition: Vec3 = Vec3.Zero,
    orbitCameraSidewaysOffset: f32 = 0.0,

    // Camera parameters when hauling:
    drivingCameraInitPositionHauling: Vec3 = Vec3.Zero,
    drivingCameraLookAtPositionHauling: Vec3 = Vec3.Zero,
    orbitCameraDistanceHauling: f32 = 0.0,
    orbitCameraLookAtPositionHauling: Vec3 = Vec3.Zero,
    orbitCameraSidewaysOffsetHauling: f32 = 0.0,

    //turnRadius: f32 = 10.0,

    topSpeed: f32 = 0.0,

    //----------------------------------------------------

    pub fn init(
        allocator: std.mem.Allocator,
        jsonResource: JsonResourcePtr,
        controllerType: VehicleControllerType,
    ) Self {
        var desc = Self{
            .allocator = allocator,
            .updateCallbackList = basis.ArrayList(UpdateCallback).init(allocator),
            .jsonResource = jsonResource,
            .vehicleControllerType = controllerType,
            .autoGearBoxParameters = basis.String.init(allocator),
        };

        {
            // We init all the elements in the list, even if only some of them actually end
            // up being used. Similarily, all elements are deinited below, and only those that
            // actually allocated memory will free it.
            var i: usize = 0;
            while (i < vehicles.MaxWheelCount) : (i += 1) {
                desc.wheelRenderMaterials.buffer[i] = basis.String.init(allocator);
                desc.wheelRenderMeshes.buffer[i] = basis.String.init(allocator);
                desc.detachedWheelGameObjectTypes.buffer[i] = basis.String.init(allocator);
            }
        }

        desc.jsonResource.addRef();

        return desc;
    }

    pub fn postInit(self: *Self) void {
        basis.resources.resource_manager.registerResourceReloadedCallback(
            self.jsonResource,
            .initMethod(
                self,
                VehicleDescription,
                VehicleDescription.onResourceReloaded,
            ),
        );

        self.loadFromJSON();
    }

    pub fn deinit(self: *Self) void {
        basis.resources.resource_manager.unregisterResourceReloadedCallback(
            self.jsonResource,
            .initMethod(
                self,
                VehicleDescription,
                VehicleDescription.onResourceReloaded,
            ),
        );

        self.autoGearBoxParameters.deinit();

        {
            var i: usize = 0;
            while (i < vehicles.MaxWheelCount) : (i += 1) {
                self.wheelRenderMaterials.buffer[i].deinit();
                self.wheelRenderMeshes.buffer[i].deinit();
                self.detachedWheelGameObjectTypes.buffer[i].deinit();
            }
        }

        self.updateCallbackList.deinit();
        self.jsonResource.release();
    }

    pub fn addUpdateCallback(self: *Self, callback: UpdateCallback) !void {
        try self.updateCallbackList.append(callback);
    }

    pub fn removeUpdateCallback(self: *Self, callback: UpdateCallback) void {
        for (self.updateCallbackList.items, 0..) |cb, i| {
            if (cb.eql(callback)) {
                _ = self.updateCallbackList.swapRemove(i);
                return;
            }
        }
    }

    //----------------------------------------------------

    fn onResourceReloaded(self: *Self) void {
        self.loadFromJSON();

        for (self.updateCallbackList.items) |cb| {
            cb.call();
        }
    }

    fn loadFromJSON(self: *Self) void {
        const jh = basis.json_helper;

        var arena = std.heap.ArenaAllocator.init(self.allocator);
        defer arena.deinit();
        const jsonAllocator = arena.allocator();
        const jsonData = self.jsonResource.getJsonData();

        const jsonValue = std.json.parseFromSliceLeaky(std.json.Value, jsonAllocator, jsonData, .{}) catch |err| {
            basis.fatalErrorWithFormat(@src(), "Error loading vehicle description from JSON data: {s}", .{@errorName(err)});
            unreachable;
        };
        const rootObject = &jsonValue.object;

        self.vehicleControllerDesc.chassisMass = jh.getFloatMember(rootObject, "chassisMass");
        self.vehicleControllerDesc.chassisCenterOfMass = jh.getVec3Member(rootObject, "chassisCenterOfMass");

        // Differential type.

        if (self.vehicleControllerType == VehicleControllerType.Type4W) {
            const diffStr = jh.getStringMember(rootObject, "differentialType");

            if (basis.string.eql(diffStr, "LSFWD")) {
                self.vehicleControllerDesc.differentialType = DiffType.LimitedSlipFrontWD;
            } else if (basis.string.eql(diffStr, "LSRWD")) {
                self.vehicleControllerDesc.differentialType = DiffType.LimitedSlipRearWD;
            } else if (basis.string.eql(diffStr, "O4WD")) {
                self.vehicleControllerDesc.differentialType = DiffType.Open4WD;
            } else if (basis.string.eql(diffStr, "OFWD")) {
                self.vehicleControllerDesc.differentialType = DiffType.OpenFrontWD;
            } else if (basis.string.eql(diffStr, "ORWD")) {
                self.vehicleControllerDesc.differentialType = DiffType.OpenRearWD;
            } else {
                self.vehicleControllerDesc.differentialType = DiffType.LimitedSlip4WD;
            }
        } else {
            self.vehicleControllerDesc.differentialType = DiffType.None;
        }

        // Steering-related.

        if (rootObject.contains("steerRiseRate")) {
            self.vehicleControllerDesc.steerRiseRate = jh.getFloatMember(rootObject, "steerRiseRate");
        } else {
            self.vehicleControllerDesc.steerRiseRate = 2.5;
        }

        if (rootObject.contains("steerFallRate")) {
            self.vehicleControllerDesc.steerFallRate = jh.getFloatMember(rootObject, "steerFallRate");
        } else {
            self.vehicleControllerDesc.steerFallRate = 5.0;
        }

        if (rootObject.contains("steerVsForwardSpeed")) {
            const steerVsForwardSpeedArray = jh.getArrayMember(rootObject, "steerVsForwardSpeed");

            self.vehicleControllerDesc.steerVsForwardSpeed.len = 0;
            for (steerVsForwardSpeedArray.items) |element| {
                self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(@as(f32, @floatCast(element.float)));
            }
        } else {
            // Set some sensible defaults.
            self.vehicleControllerDesc.steerVsForwardSpeed.len = 0;

            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(0.0); // Speed
            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(0.75); // Steering

            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(5.0); // Speed
            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(0.75); // Steering

            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(30.0); // Speed
            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(0.125); // Steering

            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(120.0); // Speed
            self.vehicleControllerDesc.steerVsForwardSpeed.appendAssumeCapacity(0.1); // Steering
        }

        // Torqe vectoring and engine/drive related.

        if (self.vehicleControllerType != VehicleControllerType.TypeNoDrive) {
            if (rootObject.contains("torqueVectoring")) {
                const torqueVectoring = &rootObject.getPtr("torqueVectoring").?.object;
                self.vehicleControllerDesc.torqueVectoring.enabled = true;
                self.vehicleControllerDesc.torqueVectoring.torquePerWheelInAir = jh.getFloatMember(torqueVectoring, "torquePerWheelInAir");
                self.vehicleControllerDesc.torqueVectoring.wheelsOnGroundThreshold = jh.getUint32Member(torqueVectoring, "wheelsOnGroundThreshold");
            } else {
                self.vehicleControllerDesc.torqueVectoring.enabled = false;
            }

            self.vehicleControllerDesc.engineMaxRotationSpeed = jh.getFloatMember(rootObject, "engineMaxRotationSpeed");
            self.vehicleControllerDesc.engineMaxTorque = jh.getFloatMember(rootObject, "engineMaxTorque");

            const gearRatiosArray = jh.getArrayMember(rootObject, "gearRatios");
            basis.assert(@src(), gearRatiosArray.items.len <= vehicles.MaxGearCount);
            self.vehicleControllerDesc.gearRatios.len = 0;
            for (gearRatiosArray.items) |element| {
                self.vehicleControllerDesc.gearRatios.appendAssumeCapacity(@as(f32, @floatCast(element.float)));
            }

            self.autoGearBoxParameters.set(jh.getStringMember(rootObject, "autoGearBoxParameters")) catch unreachable;
        }

        // Wheels.

        if (rootObject.contains("usesSweptWheels")) {
            self.vehicleControllerDesc.usesSweptWheels = jh.getBoolMember(rootObject, "usesSweptWheels");
        } else {
            self.vehicleControllerDesc.usesSweptWheels = false;
        }

        const wheelArray = jh.getArrayMember(rootObject, "wheels");
        basis.assert(@src(), wheelArray.items.len <= vehicles.MaxWheelCount);
        basis.assert(@src(), wheelArray.items.len >= 4);
        basis.assert(@src(), wheelArray.items.len % 2 == 0);

        self.vehicleControllerDesc.wheels.resize(wheelArray.items.len) catch unreachable;
        const wheelSlice = self.vehicleControllerDesc.wheels.slice();

        self.wheelRenderMaterials.resize(wheelArray.items.len) catch unreachable;
        self.wheelRenderMeshes.resize(wheelArray.items.len) catch unreachable;
        self.detachedWheelGameObjectTypes.resize(wheelArray.items.len) catch unreachable;
        self.detachedWheelLocalOffsets.resize(wheelArray.items.len) catch unreachable;

        // Set default detached wheel local offsets:
        for (self.detachedWheelLocalOffsets.slice(), 0..) |_, i| {
            self.detachedWheelLocalOffsets.set(i, Vec3.init(0.0, 1.0, 0.0));
        }

        // If we have a wheel base, we first initialize all wheels to use its values.

        if (rootObject.contains("wheelBase")) {
            const wheelBase = &rootObject.getPtr("wheelBase").?.object;

            if (wheelBase.contains("radius")) {
                for (wheelSlice) |*wheel| wheel.radius = jh.getFloatMember(wheelBase, "radius");
            }

            if (wheelBase.contains("mass")) {
                for (wheelSlice) |*wheel| wheel.mass = jh.getFloatMember(wheelBase, "mass");
            }

            if (wheelBase.contains("width")) {
                for (wheelSlice) |*wheel| wheel.width = jh.getFloatMember(wheelBase, "width");
            }

            if (wheelBase.contains("maxSteerAngle")) {
                for (wheelSlice) |*wheel| wheel.maxSteerAngle = jh.getFloatMember(wheelBase, "maxSteerAngle");
            }

            if (wheelBase.contains("innerWheelMultiplier")) {
                for (wheelSlice) |*wheel| wheel.innerWheelMultiplier = jh.getFloatMember(wheelBase, "innerWheelMultiplier");
            } else {
                for (wheelSlice) |*wheel| wheel.innerWheelMultiplier = 1.0; // Default = 1.0 (no adjustment)
            }

            if (wheelBase.contains("maxBrakeTorque")) {
                for (wheelSlice) |*wheel| wheel.maxBrakeTorque = jh.getFloatMember(wheelBase, "maxBrakeTorque");
            }

            if (wheelBase.contains("maxHandbrakeTorque")) {
                for (wheelSlice) |*wheel| wheel.maxHandbrakeTorque = jh.getFloatMember(wheelBase, "maxHandbrakeTorque");
            }

            if (wheelBase.contains("maxSuspensionCompression")) {
                for (wheelSlice) |*wheel| wheel.maxSuspensionCompression = jh.getFloatMember(wheelBase, "maxSuspensionCompression");
            }

            if (wheelBase.contains("maxSuspensionDroop")) {
                for (wheelSlice) |*wheel| wheel.maxSuspensionDroop = jh.getFloatMember(wheelBase, "maxSuspensionDroop");
            }

            if (wheelBase.contains("springStrength")) {
                for (wheelSlice) |*wheel| wheel.springStrength = jh.getFloatMember(wheelBase, "springStrength");
            }

            if (wheelBase.contains("springDamperRate")) {
                for (wheelSlice) |*wheel| wheel.springDamperRate = jh.getFloatMember(wheelBase, "springDamperRate");
            }

            if (wheelBase.contains("camberAngleAtRest")) {
                for (wheelSlice) |*wheel| wheel.camberAngleAtRest = jh.getFloatMember(wheelBase, "camberAngleAtRest");
            }

            if (wheelBase.contains("camberAngleAtMaxCompression")) {
                for (wheelSlice) |*wheel| wheel.camberAngleAtMaxCompression = jh.getFloatMember(wheelBase, "camberAngleAtMaxCompression");
            }

            if (wheelBase.contains("camberAngleAtMaxDroop")) {
                for (wheelSlice) |*wheel| wheel.camberAngleAtMaxDroop = jh.getFloatMember(wheelBase, "camberAngleAtMaxDroop");
            }

            if (wheelBase.contains("renderMaterial")) {
                for (self.wheelRenderMaterials.slice()) |*str| str.set(jh.getStringMember(wheelBase, "renderMaterial")) catch unreachable;
            }

            if (wheelBase.contains("renderMesh")) {
                for (self.wheelRenderMeshes.slice()) |*str| str.set(jh.getStringMember(wheelBase, "renderMesh")) catch unreachable;
            }

            if (wheelBase.contains("detachedObjectType")) {
                for (self.detachedWheelGameObjectTypes.slice()) |*str| str.set(jh.getStringMember(wheelBase, "detachedObjectType")) catch unreachable;
            }

            if (wheelBase.contains("detachedOffset")) {
                for (self.detachedWheelLocalOffsets.slice()) |*offset| offset.* = jh.getVec3Member(wheelBase, "detachedOffset");
            }
        }

        // Collect data for the individual wheels:

        for (wheelArray.items, 0..) |wheelValue, i| {
            const wheel = &wheelValue.object;

            basis.assert(@src(), wheel.contains("offset"));
            wheelSlice[i].offset = jh.getVec3Member(wheel, "offset");

            if (self.vehicleControllerType == VehicleControllerType.TypeNW) {
                basis.assert(@src(), wheel.contains("driven"));
                wheelSlice[i].driven = jh.getBoolMember(wheel, "driven");
            } else {
                wheelSlice[i].driven = false;
            }

            if (wheel.contains("radius")) {
                wheelSlice[i].radius = jh.getFloatMember(wheel, "radius");
            }

            if (wheel.contains("mass")) {
                wheelSlice[i].mass = jh.getFloatMember(wheel, "mass");
            }

            if (wheel.contains("width")) {
                wheelSlice[i].width = jh.getFloatMember(wheel, "width");
            }

            if (wheel.contains("maxSteerAngle")) {
                wheelSlice[i].maxSteerAngle = jh.getFloatMember(wheel, "maxSteerAngle");
            }

            if (wheel.contains("innerWheelMultiplier")) {
                wheelSlice[i].innerWheelMultiplier = jh.getFloatMember(wheel, "innerWheelMultiplier");
            }

            if (wheel.contains("maxBrakeTorque")) {
                wheelSlice[i].maxBrakeTorque = jh.getFloatMember(wheel, "maxBrakeTorque");
            }

            if (wheel.contains("maxHandbrakeTorque")) {
                wheelSlice[i].maxHandbrakeTorque = jh.getFloatMember(wheel, "maxHandbrakeTorque");
            }

            if (wheel.contains("maxSuspensionCompression")) {
                wheelSlice[i].maxSuspensionCompression = jh.getFloatMember(wheel, "maxSuspensionCompression");
            }

            if (wheel.contains("maxSuspensionDroop")) {
                wheelSlice[i].maxSuspensionDroop = jh.getFloatMember(wheel, "maxSuspensionDroop");
            }

            if (wheel.contains("springStrength")) {
                wheelSlice[i].springStrength = jh.getFloatMember(wheel, "springStrength");
            }

            if (wheel.contains("springDamperRate")) {
                wheelSlice[i].springDamperRate = jh.getFloatMember(wheel, "springDamperRate");
            }

            if (wheel.contains("camberAngleAtRest")) {
                wheelSlice[i].camberAngleAtRest = jh.getFloatMember(wheel, "camberAngleAtRest");
            }

            if (wheel.contains("camberAngleAtMaxCompression")) {
                wheelSlice[i].camberAngleAtMaxCompression = jh.getFloatMember(wheel, "camberAngleAtMaxCompression");
            }

            if (wheel.contains("camberAngleAtMaxDroop")) {
                wheelSlice[i].camberAngleAtMaxDroop = jh.getFloatMember(wheel, "camberAngleAtMaxDroop");
            }

            if (wheel.contains("renderMaterial")) {
                self.wheelRenderMaterials.buffer[i].set(jh.getStringMember(wheel, "renderMaterial")) catch unreachable;
            }

            if (wheel.contains("renderMesh")) {
                self.wheelRenderMeshes.buffer[i].set(jh.getStringMember(wheel, "renderMesh")) catch unreachable;
            }

            if (wheel.contains("detachedObjectType")) {
                self.detachedWheelGameObjectTypes.buffer[i].set(jh.getStringMember(wheel, "detachedObjectType")) catch unreachable;
            }

            if (wheel.contains("detachedOffset")) {
                self.detachedWheelLocalOffsets.buffer[i] = jh.getVec3Member(wheel, "detachedOffset");
            }
        }

        self.drivingCameraEnabled = true;
        if (rootObject.contains("drivingCameraEnabled")) {
            self.drivingCameraEnabled = jh.getBoolMember(rootObject, "drivingCameraEnabled");
        }

        self.drivingCameraInitPosition.setXYZ(0.0, 5.0, -12.0);
        self.drivingCameraLookAtPosition.setXYZ(0.0, 1.3, 0.0);
        self.orbitCameraDistance = 15.0;
        self.orbitCameraLookAtPosition.setXYZ(0.0, 2.0, 0.0);
        self.orbitCameraSidewaysOffset = 0.0;

        if (rootObject.contains("drivingCameraInitPosition")) {
            self.drivingCameraInitPosition = jh.getVec3Member(rootObject, "drivingCameraInitPosition");
        }

        if (rootObject.contains("drivingCameraLookAtPosition")) {
            self.drivingCameraLookAtPosition = jh.getVec3Member(rootObject, "drivingCameraLookAtPosition");
        }

        if (rootObject.contains("orbitCameraDistance")) {
            self.orbitCameraDistance = jh.getFloatMember(rootObject, "orbitCameraDistance");
        }

        if (rootObject.contains("orbitCameraLookAtPosition")) {
            self.orbitCameraLookAtPosition = jh.getVec3Member(rootObject, "orbitCameraLookAtPosition");
        }

        if (rootObject.contains("orbitCameraSidewaysOffset")) {
            self.orbitCameraSidewaysOffset = jh.getFloatMember(rootObject, "orbitCameraSidewaysOffset");
        }

        self.drivingCameraInitPositionHauling = self.drivingCameraInitPosition;
        self.drivingCameraLookAtPositionHauling = self.drivingCameraLookAtPosition;
        self.orbitCameraDistanceHauling = self.orbitCameraDistance;
        self.orbitCameraLookAtPositionHauling = self.orbitCameraLookAtPosition;
        self.orbitCameraSidewaysOffsetHauling = self.orbitCameraSidewaysOffset;

        if (rootObject.contains("drivingCameraInitPositionHauling")) {
            self.drivingCameraInitPositionHauling = jh.getVec3Member(rootObject, "drivingCameraInitPositionHauling");
        }

        if (rootObject.contains("drivingCameraLookAtPositionHauling")) {
            self.drivingCameraLookAtPositionHauling = jh.getVec3Member(rootObject, "drivingCameraLookAtPositionHauling");
        }

        if (rootObject.contains("orbitCameraDistanceHauling")) {
            self.orbitCameraDistanceHauling = jh.getFloatMember(rootObject, "orbitCameraDistanceHauling");
        }

        if (rootObject.contains("orbitCameraLookAtPositionHauling")) {
            self.orbitCameraLookAtPositionHauling = jh.getVec3Member(rootObject, "orbitCameraLookAtPositionHauling");
        }

        if (rootObject.contains("orbitCameraSidewaysOffsetHauling")) {
            self.orbitCameraSidewaysOffsetHauling = jh.getFloatMember(rootObject, "orbitCameraSidewaysOffsetHauling");
        }

        if (rootObject.contains("topSpeed")) {
            self.topSpeed = jh.getFloatMember(rootObject, "topSpeed");
        }
    }
};
