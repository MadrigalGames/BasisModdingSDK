// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UIButtonPtr = struct {
    const Self = @This();
    pub const WidgetType = goofy.UIWidgetType.Button;
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
        goofy.bindings.api.GoofyUIButton_setRawText(self.cppPtr, &t);
    }

    pub fn setLocalizedText(self: *const Self, locID: []const u8) void {
        const t = basis.string.toInteropString(locID);
        goofy.bindings.api.GoofyUIButton_setLocalizedText(self.cppPtr, &t);
    }
};
