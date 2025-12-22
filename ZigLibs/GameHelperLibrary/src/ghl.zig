// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

//----------------------------------------------------

pub const timeline = @import("timeline/timeline.zig");
pub const timeline_event = @import("timeline/timeline_event.zig");
pub const timeline_component_base = @import("timeline/timeline_component_base.zig");
pub const timeline_test_event = @import("timeline/timeline_test_event.zig");
pub const timeline_callback_event = @import("timeline/timeline_callback_event.zig");
pub const timeline_noop_event = @import("timeline/timeline_noop_event.zig");
pub const timeline_set_screen_color_event = @import("timeline/timeline_set_screen_color_event.zig");
pub const timeline_fade_screen_color_event = @import("timeline/timeline_fade_screen_color_event.zig");
pub const input = @import("input.zig");
pub const logger = @import("logger.zig");
pub const render_object = @import("render_object.zig");
pub const triangle_lines = @import("triangle_lines.zig");

//----------------------------------------------------

pub const Timeline = timeline.Timeline;
pub const TimelineEventData = timeline_event.TimelineEventData;
pub const TimelineEventInterface = timeline_event.TimelineEventInterface;
pub const TimelineComponentBase = timeline_component_base.TimelineComponentBase;
pub const TimelineTestEvent = timeline_test_event.TimelineTestEvent;
pub const TimelineCallbackEvent = timeline_callback_event.TimelineCallbackEvent;
pub const TimelineCallbackWithDataEvent = timeline_callback_event.TimelineCallbackWithDataEvent;
pub const TimelineNoopEvent = timeline_noop_event.TimelineNoopEvent;
pub const TimelineSetScreenColorEvent = timeline_set_screen_color_event.TimelineSetScreenColorEvent;
pub const TimelineFadeScreenColorEvent = timeline_fade_screen_color_event.TimelineFadeScreenColorEvent;
pub const PressedHeldInputHelper = input.PressedHeldInputHelper;

pub const Logger = logger.Logger;

pub const RenderObject = render_object.RenderObject;

//----------------------------------------------------

pub fn forceAnalysis() void {
    const modules = .{
        timeline,
        timeline_event,
        timeline_component_base,
        input,
        logger,
    };

    inline for (modules) |module| {
        std.testing.refAllDeclsRecursive(module);
    }
}
