// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    //----------------------------------------------------

    pub fn setRecreationCallback(self: *const Self, callback: RecreationCallback) void {
        if (basis.build_options.buildAsWASM) {
            return; // Not yet supported on WASM.
        }

        setRecreationCallbackInternal(self.cppPtr, callback);
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

pub const GlobalData = struct {
    callbackMap: CallbackMap = undefined,
};

pub fn init() void {
    goofy.g.view.callbackMap = .init(goofy.g.allocator);
}

pub fn deinit() void {
    goofy.g.view.callbackMap.deinit();
}

// Called from UIViewPtr.setRecreationCallback().
fn setRecreationCallbackInternal(
    viewCppPtr: basis.CppPtr,
    callback: RecreationCallback,
) void {
    const gop = goofy.g.view.callbackMap.getOrPut(viewCppPtr) catch @panic(
        ("Error getting view recreation callback."),
    );
    gop.value_ptr.* = callback;
}

// Execute the recreation callback. Called from the C++ side.
pub fn runRecreationCallback(
    viewCppPtr: basis.CppPtr,
    success: bool,
) void {
    if (goofy.g.view.callbackMap.get(viewCppPtr)) |cb| {
        cb.call(success);
    }
}

// Remove a recreation callback. Called from the C++ side when the view is destroyed.
pub fn removeRecreationCallback(viewCppPtr: basis.CppPtr) void {
    _ = goofy.g.view.callbackMap.orderedRemove(viewCppPtr);
}
