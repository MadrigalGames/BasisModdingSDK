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

// A "no-op" event for timelines. Can be used, eg. to artificially
// extend the duration of a timeline instance.
pub const TimelineNoopEvent = struct {
    const Self = @This();

    //----------------------------------------------------

    allocator: Allocator,
    eventData: ghl.TimelineEventData,

    //----------------------------------------------------

    pub fn init(
        allocator: Allocator,
        startTime: f32,
        duration: f32,
        onClient: bool,
    ) !ghl.TimelineEventInterface {
        const evt = try allocator.create(Self);
        evt.* = Self{
            .allocator = allocator,
            .eventData = ghl.TimelineEventData.init(startTime, duration, onClient),
        };

        const typeNameHash = comptime basis.typeinfo.getNameHashFromType(Self);

        return ghl.TimelineEventInterface.make(Self, evt, typeNameHash);
    }

    pub fn destroy(self: *Self) void {
        self.allocator.destroy(self);
    }
};
