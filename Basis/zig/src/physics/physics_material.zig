// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

// Note! Keep in sync with the C++ side.
pub const PhysicsMaterialType = enum(i32) {
    Object = 0,
    Environment,
    Trigger,
    VehicleWheel,
    VehicleWheelSwept,
    VehicleChassis,
    Character,
    Ghost,

    // These groups behave like Object, but they ignore collisions between objects within the same group.
    ObjectIgnoreInternalCollisions1,
    ObjectIgnoreInternalCollisions2,
};

pub const PhysicsMaterialPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() PhysicsMaterialPtr {
        return PhysicsMaterialPtr{
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn createMaterial(
        physicsEnginePtr: basis.CppPtr,
        materialType: PhysicsMaterialType,
        staticFriction: f32,
        dynamicFriction: f32,
        restitution: f32,
        drivable: bool,
        walkable: bool,
    ) PhysicsMaterialPtr {
        return PhysicsMaterialPtr{
            .cppPtr = basis.bindings.api.PhysicsMaterial_createMaterial(
                physicsEnginePtr,
                @intFromEnum(materialType),
                staticFriction,
                dynamicFriction,
                restitution,
                drivable,
                walkable,
            ),
        };
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.PhysicsMaterial_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        if (self.cppPtr != 0) {
            basis.bindings.api.PhysicsMaterial_release(self.cppPtr);
        }
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }

    pub fn getBasePhysicsMaterialName(self: *const Self) basis.physics.physics_engine.BasePhysicsMaterialName {
        const i = basis.bindings.api.PhysicsMaterial_getBasePhysicsMaterialName(self.cppPtr);
        return @enumFromInt(i);
    }
};
