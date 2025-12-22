// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const AngelScriptFunctionPtr = struct {
    const Self = @This();
    pub const Null = initNull();

    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn init(cppPtr: basis.CppPtr) Self {
        return Self{ .cppPtr = cppPtr };
    }

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    //----------------------------------------------------

    pub fn prepareCall(self: *const Self) void {
        if (self.cppPtr == 0) return;

        basis.bindings.api.AngelScriptFunction_prepareCall(self.cppPtr);
    }

    pub fn setBoolParam(self: *const Self, i: u32, value: bool) void {
        if (self.cppPtr == 0) return;

        basis.bindings.api.AngelScriptFunction_setBoolParam(self.cppPtr, i, value);
    }

    pub fn setIntParam(self: *const Self, i: u32, value: i32) void {
        if (self.cppPtr == 0) return;

        basis.bindings.api.AngelScriptFunction_setIntParam(self.cppPtr, i, value);
    }

    pub fn setUintParam(self: *const Self, i: u32, value: u32) void {
        if (self.cppPtr == 0) return;

        basis.bindings.api.AngelScriptFunction_setUintParam(self.cppPtr, i, value);
    }

    pub fn setFloatParam(self: *const Self, i: u32, value: f32) void {
        if (self.cppPtr == 0) return;

        basis.bindings.api.AngelScriptFunction_setFloatParam(self.cppPtr, i, value);
    }

    pub fn setStringParam(self: *const Self, i: u32, value: []const u8) void {
        if (self.cppPtr == 0) return;

        const interopValue = basis.string.toInteropString(value);
        basis.bindings.api.AngelScriptFunction_setStringParam(self.cppPtr, i, &interopValue);
    }

    pub fn setGameObjectRefParam(self: *const Self, i: u32, objectNameHash: basis.StringHash, clientOrServer: anytype) void {
        if (self.cppPtr == 0) return;

        const host = basis.host.HostPtr.init(clientOrServer);
        basis.bindings.api.AngelScriptFunction_setGameObjectRefParam(self.cppPtr, i, objectNameHash, host.cppPtr, host.isClient);
    }

    pub fn executeCall(self: *const Self) void {
        if (self.cppPtr == 0) return;

        basis.bindings.api.AngelScriptFunction_executeCall(self.cppPtr);
    }
};
