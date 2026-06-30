// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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

// Keep in sync with the enum in Renderer_setGraphicsOption() in C++.
pub const GraphicsOption = enum(i32) {
    SSAO = 0,
    AntiAliasing = 1,
    Shadows = 2,
    ShellGrass = 3,
    Vignette = 4,
};

pub const RendererPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
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

    // Returns the render window width.
    pub fn getWindowWidth(self: *const Self) u32 {
        return basis.bindings.api.Renderer_getWindowWidth(self.cppPtr);
    }

    // Returns the render window height.
    pub fn getWindowHeight(self: *const Self) u32 {
        return basis.bindings.api.Renderer_getWindowHeight(self.cppPtr);
    }

    // Returns the render viewport width, which can be smaller than the render window width.
    pub fn getRenderWidth(self: *const Self) u32 {
        return basis.bindings.api.Renderer_getRenderWidth(self.cppPtr);
    }

    // Returns the render viewport height, which can be smaller than the render window height.
    pub fn getRenderHeight(self: *const Self) u32 {
        return basis.bindings.api.Renderer_getRenderHeight(self.cppPtr);
    }

    pub fn getAspectRatio(self: *const Self) f32 {
        const width = self.getWindowWidth();
        const height = self.getWindowHeight();
        return (@as(f32, @floatFromInt(width)) / @as(f32, @floatFromInt(height)));
    }

    pub fn getRenderScale(self: *const Self) f32 {
        return basis.bindings.api.Renderer_getRenderScale(self.cppPtr);
    }

    pub fn setRenderScale(self: *const Self, scale: f32) void {
        basis.bindings.api.Renderer_setRenderScale(self.cppPtr, scale);
    }

    pub fn setGraphicsOption(self: *const Self, option: GraphicsOption, value: i32) void {
        return basis.bindings.api.Renderer_setGraphicsOption(self.cppPtr, @intFromEnum(option), value);
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

    // Returns the engine's current window mode. Use this to detect runtime mode changes
    // that bypass the game-side options system, eg. Alt+Enter.
    pub fn getWindowMode(self: *const Self) basis.renderer.RenderWindowMode {
        return @enumFromInt(basis.bindings.api.Renderer_getWindowMode(self.cppPtr));
    }

    pub fn getDisplacementEffectRenderer(self: *const Self) basis.renderer.DisplacementEffectRendererPtr {
        return basis.renderer.DisplacementEffectRendererPtr{
            .cppPtr = basis.bindings.api.Renderer_getDisplacementEffectRenderer(self.cppPtr),
        };
    }
};
