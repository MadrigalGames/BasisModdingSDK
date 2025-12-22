// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const api = @import("bindings/api.zig");

pub const generated_types = @import("bindings/generated_types.zig");
pub const generated_bind_functions = @import("bindings/generated_bind_functions.zig");
pub const generated_function_pointers = @import("bindings/generated_function_pointers.zig");

// Shorthand form to make using the generated function pointers a bit less cumbersome.
pub const fp = generated_function_pointers;

pub const InteropUIRenderContext = extern struct {
    nvgCppCtxt: basis.CppPtr = 0,
    screenWidth: f32 = 0.0,
    screenHeight: f32 = 0.0,
    pixelRectMinX: f32 = 0.0,
    pixelRectMinY: f32 = 0.0,
    pixelRectMaxX: f32 = 0.0,
    pixelRectMaxY: f32 = 0.0,
};

pub const InteropPaint = extern struct {
    xform: [6]f32, // = [_]f32{0.0} ** 6,
    extent: [2]f32, // = [_]f32{0.0} ** 2,
    radius: f32, // = 0.0,
    feather: f32, // = 0.0,
    innerColor: [4]f32, // = [_]f32{0.0} ** 4,
    outerColor: [4]f32, // = [_]f32{0.0} ** 4,
    image: i32, // = 0,
};

// Render callback types:

pub const InteropButtonRenderCallback = *const fn (
    *const InteropUIRenderContext, // Render ctxt
    *const basis.bindings.InteropVec4, // Top left X, Top left Y, Width, Height
    *const basis.bindings.InteropString, // Text
    i32, // Font handle
    u32, // Widget state flags
) callconv(.c) void;

pub const InteropSpinBoxRenderCallback = *const fn (
    *const InteropUIRenderContext, // Render ctxt
    *const basis.bindings.InteropVec4, // Top left X, Top left Y, Width, Height
    *const basis.bindings.InteropVec4, // Title width radio, button width ratio, unused, unused
    *const basis.bindings.InteropString, // Title text
    *const basis.bindings.InteropString, // Value text
    i32, // Font handle
    u32, // Widget state flags
) callconv(.c) void;
