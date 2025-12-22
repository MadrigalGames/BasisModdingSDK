// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub fn FixedLookupTable(comptime MaxSize: usize) type {
    return struct {
        const Self = @This();

        //----------------------------------------------------

        samples: [MaxSize * 2]f32 = [_]f32{0.0} ** (MaxSize * 2),
        size: usize = 0,

        //----------------------------------------------------

        pub fn addSample(self: *Self, x: f32, y: f32) void {
            basis.assert(@src(), self.size < MaxSize);
            self.samples[self.size * 2] = x;
            self.samples[(self.size * 2) + 1] = y;
            self.size += 1;
        }

        pub fn clear(self: *Self) void {
            self.size = 0;
        }

        pub fn getYAtX(self: *const Self, x: f32) f32 {
            basis.assert(@src(), self.size != 0);

            var x0 = self.getXAtIndex(0);
            var y0 = self.getYAtIndex(0);

            if (x < x0) {
                return y0;
            }

            var i: usize = 0;
            while (i < self.size) : (i += 1) {
                const xi = self.getXAtIndex(i);
                const yi = self.getYAtIndex(i);

                if ((x >= x0) and (x < xi)) {
                    return (y0 + (yi - y0) * (x - x0) / (xi - x0));
                }

                x0 = xi;
                y0 = yi;
            }

            basis.assert(@src(), x >= self.getXAtIndex(self.size - 1));
            return self.getYAtIndex(self.size - 1);
        }

        pub fn getXAtIndex(self: *const Self, i: usize) f32 {
            return self.samples[i * 2];
        }

        pub fn getYAtIndex(self: *const Self, i: usize) f32 {
            return self.samples[(i * 2) + 1];
        }

        pub fn getMinX(self: *const Self) f32 {
            return self.getXAtIndex(0);
        }

        pub fn getMaxX(self: *const Self) f32 {
            return self.getXAtIndex(self.size - 1);
        }

        pub fn getMinY(self: *const Self) f32 {
            return self.getYAtIndex(0);
        }

        pub fn getMaxY(self: *const Self) f32 {
            return self.getYAtIndex(self.size - 1);
        }
    };
}
