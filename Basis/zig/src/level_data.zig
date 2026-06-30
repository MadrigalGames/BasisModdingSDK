// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Allocator = std.mem.Allocator;

pub const LevelDataPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    /// Get the pointer to the const level data block manager which is part of the level data.
    /// A writable data block manager is only accessible through the exportLevel() method of
    /// game object components.
    pub fn getDataBlockManager(self: *const Self) LevelDataBlockManagerPtr {
        const cppPtr = basis.bindings.api.LevelData_getDataBlockManager(self.cppPtr);
        return LevelDataBlockManagerPtr{
            .cppPtr = cppPtr,
            .constPtr = true, // Always const.
        };
    }
};

pub const LevelDataBlockManagerPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,
    constPtr: bool,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0, .constPtr = false };
    }

    pub fn getDataBlock(self: *const Self, name: []const u8) LevelDataBlockPtr {
        const interopName = basis.string.toInteropString(name);
        const cppPtr = basis.bindings.api.LevelDataBlockManager_getDataBlock(self.cppPtr, &interopName);
        return LevelDataBlockPtr{
            .cppPtr = cppPtr,
            .constPtr = true,
        };
    }

    pub fn addDataBlock(self: *const Self, name: []const u8, bufferSize: u32) LevelDataBlockPtr {
        basis.assertd(@src(), !self.constPtr, "Trying to add a new data block to a const level data block manager object.");
        const interopName = basis.string.toInteropString(name);
        const cppPtr = basis.bindings.api.LevelDataBlockManager_addDataBlock(self.cppPtr, &interopName, bufferSize);
        return LevelDataBlockPtr{
            .cppPtr = cppPtr,
            .constPtr = false,
        };
    }

    pub fn addDataBlockIfDoesNotExist(self: *const Self, name: []const u8, bufferSize: u32) LevelDataBlockPtr {
        basis.assertd(@src(), !self.constPtr, "Trying to add a new data block to a const level data block manager object.");
        const interopName = basis.string.toInteropString(name);
        const cppPtr = basis.bindings.api.LevelDataBlockManager_addDataBlockIfDoesNotExist(self.cppPtr, &interopName, bufferSize);
        return LevelDataBlockPtr{
            .cppPtr = cppPtr,
            .constPtr = false,
        };
    }

    pub fn getMutableDataBlock(self: *const Self, name: []const u8) LevelDataBlockPtr {
        basis.assertd(@src(), !self.constPtr, "Trying to access a mutable data block from a const level data block manager object.");
        const interopName = basis.string.toInteropString(name);
        const cppPtr = basis.bindings.api.LevelDataBlockManager_getMutableDataBlock(self.cppPtr, &interopName);
        return LevelDataBlockPtr{
            .cppPtr = cppPtr,
            .constPtr = false,
        };
    }

    pub fn hasDataBlock(self: *const Self, name: []const u8) bool {
        const interopName = basis.string.toInteropString(name);
        return if (basis.bindings.api.LevelDataBlockManager_hasDataBlock(self.cppPtr, &interopName) == 1) true else false;
    }
};

pub const LevelDataBlockPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,
    constPtr: bool,

    const ChunkMarker: u32 = 0x1337c0de;

    pub fn initNull() Self {
        return Self{ .cppPtr = 0, .constPtr = false };
    }

    pub fn addChunk(self: *const Self, comptime T: type, chunk: T) void {
        basis.assertd(@src(), !self.constPtr, "Cannot add a chunk to a const level data block.");
        var bufferSize: u32 = 0;
        var bufferAddress = basis.bindings.api.LevelDataBlock_getWriteBuffer(self.cppPtr, &bufferSize);
        const buffer: []u8 = bufferAddress[0..bufferSize];
        const cursorPosition: usize = @intCast(basis.bindings.api.LevelDataBlock_beginWritingChunk(self.cppPtr));

        var stream = basis.BinaryWriteStream.init(buffer, true);
        stream.cursorPosition = cursorPosition;

        switch (@typeInfo(T)) {
            .int => {
                stream.putInt(T, chunk);
            },
            .float => {
                stream.putFloat(chunk);
            },
            .bool => {
                stream.putBool(chunk);
            },
            else => {
                stream.put(T, chunk);
            },
        }

        stream.putInt(u32, ChunkMarker);

        basis.bindings.api.LevelDataBlock_finishWritingChunk(self.cppPtr, @intCast(stream.cursorPosition));
    }

    pub fn getChunk(self: *const Self, index: u32, comptime T: type, chunk: *T) void {
        var bufferSize: u32 = 0;
        var bufferAddress = basis.bindings.api.LevelDataBlock_getReadBuffer(self.cppPtr, &bufferSize);
        const buffer: []const u8 = bufferAddress[0..bufferSize];
        const cursorPosition: usize = @intCast(basis.bindings.api.LevelDataBlock_getChunkStartReadBufferPosition(self.cppPtr, index));

        var stream = basis.BinaryReadStream.init(buffer, true);
        stream.cursorPosition = cursorPosition;

        switch (@typeInfo(T)) {
            .int => {
                chunk.* = stream.getInt(T);
            },
            .float => {
                chunk.* = stream.getFloat();
            },
            .bool => {
                chunk.* = stream.getBool();
            },
            else => {
                // We cannot "get" the object out of the stream like this
                // in case it is a complex object that needs allocators set
                // up before it can be deserialized.
                //chunk.* = stream.get(T);
                // So call deserialize() directly instead.
                chunk.deserialize(&stream);
            },
        }

        const markerTest = stream.getInt(u32);
        basis.assertd(
            @src(),
            markerTest == ChunkMarker,
            "Level data block read did not pass chunk marker test. Most likely the data was written in another format than it was read in.",
        );

        basis.bindings.api.LevelDataBlock_setReadBufferPosition(self.cppPtr, @as(u32, @intCast(stream.cursorPosition)));
    }

    pub fn tryGetChunk(self: *const Self, index: u32, comptime T: type, chunk: *T) !void {
        var bufferSize: u32 = 0;
        var bufferAddress = basis.bindings.api.LevelDataBlock_getReadBuffer(self.cppPtr, &bufferSize);
        const buffer: []const u8 = bufferAddress[0..bufferSize];
        const cursorPosition: usize = @as(usize, @intCast(basis.bindings.api.LevelDataBlock_getChunkStartReadBufferPosition(self.cppPtr, index)));

        var stream = basis.BinaryReadStream.init(buffer, true);
        stream.cursorPosition = cursorPosition;

        try chunk.tryDeserialize(&stream);

        basis.bindings.api.LevelDataBlock_setReadBufferPosition(self.cppPtr, @as(u32, @intCast(stream.cursorPosition)));
    }

    pub fn getChunkCount(self: *const Self) u32 {
        return basis.bindings.api.LevelDataBlock_getChunkCount(self.cppPtr);
    }
};
