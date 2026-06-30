// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

pub const PhysicsTriMeshPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() PhysicsTriMeshPtr {
        return PhysicsTriMeshPtr{
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
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

    //----------------------------------------------------

    pub fn getTriangleCount(self: *const Self) u32 {
        return basis.bindings.api.PhysicsTriMesh_getTriangleCount(self.cppPtr);
    }

    pub fn getTriangleVertices(self: *const Self, triangle: u32, p0: *Vec3, p1: *Vec3, p2: *Vec3) void {
        var _p0: basis.bindings.InteropVec3 = undefined;
        var _p1: basis.bindings.InteropVec3 = undefined;
        var _p2: basis.bindings.InteropVec3 = undefined;

        basis.bindings.api.PhysicsTriMesh_getTriangleVertices(self.cppPtr, triangle, &_p0, &_p1, &_p2);

        p0.* = Vec3.fromInterop(_p0);
        p1.* = Vec3.fromInterop(_p1);
        p2.* = Vec3.fromInterop(_p2);
    }

    // Square distance between the point and the mesh, or 0.0 if the point is inside the object,
    // or -1.0 if an error occurred (geometry type is not supported, or invalid pose).
    pub fn pointDistance(self: *const Self, point: Vec3, meshTransform: basis.physics.PhysicsTransform, closestPoint: ?*Vec3, closestIndex: ?*u32) f32 {
        const p = Vec3.toInterop(point);
        const tp = Vec3.toInterop(meshTransform.position);
        const to = basis.math.Quaternion.toInterop(meshTransform.orientation);

        var _closestPoint: basis.bindings.InteropVec3 = undefined;
        const closestPointPtr: ?*basis.bindings.InteropVec3 = if (closestPoint != null) &_closestPoint else null;

        const distanceSquared = basis.bindings.api.PhysicsTriMesh_pointDistance(self.cppPtr, &p, &tp, &to, closestPointPtr, closestIndex);

        if (closestPoint) |ptr| {
            ptr.* = Vec3.fromInterop(_closestPoint);
        }

        return distanceSquared;
    }
};
