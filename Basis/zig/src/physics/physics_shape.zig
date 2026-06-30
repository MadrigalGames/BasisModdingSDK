// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

pub const ShapeType = enum(i32) {
    Box = 0,
    Sphere,
    Capsule,
    Cylinder, // Cylinder with central axis align with the Y axis.
    CylinderX, // Cylinder with central axis align with the X axis.
    CylinderZ, // Cylinder with central axis align with the Z axis.
    Plane,
    ConvexHull,
    TriMesh,
};

pub const PhysicsShapePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() PhysicsShapePtr {
        return PhysicsShapePtr{
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.PhysicsShape_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        if (self.cppPtr != 0) {
            basis.bindings.api.PhysicsShape_release(self.cppPtr);
        }
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};
