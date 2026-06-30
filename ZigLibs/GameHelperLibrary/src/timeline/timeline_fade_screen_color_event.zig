// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const ghl = @import("../ghl.zig");

const Allocator = std.mem.Allocator;

pub const TimelineFadeScreenColorEvent = struct {
    const Self = @This();

    //----------------------------------------------------

    allocator: Allocator,
    eventData: ghl.TimelineEventData,
    fromColor: basis.Color,
    toColor: basis.Color,
    clearOnExit: bool,

    fadeTimeElapsed: f32 = 0.0,

    //----------------------------------------------------

    pub fn init(
        allocator: Allocator,
        startTime: f32,
        duration: f32,
        onClient: bool,
        fromColor: basis.Color,
        toColor: basis.Color,
        clearOnExit: bool,
    ) !ghl.TimelineEventInterface {
        const evt = try allocator.create(Self);
        evt.* = Self{
            .allocator = allocator,
            .eventData = ghl.TimelineEventData.init(startTime, duration, onClient),
            .fromColor = fromColor,
            .toColor = toColor,
            .clearOnExit = clearOnExit,
        };

        const typeNameHash = comptime basis.typeinfo.getNameHashFromType(Self);

        return ghl.TimelineEventInterface.make(Self, evt, typeNameHash);
    }

    pub fn destroy(self: *Self) void {
        self.allocator.destroy(self);
    }

    //----------------------------------------------------

    // We don't use basis.renderer.screen_fade.fade() here since that system doesn't
    // care about the timeline's play, pause etc. states.

    pub fn enter(self: *Self, skippingTimeline: bool) !void {
        _ = skippingTimeline; // autofix
        if (self.eventData.onClient) {
            self.fadeTimeElapsed = 0.0;
        }
    }

    pub fn exit(self: *Self, skippingTimeline: bool) !void {
        if (self.eventData.onClient) {
            if (self.clearOnExit) {
                basis.renderer.screen_fade.clear();
            }

            if (skippingTimeline and !self.clearOnExit) {
                basis.renderer.screen_fade.setColor(self.toColor);
            }
        }
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) !void {
        if (self.eventData.onClient) {
            self.fadeTimeElapsed += tickDeltaTime;

            const r = basis.math.remapFloat(self.fadeTimeElapsed, 0.0, self.eventData.duration, @floatFromInt(self.fromColor.r), @floatFromInt(self.toColor.r));
            const g = basis.math.remapFloat(self.fadeTimeElapsed, 0.0, self.eventData.duration, @floatFromInt(self.fromColor.g), @floatFromInt(self.toColor.g));
            const b = basis.math.remapFloat(self.fadeTimeElapsed, 0.0, self.eventData.duration, @floatFromInt(self.fromColor.b), @floatFromInt(self.toColor.b));
            const a = basis.math.remapFloat(self.fadeTimeElapsed, 0.0, self.eventData.duration, @floatFromInt(self.fromColor.a), @floatFromInt(self.toColor.a));

            basis.renderer.screen_fade.setColor(basis.Color.initRGBA(@intFromFloat(r), @intFromFloat(g), @intFromFloat(b), @intFromFloat(a)));
        }
    }
};
