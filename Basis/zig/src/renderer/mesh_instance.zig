// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const MaterialPtr = basis.renderer.MaterialPtr;

const SceneNodePtr = basis.math.SceneNodePtr;

pub const Flags = enum(i32) {
    BlocksNavMesh = 1 << 0,
    LightProbeVisualization = 1 << 1,
    RenderedUsingLightmapGI = 1 << 2, // If set, this mesh uses lightmaps when rendered
    RenderedUsingLightProbeGI = 1 << 3, // If set, this mesh uses light probes when rendered
    AffectsLightmapGI = 1 << 4, // If set, this mesh affects lightmaps, ie. is visible when baking lightmaps
    AffectsLightProbeGI = 1 << 5, // If set, this mesh affects light probes, ie. is visible when baking light probes
    EditorOnlyMesh = 1 << 6, // If set, this mesh is only visible in the editor (eg. waypoints)

    pub fn asInt(self: Flags) i32 {
        return @intFromEnum(self);
    }
};

pub const MeshInstancePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    pub fn setVisible(self: *const Self, visible: bool) void {
        basis.bindings.api.MeshInstance_setVisible(self.cppPtr, visible);
    }

    pub fn isVisible(self: *const Self) bool {
        return basis.bindings.api.MeshInstance_isVisible(self.cppPtr);
    }

    pub fn getMaterial(self: *const Self, subMeshIndex: u32) MaterialPtr {
        const matCppPtr = basis.bindings.api.MeshInstance_getMaterial(self.cppPtr, subMeshIndex);
        return MaterialPtr{ .cppPtr = matCppPtr };
    }

    pub fn setMaterial(self: *const Self, mat: MaterialPtr, subMeshIndex: u32) void {
        basis.bindings.api.MeshInstance_setMaterial(self.cppPtr, mat.cppPtr, subMeshIndex);
    }

    pub fn getFlags(self: *const Self) i32 {
        return basis.bindings.api.MeshInstance_getFlags(self.cppPtr);
    }

    pub fn isFlagSet(self: *const Self, flag: Flags) bool {
        const value = basis.bindings.api.MeshInstance_isFlagSet(self.cppPtr, flag.asInt());
        return if (value == 1) true else false;
    }

    pub fn setFlagValue(self: *const Self, flag: Flags, value: bool) void {
        const intValue: i32 = if (value) 1 else 0;
        basis.bindings.api.MeshInstance_setFlagValue(self.cppPtr, flag.asInt(), intValue);
    }

    pub fn updateLightProbeData(self: *const Self) void {
        basis.bindings.api.MeshInstance_updateLightProbeData(self.cppPtr);
    }

    pub fn isAttached(self: *const Self) bool {
        const parentNodeCppPtr = basis.bindings.api.MeshInstance_getParentSceneNode(self.cppPtr);
        return parentNodeCppPtr != 0;
    }

    pub fn getParentSceneNode(self: *const Self) SceneNodePtr {
        const parentNodeCppPtr = basis.bindings.api.MeshInstance_getParentSceneNode(self.cppPtr);
        return SceneNodePtr{
            .cppPtr = parentNodeCppPtr,
            .ownsMemory = false,
        };
    }

    pub fn setCullDistanceMultiplier(self: *const Self, multiplier: f32) void {
        basis.bindings.api.MeshInstance_setCullDistanceMultiplier(self.cppPtr, multiplier);
    }

    pub fn getCullDistanceMultiplier(self: *const Self) f32 {
        return basis.bindings.api.MeshInstance_getCullDistanceMultiplier(self.cppPtr);
    }
};
