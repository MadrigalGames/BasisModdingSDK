// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const nemo = @import("nemo.zig");

pub const GlobalVariableSetPtr = struct {
    const Self = @This();
    pub const Null = initNull();
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
        nemo.bindings.api.GlobalVariableSet_getPath(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn readFloat(self: *const Self, name: []const u8) f32 {
        const interopName = basis.string.toInteropString(name);
        return nemo.bindings.api.GlobalVariableSet_readFloat(self.cppPtr, &interopName);
    }

    pub fn writeFloat(self: *const Self, name: []const u8, value: f32) void {
        const interopName = basis.string.toInteropString(name);
        nemo.bindings.api.GlobalVariableSet_writeFloat(self.cppPtr, &interopName, value);
    }

    pub fn readInt(self: *const Self, name: []const u8) i32 {
        const interopName = basis.string.toInteropString(name);
        return nemo.bindings.api.GlobalVariableSet_readInt(self.cppPtr, &interopName);
    }

    pub fn writeInt(self: *const Self, name: []const u8, value: i32) void {
        const interopName = basis.string.toInteropString(name);
        nemo.bindings.api.GlobalVariableSet_writeInt(self.cppPtr, &interopName, value);
    }

    pub fn readBool(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return if (nemo.bindings.api.GlobalVariableSet_readBool(self.cppPtr, &interopName) == 1) true else false;
    }

    pub fn writeBool(self: *const Self, name: []const u8, value: bool) void {
        const interopName = basis.string.toInteropString(name);
        nemo.bindings.api.GlobalVariableSet_writeBool(self.cppPtr, &interopName, value);
    }

    pub fn readString(self: *const Self, name: []const u8) []const u8 {
        const interopName = basis.string.toInteropString(name);
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.GlobalVariableSet_readString(self.cppPtr, &interopName, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn writeString(self: *const Self, name: []const u8, value: []const u8) void {
        const interopName = basis.string.toInteropString(name);
        const interopValue = basis.string.toInteropString(value);
        nemo.bindings.api.GlobalVariableSet_writeString(self.cppPtr, &interopName, &interopValue);
    }
};
