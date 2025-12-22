// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

const SceneNodePtr = basis.math.SceneNodePtr;

pub const CameraPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() CameraPtr {
        return CameraPtr{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    pub fn setPerspective(self: *const Self, fovY: f32, aspectRatio: f32, nearClip: f32, farClip: f32) void {
        basis.bindings.api.Camera_setPerspective(self.cppPtr, fovY, aspectRatio, nearClip, farClip);
    }

    pub fn setOrthographic(self: *const Self, width: f32, height: f32, nearClip: f32, farClip: f32) void {
        basis.bindings.api.Camera_setOrthographic(self.cppPtr, width, height, nearClip, farClip);
    }

    pub fn getWorldPosition(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.Camera_getWorldPosition(self.cppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn getForwardDirection(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.Camera_getForwardDirection(self.cppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn getFovY(self: *const Self) f32 {
        return basis.bindings.api.Camera_getFovY(self.cppPtr);
    }

    pub fn getFovX(self: *const Self) f32 {
        return basis.bindings.api.Camera_getFovX(self.cppPtr);
    }

    pub fn getNearClip(self: *const Self) f32 {
        return basis.bindings.api.Camera_getNearClip(self.cppPtr);
    }

    pub fn getFarClip(self: *const Self) f32 {
        return basis.bindings.api.Camera_getFarClip(self.cppPtr);
    }

    pub fn getPickRay(self: *const Self, screenX: i32, screenY: i32, space: basis.math.CoordinateSpace, rayOrigin: *Vec3, rayDirection: *Vec3) void {
        var interopOrigin: basis.bindings.InteropVec3 = undefined;
        var interopDirection: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.Camera_getPickRay(self.cppPtr, screenX, screenY, @intFromEnum(space), &interopOrigin, &interopDirection);
        rayOrigin.* = Vec3.fromInterop(interopOrigin);
        rayDirection.* = Vec3.fromInterop(interopDirection);
    }

    pub fn worldToScreen(self: *const Self, worldPos: Vec3, x: *f32, y: *f32) bool {
        const interopWorldPos = Vec3.toInterop(worldPos);
        return basis.bindings.api.Camera_worldToScreen(self.cppPtr, &interopWorldPos, x, y);
    }

    pub fn worldToScreenUnbounded(self: *const Self, worldPos: Vec3, x: *f32, y: *f32) void {
        const interopWorldPos = Vec3.toInterop(worldPos);
        basis.bindings.api.Camera_worldToScreenUnbounded(self.cppPtr, &interopWorldPos, x, y);
    }

    pub fn getViewMatrix(self: *const Self) basis.math.Mat43 {
        var interopMat: basis.bindings.InteropMat43 = undefined;
        basis.bindings.api.Camera_getViewMatrix(self.cppPtr, &interopMat);
        return basis.math.Mat43.fromInterop(interopMat);
    }

    pub fn getProjectionMatrix(self: *const Self) basis.math.Mat4 {
        var interopMat: basis.bindings.InteropMat4 = undefined;
        basis.bindings.api.Camera_getProjectionMatrix(self.cppPtr, &interopMat);
        return basis.math.Mat4.fromInterop(interopMat);
    }

    pub fn isAttached(self: *const Self) bool {
        const parentNodeCppPtr = basis.bindings.api.Camera_getParentSceneNode(self.cppPtr);
        return parentNodeCppPtr != 0;
    }

    pub fn getParentSceneNode(self: *const Self) SceneNodePtr {
        const parentNodeCppPtr = basis.bindings.api.Camera_getParentSceneNode(self.cppPtr);
        return SceneNodePtr{
            .cppPtr = parentNodeCppPtr,
            .ownsMemory = false,
        };
    }
};
