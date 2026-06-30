// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const merlin = @import("merlin.zig");

pub const EffectDescriptionPtr = struct {
    const Self = @This();
    pub const Null = initNull();
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

    pub fn createInstance(self: *const Self, worldTransform: basis.math.Mat43, autoStart: bool) merlin.EffectInstancePtr {
        const interopTransform = worldTransform.toInterop();
        const cppPtr = merlin.bindings.api.EffectDescription_createInstance(
            self.cppPtr,
            &interopTransform,
            if (autoStart) 1 else 0,
        );
        return merlin.EffectInstancePtr.initFromCppPtr(cppPtr);
    }

    pub fn getParameterIndex(self: *const Self, name: []const u8) merlin.ParameterIndex {
        const interopName = basis.string.toInteropString(name);
        return merlin.bindings.api.EffectDescription_getParameterIndex(self.cppPtr, &interopName);
    }
};
