// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

pub const bindings = @import("bindings.zig");
pub const database = @import("database.zig");
pub const mission = @import("mission.zig");
pub const conversation = @import("conversation.zig");
pub const global_variable_set = @import("global_variable_set.zig");
pub const character_data = @import("character_data.zig");
pub const dialogue_timing = @import("dialogue_timing.zig");
pub const nemo_script_api = @import("nemo_script_api.zig");

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
    UnknownOnClient, // Pseudo-state: Missions are only executed on the server. On the client their state is unknown.
};

pub const ConversationState = enum(u32) {
    Idle = 0,
    Active = 1,
};

pub const DialogueMood = enum(u32) {
    Neutral = 0,
    Calm,
    Happy,
    Angry,
    Surprised,
};

// Flags:

pub const DialogueLineFlags = struct {
    pub const None: u32 = 0;
    pub const Intro: u32 = 1 << 0;
    pub const Cutoff: u32 = 1 << 1;
};

pub const DatabaseTickFlags = enum(u32) {
    None = 0,
    Missions = 1 << 0,
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
    MissionDinkRealTimeTGDialogueLine,
    MissionDinkRealTimeTGDialogueCancelled,
    MissionDinkRealTimeTGDialogueAcquireLock,
    MissionDinkRealTimeTGDialogueReleaseLock,
    MissionDinkRealTimeVoiceDialogueLine,
    MissionDinkRealTimeVoiceDialogueCancelled,
    MissionDinkRealTimeVoiceDialogueAcquireLock,
    MissionDinkRealTimeVoiceDialogueReleaseLock,

    pub fn asInt(self: Message) i32 {
        return @intFromEnum(self);
    }
};

// Types:

pub const DatabasePtr = database.DatabasePtr;
pub const MissionPtr = mission.MissionPtr;
pub const ConversationPtr = conversation.ConversationPtr;
pub const GlobalVariableSetPtr = global_variable_set.GlobalVariableSetPtr;
pub const CharacterDataPtr = character_data.CharacterDataPtr;
pub const NemoScriptAPI = nemo_script_api.NemoScriptAPI;

// Misc:

pub const NemoDBScriptHandleName = "nemoDB";

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = bindings.generated_bind_functions;
}

pub fn forceAnalysis() void {
    const modules = .{
        bindings,
        database,
        mission,
        conversation,
        global_variable_set,
        character_data,
        dialogue_timing,
        nemo_script_api,
    };

    inline for (modules) |module| {
        std.testing.refAllDecls(module);
    }
}
