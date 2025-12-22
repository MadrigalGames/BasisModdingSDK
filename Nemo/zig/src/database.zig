// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
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

    pub fn tick(self: *const Self, tickDeltaTime: f32) void {
        nemo.bindings.api.Database_tick(self.cppPtr, tickDeltaTime);
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
};
