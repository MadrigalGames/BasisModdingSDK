// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const nemo = @import("nemo.zig");

pub const CharacterDataPtr = struct {
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
        nemo.bindings.api.CharacterData_getPath(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn getFirstName(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.CharacterData_getFirstName(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn getLastName(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.CharacterData_getLastName(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn getUIColor(self: *const Self) basis.Color {
        var valueInteropColor: basis.bindings.InteropColor = undefined;
        nemo.bindings.api.CharacterData_getUIColor(self.cppPtr, &valueInteropColor);
        return basis.Color.fromInterop(valueInteropColor);
    }
};
