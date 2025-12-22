// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec2 = basis.math.Vec2;
const Vec3 = basis.math.Vec3;

pub const CharacterControllerPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    pub fn initNull() CharacterControllerPtr {
        return CharacterControllerPtr{
            .cppPtr = 0,
        };
    }

    pub fn setMovementVector(self: *const Self, movementVector: Vec2) void {
        const mv = movementVector.toInterop();
        basis.bindings.api.CharacterController_setMovementVector(self.cppPtr, &mv);
    }

    pub fn getMovementVector(self: *const Self) Vec2 {
        var interop: basis.bindings.InteropVec2 = undefined;
        basis.bindings.api.CharacterController_getMovementVector(self.cppPtr, &interop);
        return Vec2.fromInterop(interop);
    }

    pub fn getLinearVelocity(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.CharacterController_getLinearVelocity(self.cppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.CharacterController_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        if (self.cppPtr != 0) {
            basis.bindings.api.CharacterController_release(self.cppPtr);
        }
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};
