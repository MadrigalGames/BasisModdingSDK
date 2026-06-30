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

// An event type which executes a callback without any parameters.
pub const TimelineCallbackEvent = struct {
    const Self = @This();

    pub const EventCallback = basis.delegate.VoidDelegate0();

    //----------------------------------------------------

    allocator: Allocator,
    eventData: ghl.TimelineEventData,
    callback: ?EventCallback,

    //----------------------------------------------------

    pub fn init(
        allocator: Allocator,
        time: f32,
        onClient: bool,
        callback: ?EventCallback,
    ) !ghl.TimelineEventInterface {
        const evt = try allocator.create(Self);
        evt.* = Self{
            .allocator = allocator,
            .eventData = ghl.TimelineEventData.init(time, -1.0, onClient),
            .callback = callback,
        };

        const typeNameHash = comptime basis.typeinfo.getNameHashFromType(Self);

        return ghl.TimelineEventInterface.make(Self, evt, typeNameHash);
    }

    pub fn destroy(self: *Self) void {
        self.allocator.destroy(self);
    }

    //----------------------------------------------------

    pub fn enter(self: *Self, skippingTimeline: bool) !void {
        _ = skippingTimeline;
        if (self.callback) |cb| {
            cb.call();
        }
    }

    // pub fn exit(self: *Self, skippingTimeline: bool) !void {
    //     _ = self;
    // }

    // pub fn tick(self: *Self, tickDeltaTime: f32) !void {
    //     _ = tickDeltaTime;
    //     _ = self;
    // }
};

//----------------------------------------------------

// An event type which executes a callback with a data parameter.
pub fn TimelineCallbackWithDataEvent(comptime Data: type) type {
    return struct {
        const Self = @This();

        pub const EventCallback = basis.delegate.VoidDelegate1(*const Data);

        //----------------------------------------------------

        allocator: Allocator,
        eventData: ghl.TimelineEventData,
        callback: ?EventCallback,
        data: Data,

        //----------------------------------------------------

        pub fn init(
            allocator: Allocator,
            time: f32,
            onClient: bool,
            callback: ?EventCallback,
            data: Data,
        ) !ghl.TimelineEventInterface {
            const evt = try allocator.create(Self);
            evt.* = Self{
                .allocator = allocator,
                .eventData = ghl.TimelineEventData.init(time, -1.0, onClient),
                .callback = callback,
                .data = data,
            };

            const typeNameHash = comptime basis.typeinfo.getNameHashFromType(Self);

            return ghl.TimelineEventInterface.make(Self, evt, typeNameHash);
        }

        pub fn destroy(self: *Self) void {
            // Commented this out as it won't compile for primitive types such as 'usize'.
            // This can be probably be fixed by checking if the data member is a struct
            // and only doing the hasDecl() if it is...
            // if (@hasDecl(Data, "deinit")) {
            //     self.data.deinit();
            // }
            self.allocator.destroy(self);
        }

        //----------------------------------------------------

        pub fn enter(self: *Self, skippingTimeline: bool) !void {
            _ = skippingTimeline;
            if (self.callback) |cb| {
                cb.call(&self.data);
            }
        }

        // pub fn exit(self: *Self) !void {
        //     _ = self;
        // }

        // pub fn tick(self: *Self, tickDeltaTime: f32) !void {
        //     _ = tickDeltaTime;
        //     _ = self;
        // }
    };
}
