// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UICanvasPtr = struct {
    const Self = @This();
    pub const WidgetType = goofy.UIWidgetType.Canvas;
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    base: goofy.UIWidgetPtr,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .base = .Null,
        };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{ .cppPtr = cppPtr, .base = goofy.UIWidgetPtr.init(
            cppPtr,
            WidgetType,
        ) };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    //----------------------------------------------------

    pub fn setRenderCallback(self: *const Self, callback: RenderCallback) void {
        setRenderCallbackInternal(self.cppPtr, callback);
        goofy.bindings.api.GoofyUICanvas_setRenderCallbackEnabled(self.cppPtr, 1);
    }

    pub fn getUserData(self: *const Self) basis.math.Vec4 {
        var interop: basis.bindings.InteropVec4 = undefined;
        goofy.bindings.api.GoofyUICanvas_getUserData(self.cppPtr, &interop);
        return basis.math.Vec4.fromInterop(interop);
    }
};

pub const RenderCallback = basis.delegate.VoidDelegate4(
    goofy.UIRenderContext,
    UICanvasPtr,
    basis.math.Vec2, // Pixel pos
    basis.math.Vec2, // Pixel size
);

//----------------------------------------------------

// Logic and data for handling render callback calls coming from the C++ side.

const CallbackMap = std.AutoArrayHashMap(basis.CppPtr, RenderCallback);

pub const GlobalData = struct {
    callbackMap: CallbackMap = undefined,
};

pub fn init() void {
    goofy.g.canvas.callbackMap = .init(goofy.g.allocator);
}

pub fn deinit() void {
    goofy.g.canvas.callbackMap.deinit();
}

// Called from UICanvasPtr.setRenderCallback().
fn setRenderCallbackInternal(
    canvasCppPtr: basis.CppPtr,
    callback: RenderCallback,
) void {
    const gop = goofy.g.canvas.callbackMap.getOrPut(canvasCppPtr) catch unreachable;
    gop.value_ptr.* = callback;
}

// Execute the render callback. Called from the C++ side.
pub fn runRenderCallback(
    render_ctxt: *const goofy.bindings.InteropUIRenderContext,
    canvas_cpp_ptr: basis.CppPtr,
    pixel_pos: *const basis.bindings.InteropVec2,
    pixel_size: *const basis.bindings.InteropVec2,
) void {
    if (goofy.g.canvas.callbackMap.get(canvas_cpp_ptr)) |cb| {
        const pixel_rect = basis.math.AABB2D.init(
            render_ctxt.pixelRectMinX,
            render_ctxt.pixelRectMinY,
            render_ctxt.pixelRectMaxX,
            render_ctxt.pixelRectMaxY,
        );
        const pixel_pos_vec2 = basis.math.Vec2.fromInterop(pixel_pos.*);
        const pixel_size_vec2 = basis.math.Vec2.fromInterop(pixel_size.*);
        const canvas = goofy.UICanvasPtr.initFromCppPtr(canvas_cpp_ptr);
        const ctxt = goofy.UIRenderContext.init(
            render_ctxt.nvgCppCtxt,
            render_ctxt.screenWidth,
            render_ctxt.screenHeight,
            pixel_rect,
        );

        cb.call(ctxt, canvas, pixel_pos_vec2, pixel_size_vec2);
    }
}

// Remove a render callback. Called from the C++ side when the canvas is destroyed.
pub fn removeRenderCallback(canvas_cpp_ptr: basis.CppPtr) void {
    _ = goofy.g.canvas.callbackMap.orderedRemove(canvas_cpp_ptr);
}
