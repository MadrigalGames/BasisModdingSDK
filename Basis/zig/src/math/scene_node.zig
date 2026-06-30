// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;
const Mat43 = basis.math.Mat43;
const MeshInstancePtr = basis.renderer.MeshInstancePtr;
const CameraPtr = basis.renderer.CameraPtr;

pub const SceneNodePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    ownsMemory: bool,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .ownsMemory = false,
        };
    }

    pub fn initNew() Self {
        return Self{
            .cppPtr = basis.bindings.api.SceneNode_newNode(),
            .ownsMemory = true,
        };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{
            .cppPtr = cppPtr,
            .ownsMemory = false,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.ownsMemory) {
            basis.bindings.api.SceneNode_deleteNode(self.cppPtr);
        }

        self.cppPtr = 0;
        self.ownsMemory = false;
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn createChildNode(self: *const Self) SceneNodePtr {
        return SceneNodePtr{
            .cppPtr = basis.bindings.api.SceneNode_createChildNode(self.cppPtr),
            .ownsMemory = false,
        };
    }

    pub fn destroyChildNode(self: *const Self, child: SceneNodePtr) void {
        basis.bindings.api.SceneNode_destroyChildNode(self.cppPtr, child.cppPtr);
    }

    pub fn detachAll(self: *const Self) void {
        basis.bindings.api.SceneNode_detachAll(self.cppPtr);
    }

    pub fn destroyAllChildNodes(self: *const Self) void {
        basis.bindings.api.SceneNode_destroyAllChildNodes(self.cppPtr);
    }

    pub fn setPosition(self: *const Self, position: Vec3) void {
        self.setPositionInSpace(position, basis.math.CoordinateSpace.Parent, false);
    }

    pub fn setPositionInSpace(self: *const Self, position: Vec3, space: basis.math.CoordinateSpace, immediateUpdate: bool) void {
        const p = position.toInterop();
        basis.bindings.api.SceneNode_setPosition(self.cppPtr, &p, @intFromEnum(space), immediateUpdate);
    }

    pub fn getPosition(self: *const Self) Vec3 {
        return self.getPositionInSpace(basis.math.CoordinateSpace.Parent);
    }

    pub fn getPositionInSpace(self: *const Self, space: basis.math.CoordinateSpace) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.SceneNode_getPosition(self.cppPtr, @intFromEnum(space), &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn setOrientation(self: *const Self, orientation: Quaternion) void {
        self.setOrientationInSpace(orientation, basis.math.CoordinateSpace.Parent, false);
    }

    pub fn setOrientationInSpace(self: *const Self, orientation: Quaternion, space: basis.math.CoordinateSpace, immediateUpdate: bool) void {
        const o = orientation.toInterop();
        basis.bindings.api.SceneNode_setOrientation(self.cppPtr, &o, @intFromEnum(space), immediateUpdate);
    }

    pub fn getOrientation(self: *const Self) Quaternion {
        return self.getOrientationInSpace(basis.math.CoordinateSpace.Parent);
    }

    pub fn getOrientationInSpace(self: *const Self, space: basis.math.CoordinateSpace) Quaternion {
        var interop: basis.bindings.InteropQuaternion = undefined;
        basis.bindings.api.SceneNode_getOrientation(self.cppPtr, @intFromEnum(space), &interop);
        return Quaternion.fromInterop(interop);
    }

    pub fn setScale(self: *const Self, scale: Vec3, immediateUpdate: bool) void {
        const s = scale.toInterop();
        basis.bindings.api.SceneNode_setScale(self.cppPtr, &s, immediateUpdate);
    }

    pub fn getScale(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.SceneNode_getScale(self.cppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn translate(self: *const Self, translation: Vec3) void {
        self.translateInSpace(translation, basis.math.CoordinateSpace.Local, false);
    }

    pub fn translateInSpace(self: *const Self, translation: Vec3, space: basis.math.CoordinateSpace, immediateUpdate: bool) void {
        const t = translation.toInterop();
        basis.bindings.api.SceneNode_translate(self.cppPtr, &t, @intFromEnum(space), immediateUpdate);
    }

    pub fn yaw(self: *const Self, angle: f32) void {
        self.yawInSpace(angle, basis.math.CoordinateSpace.Local, false);
    }

    pub fn yawInSpace(self: *const Self, angle: f32, space: basis.math.CoordinateSpace, immediateUpdate: bool) void {
        basis.bindings.api.SceneNode_yaw(self.cppPtr, angle, @intFromEnum(space), immediateUpdate);
    }

    pub fn pitch(self: *const Self, angle: f32) void {
        self.pitchInSpace(angle, basis.math.CoordinateSpace.Local, false);
    }

    pub fn pitchInSpace(self: *const Self, angle: f32, space: basis.math.CoordinateSpace, immediateUpdate: bool) void {
        basis.bindings.api.SceneNode_pitch(self.cppPtr, angle, @intFromEnum(space), immediateUpdate);
    }

    pub fn roll(self: *const Self, angle: f32) void {
        self.rollInSpace(angle, basis.math.CoordinateSpace.Local, false);
    }

    pub fn rollInSpace(self: *const Self, angle: f32, space: basis.math.CoordinateSpace, immediateUpdate: bool) void {
        basis.bindings.api.SceneNode_roll(self.cppPtr, angle, @intFromEnum(space), immediateUpdate);
    }

    pub fn lookAtSceneNode(self: *const Self, sceneNode: SceneNodePtr, immediateUpdate: bool) void {
        basis.bindings.api.SceneNode_lookAtSceneNode(self.cppPtr, sceneNode.cppPtr, immediateUpdate);
    }

    pub fn attachMeshInstance(self: *const Self, meshInstance: MeshInstancePtr) void {
        basis.bindings.api.SceneNode_attachMeshInstance(self.cppPtr, meshInstance.cppPtr);
    }

    pub fn detachMeshInstance(self: *const Self, meshInstance: MeshInstancePtr) void {
        basis.bindings.api.SceneNode_detachMeshInstance(self.cppPtr, meshInstance.cppPtr);
    }

    pub fn isMeshInstanceAttached(self: *const Self, meshInstance: MeshInstancePtr) bool {
        return basis.bindings.api.SceneNode_isMeshInstanceAttached(self.cppPtr, meshInstance.cppPtr) == 1;
    }

    pub fn attachCamera(self: *const Self, camera: CameraPtr) void {
        basis.bindings.api.SceneNode_attachCamera(self.cppPtr, camera.cppPtr);
    }

    pub fn detachCamera(self: *const Self, camera: CameraPtr) void {
        basis.bindings.api.SceneNode_detachCamera(self.cppPtr, camera.cppPtr);
    }

    pub fn isCameraAttached(self: *const Self, camera: CameraPtr) bool {
        return basis.bindings.api.SceneNode_isCameraAttached(self.cppPtr, camera.cppPtr) == 1;
    }

    pub fn getLocalToParentTransform(self: *const Self) Mat43 {
        var interopMat: basis.bindings.InteropMat43 = undefined;
        basis.bindings.api.SceneNode_getLocalToParentTransform(self.cppPtr, &interopMat);
        return basis.math.Mat43.fromInterop(interopMat);
    }

    pub fn getLocalToWorldTransform(self: *const Self) Mat43 {
        var interopMat: basis.bindings.InteropMat43 = undefined;
        basis.bindings.api.SceneNode_getLocalToWorldTransform(self.cppPtr, &interopMat);
        return basis.math.Mat43.fromInterop(interopMat);
    }

    pub fn getLocalToAncestorTransform(self: *const Self, ancestor: Self) Mat43 {
        var interopMat: basis.bindings.InteropMat43 = undefined;
        basis.bindings.api.SceneNode_getLocalToAncestorTransform(self.cppPtr, ancestor.cppPtr, &interopMat);
        return basis.math.Mat43.fromInterop(interopMat);
    }
};
