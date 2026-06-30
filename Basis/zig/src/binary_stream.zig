// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const String = basis.String;

pub const BinaryReadStream = struct {
    const Self = @This();

    buffer: []const u8,
    endian: std.builtin.Endian,
    cursorPosition: usize,

    pub fn init(buffer: []const u8, littleEndian: bool) Self {
        return Self{
            .buffer = buffer,
            .endian = if (littleEndian) std.builtin.Endian.little else std.builtin.Endian.big,
            .cursorPosition = 0,
        };
    }

    //----------------------------------------------------

    pub fn getInt(self: *Self, comptime T: type) T {
        const size = @sizeOf(T);
        const t = std.mem.readInt(T, self.buffer[self.cursorPosition..][0..size], self.endian);
        self.cursorPosition += size;
        return t;
    }

    pub fn getBool(self: *Self) bool {
        return self.getInt(u8) == 1;
    }

    pub fn getFloat(self: *Self) f32 {
        const t = self.getInt(u32);
        return @as(f32, @bitCast(t));
    }

    pub fn get(self: *Self, comptime T: type) T {
        var val: T = undefined;
        val.deserialize(self);
        return val;
    }

    /// Returns a zero-copy slice into the stream's buffer for a length-prefixed string.
    /// The returned slice is valid only as long as the underlying buffer is.
    pub fn getStringSlice(self: *Self) []const u8 {
        const length: usize = @intCast(self.getInt(u32));
        const slice = self.buffer[self.cursorPosition..][0..length];
        self.cursorPosition += length;
        return slice;
    }

    /// Deserialize an array list of the given T. The array list needs to be fully
    /// initialized with a valid allocator.
    pub fn deserializeArrayList(self: *Self, comptime T: type, val: *basis.ArrayList(T)) !void {
        val.clearAndFree();

        const length = self.getInt(u32);

        try val.ensureTotalCapacity(@intCast(length));

        var i: u32 = 0;
        while (i < length) : (i += 1) {
            const e = self.get(T);
            val.appendAssumeCapacity(e);
        }
    }

    /// Deserialize an array list of strings. The array list needs to be fully
    /// initialized with a valid allocator. New strings are initialized with the
    /// same allocator as the list.
    pub fn deserializeStringArrayList(self: *Self, val: *basis.ArrayList(String)) !void {
        val.clearAndFree();

        const length = self.getInt(u32);

        try val.ensureTotalCapacity(@intCast(length));

        var i: u32 = 0;
        while (i < length) : (i += 1) {
            var e = String.init(val.allocator);
            try self.deserializeString(&e);
            val.appendAssumeCapacity(e);
        }
    }

    // Deserialize a string. This is not called "getString()" to
    // make it very clear that you need to provide a fully initialized
    // string. The stream is not going to construct one for you.
    pub fn deserializeString(self: *Self, string: *String) String.Error!void {
        const length: usize = @intCast(self.getInt(u32));

        string.clear();

        if (length > 0) {
            try string.allocate(length);

            const target = string.buffer.?;
            self.read(target, length);
            string.size = length;
        }
    }

    // Deserialize into an InPlaceString. Generic on the capacity via anytype;
    // returns whatever error type the target's set() returns.
    pub fn deserializeInPlaceString(self: *Self, string: anytype) !void {
        const length: usize = @intCast(self.getInt(u32));

        if (length == 0) {
            string.clear();
            return;
        }

        const slice = self.buffer[self.cursorPosition..][0..length];
        self.cursorPosition += length;
        try string.set(slice);
    }

    pub fn read(self: *Self, target: []u8, length: usize) void {
        const sourceStart = self.cursorPosition;

        //const sourceEnd = self.cursorPosition + length;
        //std.mem.copy(u8, target[0..], self.buffer[sourceStart..sourceEnd]);

        @memcpy(target[0..length], self.buffer[sourceStart..][0..length]);

        self.cursorPosition += length;
    }
};

pub const BinaryWriteStream = struct {
    const Self = @This();

    buffer: []u8,
    endian: std.builtin.Endian,
    cursorPosition: usize,

    pub fn init(buffer: []u8, littleEndian: bool) Self {
        return Self{
            .buffer = buffer,
            .endian = if (littleEndian) std.builtin.Endian.little else std.builtin.Endian.big,
            .cursorPosition = 0,
        };
    }

    //----------------------------------------------------

    pub fn putInt(self: *Self, comptime T: type, val: T) void {
        const size = @sizeOf(T);
        std.mem.writeInt(T, self.buffer[self.cursorPosition..][0..size], val, self.endian);
        self.cursorPosition += size;
    }

    pub fn putBool(self: *Self, val: bool) void {
        const v: u8 = if (val) 1 else 0;
        self.putInt(u8, v);
    }

    pub fn putFloat(self: *Self, val: f32) void {
        self.putInt(u32, @as(u32, @bitCast(val)));
    }

    pub fn putString(self: *Self, val: []const u8) void {
        const length = @as(u32, @intCast(val.len));
        self.putInt(u32, length);

        if (length > 0) {
            @memcpy(self.buffer[self.cursorPosition..][0..val.len], val);
            self.cursorPosition += val.len;
        }
    }

    pub fn put(self: *Self, comptime T: type, val: T) void {
        val.serialize(self);
    }

    pub fn putArrayList(self: *Self, comptime T: type, val: basis.ArrayList(T)) void {
        const length: u32 = @intCast(val.items.len);
        self.putInt(u32, length);

        for (val.items) |e| {
            self.put(T, e);
        }
    }

    pub fn putStringArrayList(self: *Self, val: basis.ArrayList(String)) void {
        const length: u32 = @intCast(val.items.len);
        self.putInt(u32, length);

        for (val.items) |e| {
            self.putString(e.str());
        }
    }

    pub fn write(self: *Self, data: []const u8) void {
        const target = self.buffer[self.cursorPosition..];
        const length = data.len;

        @memcpy(target[0..length], data[0..length]);

        self.cursorPosition += length;
    }
};
