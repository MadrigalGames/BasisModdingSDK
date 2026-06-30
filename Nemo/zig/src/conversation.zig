// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const nemo = @import("nemo.zig");

pub const ConversationPtr = struct {
    const Self = @This();
    pub const Null = initNull();

    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    pub fn getPath(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.Conversation_getPath(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn getState(self: *const Self) nemo.ConversationState {
        const stateInt = nemo.bindings.api.Conversation_getState(self.cppPtr);
        return @enumFromInt(stateInt);
    }

    pub fn start(self: *const Self) void {
        nemo.bindings.api.Conversation_start(self.cppPtr);
    }

    pub fn end(self: *const Self) void {
        nemo.bindings.api.Conversation_end(self.cppPtr);
    }

    pub const ItemType = enum(u32) {
        Line = 0,
        Response = 1,
        CustomSystemCommand = 2,
        Delay = 3,
    };

    /// A line spoken by an NPC, or a single response option for the player.
    pub const Line = struct {
        characterPathHash: basis.StringHash,
        text: []const u8,
        mood: nemo.DialogueMood,

        // Voice fields. voiceTemplateIndex == -1 means the line is a TG line,
        // in which case the audio paths are empty.
        voiceTemplateIndex: i32,
        audioClipPath: []const u8,
        audioEventPath: []const u8,
        duration: f32,

        // TG fields (used when voiceTemplateIndex == -1).
        charsPerSecond: f32,
        flags: u32,
    };

    /// One unit of conversation flow, produced by advance().
    /// type == .Line:                a single line spoken by an NPC.
    /// type == .Response:            the set of response options the player can pick from.
    /// type == .CustomSystemCommand: a game-specific command (verb + optional text payload).
    pub const Item = struct {
        type: ItemType,
        lines: basis.BoundedArray(Line, 8),
        verb: []const u8 = "",
        text: []const u8 = "",
        delayDuration: f32 = 0,
    };

    /// Advances the runner to the next item.
    /// Returns null if the runner has no more content (the conversation self-ends in that case).
    /// Slices in the returned Item point into the caller-provided scratchBuffer and are
    /// valid only until the buffer is reused (typically: the next advance call).
    pub fn advance(self: *const Self, scratchBuffer: []u8) ?Item {
        const bytesWritten = nemo.bindings.api.Conversation_advance(
            self.cppPtr,
            scratchBuffer.ptr,
            @intCast(scratchBuffer.len),
        );
        if (bytesWritten == 0) return null;

        var stream = basis.BinaryReadStream.init(scratchBuffer[0..@intCast(bytesWritten)], true);

        var item = Item{
            .type = @enumFromInt(stream.getInt(u32)),
            .lines = .{},
        };

        const lineCount = stream.getInt(u32);
        var i: u32 = 0;
        while (i < lineCount) : (i += 1) {
            var line: Line = undefined;
            line.characterPathHash = stream.getInt(u32);
            line.text = stream.getStringSlice();
            line.mood = @enumFromInt(stream.getInt(u32));
            line.voiceTemplateIndex = stream.getInt(i32);
            line.audioClipPath = stream.getStringSlice();
            line.audioEventPath = stream.getStringSlice();
            line.duration = stream.getFloat();
            line.charsPerSecond = stream.getFloat();
            line.flags = stream.getInt(u32);
            item.lines.appendAssumeCapacity(line);
        }

        if (item.type == .CustomSystemCommand) {
            item.verb = stream.getStringSlice();
            item.text = stream.getStringSlice();
        }
        if (item.type == .Delay) {
            item.delayDuration = stream.getFloat();
        }

        return item;
    }

    /// Picks one of the options from the current Response item. Caller is
    /// expected to follow up with advance() to fetch the next item.
    pub fn selectResponse(self: *const Self, index: u32) void {
        nemo.bindings.api.Conversation_selectResponse(self.cppPtr, index);
    }

    pub fn getInkInt(self: *const Self, name: []const u8) i32 {
        const interopName = basis.string.toInteropString(name);
        return nemo.bindings.api.Conversation_getInkInt(self.cppPtr, &interopName);
    }

    pub fn setInkInt(self: *const Self, name: []const u8, value: i32) void {
        const interopName = basis.string.toInteropString(name);
        nemo.bindings.api.Conversation_setInkInt(self.cppPtr, &interopName, value);
    }

    pub fn getInkFloat(self: *const Self, name: []const u8) f32 {
        const interopName = basis.string.toInteropString(name);
        return nemo.bindings.api.Conversation_getInkFloat(self.cppPtr, &interopName);
    }

    pub fn setInkFloat(self: *const Self, name: []const u8, value: f32) void {
        const interopName = basis.string.toInteropString(name);
        nemo.bindings.api.Conversation_setInkFloat(self.cppPtr, &interopName, value);
    }

    pub fn getInkBool(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return if (nemo.bindings.api.Conversation_getInkBool(self.cppPtr, &interopName) == 1) true else false;
    }

    pub fn setInkBool(self: *const Self, name: []const u8, value: bool) void {
        const interopName = basis.string.toInteropString(name);
        nemo.bindings.api.Conversation_setInkBool(self.cppPtr, &interopName, value);
    }

    pub fn getInkString(self: *const Self, name: []const u8) []const u8 {
        const interopName = basis.string.toInteropString(name);
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.Conversation_getInkString(self.cppPtr, &interopName, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn setInkString(self: *const Self, name: []const u8, value: []const u8) void {
        const interopName = basis.string.toInteropString(name);
        const interopValue = basis.string.toInteropString(value);
        nemo.bindings.api.Conversation_setInkString(self.cppPtr, &interopName, &interopValue);
    }
};
