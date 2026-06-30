// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Allocator = std.mem.Allocator;

pub const SerializableBlob = struct {
    const Self = @This();

    //----------------------------------------------------

    allocator: Allocator,
    buffer: []u8,
    internalCopy: bool,

    //----------------------------------------------------

    pub fn initWithBuffer(allocator: Allocator, buffer: []u8, createInternalCopy: bool) !Self {
        const buf = if (createInternalCopy) blk: {
            const bufferCopy = try allocator.alloc(u8, buffer.len);
            @memcpy(bufferCopy, buffer);
            break :blk bufferCopy;
        } else buffer;

        return Self{
            .allocator = allocator,
            .buffer = buf,
            .internalCopy = createInternalCopy,
        };
    }

    pub fn init(allocator: Allocator) Self {
        return Self{
            .allocator = allocator,
            .buffer = &.{},
            .internalCopy = true,
        };
    }

    pub fn initCopy(other: *const Self) !Self {
        const buf = if (other.internalCopy) blk: {
            const bufferCopy = try other.allocator.alloc(u8, other.buffer.len);
            @memcpy(bufferCopy, other.buffer);
            break :blk bufferCopy;
        } else other.buffer;

        return Self{
            .allocator = other.allocator,
            .buffer = buf,
            .internalCopy = other.internalCopy,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.internalCopy and self.buffer.len > 0) {
            self.allocator.free(self.buffer);
            self.buffer = &.{};
        }
    }

    //----------------------------------------------------

    pub fn tryDeserialize(self: *Self, stream: *basis.BinaryReadStream) !void {
        const oldBufferSize = self.buffer.len;

        if (self.internalCopy and self.buffer.len > 0) {
            self.allocator.free(self.buffer);
            self.buffer = &.{};
        }

        const newBufferSize: usize = @intCast(stream.getInt(i32));

        if (newBufferSize > 0) {
            if (self.internalCopy) {
                self.buffer = try self.allocator.alloc(u8, newBufferSize);
            } else {
                // If we don't allocate a buffer of the correct size,
                // make sure the buffer we have is large enough to hold the data.
                basis.assertd(
                    @src(),
                    oldBufferSize >= newBufferSize,
                    "SerializableBlob trying to deserialize into a buffer which is too small.",
                );

                self.buffer = self.buffer[0..newBufferSize];
            }

            stream.read(self.buffer, newBufferSize);
        }
    }

    pub fn serialize(self: Self, stream: *basis.BinaryWriteStream) void {
        // See C++ version for why we use i32 here...
        stream.putInt(i32, @intCast(self.buffer.len));

        if (self.buffer.len > 0) {
            stream.write(self.buffer[0..self.buffer.len]);
        }
    }
};
