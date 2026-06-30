// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

// Fixed-capacity, inline-buffer UTF-8 string. API mirrors basis.String
// (thirdparty/zig-string.zig) but with a compile-time bounded buffer and
// no allocator. Operations that would exceed CAPACITY return Error.Overflow.

const std = @import("std");

pub fn InPlaceString(comptime CAPACITY: usize) type {
    return struct {
        const Self = @This();

        buffer: [CAPACITY]u8 = undefined,
        /// Number of bytes currently used in the buffer.
        size: usize = 0,

        pub const Error = error{
            Overflow,
            InvalidRange,
        };

        // ----------------------------------------------------------------
        // Construction

        pub fn init() Self {
            return .{};
        }

        pub fn initWithContents(contents: []const u8) Error!Self {
            var s = Self{};
            try s.concat(contents);
            return s;
        }

        // ----------------------------------------------------------------
        // Queries

        /// Returns the size of the internal buffer
        pub fn capacity(_: Self) usize {
            return CAPACITY;
        }

        /// Checks the String is empty
        pub inline fn isEmpty(self: Self) bool {
            return self.size == 0;
        }

        /// Returns the String as a string literal
        pub fn str(self: *const Self) []const u8 {
            return self.buffer[0..self.size];
        }

        /// Returns amount of characters in the String
        pub fn len(self: Self) usize {
            var length: usize = 0;
            var i: usize = 0;
            while (i < self.size) {
                i += getUTF8Size(self.buffer[i]);
                length += 1;
            }
            return length;
        }

        /// Compares this String with a string literal
        pub fn cmp(self: Self, literal: []const u8) bool {
            return std.mem.eql(u8, self.buffer[0..self.size], literal);
        }

        /// Returns a character at the specified index
        pub fn charAt(self: Self, index: usize) ?[]const u8 {
            if (getIndex(self.buffer[0..self.size], index, true)) |i| {
                const sz = getUTF8Size(self.buffer[i]);
                return self.buffer[i..(i + sz)];
            }
            return null;
        }

        /// Finds the first occurrence of the string literal
        pub fn find(self: Self, literal: []const u8) ?usize {
            const index = std.mem.indexOf(u8, self.buffer[0..self.size], literal);
            if (index) |i| {
                return getIndex(self.buffer[0..self.size], i, false);
            }
            return null;
        }

        /// Finds the last occurrence of the string literal
        pub fn rfind(self: Self, literal: []const u8) ?usize {
            const index = std.mem.lastIndexOf(u8, self.buffer[0..self.size], literal);
            if (index) |i| {
                return getIndex(self.buffer[0..self.size], i, false);
            }
            return null;
        }

        pub fn starts_with(self: *const Self, literal: []const u8) bool {
            const index = std.mem.indexOf(u8, self.buffer[0..self.size], literal);
            return index == 0;
        }

        pub fn ends_with(self: *const Self, literal: []const u8) bool {
            if (literal.len > self.size) return false;
            const index = std.mem.lastIndexOf(u8, self.buffer[0..self.size], literal);
            const i: usize = self.size - literal.len;
            return index == i;
        }

        // ----------------------------------------------------------------
        // Mutation

        /// Clears the contents of the String but leaves the capacity
        pub fn clear(self: *Self) void {
            self.size = 0;
        }

        /// Sets the string contents to a literal value
        pub fn set(self: *Self, literal: []const u8) Error!void {
            self.clear();
            try self.insert(literal, 0);
        }

        /// Appends a character onto the end of the String
        pub fn concat(self: *Self, char: []const u8) Error!void {
            try self.insert(char, self.len());
        }

        /// Inserts a string literal into the String at an index
        pub fn insert(self: *Self, literal: []const u8, index: usize) Error!void {
            if (self.size + literal.len > CAPACITY) {
                return Error.Overflow;
            }

            if (index == self.len()) {
                // Append at the end.
                var i: usize = 0;
                while (i < literal.len) : (i += 1) {
                    self.buffer[self.size + i] = literal[i];
                }
            } else {
                if (getIndex(self.buffer[0..self.size], index, true)) |k| {
                    // Shift existing bytes after k up by literal.len.
                    var i: usize = self.size;
                    while (i > k) {
                        i -= 1;
                        self.buffer[i + literal.len] = self.buffer[i];
                    }
                    // Write the new bytes.
                    i = 0;
                    while (i < literal.len) : (i += 1) {
                        self.buffer[k + i] = literal[i];
                    }
                }
            }

            self.size += literal.len;
        }

        /// Removes the last character from the String
        pub fn pop(self: *Self) ?[]const u8 {
            if (self.size == 0) return null;

            var i: usize = 0;
            while (i < self.size) {
                const sz = getUTF8Size(self.buffer[i]);
                if (i + sz >= self.size) break;
                i += sz;
            }

            const ret = self.buffer[i..self.size];
            self.size = i;
            return ret;
        }

        /// Removes a character at the specified index
        pub fn remove(self: *Self, index: usize) Error!void {
            try self.removeRange(index, index + 1);
        }

        /// Removes a range of character from the String
        /// Start (inclusive) - End (Exclusive)
        pub fn removeRange(self: *Self, start: usize, end: usize) Error!void {
            const length = self.len();
            if (end < start or end > length) return Error.InvalidRange;

            const rStart = getIndex(self.buffer[0..self.size], start, true).?;
            const rEnd = getIndex(self.buffer[0..self.size], end, true).?;
            const difference = rEnd - rStart;

            var i: usize = rEnd;
            while (i < self.size) : (i += 1) {
                self.buffer[i - difference] = self.buffer[i];
            }

            self.size -= difference;
        }

        /// Trims all whitelist characters at the start of the String.
        pub fn trimStart(self: *Self, whitelist: []const u8) void {
            var i: usize = 0;
            while (i < self.size) : (i += 1) {
                const sz = getUTF8Size(self.buffer[i]);
                if (sz > 1 or !inWhitelist(self.buffer[i], whitelist)) break;
            }

            if (getIndex(self.buffer[0..self.size], i, false)) |k| {
                self.removeRange(0, k) catch {};
            }
        }

        /// Trims all whitelist characters at the end of the String.
        pub fn trimEnd(self: *Self, whitelist: []const u8) void {
            self.reverse();
            self.trimStart(whitelist);
            self.reverse();
        }

        /// Trims all whitelist characters from both ends of the String
        pub fn trim(self: *Self, whitelist: []const u8) void {
            self.trimStart(whitelist);
            self.trimEnd(whitelist);
        }

        /// Reverses the characters in this String
        pub fn reverse(self: *Self) void {
            var i: usize = 0;
            while (i < self.size) {
                const sz = getUTF8Size(self.buffer[i]);
                if (sz > 1) std.mem.reverse(u8, self.buffer[i..(i + sz)]);
                i += sz;
            }
            std.mem.reverse(u8, self.buffer[0..self.size]);
        }

        /// Converts all (ASCII) uppercase letters to lowercase
        pub fn toLowercase(self: *Self) void {
            var i: usize = 0;
            while (i < self.size) {
                const sz = getUTF8Size(self.buffer[i]);
                if (sz == 1) self.buffer[i] = std.ascii.toLower(self.buffer[i]);
                i += sz;
            }
        }

        /// Converts all (ASCII) uppercase letters to lowercase
        pub fn toUppercase(self: *Self) void {
            var i: usize = 0;
            while (i < self.size) {
                const sz = getUTF8Size(self.buffer[i]);
                if (sz == 1) self.buffer[i] = std.ascii.toUpper(self.buffer[i]);
                i += sz;
            }
        }

        // ----------------------------------------------------------------
        // Producing

        /// Copies this String into a new one
        pub fn clone(self: Self) Self {
            var copy = Self{};
            @memcpy(copy.buffer[0..self.size], self.buffer[0..self.size]);
            copy.size = self.size;
            return copy;
        }

        /// Creates a String from a given range
        pub fn substr(self: Self, start: usize, end: usize) Error!Self {
            var result = Self{};
            if (getIndex(self.buffer[0..self.size], start, true)) |rStart| {
                if (getIndex(self.buffer[0..self.size], end, true)) |rEnd| {
                    if (rEnd < rStart or rEnd > self.size)
                        return Error.InvalidRange;
                    try result.concat(self.buffer[rStart..rEnd]);
                }
            }
            return result;
        }

        /// Splits the String into a slice, based on a delimiter and an index
        pub fn split(self: *const Self, delimiters: []const u8, index: usize) ?[]const u8 {
            if (self.size == 0) return null;

            var i: usize = 0;
            var block: usize = 0;
            var start: usize = 0;

            while (i < self.size) {
                const sz = getUTF8Size(self.buffer[i]);
                if (sz == delimiters.len) {
                    if (std.mem.eql(u8, delimiters, self.buffer[i..(i + sz)])) {
                        if (block == index) return self.buffer[start..i];
                        start = i + sz;
                        block += 1;
                    }
                }

                i += sz;
            }

            if (i + 1 >= self.size and block == index) {
                return self.buffer[start..self.size];
            }

            return null;
        }

        // ----------------------------------------------------------------
        // Iteration

        pub const StringIterator = struct {
            string: *const Self,
            index: usize,

            pub fn next(it: *StringIterator) ?[]const u8 {
                if (it.index == it.string.size) return null;
                const i = it.index;
                it.index += getUTF8Size(it.string.buffer[i]);
                return it.string.buffer[i..it.index];
            }

            /// Iterates over and returns the next N characters. Added for Basis.
            pub fn nextN(it: *StringIterator, n: usize) ?[]const u8 {
                if (it.index + n - 1 >= it.string.size) return null;
                const i = it.index;
                for (0..n) |j| {
                    it.index += getUTF8Size(it.string.buffer[i + j]);
                }
                return it.string.buffer[i..it.index];
            }
        };

        pub fn iterator(self: *const Self) StringIterator {
            return StringIterator{
                .string = self,
                .index = 0,
            };
        }

        // ----------------------------------------------------------------
        // Helpers

        /// Returns whether or not a character is whitelisted
        fn inWhitelist(char: u8, whitelist: []const u8) bool {
            var i: usize = 0;
            while (i < whitelist.len) : (i += 1) {
                if (whitelist[i] == char) return true;
            }
            return false;
        }

        /// Returns the real index of a unicode string literal
        fn getIndex(unicode: []const u8, index: usize, real: bool) ?usize {
            var i: usize = 0;
            var j: usize = 0;
            while (i < unicode.len) {
                if (real) {
                    if (j == index) return i;
                } else {
                    if (i == index) return j;
                }
                i += getUTF8Size(unicode[i]);
                j += 1;
            }
            return null;
        }

        /// Returns the UTF-8 character's size
        inline fn getUTF8Size(char: u8) u3 {
            return std.unicode.utf8ByteSequenceLength(char) catch {
                return 1;
            };
        }
    };
}
