// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const TempMemoryRingBuffer = struct {
    const Self = @This();

    const Element = struct {
        buffer: []u8,
    };

    //----------------------------------------------------

    allocator: std.mem.Allocator,

    elementCount: usize,
    elementSize: usize,

    elements: basis.ArrayList(Element),
    currentIndex: usize,

    //----------------------------------------------------

    pub fn init(allocator: std.mem.Allocator, elementCount: usize, elementSize: usize) !Self {
        var self = Self{
            .allocator = allocator,
            .elementCount = elementCount,
            .elementSize = elementSize,
            .elements = .init(allocator),
            .currentIndex = 0,
        };

        for (0..elementCount) |_| {
            const buffer = try allocator.alloc(u8, elementSize);

            try self.elements.append(Element{
                .buffer = buffer,
            });
        }

        return self;
    }

    pub fn deinit(self: *Self) void {
        for (self.elements.items) |e| {
            self.allocator.free(e.buffer);
        }
        self.elements.deinit();
    }

    //----------------------------------------------------

    pub fn get(self: *Self) []u8 {
        const buffer = self.elements.items[self.currentIndex].buffer;
        self.currentIndex = (self.currentIndex + 1) % self.elementCount;
        return buffer;
    }
};
