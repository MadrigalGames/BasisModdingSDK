// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const GameObjectRef = struct {
    const Self = @This();

    name: basis.String,
    nameHash: basis.StringHash,

    //----------------------------------------------------

    pub fn init(allocator: std.mem.Allocator) GameObjectRef {
        return Self{
            .name = basis.String.init(allocator),
            .nameHash = 0,
        };
    }

    pub fn deinit(self: *Self) void {
        self.name.deinit();
    }

    //----------------------------------------------------

    pub fn set(self: *Self, name: []const u8) basis.String.Error!void {
        try self.name.set(name);
        self.nameHash = basis.string.makeStringHash(name);
    }

    pub fn str(self: *const Self) []const u8 {
        return self.name.str();
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Self, stream: *basis.BinaryReadStream) void {
        deserializeStatic(&self.name, &self.nameHash, stream);
    }

    pub fn serialize(self: Self, stream: *basis.BinaryWriteStream) void {
        serializeStatic(self.name.str(), self.nameHash, stream);
    }

    pub fn deserializeStatic(name: *basis.String, hash: *basis.StringHash, stream: *basis.BinaryReadStream) void {
        stream.deserializeString(name) catch unreachable;
        hash.* = stream.getInt(basis.StringHash);
    }

    pub fn serializeStatic(name: []const u8, hash: basis.StringHash, stream: *basis.BinaryWriteStream) void {
        stream.putString(name);
        stream.putInt(basis.StringHash, hash);
    }
};
