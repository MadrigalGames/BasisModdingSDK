// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const bindings = @import("bindings.zig");
pub const database = @import("database.zig");
pub const mission = @import("mission.zig");
pub const global_variable_set = @import("global_variable_set.zig");
pub const character_data = @import("character_data.zig");

// Enums:

/////////////////////////////////////////////////
// Note! Keep the enums in sync with the C++ versions!
/////////////////////////////////////////////////

pub const MissionState = enum(u32) {
    Locked = 0,
    Unlocked,
    Started,
    Completed,
    Failed,
    Aborted,
};

pub const MessageCategory = enum(i32) {
    Missions = basis.messaging.FirstGameMessageCategory + 60,
};

pub const Message = enum(i32) {
    // Mission messages (category: Missions)
    MissionUnlocked = basis.messaging.FirstGameMessage + 600,
    MissionStarted,
    MissionCompleted,
    MissionAborted,
    MissionFailed,
    MissionGuidanceUpdated,
    MissionDialogue,
    MissionMarkerUpdated,
    MissionRequestedTrackedStatus,

    pub fn asInt(self: Message) i32 {
        return @intFromEnum(self);
    }
};

// Types:

pub const DatabasePtr = database.DatabasePtr;
pub const MissionPtr = mission.MissionPtr;
pub const GlobalVariableSetPtr = global_variable_set.GlobalVariableSetPtr;
pub const CharacterDataPtr = character_data.CharacterDataPtr;

// Misc:

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = bindings.generated_bind_functions;
}

pub fn forceAnalysis() void {
    const modules = .{
        bindings,
        database,
        mission,
        global_variable_set,
        character_data,
    };

    inline for (modules) |module| {
        std.testing.refAllDeclsRecursive(module);
    }
}
