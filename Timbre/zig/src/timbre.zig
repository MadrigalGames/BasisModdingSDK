// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");

pub const bindings = @import("bindings.zig");
pub const sound_manager = @import("sound_manager.zig");
pub const event_description = @import("event_description.zig");
pub const event_instance = @import("event_instance.zig");
pub const group_bus = @import("group_bus.zig");
pub const components = @import("components/components.zig");

// Enums:

pub const PlaybackState = enum(u32) {
    Stopped = 0,
    Playing,
    Paused,
    Finished,
};

// Types:

pub const EventDescriptionPtr = event_description.EventDescriptionPtr;
pub const EventInstancePtr = event_instance.EventInstancePtr;
pub const GroupBusPtr = group_bus.GroupBusPtr;

// Misc:

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = bindings.generated_bind_functions;
}

pub fn forceAnalysis() void {
    const modules = .{
        bindings,
        sound_manager,
        event_description,
        event_instance,
        group_bus,
        components,
    };

    inline for (modules) |module| {
        std.testing.refAllDeclsRecursive(module);
    }
}
