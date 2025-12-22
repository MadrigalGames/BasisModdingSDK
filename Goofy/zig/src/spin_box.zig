// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UISpinBoxPtr = struct {
    const Self = @This();
    pub const WidgetType = goofy.UIWidgetType.SpinBox;
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

    //----------------------------------------------------

    pub fn addItem(self: *const Self, value: i32, text: []const u8, isLocalized: bool) void {
        const interopText = basis.string.toInteropString(text);
        goofy.bindings.api.GoofyUISpinBox_addItem(self.cppPtr, value, &interopText, isLocalized);
    }

    pub fn clearItems(self: *const Self) void {
        goofy.bindings.api.GoofyUISpinBox_clearItems(self.cppPtr);
    }

    pub fn setSelectedValue(self: *const Self, value: i32) void {
        goofy.bindings.api.GoofyUISpinBox_setSelectedValue(self.cppPtr, value);
    }

    pub fn getSelectedValue(self: *const Self) i32 {
        return goofy.bindings.api.GoofyUISpinBox_getSelectedValue(self.cppPtr);
    }
};
