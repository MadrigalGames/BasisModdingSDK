// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const ComponentRegistration = struct {
    const Self = @This();

    //----------------------------------------------------

    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn init(cppPtr: basis.CppPtr) Self {
        return Self{
            .cppPtr = cppPtr,
        };
    }

    //----------------------------------------------------

    pub fn registerComponentType(self: *const Self, typeName: []const u8) void {
        const interopTypeName = basis.string.toInteropString(typeName);
        basis.bindings.api.ZigAngelScriptComponentRegistration_registerComponentType(self.cppPtr, &interopTypeName);
    }

    pub fn registerComponentMethod(self: *const Self, declaration: []const u8, functionPtr: anytype) void {
        const interopDeclaration = basis.string.toInteropString(declaration);
        const functionIntPtr: basis.IntPtr = @intFromPtr(functionPtr);
        basis.bindings.api.ZigAngelScriptComponentRegistration_registerComponentMethod(self.cppPtr, &interopDeclaration, functionIntPtr);
    }

    pub fn registerComponentEventAutoComplete(self: *const Self, declaration: []const u8) void {
        const interopDeclaration = basis.string.toInteropString(declaration);
        basis.bindings.api.ZigAngelScriptComponentRegistration_registerComponentEventAutoComplete(self.cppPtr, &interopDeclaration);
    }
};
