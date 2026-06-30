// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");
const basis = @import("../basis.zig");

pub const HeapAllocator = struct {
    pub const DeinitResult = enum { ok };

    pub fn allocator(self: *HeapAllocator) std.mem.Allocator {
        return .{
            .ptr = self,
            .vtable = &.{
                .alloc = alloc,
                .resize = std.mem.Allocator.noResize,
                .remap = std.mem.Allocator.noRemap,
                .free = free,
            },
        };
    }

    pub fn deinit(self: *HeapAllocator) DeinitResult {
        // This is here just to provide an interface similar to Zig's GPA.
        _ = self;
        return .ok;
    }

    //----------------------------------------------------

    fn alloc(
        ctx: *anyopaque,
        len: usize,
        alignment: std.mem.Alignment,
        return_address: usize,
    ) ?[*]u8 {
        _ = ctx;
        _ = return_address;
        basis.assert(@src(), len > 0);
        const alignmentBytes = alignment.toByteUnits();
        return basis.bindings.api.Core_heapAlloc(@intCast(len), @intCast(alignmentBytes));
    }

    // fn alloc(
    //     ctx: *anyopaque,
    //     len: usize,
    //     log2_align: u8,
    //     return_address: usize,
    // ) ?[*]u8 {
    //     _ = ctx;
    //     _ = return_address;
    //     basis.assert(@src(), len > 0);
    //     return alignedAlloc(len, log2_align);
    // }

    fn free(
        ctx: *anyopaque,
        memory: []u8,
        alignment: std.mem.Alignment,
        ret_addr: usize,
    ) void {
        _ = ctx;
        _ = alignment;
        _ = ret_addr;
        basis.bindings.api.Core_heapFree(memory.ptr);
    }

    //----------------------------------------------------

    // fn alignedAlloc(len: usize, log2_align: u8) ?[*]u8 {
    //     const alignment = @as(usize, 1) << @as(std.mem.Allocator.Log2Align, @intCast(log2_align));
    //     const buf = basis.bindings.api.Core_heapAlloc(@intCast(len), @intCast(alignment));
    //     return buf;
    // }
};
