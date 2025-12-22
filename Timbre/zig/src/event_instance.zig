// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const timbre = @import("timbre.zig");

pub const EventInstancePtr = struct {
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
        timbre.bindings.api.EventInstance_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        timbre.bindings.api.EventInstance_release(self.cppPtr);
        self.cppPtr = 0;
    }

    pub fn releaseWhenFinished(self: *const Self) void {
        timbre.bindings.api.EventInstance_releaseWhenFinished(self.cppPtr);
    }

    pub fn releaseAfterFadeOut(self: *const Self, fadeOutDuration: f32) void {
        timbre.bindings.api.EventInstance_releaseAfterFadeOut(self.cppPtr, fadeOutDuration);
    }

    pub fn getState(self: *const Self) timbre.PlaybackState {
        const stateInt = timbre.bindings.api.EventInstance_getState(self.cppPtr);
        return @as(timbre.PlaybackState, @enumFromInt(stateInt));
    }

    pub fn start(self: *const Self) void {
        timbre.bindings.api.EventInstance_start(self.cppPtr);
    }

    pub fn pause(self: *const Self) void {
        timbre.bindings.api.EventInstance_pause(self.cppPtr);
    }

    pub fn stop(self: *const Self) void {
        timbre.bindings.api.EventInstance_stop(self.cppPtr);
    }

    pub fn setParameterByName(self: *const Self, name: []const u8, value: f32) void {
        const interopName = basis.string.toInteropString(name);
        timbre.bindings.api.EventInstance_setParameterByName(self.cppPtr, &interopName, value);
    }

    pub fn setParameterByIndex(self: *const Self, index: u32, value: f32) void {
        timbre.bindings.api.EventInstance_setParameterByIndex(self.cppPtr, index, value);
    }

    pub fn set3DParameters(self: *const Self, position: basis.math.Vec3, linearVelocity: basis.math.Vec3) void {
        const p = position.toInterop();
        const lv = linearVelocity.toInterop();
        timbre.bindings.api.EventInstance_set3DParameters(self.cppPtr, &p, &lv);
    }

    pub fn sendSignal(self: *const Self, signal: []const u8) void {
        const interopSignal = basis.string.toInteropString(signal);
        timbre.bindings.api.EventInstance_sendSignal(self.cppPtr, &interopSignal);
    }

    pub fn fadeIn(self: *const Self, fadeInDuration: f32) void {
        timbre.bindings.api.EventInstance_fadeIn(self.cppPtr, fadeInDuration);
    }
};
