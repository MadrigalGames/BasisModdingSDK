// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const timbre = @import("timbre.zig");

pub const EventDescriptionPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    pub const InvalidParameterIndex: u32 = 0xFFFFFFFF;
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{
            .cppPtr = cppPtr,
        };
    }

    //----------------------------------------------------

    pub fn createInstance(self: *const Self, autoPause: bool) timbre.EventInstancePtr {
        const cppPtr = timbre.bindings.api.EventDescription_createInstance(
            self.cppPtr,
            if (autoPause) 1 else 0,
        );
        return timbre.EventInstancePtr.initFromCppPtr(cppPtr);
    }

    pub fn createInstanceWithAutoPauseTickLevel(self: *const Self, autoPauseTickLevel: basis.game_session.TickLevel) timbre.EventInstancePtr {
        const cppPtr = timbre.bindings.api.EventDescription_createInstanceWithAutoPauseTickLevel(
            self.cppPtr,
            @intCast(@intFromEnum(autoPauseTickLevel)),
        );
        return timbre.EventInstancePtr.initFromCppPtr(cppPtr);
    }

    pub fn getParameterIndex(self: *const Self, name: []const u8) u32 {
        const interopName = basis.string.toInteropString(name);
        return timbre.bindings.api.EventDescription_getParameterIndex(self.cppPtr, &interopName);
    }

    pub fn getLength(self: *const Self) f32 {
        return timbre.bindings.api.EventDescription_getLength(self.cppPtr);
    }
};
