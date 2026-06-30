// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
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
        basis.assert(@src(), self.cppPtr != 0);

        basis.bindings.api.AngelScriptFunction_prepareCall(self.cppPtr);
    }

    pub fn setBoolParam(self: *const Self, i: u32, value: bool) void {
        basis.assert(@src(), self.cppPtr != 0);

        basis.bindings.api.AngelScriptFunction_setBoolParam(self.cppPtr, i, value);
    }

    pub fn setIntParam(self: *const Self, i: u32, value: i32) void {
        basis.assert(@src(), self.cppPtr != 0);

        basis.bindings.api.AngelScriptFunction_setIntParam(self.cppPtr, i, value);
    }

    pub fn setUintParam(self: *const Self, i: u32, value: u32) void {
        basis.assert(@src(), self.cppPtr != 0);

        basis.bindings.api.AngelScriptFunction_setUintParam(self.cppPtr, i, value);
    }

    pub fn setFloatParam(self: *const Self, i: u32, value: f32) void {
        basis.assert(@src(), self.cppPtr != 0);

        basis.bindings.api.AngelScriptFunction_setFloatParam(self.cppPtr, i, value);
    }

    pub fn setStringParam(self: *const Self, i: u32, value: []const u8) void {
        basis.assert(@src(), self.cppPtr != 0);

        const interopValue = basis.string.toInteropString(value);
        basis.bindings.api.AngelScriptFunction_setStringParam(self.cppPtr, i, &interopValue);
    }

    pub fn setGameObjectRefParam(self: *const Self, i: u32, objectNameHash: basis.StringHash, clientOrServer: anytype) void {
        basis.assert(@src(), self.cppPtr != 0);

        const host = basis.host.HostPtr.init(clientOrServer);
        basis.bindings.api.AngelScriptFunction_setGameObjectRefParam(self.cppPtr, i, objectNameHash, host.cppPtr, host.isClient);
    }

    pub fn getReturnBool(self: *const Self) bool {
        basis.assert(@src(), self.cppPtr != 0);
        return (basis.bindings.api.AngelScriptFunction_getReturnBool(self.cppPtr) == 1);
    }

    pub fn getReturnInt(self: *const Self) i32 {
        basis.assert(@src(), self.cppPtr != 0);
        return basis.bindings.api.AngelScriptFunction_getReturnInt(self.cppPtr);
    }

    pub fn getReturnUint(self: *const Self) u32 {
        basis.assert(@src(), self.cppPtr != 0);
        return basis.bindings.api.AngelScriptFunction_getReturnUint(self.cppPtr);
    }

    pub fn getReturnFloat(self: *const Self) f32 {
        basis.assert(@src(), self.cppPtr != 0);
        return basis.bindings.api.AngelScriptFunction_getReturnFloat(self.cppPtr);
    }

    pub fn executeCall(self: *const Self) void {
        basis.assert(@src(), self.cppPtr != 0);

        basis.bindings.api.AngelScriptFunction_executeCall(self.cppPtr);
    }
};
