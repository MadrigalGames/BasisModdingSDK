// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const TimelineEventInterface = struct {
    const Self = @This();

    const VirtualTable = struct {
        // These can be implemented by the event struct, if needed.
        enter: *const fn (*Self, bool) void,
        exit: *const fn (*Self, bool) void,
        tick: *const fn (*Self, f32) void,

        // These are forwarded to the "eventData" member of the
        // event struct. No functions need to be added to the struct.
        getStartTime: *const fn (*const Self) f32,
        getDuration: *const fn (*const Self) f32,
        isInstantaneous: *const fn (*const Self) bool,

        // This must be implemented by the event struct, and should
        // destroy it, deallocating the memory as well.
        destroy: *const fn (*Self) void,
    };

    //----------------------------------------------------

    object: basis.IntPtr = 0,
    typeNameHash: u32 = 0,
    vTable: *const VirtualTable = undefined,

    //----------------------------------------------------

    pub fn enter(self: *Self, skippingTimeline: bool) void {
        self.vTable.enter(self, skippingTimeline);
    }

    pub fn exit(self: *Self, skippingTimeline: bool) void {
        self.vTable.exit(self, skippingTimeline);
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) void {
        self.vTable.tick(self, tickDeltaTime);
    }

    pub fn getStartTime(self: *const Self) f32 {
        return self.vTable.getStartTime(self);
    }

    pub fn getDuration(self: *const Self) f32 {
        return self.vTable.getDuration(self);
    }

    pub fn isInstantaneous(self: *const Self) bool {
        return self.vTable.isInstantaneous(self);
    }

    pub fn destroy(self: *Self) void {
        self.vTable.destroy(self);
    }

    //----------------------------------------------------

    pub fn getTyped(self: *Self, comptime T: type) *T {
        return @as(*T, @ptrFromInt(self.object));
    }

    pub fn getConstTyped(self: *const Self, comptime T: type) *const T {
        return @as(*T, @ptrFromInt(self.object));
    }

    pub fn make(comptime T: type, eventPtr: *T, typeNameHash: u32) Self {
        var self = Self{
            .object = @intFromPtr(eventPtr),
            .vTable = undefined,
            .typeNameHash = typeNameHash,
        };
        self.setupVTable(T);
        return self;
    }

    pub fn setupVTable(_self: *Self, comptime T: type) void {
        _self.vTable = &.{
            .enter = struct {
                fn _c(self: *Self, skippingTimeline: bool) void {
                    if (@hasDecl(T, "enter")) {
                        self.getTyped(T).enter(skippingTimeline) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in TL event enter(): {s}", .{@errorName(err)});
                        };
                    }
                }
            }._c,
            .exit = struct {
                fn _c(self: *Self, skippingTimeline: bool) void {
                    if (@hasDecl(T, "exit")) {
                        self.getTyped(T).exit(skippingTimeline) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in TL event exit(): {s}", .{@errorName(err)});
                        };
                    }
                }
            }._c,
            .tick = struct {
                fn _c(self: *Self, tickDeltaTime: f32) void {
                    if (@hasDecl(T, "tick")) {
                        self.getTyped(T).tick(tickDeltaTime) catch |err| {
                            basis.fatalErrorWithFormat(@src(), "Error in TL event tick(): {s}", .{@errorName(err)});
                        };
                    }
                }
            }._c,

            // These function directly access the "eventData" member
            // of the event implementation struct so that it doesn't
            // have to have methods just for this.
            .getStartTime = struct {
                fn _c(self: *const Self) f32 {
                    return self.getConstTyped(T).eventData.startTime;
                }
            }._c,
            .getDuration = struct {
                fn _c(self: *const Self) f32 {
                    return self.getConstTyped(T).eventData.duration;
                }
            }._c,
            .isInstantaneous = struct {
                fn _c(self: *const Self) bool {
                    return self.getConstTyped(T).eventData.duration < 0.0;
                }
            }._c,

            .destroy = struct {
                fn _c(self: *Self) void {
                    self.getTyped(T).destroy();
                }
            }._c,
        };
    }
};

// All structs implementing the timeline event interface
// should have one of these as a member named "eventData".
pub const TimelineEventData = struct {
    startTime: f32,
    duration: f32,
    onClient: bool,

    pub fn init(startTime: f32, duration: f32, onClient: bool) TimelineEventData {
        return TimelineEventData{
            .startTime = startTime,
            .duration = duration,
            .onClient = onClient,
        };
    }
};
