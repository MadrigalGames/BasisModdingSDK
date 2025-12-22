// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const ghl = @import("../ghl.zig");

const Allocator = std.mem.Allocator;

pub const TimelineSetScreenColorEvent = struct {
    const Self = @This();

    //----------------------------------------------------

    allocator: Allocator,
    eventData: ghl.TimelineEventData,
    color: basis.Color,
    clearOnExit: bool,

    //----------------------------------------------------

    pub fn init(
        allocator: Allocator,
        startTime: f32,
        duration: f32,
        onClient: bool,
        color: basis.Color,
        clearOnExit: bool,
    ) !ghl.TimelineEventInterface {
        const evt = try allocator.create(Self);
        evt.* = Self{
            .allocator = allocator,
            .eventData = ghl.TimelineEventData.init(startTime, duration, onClient),
            .color = color,
            .clearOnExit = clearOnExit,
        };

        return ghl.TimelineEventInterface.make(Self, evt);
    }

    pub fn destroy(self: *Self) void {
        self.allocator.destroy(self);
    }

    //----------------------------------------------------

    pub fn enter(self: *Self, skippingTimeline: bool) !void {
        _ = skippingTimeline; // autofix
        if (self.eventData.onClient) {
            basis.renderer.screen_fade.setColor(self.color);
        }
    }

    pub fn exit(self: *Self, skippingTimeline: bool) !void {
        _ = skippingTimeline; // autofix
        if (self.eventData.onClient and self.clearOnExit) {
            basis.renderer.screen_fade.clear();
        }
    }

    // pub fn tick(self: *Self, tickDeltaTime: f32) !void {
    //     _ = tickDeltaTime;
    //     _ = self;
    // }
};
