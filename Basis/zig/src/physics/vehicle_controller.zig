// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const vehicles = basis.physics.vehicles;

const Vec3 = basis.math.Vec3;

// Note that the values of these enums match those on the C++ side.

pub const VehicleControllerType = enum(i32) {
    Type4W = 0,
    TypeNW,
    TypeNoDrive,
};

pub const DiffType = enum(i32) {
    None = 0,
    LimitedSlip4WD,
    LimitedSlipFrontWD,
    LimitedSlipRearWD,
    Open4WD,
    OpenFrontWD,
    OpenRearWD,
};

pub const VehicleControllerDescription = struct {
    const Self = @This();

    // Wheel ordering:
    // The first 4 wheels are the front/rear wheels.
    // Index 0: Front left wheel
    // Index 1: Front right wheel
    // Index 2: Rear left wheel
    // Index 3: Rear right wheel
    // Index 4+: Other (eg. middle) wheels
    // Even indices MUST be left side wheels, odd MUST be right side wheels.

    pub const WheelDescription = struct {
        radius: f32 = 0.0,
        mass: f32 = 0.0,
        width: f32 = 0.0,
        maxSteerAngle: f32 = 0.0,
        maxBrakeTorque: f32 = 0.0,
        maxHandbrakeTorque: f32 = 0.0,

        maxSuspensionCompression: f32 = 0.0,
        maxSuspensionDroop: f32 = 0.0,
        springStrength: f32 = 0.0,
        springDamperRate: f32 = 0.0,

        camberAngleAtRest: f32 = 0.0,
        camberAngleAtMaxCompression: f32 = 0.0,
        camberAngleAtMaxDroop: f32 = 0.0,

        offset: basis.math.Vec3 = basis.math.Vec3.Zero,
        driven: bool = false, // Used only by NW controllers.

        // Used only by NW controllers.
        // Used to approximate Ackermann steering.
        innerWheelMultiplier: f32 = 1.0,
    };

    pub const TorqueVectoringParameters = struct {
        enabled: bool = false,

        // How much torque to deliver to wheels that are not touching the ground.
        torquePerWheelInAir: f32 = 0.0,

        // How many wheels need to be touching the ground for the torque vectoring to be enabled.
        wheelsOnGroundThreshold: u32 = 0,
    };

    pub const WheelDescriptionList = basis.BoundedArray(WheelDescription, vehicles.MaxWheelCount);
    pub const GearRatioList = basis.BoundedArray(f32, vehicles.MaxGearCount);

    pub const SteerVsForwardSpeedTableSize = 2 * 8;
    pub const SteerVsForwardSpeedTable = basis.BoundedArray(f32, SteerVsForwardSpeedTableSize);

    //----------------------------------------------------

    chassisRigidBody: ?basis.physics.PhysicsActorPtr = null,
    chassisMass: f32 = 0.0,
    chassisCenterOfMass: basis.math.Vec3 = basis.math.Vec3.Zero,

    wheels: WheelDescriptionList = WheelDescriptionList{ .len = 0 },

    engineMaxRotationSpeed: f32 = 0.0, // rad/s
    engineMaxTorque: f32 = 0.0,

    differentialType: DiffType = DiffType.None,

    torqueVectoring: TorqueVectoringParameters = .{
        .enabled = false,
        .torquePerWheelInAir = 0.0,
        .wheelsOnGroundThreshold = 0,
    },

    gearRatios: GearRatioList = GearRatioList{ .len = 0 }, // Including N & R.
    gearSwitchTime: f32 = 0.0,
    autoGearBox: bool = false,

    steerRiseRate: f32 = 0.0,
    steerFallRate: f32 = 0.0,
    steerVsForwardSpeed: SteerVsForwardSpeedTable = SteerVsForwardSpeedTable{ .len = 0 },

    // If true, the vehicle must use VehicleWheelSwept as the material for the wheels.
    // If false, uses raycast wheels, and must use VehicleWheel as the material for the wheels.
    usesSweptWheels: bool = false,
};

