// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

const PhysicsMaterialPtr = basis.physics.PhysicsMaterialPtr;

pub const MaxWheelCount = 8;
pub const MaxGearCount = @intFromEnum(VehicleGear.GearMaxCount);

// Note that the values of this enum match the values of the gears enum in physx::PxVehicleGearsData.
pub const VehicleGear = enum(i32) {
    GearR = 0,
    GearN,
    Gear1,
    Gear2,
    Gear3,
    Gear4,
    Gear5,
    Gear6,
    Gear7,
    Gear8,
    Gear9,
    Gear10,

    GearMaxCount,

    pub fn asInt(self: VehicleGear) i32 {
        return @intFromEnum(self);
    }

    pub fn asString(self: VehicleGear) []const u8 {
        switch (self.asInt()) {
            0 => return "R",
            1 => return "N",
            2 => return "1",
            3 => return "2",
            4 => return "3",
            5 => return "4",
            6 => return "5",
            7 => return "6",
            8 => return "7",
            9 => return "8",
            10 => return "9",
            else => return "10",
        }
    }
};

pub const VehicleInputData = struct {
    acceleration: f32 = 0.0, // Range: [0, 1]. 1 = Gas pedal fully pressed, 0 = pedal resting.
    brake: f32 = 0.0, // Range: [0, 1]. 1 = Brake pedal fully pressed, 0 = pedal resting.
    steering: f32 = 0.0, // Range: [-1, 1]. 1 = Steer to the right, -1 = steer to the left.
    handbrake: f32 = 0.0, // Range: [0, 1]. 1 = Handbrake fully engaged, 0 = handbrake fully disengaged.
};

pub const VehicleStateInfo = struct {
    engineRotationSpeed: f32 = 0.0, // rad/s
    currentGear: VehicleGear = .GearN,
    currentSpeedForward: f32 = 0.0, // m/s
    inAir: bool = false,
    hasStickyTires: bool = false,
};

pub const VehicleWheelStateInfo = struct {
    localTransform: basis.physics.PhysicsTransform,
    contactPoint: basis.math.Vec3,
    rotationSpeed: f32, // rad/s
    rotationAngle: f32,
    steeringAngle: f32,
    inAir: bool,
    longitudinalSlip: f32,
    lateralSlip: f32,
    tireFriction: f32,
    suspensionJounce: f32,
    suspensionSpringForce: f32,
    surfaceMaterialCppPtr: basis.CppPtr,
    stickyTire: bool,

    pub fn getMaterial(self: *const VehicleWheelStateInfo) PhysicsMaterialPtr {
        return PhysicsMaterialPtr{ .cppPtr = self.surfaceMaterialCppPtr };
    }
};
