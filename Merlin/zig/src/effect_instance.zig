// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const merlin = @import("merlin.zig");

pub const EffectInstancePtr = struct {
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

    pub fn release(self: *const Self) void {
        merlin.bindings.api.EffectInstance_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }

    pub fn releaseWhenFinished(self: *const Self) void {
        merlin.bindings.api.EffectInstance_releaseWhenFinished(self.cppPtr);
    }

    pub fn releaseWhenFinishedAndZero(self: *Self) void {
        merlin.bindings.api.EffectInstance_releaseWhenFinished(self.cppPtr);
        self.cppPtr = 0;
    }

    pub fn setTransform(self: *const Self, worldTransform: basis.math.Mat43) void {
        const interopTransform = worldTransform.toInterop();
        merlin.bindings.api.EffectInstance_setTransform(self.cppPtr, &interopTransform);
    }

    pub fn getState(self: Self) merlin.EffectInstanceState {
        const stateInt = merlin.bindings.api.EffectInstance_getState(self.cppPtr);
        return @as(merlin.EffectInstanceState, @enumFromInt(stateInt));
    }

    pub fn start(self: *const Self) void {
        merlin.bindings.api.EffectInstance_start(self.cppPtr);
    }

    pub fn pause(self: *const Self) void {
        merlin.bindings.api.EffectInstance_pause(self.cppPtr);
    }

    pub fn stop(self: *const Self) void {
        merlin.bindings.api.EffectInstance_stop(self.cppPtr);
    }

    pub fn stopEmitting(self: *const Self) void {
        merlin.bindings.api.EffectInstance_stopEmitting(self.cppPtr);
    }

    pub fn setIntParameter(self: *const Self, index: merlin.ParameterIndex, value: i32) void {
        merlin.bindings.api.EffectInstance_setIntParameter(self.cppPtr, index, value);
    }

    pub fn setFloatParameter(self: *const Self, index: merlin.ParameterIndex, value: f32) void {
        merlin.bindings.api.EffectInstance_setFloatParameter(self.cppPtr, index, value);
    }

    pub fn setVectorParameter(self: *const Self, index: merlin.ParameterIndex, value: basis.math.Vec4) void {
        const interopValue = value.toInterop();
        merlin.bindings.api.EffectInstance_setVectorParameter(self.cppPtr, index, &interopValue);
    }
};
