// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const nemo = @import("nemo.zig");

pub const DatabasePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,
    ownsMemory: bool,

    //----------------------------------------------------

    pub fn initNew() Self {
        return Self{
            .cppPtr = nemo.bindings.api.Database_newDatabase(),
            .ownsMemory = true,
        };
    }

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .ownsMemory = false,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.ownsMemory) {
            nemo.bindings.api.Database_deleteDatabase(self.cppPtr);
        }

        self.cppPtr = 0;
        self.ownsMemory = false;
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    pub fn loadOnClient(self: *const Self, client: basis.host.ClientPtr, fileResourcePath: []const u8) void {
        const interopPath = basis.string.toInteropString(fileResourcePath);
        nemo.bindings.api.Database_loadOnClient(self.cppPtr, client.cppPtr, &interopPath);
    }

    pub fn loadOnServer(self: *const Self, server: basis.host.ServerPtr, fileResourcePath: []const u8) void {
        const interopPath = basis.string.toInteropString(fileResourcePath);
        nemo.bindings.api.Database_loadOnServer(self.cppPtr, server.cppPtr, &interopPath);
    }

    pub fn unload(self: *const Self) void {
        nemo.bindings.api.Database_unload(self.cppPtr);
    }

    pub fn tick(self: *const Self, tickDeltaTime: f32, flags: nemo.DatabaseTickFlags) void {
        nemo.bindings.api.Database_tick(self.cppPtr, tickDeltaTime, @intFromEnum(flags));
    }

    pub fn setLanguageCode(self: *const Self, languageCode: []const u8) void {
        const interopCode = basis.string.toInteropString(languageCode);
        nemo.bindings.api.Database_setLanguageCode(self.cppPtr, &interopCode);
    }

    pub fn getLanguageCode(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.Database_getLanguageCode(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn setVoiceLanguageCode(self: *const Self, voiceLanguageCode: []const u8) void {
        const interopCode = basis.string.toInteropString(voiceLanguageCode);
        nemo.bindings.api.Database_setVoiceLanguageCode(self.cppPtr, &interopCode);
    }

    pub fn getVoiceLanguageCode(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        nemo.bindings.api.Database_getVoiceLanguageCode(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }

    pub fn setVoiceClipDurationCallback(self: *const Self, callback: basis.bindings.FP_f32_u32) void {
        nemo.bindings.api.Database_setVoiceClipDurationCallback(self.cppPtr, callback);
    }

    pub fn serialize(self: *const Self, stream: *basis.BinaryWriteStream) void {
        const bufferFreeLength: u32 = @intCast(stream.buffer.len - stream.cursorPosition);
        const ptr: [*c]u8 = &stream.buffer[0];

        const bytesWritten = nemo.bindings.api.Database_serialize(self.cppPtr, ptr, bufferFreeLength);

        stream.cursorPosition += bytesWritten;
    }

    pub fn deserialize(self: *Self, stream: *basis.BinaryReadStream) void {
        const bufferFreeLength: u32 = @intCast(stream.buffer.len - stream.cursorPosition);
        const ptr: [*c]const u8 = &stream.buffer[0];

        const bytesRead = nemo.bindings.api.Database_deserialize(self.cppPtr, ptr, bufferFreeLength);

        stream.cursorPosition += bytesRead;
    }

    //----------------------------------------------------

    pub fn getMissionByPath(self: *const Self, path: []const u8) nemo.MissionPtr {
        const interopPath = basis.string.toInteropString(path);
        const missionCppPtr = nemo.bindings.api.Database_getMissionByPath(self.cppPtr, &interopPath);

        return nemo.MissionPtr{ .cppPtr = missionCppPtr };
    }

    pub fn getMissionByPathHash(self: *const Self, pathHash: basis.StringHash) nemo.MissionPtr {
        const missionCppPtr = nemo.bindings.api.Database_getMissionByPathHash(self.cppPtr, pathHash);

        return nemo.MissionPtr{ .cppPtr = missionCppPtr };
    }

    pub fn getGlobalVariableSetByPath(self: *const Self, path: []const u8) nemo.GlobalVariableSetPtr {
        const interopPath = basis.string.toInteropString(path);
        const missionCppPtr = nemo.bindings.api.Database_getGlobalVariableSetByPath(self.cppPtr, &interopPath);

        return nemo.GlobalVariableSetPtr{ .cppPtr = missionCppPtr };
    }

    pub fn getGlobalVariableSetByPathHash(self: *const Self, pathHash: basis.StringHash) nemo.GlobalVariableSetPtr {
        const missionCppPtr = nemo.bindings.api.Database_getGlobalVariableSetByPathHash(self.cppPtr, pathHash);

        return nemo.GlobalVariableSetPtr{ .cppPtr = missionCppPtr };
    }

    pub fn getCharacterDataByPath(self: *const Self, path: []const u8) nemo.CharacterDataPtr {
        const interopPath = basis.string.toInteropString(path);
        const characterCppPtr = nemo.bindings.api.Database_getCharacterDataByPath(self.cppPtr, &interopPath);

        return nemo.CharacterDataPtr{ .cppPtr = characterCppPtr };
    }

    pub fn getCharacterDataByPathHash(self: *const Self, pathHash: basis.StringHash) nemo.CharacterDataPtr {
        const characterCppPtr = nemo.bindings.api.Database_getCharacterDataByPathHash(self.cppPtr, pathHash);

        return nemo.CharacterDataPtr{ .cppPtr = characterCppPtr };
    }

    pub fn getConversationByPath(self: *const Self, path: []const u8) nemo.ConversationPtr {
        const interopPath = basis.string.toInteropString(path);
        const conversationCppPtr = nemo.bindings.api.Database_getConversationByPath(self.cppPtr, &interopPath);

        return nemo.ConversationPtr{ .cppPtr = conversationCppPtr };
    }

    pub fn getConversationByPathHash(self: *const Self, pathHash: basis.StringHash) nemo.ConversationPtr {
        const conversationCppPtr = nemo.bindings.api.Database_getConversationByPathHash(self.cppPtr, pathHash);

        return nemo.ConversationPtr{ .cppPtr = conversationCppPtr };
    }

    //----------------------------------------------------

    pub fn generateScriptApi(self: *const Self) void {
        nemo.bindings.api.Database_generateScriptApi(self.cppPtr);
    }

    pub fn getScriptPreface(self: *const Self, outBuffer: *basis.bindings.InteropBuffer) void {
        nemo.bindings.api.Database_getScriptPreface(self.cppPtr, outBuffer);
    }

    pub fn appendAutoCompleteList(self: *const Self, vectorPtr: basis.IntPtr) void {
        nemo.bindings.api.Database_appendAutoCompleteList(self.cppPtr, @intCast(vectorPtr));
    }
};
