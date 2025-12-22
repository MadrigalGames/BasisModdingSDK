// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const timbre = @import("timbre");
const ghl = @import("../ghl.zig");

const Allocator = std.mem.Allocator;

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

const Timeline = ghl.Timeline;

const PropagatedValue = basis.network.PropagatedValue;
const PropagatedValueHandle = basis.network.PropagatedValueHandle;
const PropagatedAction = basis.network.PropagatedAction;
const PropagatedActionHandle = basis.network.PropagatedActionHandle;

const AngelScriptFunctionPtr = basis.angelscript.AngelScriptFunctionPtr;

pub const TimelineComponentBase = struct {
    const Self = @This();

    //----------------------------------------------------

    context: GameObjectComponent,
    timeline: Timeline,

    // Here we use PVs as propagated function calls with a single parameter.
    eventEnteredValue: PropagatedValueHandle(u32),
    eventExitedValue: PropagatedValueHandle(u32),

    playAction: PropagatedActionHandle,
    stopAction: PropagatedActionHandle,
    timelineFinishedAction: PropagatedActionHandle,

    enableCinematicInput: bool = false,

    onTimelineFinishedScriptFunction: AngelScriptFunctionPtr = AngelScriptFunctionPtr.Null,

    // Managed sounds are "owned" by the timeline component. The idea is that these sounds can exist outside
    // the events that create them, and even keep playing after the TL has ended. If the sounds are to continue
    // after the TL has ended, or be released in some specifc way (eg. by fading) then some sort of cleanup node
    // needs to be added to the TL. That node needs to release the sounds in some specific way, and clear the
    // managedSounds list. If the are still sound in the list, when the TL ends, it releases the sounds itself.
    managedSounds: basis.ArrayList(timbre.EventInstancePtr),

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) Self {
        return Self{
            .context = context,
            .timeline = Timeline.init(context.allocator),

            .eventEnteredValue = PropagatedValue(u32).init(context, "EventEnteredValue", true, true, 0),
            .eventExitedValue = PropagatedValue(u32).init(context, "EventExitedValue", true, true, 0),

            .playAction = PropagatedAction.init(context, "PlayAction", true, true),
            .stopAction = PropagatedAction.init(context, "StopAction", true, true),
            .timelineFinishedAction = PropagatedAction.init(context, "TimelineFinishedAction", true, true),

            .managedSounds = basis.ArrayList(timbre.EventInstancePtr).init(context.allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        self.releaseManagedSounds();
        self.managedSounds.deinit();

        self.timeline.deinit();

        self.eventEnteredValue.deinit();
        self.eventExitedValue.deinit();
        self.playAction.deinit();
        self.stopAction.deinit();
        self.timelineFinishedAction.deinit();
    }

    pub fn finalizeTimelineSetup(self: *Self, enableCinematicInput: bool) void {
        self.enableCinematicInput = enableCinematicInput;

        self.eventEnteredValue.setValueChangedCallback(.initMethod(self, Self, onEventEnteredValue));
        self.eventExitedValue.setValueChangedCallback(.initMethod(self, Self, onEventExitedValue));

        self.playAction.setActionFiredCallback(.initMethod(self, Self, onPlayActionFired));
        self.stopAction.setActionFiredCallback(.initMethod(self, Self, onStopActionFired));
        self.timelineFinishedAction.setActionFiredCallback(.initMethod(self, Self, onTimelineFinishedActionFired));

        if (!self.context.inEditor()) {
            self.timeline.finalizeSetup();

            // if (mModule.isLoaded())
            // {
            //     asIScriptModule* scriptModule = mModule.getScriptModule();
            //     mOnTimelineFinishedFunction.init(scriptModule, ON_TIMELINE_FINISHED_DECL);
            // }

            if (self.context.onServer()) {
                self.timeline.playbackFinishedCallback = .initMethod(self, Self, onTimelinePlaybackFinished);

                // On the server we hook up the network interface CBs, so that entering/exiting
                // events etc. get picked up and sent to all the clients.
                self.timeline.networkHelper.enterEventCB = .initMethod(self, Self, onEventEnteredOnServer);
                self.timeline.networkHelper.exitEventCB = .initMethod(self, Self, onEventExitedOnServer);
            }
        }
    }

    //----------------------------------------------------

    pub fn tick(self: *Self, tickDeltaTime: f32) void {
        if (!self.context.inEditor()) {
            const drivePlayback = self.context.onServer();
            self.timeline.tick(tickDeltaTime, drivePlayback);
        }
    }

    //----------------------------------------------------

    // Playback:

    pub fn play(self: *Self) void {
        if (self.context.onServer()) {
            self.playAction.fire();
        }
    }

    pub fn stop(self: *Self) void {
        if (self.context.onServer()) {
            self.stopAction.fire();
        }
    }

    pub fn skip(self: *Self) void {
        if (self.context.onServer()) {
            self.timeline.skip();
        }
    }

    //----------------------------------------------------

    fn onTimelinePlaybackFinished(self: *Self, skippedToEnd: bool) void {
        basis.assert(@src(), self.context.onServer());

        self.timelineFinishedAction.fire();

        if (!self.onTimelineFinishedScriptFunction.isNull()) {
            self.onTimelineFinishedScriptFunction.prepareCall();
            self.onTimelineFinishedScriptFunction.setBoolParam(0, skippedToEnd);
            self.onTimelineFinishedScriptFunction.executeCall();
        }
    }

    fn onEventEnteredOnServer(self: *Self, eventIndex: u32, skippedToEnd: bool) void {
        basis.assert(@src(), self.context.onServer());
        const packedData = packEventNetworkData(eventIndex, skippedToEnd);
        self.eventEnteredValue.set(packedData);
    }

    fn onEventExitedOnServer(self: *Self, eventIndex: u32, skippedToEnd: bool) void {
        basis.assert(@src(), self.context.onServer());
        const packedData = packEventNetworkData(eventIndex, skippedToEnd);
        self.eventExitedValue.set(packedData);
    }

    fn onEventEnteredValue(self: *Self, netData: u32, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;

        var eventIndex: u32 = 0;
        var skippingTimeline: bool = false;
        unpackEventNetworkData(netData, &eventIndex, &skippingTimeline);

        if (self.context.onClient()) {
            //basis.printf("Event {} entered on client\n", .{eventIndex});
            self.timeline._enterEvent(@intCast(eventIndex), skippingTimeline);
        }
    }

    fn onEventExitedValue(self: *Self, netData: u32, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;

        var eventIndex: u32 = 0;
        var skippingTimeline: bool = false;
        unpackEventNetworkData(netData, &eventIndex, &skippingTimeline);

        if (self.context.onClient()) {
            //basis.printf("Event {} exited on client\n", .{eventIndex});
            self.timeline._exitEvent(@intCast(eventIndex), skippingTimeline);
        }
    }

    fn onPlayActionFired(self: *Self, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;

        if (self.context.onClient()) {
            if (self.enableCinematicInput) {
                //basis.print("Enabled cinematic input\n");
                basis.input.addGameInputContextToFront(ghl.input.InputContextID.CinematicControls);
            }
        } else {
            self.timeline.play();
        }
    }

    fn onStopActionFired(self: *Self, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;

        if (self.context.onClient()) {
            if (self.enableCinematicInput) {
                //basis.print("Disabled cinematic input\n");
                basis.input.removeGameInputContext(ghl.input.InputContextID.CinematicControls);
            }

            self.releaseManagedSounds();
        } else {
            self.timeline.stop();
        }
    }

    fn onTimelineFinishedActionFired(self: *Self, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;

        if (self.context.onClient()) {
            if (self.enableCinematicInput) {
                //basis.print("Disabled cinematic input\n");
                basis.input.removeGameInputContext(ghl.input.InputContextID.CinematicControls);
            }

            self.releaseManagedSounds();
        }
    }

    fn packEventNetworkData(eventIndex: u32, skippedToEnd: bool) u32 {
        var memory: u32 = 0;
        const bytes = std.mem.asBytes(&memory);

        // Write the event index as a u16 into the first bytes.
        std.mem.writePackedInt(u16, bytes, 0, @intCast(eventIndex), .little);

        // The rest of the u32 can be used for flags and other stuff...
        std.mem.writePackedInt(u1, bytes, 16, @intFromBool(skippedToEnd), .little);

        return memory;
    }

    fn unpackEventNetworkData(netData: u32, eventIndex: *u32, skippedToEnd: *bool) void {
        const bytes = std.mem.asBytes(&netData);

        // Undo the packing done in packEventNetworkData().
        eventIndex.* = @intCast(std.mem.readPackedInt(u16, bytes, 0, .little));
        skippedToEnd.* = std.mem.readPackedInt(u1, bytes, 16, .little) == 1;
    }

    fn releaseManagedSounds(self: *Self) void {
        for (self.managedSounds.items) |evt| {
            evt.release();
        }
        self.managedSounds.clearRetainingCapacity();
    }
};