pub const VehicleControllerPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    controllerType: VehicleControllerType,

    pub fn initNull() VehicleControllerPtr {
        return VehicleControllerPtr{
            .cppPtr = 0,
            .controllerType = VehicleControllerType.Type4W,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    pub fn reinit(self: *Self, desc: VehicleControllerDescription) void {
        const interopDesc = basis.bindings.InteropVehCtrlDesc.initFromDesc(desc);
        basis.bindings.api.VehicleController_reinit(self.cppPtr, &interopDesc);
    }

    pub fn setInputData(self: *Self, inputData: vehicles.VehicleInputData) void {
        const interopData = basis.bindings.InteropVehInputData{
            .acceleration = inputData.acceleration,
            .brake = inputData.brake,
            .steering = inputData.steering,
            .handbrake = inputData.handbrake,
        };

        basis.bindings.api.VehicleController_setInputData(self.cppPtr, &interopData);
    }

    pub fn getInputData(self: *const Self) vehicles.VehicleInputData {
        var interopData: basis.bindings.InteropVehInputData = undefined;
        basis.bindings.api.VehicleController_getInputData(self.cppPtr, &interopData);

        return vehicles.VehicleInputData{
            .acceleration = interopData.acceleration,
            .brake = interopData.brake,
            .steering = interopData.steering,
            .handbrake = interopData.handbrake,
        };
    }

    pub fn startGearChange(self: *Self, targetGear: vehicles.VehicleGear) void {
        basis.bindings.api.VehicleController_startGearChange(self.cppPtr, @intFromEnum(targetGear));
    }

    pub fn forceGearChange(self: *Self, targetGear: vehicles.VehicleGear) void {
        basis.bindings.api.VehicleController_forceGearChange(self.cppPtr, @intFromEnum(targetGear));
    }

    pub fn freezeInputData(self: *Self, forceBrakes: bool) void {
        basis.bindings.api.VehicleController_freezeInputData(self.cppPtr, if (forceBrakes) 1 else 0);
    }

    pub fn unfreezeInputData(self: *Self) void {
        basis.bindings.api.VehicleController_unfreezeInputData(self.cppPtr);
    }

    pub fn getFastestWheelRotationSpeed(self: *const Self) f32 {
        return basis.bindings.api.VehicleController_getFastestWheelRotationSpeed(self.cppPtr);
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.VehicleController_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        if (self.cppPtr != 0) {
            basis.bindings.api.VehicleController_release(self.cppPtr);
        }
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }

    pub fn getWheelCount(self: *const Self) usize {
        return @intCast(basis.bindings.api.VehicleController_getWheelCount(self.cppPtr));
    }

    pub fn getStateInfo(self: *const Self) vehicles.VehicleStateInfo {
        var interopData: basis.bindings.InteropVehStateInfo = undefined;
        basis.bindings.api.VehicleController_getStateInfo(self.cppPtr, &interopData);
        return vehicles.VehicleStateInfo{
            .engineRotationSpeed = interopData.engineRotationSpeed,
            .currentGear = @as(vehicles.VehicleGear, @enumFromInt(interopData.currentGear)),
            .currentSpeedForward = interopData.currentSpeedForward,
            .inAir = interopData.inAir,
            .hasStickyTires = interopData.hasStickyTires,
        };
    }

    pub fn getWheelStateInfo(self: *const Self, wheelIndex: usize) vehicles.VehicleWheelStateInfo {
        var interopData: basis.bindings.InteropVehWheelStateInfo = undefined;
        basis.bindings.api.VehicleController_getWheelStateInfo(self.cppPtr, @as(u32, @intCast(wheelIndex)), &interopData);
        return vehicles.VehicleWheelStateInfo{
            .localTransform = basis.physics.PhysicsTransform{
                .position = basis.math.Vec3.fromInterop(interopData.localPos),
                .orientation = basis.math.Quaternion.fromInterop(interopData.localOri),
            },
            .contactPoint = basis.math.Vec3.fromInterop(interopData.contactPoint),
            .rotationSpeed = interopData.rotationSpeed,
            .rotationAngle = interopData.rotationAngle,
            .steeringAngle = interopData.steeringAngle,
            .inAir = interopData.inAir,
            .longitudinalSlip = interopData.longitudinalSlip,
            .lateralSlip = interopData.lateralSlip,
            .tireFriction = interopData.tireFriction,
            .suspensionJounce = interopData.suspensionJounce,
            .suspensionSpringForce = interopData.suspensionSpringForce,
            .surfaceMaterialCppPtr = interopData.surfaceMaterialCppPtr,
            .stickyTire = interopData.stickyTire,
        };
    }
};
