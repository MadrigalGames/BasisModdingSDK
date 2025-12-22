// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UIViewPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{ .cppPtr = cppPtr };
    }

    //----------------------------------------------------

    pub fn setRecreationCallback(self: *const Self, callback: RecreationCallback) void {
        if (basis.build_options.buildAsWASM) {
            return; // Not yet supported on WASM.
        }

        addRecreationCallback(self.cppPtr, callback);
        goofy.bindings.api.GoofyUIView_setRecreationCallbackEnabled(self.cppPtr, 1);
    }

    //----------------------------------------------------

    pub fn getWidget(self: *const Self, comptime T: type, name: []const u8) ?T {
        const interopName = basis.string.toInteropString(name);
        const widgetCppPtr = goofy.bindings.api.GoofyUIView_getWidget(self.cppPtr, &interopName);

        if (widgetCppPtr == 0) {
            return null;
        }

        return T.initFromCppPtr(widgetCppPtr);
    }

    pub fn getAndAssertWidget(self: *const Self, comptime T: type, name: []const u8) T {
        const interopName = basis.string.toInteropString(name);
        const widgetCppPtr = goofy.bindings.api.GoofyUIView_getWidget(self.cppPtr, &interopName);

        basis.assertf(@src(), widgetCppPtr != 0, "Could not find widget with name \"{s}\".", .{name});

        return T.initFromCppPtr(widgetCppPtr);
    }

    pub fn requestFocusChange(self: *const Self, widget: anytype) void {
        const widgetCppPtr: basis.CppPtr = widget.cppPtr;
        const widgetType: goofy.UIWidgetType = @TypeOf(widget).WidgetType;

        goofy.bindings.api.GoofyUIView_requestFocusChange(self.cppPtr, widgetCppPtr, @intFromEnum(widgetType));
    }

    pub fn setRaiseNavDirEvents(self: *const Self, raiseEvents: bool) void {
        goofy.bindings.api.GoofyUIView_setRaiseNavDirEvents(self.cppPtr, if (raiseEvents) 1 else 0);
    }

    pub fn setRaiseMouseEvents(self: *const Self, raiseEvents: bool) void {
        goofy.bindings.api.GoofyUIView_setRaiseMouseEvents(self.cppPtr, if (raiseEvents) 1 else 0);
    }
};

pub const RecreationCallback = basis.delegate.VoidDelegate1(bool);

//----------------------------------------------------

// Logic and data for handling recreation callback calls coming from the C++ side.

const CallbackMap = std.AutoArrayHashMap(basis.CppPtr, RecreationCallback);

var gCallbackAllocator: std.mem.Allocator = undefined;
var gCallbackMap: *CallbackMap = undefined;

// Init the map of callbacks. Called from goofy.init().
pub fn initCallbackMap(allocator: std.mem.Allocator) void {
    gCallbackAllocator = allocator;

    gCallbackMap = gCallbackAllocator.create(CallbackMap) catch unreachable;
    gCallbackMap.* = CallbackMap.init(gCallbackAllocator);
}

// Deinit the map of callbacks. Called from goofy.deinit().
pub fn deinitCallbackMap() void {
    gCallbackMap.deinit();
    gCallbackAllocator.destroy(gCallbackMap);
}

// Add a new callback. Called from UIViewPtr.setRecreationCallback().
fn addRecreationCallback(
    viewCppPtr: basis.CppPtr,
    callback: RecreationCallback,
) void {
    const gop = gCallbackMap.getOrPut(viewCppPtr) catch unreachable;
    basis.assertd(@src(), !gop.found_existing, "UIView recreation callback already registered.");
    gop.value_ptr.* = callback;
}

// Execute the recreation callback. Called from the C++ side.
pub fn runRecreationCallback(
    viewCppPtr: basis.CppPtr,
    success: bool,
) callconv(.c) void {
    if (gCallbackMap.get(viewCppPtr)) |cb| {
        cb.call(success);
    }
}

// Remove a recreation callback. Called from the C++ side when the view is destroyed.
pub fn removeRecreationCallback(viewCppPtr: basis.CppPtr) void {
    _ = gCallbackMap.orderedRemove(viewCppPtr);
}
