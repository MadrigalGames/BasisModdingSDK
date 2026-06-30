// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UIWidgetPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    widgetType: goofy.UIWidgetType,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .widgetType = goofy.UIWidgetType.Unknown,
        };
    }

    pub fn init(cppPtr: basis.CppPtr, widgetType: goofy.UIWidgetType) Self {
        return Self{
            .cppPtr = cppPtr,
            .widgetType = widgetType,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    pub fn getName(self: *const Self) []const u8 {
        var str: basis.bindings.InteropString = undefined;
        goofy.bindings.api.GoofyUIWidget_getName(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            &str,
        );
        return str.ptr[0..str.len];
    }

    pub fn setPosition(self: *const Self, pos: basis.math.Vec2) void {
        const interopPos = pos.toInterop();
        goofy.bindings.api.GoofyUIWidget_setPosition(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            &interopPos,
        );
    }

    pub fn getPosition(self: *const Self) basis.math.Vec2 {
        var interopPos: basis.bindings.InteropVec2 = undefined;

        goofy.bindings.api.GoofyUIWidget_getPosition(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            &interopPos,
        );

        return basis.math.Vec2.fromInterop(interopPos);
    }

    pub fn setSize(self: *const Self, size: basis.math.Vec2) void {
        const interopSize = size.toInterop();
        goofy.bindings.api.GoofyUIWidget_setSize(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            &interopSize,
        );
    }

    pub fn getSize(self: *const Self) basis.math.Vec2 {
        var interopSize: basis.bindings.InteropVec2 = undefined;

        goofy.bindings.api.GoofyUIWidget_getSize(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            &interopSize,
        );

        return basis.math.Vec2.fromInterop(interopSize);
    }

    pub fn setVisible(self: *const Self, visible: bool) void {
        goofy.bindings.api.GoofyUIWidget_setVisible(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            visible,
        );
    }

    pub fn isVisible(self: *const Self) bool {
        const visible = goofy.bindings.api.GoofyUIWidget_isVisible(
            self.cppPtr,
            @intFromEnum(self.widgetType),
        );
        return if (visible == 1) true else false;
    }

    pub fn setEnabled(self: *const Self, enabled: bool) void {
        goofy.bindings.api.GoofyUIWidget_setEnabled(
            self.cppPtr,
            @intFromEnum(self.widgetType),
            enabled,
        );
    }

    pub fn isEnabled(self: *const Self) bool {
        const enabled = goofy.bindings.api.GoofyUIWidget_isEnabled(
            self.cppPtr,
            @intFromEnum(self.widgetType),
        );
        return if (enabled == 1) true else false;
    }
};
