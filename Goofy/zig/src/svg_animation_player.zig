// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const SVGAnimationPlayerPtr = struct {
    const Self = @This();
    pub const Null = initNull();

    pub const State = enum(u32) {
        Stopped = 0,
        Paused,
        Playing,
        PlayedToTheEnd,
    };

    cppPtr: basis.CppPtr,
    ownsMemory: bool,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .ownsMemory = false,
        };
    }

    pub fn initNew() Self {
        return Self{
            .cppPtr = goofy.bindings.api.GoofySVGAnimationPlayer_newPlayer(),
            .ownsMemory = true,
        };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{
            .cppPtr = cppPtr,
            .ownsMemory = false,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.ownsMemory) {
            goofy.bindings.api.GoofySVGAnimationPlayer_deletePlayer(self.cppPtr);
        }

        self.cppPtr = 0;
        self.ownsMemory = false;
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    pub fn getWidth(self: *const Self) f32 {
        return goofy.bindings.api.GoofySVGAnimationPlayer_getWidth(self.cppPtr);
    }

    pub fn getHeight(self: *const Self) f32 {
        return goofy.bindings.api.GoofySVGAnimationPlayer_getHeight(self.cppPtr);
    }

    pub fn setDeltaTimeLimitEnabled(self: *const Self, enabled: bool) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_setDeltaTimeLimitEnabled(self.cppPtr, enabled);
    }

    pub fn loadAnimation(self: *const Self, dataFile: basis.resources.RawDataFilePtr) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_loadAnimation(self.cppPtr, dataFile.cppPtr);
    }

    pub fn render(self: *const Self, ctx: goofy.UIRenderContext, rect: basis.math.AABB2D) void {
        const interopCtxt = ctx.toInterop();
        const rectMin = rect.min.toInterop();
        const rectMax = rect.max.toInterop();

        goofy.bindings.api.GoofySVGAnimationPlayer_render(self.cppPtr, &interopCtxt, &rectMin, &rectMax);
    }

    pub fn renderUnstretched(self: *const Self, ctx: goofy.UIRenderContext, position: basis.math.Vec2, width: f32, pivot: goofy.UIPivot) void {
        const interopCtxt = ctx.toInterop();
        const interopPos = position.toInterop();

        goofy.bindings.api.GoofySVGAnimationPlayer_renderUnstretched(self.cppPtr, &interopCtxt, &interopPos, width, @intFromEnum(pivot));
    }

    pub fn play(self: *const Self) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_play(self.cppPtr);
    }

    pub fn pause(self: *const Self) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_pause(self.cppPtr);
    }

    pub fn stop(self: *const Self) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_stop(self.cppPtr);
    }

    pub fn jumpToEnd(self: *const Self) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_jumpToEnd(self.cppPtr);
    }

    pub fn setLooping(self: *const Self, looping: bool) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_setLooping(self.cppPtr, looping);
    }

    pub fn update(self: *const Self, deltaTime: f32) void {
        goofy.bindings.api.GoofySVGAnimationPlayer_update(self.cppPtr, deltaTime);
    }

    pub fn getState(self: *const Self) State {
        const stateUint = goofy.bindings.api.GoofySVGAnimationPlayer_getState(self.cppPtr);
        return @enumFromInt(stateUint);
    }

    pub fn getCurrentTime(self: *const Self) f32 {
        return goofy.bindings.api.GoofySVGAnimationPlayer_getCurrentTime(self.cppPtr);
    }

    pub fn setCurrentTime(self: *const Self, time: f32) void {
        return goofy.bindings.api.GoofySVGAnimationPlayer_setCurrentTime(self.cppPtr, time);
    }
};
