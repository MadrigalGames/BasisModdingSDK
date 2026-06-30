// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UILabelPtr = struct {
    const Self = @This();
    pub const WidgetType = goofy.UIWidgetType.Label;
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    base: goofy.UIWidgetPtr,

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

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    //----------------------------------------------------

    pub fn setRawText(self: *const Self, text: []const u8) void {
        const t = basis.string.toInteropString(text);
        goofy.bindings.api.GoofyUILabel_setRawText(self.cppPtr, &t);
    }

    pub fn setLocalizedText(self: *const Self, locID: []const u8) void {
        const t = basis.string.toInteropString(locID);
        goofy.bindings.api.GoofyUILabel_setLocalizedText(self.cppPtr, &t);
    }

    pub fn setColor(self: *const Self, color: basis.Color) void {
        const c = basis.Color.toInterop(color);
        goofy.bindings.api.GoofyUILabel_setColor(self.cppPtr, &c);
    }

    pub fn getColor(self: *const Self) basis.Color {
        var c: basis.bindings.InteropColor = undefined;
        goofy.bindings.api.GoofyUILabel_getColor(self.cppPtr, &c);
        return basis.Color.fromInterop(c);
    }

    pub fn setColorAlpha(self: *const Self, alpha: u8) void {
        var c = self.getColor();
        c.a = alpha;
        self.setColor(c);
    }
};
