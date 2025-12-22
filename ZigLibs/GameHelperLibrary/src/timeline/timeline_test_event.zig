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

pub const TimelineTestEvent = struct {
    const Self = @This();

    //----------------------------------------------------

    allocator: Allocator,
    eventData: ghl.TimelineEventData,

    //----------------------------------------------------

    pub fn init(allocator: Allocator, startTime: f32, duration: f32, onClient: bool) !ghl.TimelineEventInterface {
        const evt = try allocator.create(Self);
        evt.* = Self{
            .allocator = allocator,
            .eventData = ghl.TimelineEventData.init(startTime, duration, onClient),
        };

        return ghl.TimelineEventInterface.make(Self, evt);
    }

    pub fn destroy(self: *Self) void {
        basis.print("Destroying test event\n");
        self.allocator.destroy(self);
    }

    //----------------------------------------------------

    pub fn enter(self: *Self, skippingTimeline: bool) !void {
        _ = skippingTimeline; // autofix
        basis.printf("Entering test event, start time: {d:.2}\n", .{self.eventData.startTime});
    }

    pub fn exit(self: *Self, skippingTimeline: bool) !void {
        _ = skippingTimeline; // autofix
        basis.printf("Exiting test event, duration: {d:.2}\n", .{self.eventData.duration});
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) !void {
        _ = tickDeltaTime;
        _ = self;
        basis.print("Ticking test event\n");
    }
};
