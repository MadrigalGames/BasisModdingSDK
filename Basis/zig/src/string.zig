// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const zig_string = @import("thirdparty/zig-string.zig");

pub const String = zig_string.String;

pub const StringHash = u32;

// This needs to match the seed used on the C++/C# side.
const HASH_SEED = 0;

pub fn makeStringHash(string: []const u8) StringHash {
    return std.hash.Murmur3_32.hashWithSeed(string, HASH_SEED);
}

pub fn init(allocator: std.mem.Allocator, contents: []const u8) String {
    var str = String.init(allocator);

    str.concat(contents) catch |err| {
        basis.fatalErrorWithName(@src(), err);
    };

    return str;
}

pub fn toInteropString(literal: []const u8) basis.bindings.InteropString {
    if (literal.len == 0) {
        return basis.bindings.InteropString{ .ptr = 0, .len = 0 };
    }

    return basis.bindings.InteropString{ .ptr = &literal[0], .len = @as(u32, @intCast(literal.len)) };
}

pub fn fromInteropString(interop: *const basis.bindings.InteropString) []const u8 {
    return interop.ptr[0..interop.len];
}

pub fn copyToInteropBuffer(buf: *basis.bindings.InteropBuffer, str: []const u8) void {
    basis.assertd(@src(), str.len < buf.capacity, "Error copying string to interop buffer. Buffer to small.");
    @memcpy(buf.ptr[0..str.len], str.ptr[0..str.len]);
    buf.len = @intCast(str.len);
}

// String comparison.
pub fn eql(s1: []const u8, s2: []const u8) bool {
    return std.mem.eql(u8, s1, s2);
}
