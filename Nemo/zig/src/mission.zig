// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const nemo = @import("nemo.zig");

pub const MissionPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    pub fn getPath(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.Mission_getPath(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn getState(self: *const Self) nemo.MissionState {
        const stateInt = nemo.bindings.api.Mission_getState(self.cppPtr);
        return @enumFromInt(stateInt);
    }

    pub fn start(self: *const Self) void {
        nemo.bindings.api.Mission_start(self.cppPtr);
    }

    pub fn abort(self: *const Self) void {
        nemo.bindings.api.Mission_abort(self.cppPtr);
    }
};
