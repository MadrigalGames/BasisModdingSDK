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

const TimelineEventInterface = ghl.TimelineEventInterface;

const TIMELINE_DEBUG_OUTPUT = false;

pub const Timeline = struct {
    const Self = @This();

    /// Param: skipped to end (true/false).
    pub const PlaybackFinishedCallback = basis.delegate.VoidDelegate1(bool);

    /// Param: event index.
    pub const EventCallback = basis.delegate.VoidDelegate2(u32, bool);

    pub const State = enum(u32) {
        Setup = 0,
        Stopped,
        Paused,
        Playing,
        PlayedToTheEnd,
    };

    pub const EventState = enum(u32) {
        NotYetProcessed = 0,
        Active,
        Processed,
    };

    const EventData = struct {
        startTime: f32,
        endTime: f32, // -1 if the event is instantaneous.
        state: EventState,
        interface: TimelineEventInterface,
    };

    // Stuff to make it easier to create networked timelines.
    pub const NetworkHelper = struct {
        enterEventCB: ?EventCallback = null,
        exitEventCB: ?EventCallback = null,
    };

    //----------------------------------------------------

    allocator: Allocator,
    state: State = .Setup,
    events: basis.ArrayList(EventData),
    currentTime: f32 = 0.0,
    totalTime: f32 = 0.0,
    playbackFinishedCallback: ?PlaybackFinishedCallback = null,
    networkHelper: NetworkHelper = .{},

    //----------------------------------------------------

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
            .events = basis.ArrayList(EventData).init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.clearEvents();
        self.events.deinit();
    }

    //----------------------------------------------------
    // Playback:

    pub fn play(self: *Self) void {
        basis.assertd(@src(), self.state != .Setup, "Cannot play timeline. finalizeSetup() has not been called.");

        if (self.state == .Stopped or self.state == .PlayedToTheEnd) {
            self.currentTime = 0.0;

            if (TIMELINE_DEBUG_OUTPUT) {
                basis.printf("TIMELINE: Playing\n", .{});
            }
        }

        self.state = .Playing;
    }

    pub fn pause(self: *Self) void {
        basis.assertd(@src(), self.state != .Setup, "Cannot pause timeline. finalizeSetup() has not been called.");

        self.state = .Paused;
    }

    pub fn stop(self: *Self) void {
        basis.assertd(@src(), self.state != .Setup, "Cannot stop timeline. finalizeSetup() has not been called.");

        if (self.state != .Stopped) {
            self.currentTime = 0.0;

            for (self.events.items, 0..) |*e, i| {
                if (e.state == .Active) {
                    self._exitEvent(@intCast(i), false);
                }

                e.state = .NotYetProcessed;
            }

            if (TIMELINE_DEBUG_OUTPUT) {
                basis.printf("TIMELINE: Stopped\n", .{});
            }
        }

        self.state = .Stopped;
    }

    pub fn skip(self: *Self) void {
        basis.assertd(@src(), self.state != .Setup, "Cannot skip timeline. finalizeSetup() has not been called.");

        if (self.state == .Playing) {
            const fromTime = self.currentTime;
            const playingToTheEnd = true;

            self.advanceTime(fromTime, self.totalTime, playingToTheEnd, true);

            self.state = .PlayedToTheEnd;

            if (TIMELINE_DEBUG_OUTPUT) {
                basis.printf("TIMELINE: Skipped\n", .{});
            }

            if (self.playbackFinishedCallback) |cb| {
                cb.call(true);
            }
        }
    }

    //----------------------------------------------------
    // Setup and teardown:

    // Call this to add an event. Returns the total time (length) of the timeline with all events added so far.
    pub fn addEvent(self: *Self, evt: TimelineEventInterface) !f32 {
        basis.assertd(
            @src(),
            self.state == .Setup,
            "Cannot add event since finalizeSetup() has been called for this timeline. Add all events before calling finalizeSetup().",
        );

        const evtData = EventData{
            .startTime = evt.getStartTime(),
            .endTime = if (evt.isInstantaneous()) -1.0 else evt.getStartTime() + evt.getDuration(),
            .state = .NotYetProcessed,
            .interface = evt,
        };

        try self.events.append(evtData);

        return self.getTotalTimeSoFar();
    }

    // Call this when all events have been added.
    pub fn finalizeSetup(self: *Self) void {
        basis.assert(@src(), self.state == .Setup);

        // Sort the events based on their start and end time on the timeline.
        std.mem.sort(EventData, self.events.items, {}, compareEventDatasForSorting);

        self.totalTime = 0.0;
        for (self.events.items) |e| {
            const endTime = if (e.endTime < 0.0) e.startTime else e.endTime;
            self.totalTime = @max(endTime, self.totalTime);
        }

        self.state = .Stopped;
    }

    pub fn clearEvents(self: *Self) void {
        for (self.events.items) |*e| {
            e.interface.destroy();
        }
        self.events.clearAndFree();
        self.totalTime = 0.0;
        self.state = .Setup;
    }

    pub fn beforeHotReload(self: *Self) void {
        _ = self; // autofix
        // TODO: Add beforeHotReload() to the event interface type and call it here on all event interfaces.
    }

    pub fn afterHotReload(self: *Self, comptime SupportedEventTypes: []const type) void {
        self.fixupActionVTables(SupportedEventTypes);

        // TODO: Add afterHotReload() to the event interface type and call it here on all event interfaces.
    }

    //----------------------------------------------------

    /// Call this to update the timeline. Set drivePlayback to true if you want
    /// to update the playhead position of the timeline. With drivePlayback set
    /// to false, the timeline playback isn't updated but the active events are
    /// ticked. This is useful, eg., with networked timelines where the server
    /// is driving the playback (drivePlayback = true), but the client should
    /// still tick the currently active events (drivePlayback = false).
    pub fn tick(self: *Self, tickDeltaTime: f32, drivePlayback: bool) void {
        if (self.state == .Setup) return;

        if (drivePlayback and self.state == .Playing) {
            const fromTime = self.currentTime;
            var playingToTheEnd: bool = false;

            self.currentTime += tickDeltaTime;

            if (self.currentTime >= self.totalTime) {
                self.currentTime = self.totalTime;
                playingToTheEnd = true;
            }

            self.advanceTime(fromTime, self.currentTime, playingToTheEnd, false);

            if (playingToTheEnd) {
                self.state = .PlayedToTheEnd;

                for (self.events.items) |*e| {
                    e.state = .NotYetProcessed;
                }

                if (TIMELINE_DEBUG_OUTPUT) {
                    basis.printf("TIMELINE: Finished\n", .{});
                }

                if (self.playbackFinishedCallback) |cb| {
                    cb.call(false);
                }
            }
        }

        self.tickActiveEvents(tickDeltaTime);
    }

    //----------------------------------------------------

    pub fn _enterEvent(self: *Self, eventIndex: u32, skippingTimeline: bool) void {
        var evt: *EventData = &self.events.items[@intCast(eventIndex)];

        if (TIMELINE_DEBUG_OUTPUT) {
            basis.printf("TIMELINE: Event {} entered\n", .{eventIndex});
        }

        evt.state = .Active;
        evt.interface.enter(skippingTimeline);

        if (self.networkHelper.enterEventCB) |cb| {
            cb.call(eventIndex, skippingTimeline);
        }
    }

    pub fn _exitEvent(self: *Self, eventIndex: u32, skippingTimeline: bool) void {
        var evt: *EventData = &self.events.items[@intCast(eventIndex)];

        if (TIMELINE_DEBUG_OUTPUT) {
            basis.printf("TIMELINE: Event {} exited\n", .{eventIndex});
        }

        evt.state = .Processed;
        evt.interface.exit(skippingTimeline);

        if (self.networkHelper.exitEventCB) |cb| {
            cb.call(eventIndex, skippingTimeline);
        }
    }

    //----------------------------------------------------

    fn fixupActionVTables(self: *Self, comptime SupportedEventTypes: []const type) void {
        for (self.events.items) |*e| {
            inline for (SupportedEventTypes) |T| {
                if (e.interface.typeNameHash == T.NameHash) {
                    e.interface.setupVTable(T.Type);
                }
            }
        }
    }

    fn compareEventDatasForSorting(context: void, a: EventData, b: EventData) bool {
        _ = context;

        const endTimeA = if (a.endTime < 0.0) a.startTime else a.endTime;
        const endTimeB = if (b.endTime < 0.0) b.startTime else b.endTime;

        // Sort on start time, then on end time.

        if (a.startTime == b.startTime) {
            return endTimeA < endTimeB;
        }

        return a.startTime < b.startTime;
    }

    fn advanceTime(self: *Self, fromTime: f32, toTime: f32, playingToTheEnd: bool, skippingTimeline: bool) void {
        _ = fromTime;

        for (self.events.items, 0..) |*e, i| {
            if (e.state == .Processed) {
                continue;
            }

            const instantaneous = e.endTime < 0.0;
            const endTime = if (instantaneous) e.startTime else e.endTime;

            if (toTime >= e.startTime and e.state == .NotYetProcessed) {
                self._enterEvent(@intCast(i), skippingTimeline);
            }

            if (e.state == .Active and (instantaneous or toTime >= endTime or playingToTheEnd)) {
                self._exitEvent(@intCast(i), skippingTimeline);
            }
        }
    }

    fn tickActiveEvents(self: *Self, tickDeltaTime: f32) void {
        for (self.events.items) |*e| {
            if (e.state == .Active) {
                e.interface.tick(tickDeltaTime);
            }
        }
    }

    // Can be called during setup to get the total-time of the TL with all the events added so far.
    fn getTotalTimeSoFar(self: *const Self) f32 {
        var totalTime: f32 = 0.0;
        for (self.events.items) |e| {
            const endTime = if (e.endTime < 0.0) e.startTime else e.endTime;
            totalTime = @max(endTime, totalTime);
        }
        return totalTime;
    }
};
