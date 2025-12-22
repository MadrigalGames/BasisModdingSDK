// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const MeshPtr = basis.renderer.MeshPtr;
const MeshInstancePtr = basis.renderer.MeshInstancePtr;
const MaterialPtr = basis.renderer.MaterialPtr;
const CameraPtr = basis.renderer.CameraPtr;
const RenderablePtr = basis.renderer.RenderablePtr;
const TireTrackRendererPtr = basis.renderer.TireTrackRendererPtr;

const SceneNodePtr = basis.math.SceneNodePtr;

const Vec3 = basis.math.Vec3;

//----------------------------------------------------

pub const RayCastHitGroup = enum(u32) {
    None = 0,
    Mesh = (1 << 0),
    EditorIcon = (1 << 1),
    Terrain = (1 << 2),
    Decal = (1 << 3),
    LightProbe = (1 << 4),

    // Having this here causes "error: dependency loop detected". Maybe move outside the enum?
    //All = (asInt(RayCastHitGroup.Mesh) | asInt(RayCastHitGroup.EditorIcon) | asInt(RayCastHitGroup.Terrain) | asInt(RayCastHitGroup.Decal) | asInt(RayCastHitGroup.LightProbe)),

    pub fn asInt(self: RayCastHitGroup) u32 {
        return @intFromEnum(self);
    }
};

//----------------------------------------------------

pub const RayCastResult = struct {
    hitPoint: Vec3,
    hitPointNormal: Vec3,
    hitObject: basis.CppPtr,

    pub fn initZero() RayCastResult {
        return RayCastResult{
            .hitPoint = Vec3.Zero,
            .hitPointNormal = Vec3.Zero,
            .hitObject = 0,
        };
    }

    pub fn getHitRenderable(self: RayCastResult) RenderablePtr {
        return RenderablePtr{
            .cppPtr = self.hitObject,
        };
    }

    pub fn toInterop(self: RayCastResult) basis.bindings.RendererInteropRayCastResult {
        return basis.bindings.RendererInteropRayCastResult{
            .hitPoint = self.hitPoint.toInterop(),
            .hitPointNormal = self.hitPointNormal.toInterop(),
            .hitObject = self.hitObject,
        };
    }

    pub fn fromInterop(interop: basis.bindings.RendererInteropRayCastResult) RayCastResult {
        return RayCastResult{
            .hitPoint = Vec3.fromInterop(interop.hitPoint),
            .hitPointNormal = Vec3.fromInterop(interop.hitPointNormal),
            .hitObject = interop.hitObject,
        };
    }
};

//----------------------------------------------------

pub const RenderScenePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    //----------------------------------------------------

    pub fn getRootSceneNode(self: *const Self) SceneNodePtr {
        const sceneNodeCppPtr = basis.bindings.api.RenderScene_getRootSceneNode(self.cppPtr);
        return SceneNodePtr{
            .cppPtr = sceneNodeCppPtr,
            .ownsMemory = false,
        };
    }

    pub fn destroySceneNode(self: *const Self, sceneNode: SceneNodePtr) void {
        basis.bindings.api.RenderScene_destroySceneNode(self.cppPtr, sceneNode.cppPtr);
    }

    //----------------------------------------------------

    pub fn createCamera(self: *const Self) CameraPtr {
        return CameraPtr{
            .cppPtr = basis.bindings.api.RenderScene_createCamera(self.cppPtr),
        };
    }

    pub fn destroyCamera(self: *const Self, camera: CameraPtr) void {
        basis.bindings.api.RenderScene_destroyCamera(self.cppPtr, camera.cppPtr);
    }

    //----------------------------------------------------

    pub fn createDynamicMeshInstance(self: *const Self, mesh: MeshPtr, materials: []const MaterialPtr) MeshInstancePtr {
        var materialPtrs: [8]basis.CppPtr = undefined;
        const materialCount: u32 = @as(u32, @intCast(materials.len));

        for (materials, 0..) |material, i| {
            materialPtrs[i] = material.cppPtr;
        }

        return MeshInstancePtr{
            .cppPtr = basis.bindings.api.RenderScene_createDynamicMeshInstance(self.cppPtr, mesh.cppPtr, &materialPtrs, materialCount),
        };
    }

    pub fn createStaticMeshInstance(self: *const Self, mesh: MeshPtr, materials: []const MaterialPtr, addToBVH: bool) MeshInstancePtr {
        var materialPtrs: [8]basis.CppPtr = undefined;
        const materialCount: u32 = @as(u32, @intCast(materials.len));

        for (materials, 0..) |material, i| {
            materialPtrs[i] = material.cppPtr;
        }

        return MeshInstancePtr{
            .cppPtr = basis.bindings.api.RenderScene_createStaticMeshInstance(
                self.cppPtr,
                mesh.cppPtr,
                &materialPtrs,
                materialCount,
                addToBVH,
            ),
        };
    }

    pub fn destroyMeshInstance(self: *const Self, meshInstance: MeshInstancePtr) void {
        basis.bindings.api.RenderScene_destroyMeshInstance(self.cppPtr, meshInstance.cppPtr);
    }

    //----------------------------------------------------

    pub fn castRay(self: *const Self, rayOrigin: Vec3, rayDirection: Vec3, hitGroupMask: u32, onlyAABB: bool, result: *RayCastResult) bool {
        var interopResult: basis.bindings.RendererInteropRayCastResult = undefined;
        const interopOrigin = rayOrigin.toInterop();
        const interopDirection = rayDirection.toInterop();

        const wasHit = basis.bindings.api.RenderScene_castRay(self.cppPtr, &interopOrigin, &interopDirection, &interopResult, hitGroupMask, if (onlyAABB) 1 else 0);

        if (wasHit == 1) {
            result.hitPoint = Vec3.fromInterop(interopResult.hitPoint);
            result.hitPointNormal = Vec3.fromInterop(interopResult.hitPointNormal);
            result.hitObject = interopResult.hitObject;
            return true;
        }

        return false;
    }

    //----------------------------------------------------

    pub fn getTireTrackRenderer(self: *const Self) TireTrackRendererPtr {
        const cppPtr = basis.bindings.api.RenderScene_getTireTrackRenderer(self.cppPtr);
        return TireTrackRendererPtr{
            .cppPtr = cppPtr,
        };
    }
};
