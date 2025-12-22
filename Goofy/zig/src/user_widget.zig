// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UserWidgetEventType = enum(u32) {
    Pressed = 0,
    Released,
    Clicked,
    NavDirectionalInput,
    MouseMovedOnWidget,
    BecameFocused,
    BecameUnfocused,
};

pub const UIUserWidgetPtr = struct {
    const Self = @This();
    pub const WidgetType = goofy.UIWidgetType.UserWidget;
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    base: goofy.UIWidgetPtr,

    //----------------------------------------------------

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .base = goofy.UIWidgetPtr.initNull(),
        };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{ .cppPtr = cppPtr, .base = goofy.UIWidgetPtr.init(
            cppPtr,
            WidgetType,
        ) };
    }

    //----------------------------------------------------

    pub fn setRenderCallback(self: *const Self, callback: RenderCallback) void {
        addRenderCallback(self.cppPtr, callback);
        goofy.bindings.api.GoofyUIUserWidget_setRenderCallbackEnabled(self.cppPtr, 1);
    }

    pub fn setEventCallback(self: *const Self, callback: EventCallback) void {
        addEventCallback(self.cppPtr, callback);
        goofy.bindings.api.GoofyUIUserWidget_setEventCallbackEnabled(self.cppPtr, 1);
    }

    pub fn getUserData(self: *const Self) basis.math.Vec4 {
        var interop: basis.bindings.InteropVec4 = undefined;
        goofy.bindings.api.GoofyUIUserWidget_getUserData(self.cppPtr, &interop);
        return basis.math.Vec4.fromInterop(interop);
    }
};

pub const RenderCallback = basis.delegate.VoidDelegate4(
    goofy.UIRenderContext,
    UIUserWidgetPtr,
    basis.math.Vec2, // Pixel pos
    basis.math.Vec2, // Pixel size
);

pub const EventCallback = basis.delegate.VoidDelegate4(
    UIUserWidgetPtr,
    UserWidgetEventType,
    basis.math.Vec4, // Float data
    u32, // Uint data
);

//----------------------------------------------------

// Logic and data for handling render/event callback calls coming from the C++ side.

const RenderCallbackMap = std.AutoArrayHashMap(basis.CppPtr, RenderCallback);

const EventCallbackMap = std.AutoArrayHashMap(basis.CppPtr, EventCallback);

var gCallbackAllocator: std.mem.Allocator = undefined;
var gRenderCallbackMap: *RenderCallbackMap = undefined;
var gEventCallbackMap: *EventCallbackMap = undefined;

// Init the map of callbacks. Called from goofy.init().
pub fn initCallbackMap(allocator: std.mem.Allocator) void {
    gCallbackAllocator = allocator;

    gRenderCallbackMap = gCallbackAllocator.create(RenderCallbackMap) catch unreachable;
    gRenderCallbackMap.* = RenderCallbackMap.init(gCallbackAllocator);

    gEventCallbackMap = gCallbackAllocator.create(EventCallbackMap) catch unreachable;
    gEventCallbackMap.* = EventCallbackMap.init(gCallbackAllocator);
}

// Deinit the map of callbacks. Called from goofy.deinit().
pub fn deinitCallbackMap() void {
    gRenderCallbackMap.deinit();
    gCallbackAllocator.destroy(gRenderCallbackMap);

    gEventCallbackMap.deinit();
    gCallbackAllocator.destroy(gEventCallbackMap);
}

// Add a new callback. Called from UIUserWidgetPtr.setRenderCallback().
fn addRenderCallback(
    userWidgetCppPtr: basis.CppPtr,
    callback: RenderCallback,
) void {
    const gop = gRenderCallbackMap.getOrPut(userWidgetCppPtr) catch unreachable;
    basis.assertd(@src(), !gop.found_existing, "UIUserWidget render callback already registered.");
    gop.value_ptr.* = callback;
}

// Execute the render callback. Called from the C++ side.
pub fn runRenderCallback(
    renderCtxt: *const goofy.bindings.InteropUIRenderContext,
    userWidgetCppPtr: basis.CppPtr,
    pixelPos: *const basis.bindings.InteropVec2,
    pixelSize: *const basis.bindings.InteropVec2,
) callconv(.c) void {
    if (gRenderCallbackMap.get(userWidgetCppPtr)) |cb| {
        const pixel_rect = basis.math.AABB2D.init(
            renderCtxt.pixelRectMinX,
            renderCtxt.pixelRectMinY,
            renderCtxt.pixelRectMaxX,
            renderCtxt.pixelRectMaxY,
        );
        const pixelPos_vec2 = basis.math.Vec2.fromInterop(pixelPos.*);
        const pixelSize_vec2 = basis.math.Vec2.fromInterop(pixelSize.*);
        const userWidget = goofy.UIUserWidgetPtr.initFromCppPtr(userWidgetCppPtr);
        const ctxt = goofy.UIRenderContext.init(
            renderCtxt.nvgCppCtxt,
            renderCtxt.screenWidth,
            renderCtxt.screenHeight,
            pixel_rect,
        );

        cb.call(ctxt, userWidget, pixelPos_vec2, pixelSize_vec2);
    }
}

// Remove a render callback. Called from the C++ side when the user widget is destroyed.
pub fn removeRenderCallback(userWidgetCppPtr: basis.CppPtr) void {
    _ = gRenderCallbackMap.orderedRemove(userWidgetCppPtr);
}

//----------------------------------------------------

// Add a new callback. Called from UIUserWidgetPtr.setEventCallback().
fn addEventCallback(
    userWidgetCppPtr: basis.CppPtr,
    callback: EventCallback,
) void {
    const gop = gEventCallbackMap.getOrPut(userWidgetCppPtr) catch unreachable;
    basis.assertd(@src(), !gop.found_existing, "UIUserWidget event callback already registered.");
    gop.value_ptr.* = callback;
}

pub fn runEventCallback(
    userWidgetCppPtr: basis.CppPtr,
    eventType: u32,
    floatData: *const basis.bindings.InteropVec4,
    uintData: u32,
) callconv(.c) void {
    if (gEventCallbackMap.get(userWidgetCppPtr)) |cb| {
        const userWidget = goofy.UIUserWidgetPtr.initFromCppPtr(userWidgetCppPtr);
        const eventType_: UserWidgetEventType = @enumFromInt(eventType);
        const floatData_ = basis.math.Vec4.fromInterop(floatData.*);

        cb.call(userWidget, eventType_, floatData_, uintData);
    }
}

// Remove an event callback. Called from the C++ side when the user widget is destroyed.
pub fn removeEventCallback(userWidgetCppPtr: basis.CppPtr) void {
    _ = gEventCallbackMap.orderedRemove(userWidgetCppPtr);
}
