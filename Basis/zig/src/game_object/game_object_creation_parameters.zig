// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;

pub const GameObjectCreationParametersPtr = struct {
    const Self = @This();

    cppPtr: basis.CppPtr,
    explicitAllocation: bool,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .explicitAllocation = false,
        };
    }

    pub fn initNew() Self {
        return Self{
            .cppPtr = basis.bindings.api.GameObjectCreationParameters_newParams(),
            .explicitAllocation = true,
        };
    }

    pub fn initWithNameAndType(objectName: []const u8, objectType: []const u8) Self {
        const interopName = basis.string.toInteropString(objectName);
        const interopType = basis.string.toInteropString(objectType);

        return Self{
            .cppPtr = basis.bindings.api.GameObjectCreationParameters_newParamsWithNameAndType(&interopName, &interopType),
            .explicitAllocation = true,
        };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{
            .cppPtr = cppPtr,
            .explicitAllocation = false,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.explicitAllocation) {
            basis.bindings.api.GameObjectCreationParameters_deleteParams(self.cppPtr);
        }

        self.cppPtr = 0;
        self.explicitAllocation = false;
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    pub fn setStartTransform(self: *const Self, position: Vec3, orientation: Quaternion) void {
        const interopPos = position.toInterop();
        const interopOri = orientation.toInterop();

        basis.bindings.api.GameObjectCreationParameters_setStartTransform(self.cppPtr, &interopPos, &interopOri);
    }

    pub fn setPropertyBundlePath(self: *const Self, path: []const u8) void {
        const interopPath = basis.string.toInteropString(path);
        basis.bindings.api.GameObjectCreationParameters_setPropertyBundlePath(self.cppPtr, &interopPath);
    }
};
