// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const TypeRegistration = struct {
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

    /// Register an enum with AngelScript. We require the user to give the enum name rather
    /// than reading it from the type, to allow registering the enum exactly how we want.
    /// The enum field names and values are read from the given type.
    pub fn registerEnum(self: *const Self, typeName: []const u8, comptime T: type) void {
        self.registerEnumType(typeName);

        inline for (std.meta.fields(T)) |f| {
            const valueName = f.name;
            const intValue: i32 = @intCast(f.value);
            self.registerEnumValue(typeName, valueName, intValue);
        }
    }

    //----------------------------------------------------

    fn registerEnumType(self: *const Self, typeName: []const u8) void {
        const interopTypeName = basis.string.toInteropString(typeName);
        basis.bindings.api.ZigAngelScriptTypeRegistration_registerEnumType(self.cppPtr, &interopTypeName);
    }

    fn registerEnumValue(self: *const Self, typeName: []const u8, valueName: []const u8, value: i32) void {
        const interopTypeName = basis.string.toInteropString(typeName);
        const interopValueName = basis.string.toInteropString(valueName);
        basis.bindings.api.ZigAngelScriptTypeRegistration_registerEnumValue(self.cppPtr, &interopTypeName, &interopValueName, value);
    }
};
