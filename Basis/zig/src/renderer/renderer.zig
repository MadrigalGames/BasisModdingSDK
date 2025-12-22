// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const RenderScenePtr = basis.renderer.RenderScenePtr;
const CameraPtr = basis.renderer.CameraPtr;
const MeshPtr = basis.renderer.MeshPtr;

const MeshGeometryPtr = basis.renderer.mesh_geometry.MeshGeometryPtr;

const VertexFormatType = basis.renderer.vertex_formats.VertexFormatType;

pub const RendererPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn getPrimaryScene(self: *const Self) RenderScenePtr {
        return RenderScenePtr{
            .cppPtr = basis.bindings.api.Renderer_getPrimaryScene(self.cppPtr),
        };
    }

    pub fn addCameraToBackOfQueue(self: *const Self, camera: CameraPtr) void {
        basis.bindings.api.Renderer_addCameraToBackOfQueue(self.cppPtr, camera.cppPtr);
    }

    pub fn addCameraToFrontOfQueue(self: *const Self, camera: CameraPtr) void {
        basis.bindings.api.Renderer_addCameraToFrontOfQueue(self.cppPtr, camera.cppPtr);
    }

    pub fn removeCameraFromQueue(self: *const Self, camera: CameraPtr) void {
        basis.bindings.api.Renderer_removeCameraFromQueue(self.cppPtr, camera.cppPtr);
    }

    pub fn getMainCamera(self: *const Self) CameraPtr {
        return CameraPtr{
            .cppPtr = basis.bindings.api.Renderer_getMainCamera(self.cppPtr),
        };
    }

    pub fn getScreenWidth(self: *const Self) u32 {
        return basis.bindings.api.Renderer_getScreenWidth(self.cppPtr);
    }

    pub fn getScreenHeight(self: *const Self) u32 {
        return basis.bindings.api.Renderer_getScreenHeight(self.cppPtr);
    }

    pub fn getAspectRatio(self: *const Self) f32 {
        const width = self.getScreenWidth();
        const height = self.getScreenHeight();
        return (@as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)));
    }

    pub fn setVignetteEnabled(self: *const Self, enabled: bool) void {
        return basis.bindings.api.Renderer_setVignetteEnabled(self.cppPtr, if (enabled) 1 else 0);
    }

    pub fn createMesh(self: *const Self, geom: MeshGeometryPtr, createImmutableGPUBuffers: bool, debugName: []const u8) MeshPtr {
        const interopDebugName = basis.string.toInteropString(debugName);
        const meshCppPtr = basis.bindings.api.Renderer_createMesh(self.cppPtr, geom.cppPtr, createImmutableGPUBuffers, &interopDebugName);
        return MeshPtr{ .cppPtr = meshCppPtr };
    }

    pub fn createMeshManual(self: *const Self, vertexFormatType: VertexFormatType, vertexCount: u32, indexCount: u32, debugName: []const u8) MeshPtr {
        const interopDebugName = basis.string.toInteropString(debugName);
        const meshCppPtr = basis.bindings.api.Renderer_createMeshManual(self.cppPtr, vertexFormatType.asInt(), vertexCount, indexCount, &interopDebugName);
        return MeshPtr{ .cppPtr = meshCppPtr };
    }

    pub fn captureSinglePre2DFrame(self: *const Self, outputFolderPath: []const u8) void {
        const interopOutputFolderPath = basis.string.toInteropString(outputFolderPath);
        basis.bindings.api.Renderer_captureSinglePre2DFrame(self.cppPtr, &interopOutputFolderPath);
    }

    pub fn captureSingleFullEndUserFrame(self: *const Self, outputFolderPath: []const u8) void {
        const interopOutputFolderPath = basis.string.toInteropString(outputFolderPath);
        basis.bindings.api.Renderer_captureSingleFullEndUserFrame(self.cppPtr, &interopOutputFolderPath);
    }

    pub fn captureSingleFullFrame(self: *const Self, outputFolderPath: []const u8) void {
        const interopOutputFolderPath = basis.string.toInteropString(outputFolderPath);
        basis.bindings.api.Renderer_captureSingleFullFrame(self.cppPtr, &interopOutputFolderPath);
    }

    pub fn startCapturingPre2DFrames(self: *const Self, outputFolderPath: []const u8, debugDrawInfo: bool, interval: u32) void {
        const interopOutputFolderPath = basis.string.toInteropString(outputFolderPath);
        basis.bindings.api.Renderer_startCapturingPre2DFrames(
            self.cppPtr,
            &interopOutputFolderPath,
            if (debugDrawInfo) 1 else 0,
            interval,
        );
    }

    pub fn startCapturingFullEndUserFrames(self: *const Self, outputFolderPath: []const u8, debugDrawInfo: bool, interval: u32) void {
        const interopOutputFolderPath = basis.string.toInteropString(outputFolderPath);
        basis.bindings.api.Renderer_startCapturingFullEndUserFrames(
            self.cppPtr,
            &interopOutputFolderPath,
            if (debugDrawInfo) 1 else 0,
            interval,
        );
    }

    pub fn startCapturingFullFrames(self: *const Self, outputFolderPath: []const u8, debugDrawInfo: bool, interval: u32) void {
        const interopOutputFolderPath = basis.string.toInteropString(outputFolderPath);
        basis.bindings.api.Renderer_startCapturingFullFrames(
            self.cppPtr,
            &interopOutputFolderPath,
            if (debugDrawInfo) 1 else 0,
            interval,
        );
    }

    pub fn stopCapturingFrames(self: *const Self) void {
        basis.bindings.api.Renderer_stopCapturingFrames(self.cppPtr);
    }

    pub fn applyDisplayOptions(self: *const Self, renderWindowMode: basis.renderer.RenderWindowMode, width: i32, height: i32, vsync: bool, framerateLimit: i32) void {
        basis.bindings.api.Renderer_applyDisplayOptions(
            self.cppPtr,
            @intFromEnum(renderWindowMode),
            width,
            height,
            vsync,
            framerateLimit,
        );
    }

    pub fn applyVsyncAndFramerateLimit(self: *const Self, vsync: bool, framerateLimit: i32) void {
        basis.bindings.api.Renderer_applyVsyncAndFramerateLimit(self.cppPtr, vsync, framerateLimit);
    }

    pub fn getDisplacementEffectRenderer(self: *const Self) basis.renderer.DisplacementEffectRendererPtr {
        return basis.renderer.DisplacementEffectRendererPtr{
            .cppPtr = basis.bindings.api.Renderer_getDisplacementEffectRenderer(self.cppPtr),
        };
    }
};
