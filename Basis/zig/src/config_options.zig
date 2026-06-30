// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const ConfigOptionsPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    //----------------------------------------------------

    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn addString(self: *const Self, name: []const u8, value: []const u8) void {
        const interopName = basis.string.toInteropString(name);
        const interopValue = basis.string.toInteropString(value);
        basis.bindings.api.ConfigOptions_addString(self.cppPtr, &interopName, &interopValue);
    }

    pub fn addFloat(self: *const Self, name: []const u8, value: f32) void {
        const interopName = basis.string.toInteropString(name);
        basis.bindings.api.ConfigOptions_addFloat(self.cppPtr, &interopName, value);
    }

    pub fn addInteger(self: *const Self, name: []const u8, value: i32) void {
        const interopName = basis.string.toInteropString(name);
        basis.bindings.api.ConfigOptions_addInteger(self.cppPtr, &interopName, value);
    }

    pub fn addBool(self: *const Self, name: []const u8, value: bool) void {
        const interopName = basis.string.toInteropString(name);
        basis.bindings.api.ConfigOptions_addBool(self.cppPtr, &interopName, value);
    }

    pub fn getString(self: *const Self, name: []const u8) []const u8 {
        const interopName = basis.string.toInteropString(name);
        var str: basis.bindings.InteropString = undefined;
        basis.bindings.api.ConfigOptions_getString(self.cppPtr, &interopName, &str);
        return str.ptr[0..str.len];
    }

    pub fn getFloat(self: *const Self, name: []const u8) f32 {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_getFloat(self.cppPtr, &interopName);
    }

    pub fn getInteger(self: *const Self, name: []const u8) i32 {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_getInteger(self.cppPtr, &interopName);
    }

    pub fn getBool(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_getBool(self.cppPtr, &interopName);
    }

    pub fn setString(self: *const Self, name: []const u8, value: []const u8) void {
        const interopName = basis.string.toInteropString(name);
        const interopValue = basis.string.toInteropString(value);
        basis.bindings.api.ConfigOptions_setString(self.cppPtr, &interopName, &interopValue);
    }

    pub fn setFloat(self: *const Self, name: []const u8, value: f32) void {
        const interopName = basis.string.toInteropString(name);
        basis.bindings.api.ConfigOptions_setFloat(self.cppPtr, &interopName, value);
    }

    pub fn setInteger(self: *const Self, name: []const u8, value: i32) void {
        const interopName = basis.string.toInteropString(name);
        basis.bindings.api.ConfigOptions_setInteger(self.cppPtr, &interopName, value);
    }

    pub fn setBool(self: *const Self, name: []const u8, value: bool) void {
        const interopName = basis.string.toInteropString(name);
        basis.bindings.api.ConfigOptions_setBool(self.cppPtr, &interopName, value);
    }

    pub fn hasString(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_hasString(self.cppPtr, &interopName);
    }

    pub fn hasFloat(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_hasFloat(self.cppPtr, &interopName);
    }

    pub fn hasInteger(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_hasInteger(self.cppPtr, &interopName);
    }

    pub fn hasBool(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return basis.bindings.api.ConfigOptions_hasBool(self.cppPtr, &interopName);
    }

    pub fn save(self: *const Self) void {
        basis.bindings.api.ConfigOptions_save(self.cppPtr);
    }
};
