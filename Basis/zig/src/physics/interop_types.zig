// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const vehicles = basis.physics.vehicles;

const InteropVec3 = basis.bindings.InteropVec3;
const InteropQuaternion = basis.bindings.InteropQuaternion;

const VehicleControllerDescription = basis.physics.vehicle_controller.VehicleControllerDescription;

pub const InteropWheelDesc = extern struct {
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
    offset: InteropVec3 = undefined,
    driven: bool = false,
    innerWheelMultiplier: f32 = 1.0,
};

pub const InteropVehCtrlDesc = extern struct {
    chassisRigidBodyIntPtr: basis.CppPtr = 0,
    chassisMass: f32 = 0.0,
    chassisCenterOfMass: InteropVec3 = undefined,
    wheels: [vehicles.MaxWheelCount]InteropWheelDesc = undefined,
    wheelCount: u32 = 0,
    engineMaxRotationSpeed: f32 = 0.0,
    engineMaxTorque: f32 = 0.0,
    differentialType: i32 = 0,
    torqueVectoringEnabled: bool = false,
    torquePerWheelInAir: f32 = 0.0,
    wheelsOnGroundThreshold: u32 = 0.0,
    gearRatios: [vehicles.MaxGearCount]f32 = undefined,
    gearCount: u32 = 0,
    gearSwitchTime: f32 = 0.0,
    autoGearBox: bool = false,
    steerRiseRate: f32 = 0.0,
    steerFallRate: f32 = 0.0,
    steerVsForwardSpeed: [VehicleControllerDescription.SteerVsForwardSpeedTableSize]f32 = undefined,
    steerVsForwardSpeedCount: u32 = 0,
    usesSweptWheels: bool = false,

    //----------------------------------------------------

    pub fn initFromDesc(desc: VehicleControllerDescription) basis.bindings.InteropVehCtrlDesc {
        var interopDesc = basis.bindings.InteropVehCtrlDesc{};

        if (desc.chassisRigidBody) |rb| {
            interopDesc.chassisRigidBodyIntPtr = rb.cppPtr;
        } else {
            interopDesc.chassisRigidBodyIntPtr = 0;
        }

        interopDesc.chassisMass = desc.chassisMass;
        interopDesc.chassisCenterOfMass = desc.chassisCenterOfMass.toInterop();

        interopDesc.wheelCount = @as(u32, @intCast(desc.wheels.len));
        for (desc.wheels.slice(), 0..) |wheel, i| {
            interopDesc.wheels[i].radius = wheel.radius;
            interopDesc.wheels[i].mass = wheel.mass;
            interopDesc.wheels[i].width = wheel.width;
            interopDesc.wheels[i].maxSteerAngle = wheel.maxSteerAngle;
            interopDesc.wheels[i].maxBrakeTorque = wheel.maxBrakeTorque;
            interopDesc.wheels[i].maxHandbrakeTorque = wheel.maxHandbrakeTorque;
            interopDesc.wheels[i].maxSuspensionCompression = wheel.maxSuspensionCompression;
            interopDesc.wheels[i].maxSuspensionDroop = wheel.maxSuspensionDroop;
            interopDesc.wheels[i].springStrength = wheel.springStrength;
            interopDesc.wheels[i].springDamperRate = wheel.springDamperRate;
            interopDesc.wheels[i].camberAngleAtRest = wheel.camberAngleAtRest;
            interopDesc.wheels[i].camberAngleAtMaxCompression = wheel.camberAngleAtMaxCompression;
            interopDesc.wheels[i].camberAngleAtMaxDroop = wheel.camberAngleAtMaxDroop;
            interopDesc.wheels[i].offset = wheel.offset.toInterop();
            interopDesc.wheels[i].driven = wheel.driven;
            interopDesc.wheels[i].innerWheelMultiplier = wheel.innerWheelMultiplier;
        }

        interopDesc.engineMaxRotationSpeed = desc.engineMaxRotationSpeed;
        interopDesc.engineMaxTorque = desc.engineMaxTorque;
        interopDesc.differentialType = @intFromEnum(desc.differentialType);
        interopDesc.torqueVectoringEnabled = desc.torqueVectoring.enabled;
        interopDesc.torquePerWheelInAir = desc.torqueVectoring.torquePerWheelInAir;
        interopDesc.wheelsOnGroundThreshold = desc.torqueVectoring.wheelsOnGroundThreshold;

        interopDesc.gearCount = @as(u32, @intCast(desc.gearRatios.len));
        for (desc.gearRatios.slice(), 0..) |gearRatio, i| {
            interopDesc.gearRatios[i] = gearRatio;
        }

        interopDesc.gearSwitchTime = desc.gearSwitchTime;
        interopDesc.autoGearBox = desc.autoGearBox;

        interopDesc.steerRiseRate = desc.steerRiseRate;
        interopDesc.steerFallRate = desc.steerFallRate;

        interopDesc.steerVsForwardSpeedCount = @as(u32, @intCast(desc.steerVsForwardSpeed.len));
        for (desc.steerVsForwardSpeed.slice(), 0..) |value, i| {
            interopDesc.steerVsForwardSpeed[i] = value;
        }

        interopDesc.usesSweptWheels = desc.usesSweptWheels;

        return interopDesc;
    }
};

pub const InteropVehInputData = extern struct {
    acceleration: f32,
    brake: f32,
    steering: f32,
    handbrake: f32,
};

pub const InteropVehStateInfo = extern struct {
    engineRotationSpeed: f32 = 0.0,
    currentGear: i32 = 0,
    currentSpeedForward: f32 = 0.0,
    inAir: bool = false,
    hasStickyTires: bool = false,
};

pub const InteropVehWheelStateInfo = extern struct {
    localPos: InteropVec3 = undefined,
    localOri: InteropQuaternion = undefined,
    contactPoint: InteropVec3 = undefined,
    rotationSpeed: f32 = 0.0,
    rotationAngle: f32 = 0.0,
    steeringAngle: f32 = 0.0,
    inAir: bool = false,
    longitudinalSlip: f32 = 0.0,
    lateralSlip: f32 = 0.0,
    tireFriction: f32 = 0.0,
    suspensionJounce: f32 = 0.0,
    suspensionSpringForce: f32 = 0.0,
    surfaceMaterialCppPtr: basis.CppPtr = 0,
    stickyTire: bool = false,
};

pub const InteropCollisionPoint = extern struct {
    position: InteropVec3 = undefined,
    normal: InteropVec3 = undefined,
    impulse: InteropVec3 = undefined,
    force: f32 = 0.0,
    material0: basis.CppPtr = 0,
    material1: basis.CppPtr = 0,
};

const MaxCollisionPointCount = basis.physics.CollisionData.MaxCollisionPointCount;

pub const InteropCollisionData = extern struct {
    shape0: basis.CppPtr = 0,
    shape1: basis.CppPtr = 0,
    collisionPoints: [MaxCollisionPointCount]InteropCollisionPoint = undefined,
    collisionPointCount: u32 = 0,
};
