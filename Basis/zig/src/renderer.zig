// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

// Keep in sync with C++!
pub const RenderWindowMode = enum(i32) {
    Windowed = 0,
    FullscreenBorderless = 1,
    FullscreenExclusive = 2,
};

pub const material = @import("renderer/material.zig");
pub const mesh = @import("renderer/mesh.zig");
pub const renderable = @import("renderer/renderable.zig");
pub const mesh_instance = @import("renderer/mesh_instance.zig");
pub const render_scene = @import("renderer/render_scene.zig");
pub const renderer = @import("renderer/renderer.zig");
pub const camera = @import("renderer/camera.zig");
pub const screen_fade = @import("renderer/screen_fade.zig");
pub const mesh_geometry = @import("renderer/mesh_geometry.zig");
pub const vertex_formats = @import("renderer/vertex_formats.zig");
pub const geometry_generator = @import("renderer/geometry_generator.zig");
pub const tire_track_renderer = @import("renderer/tire_track_renderer.zig");
pub const displacement_effect_renderer = @import("renderer/displacement_effect_renderer.zig");

pub const MaterialPtr = material.MaterialPtr;
pub const MeshPtr = mesh.MeshPtr;
pub const RenderablePtr = renderable.RenderablePtr;
pub const MeshInstancePtr = mesh_instance.MeshInstancePtr;
pub const RenderScenePtr = render_scene.RenderScenePtr;
pub const RendererPtr = renderer.RendererPtr;
pub const CameraPtr = camera.CameraPtr;
pub const TireTrackRendererPtr = tire_track_renderer.TireTrackRendererPtr;
pub const DisplacementEffectID = displacement_effect_renderer.DisplacementEffectID;
pub const DisplacementEffectRendererPtr = displacement_effect_renderer.DisplacementEffectRendererPtr;
