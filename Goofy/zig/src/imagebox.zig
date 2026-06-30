// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UIImageBoxPtr = struct {
    const Self = @This();
    pub const WidgetType = goofy.UIWidgetType.ImageBox;
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

    pub fn play(self: *const Self) void {
        goofy.bindings.api.GoofyUIImageBox_play(self.cppPtr);
    }

    pub fn pause(self: *const Self) void {
        goofy.bindings.api.GoofyUIImageBox_pause(self.cppPtr);
    }

    pub fn stop(self: *const Self) void {
        goofy.bindings.api.GoofyUIImageBox_stop(self.cppPtr);
    }

    pub fn jumpToEnd(self: *const Self) void {
        goofy.bindings.api.GoofyUIImageBox_jumpToEnd(self.cppPtr);
    }
};
