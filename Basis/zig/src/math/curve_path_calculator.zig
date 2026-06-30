// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

pub fn CurvePathCalculator(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const CurvePath = basis.math.CurvePath(T);

        //----------------------------------------------------

        maxPointCount: usize = 0,
        hasAllocatedBuffers: bool = false,
        allocator: Allocator = undefined,

        // Buffers:
        resultBuffer: []T = &[_]T{},
        targetBuffer: []T = &[_]T{},
        lowerDiagBuffer: []f32 = &[_]f32{},
        mainDiagBuffer: []f32 = &[_]f32{},
        upperDiagBuffer: []f32 = &[_]f32{},
        newTargetBuffer: []T = &[_]T{},
        newUpperDiagBuffer: []f32 = &[_]f32{},

        //----------------------------------------------------

        pub fn init(allocator: Allocator, maxPointCount: usize) Self {
            return Self{
                .maxPointCount = maxPointCount,
                .hasAllocatedBuffers = false,
                .allocator = allocator,
            };
        }

        pub fn deinit(self: *Self) void {
            self.freeBuffers();
        }

        // Calculates the path so that it smoothly passes through the given points.
        // Returns the full length of the calculated path.
        pub fn calculateFromPoints(self: *Self, curvePath: *CurvePath, points: []const T) !f32 {
            basis.assertd(@src(), points.len >= 2, "At least two positions needed to construct a curve path.");
            basis.assert(@src(), points.len <= self.maxPointCount);

            if (!self.hasAllocatedBuffers) {
                try self.allocateBuffers();
            }

            return try self.calculateFromPointsInternal(curvePath, points);
        }

        //----------------------------------------------------

        fn allocateBuffers(self: *Self) !void {
            if (self.hasAllocatedBuffers) {
                return;
            }

            const segmentCount = self.maxPointCount - 1;

            self.resultBuffer = try self.allocator.alloc(T, segmentCount * 2);
            self.targetBuffer = try self.allocator.alloc(T, segmentCount);
            self.lowerDiagBuffer = try self.allocator.alloc(f32, segmentCount - 1);
            self.mainDiagBuffer = try self.allocator.alloc(f32, segmentCount);
            self.upperDiagBuffer = try self.allocator.alloc(f32, segmentCount - 1);
            self.newTargetBuffer = try self.allocator.alloc(T, segmentCount);
            self.newUpperDiagBuffer = try self.allocator.alloc(f32, segmentCount - 1);

            self.hasAllocatedBuffers = true;
        }

        fn freeBuffers(self: *Self) void {
            if (!self.hasAllocatedBuffers) {
                return;
            }

            self.allocator.free(self.resultBuffer);
            self.allocator.free(self.targetBuffer);
            self.allocator.free(self.lowerDiagBuffer);
            self.allocator.free(self.mainDiagBuffer);
            self.allocator.free(self.upperDiagBuffer);
            self.allocator.free(self.newTargetBuffer);
            self.allocator.free(self.newUpperDiagBuffer);

            self.hasAllocatedBuffers = false;
        }

        fn calculateFromPointsInternal(self: *Self, curvePath: *CurvePath, points: []const T) !f32 {
            curvePath.segments.clearRetainingCapacity();

            if (points.len == 2) {
                const startToEnd = points[1].sub(points[0]);

                try curvePath.segments.resize(1);
                curvePath.segments.items[0].curve.set(
                    points[0],
                    points[0].add(startToEnd.multiplyFloat(0.1)),
                    points[1],
                    points[0].add(startToEnd.multiplyFloat(0.9)),
                );
                curvePath.segments.items[0].length = startToEnd.length();
                curvePath.segments.items[0].startT = 0.0;
                curvePath.segments.items[0].endT = 1.0;

                return curvePath.segments.items[0].length;
            } else {
                const segmentCount = points.len - 1;

                var totalLength: f32 = 0.0;

                // Calculate the control points for a smooth path.

                self.computeControlPoints(segmentCount, points);

                try curvePath.segments.resize(segmentCount);

                // Init the curve segments.

                {
                    var i: usize = 0;
                    var pi: usize = 0;
                    while (i < segmentCount) : (i += 1) {
                        const startPosition = points[pi];
                        const endPosition = points[pi + 1];

                        const startCp = self.resultBuffer[i];
                        const endCp = self.resultBuffer[segmentCount + i];

                        curvePath.segments.items[i].curve.set(startPosition, startCp, endPosition, endCp);

                        pi += 1;
                    }
                }

                // Calculate the length of each segment.

                for (curvePath.segments.items) |*s| {
                    const RESOLUTION = 100.0;
                    const STEP_SIZE = 1.0 / RESOLUTION;

                    s.length = 0.0;

                    var t: f32 = 0.0;
                    var prevPos = s.curve.getPointAtT(t);

                    while (t < 1.0) {
                        t = std.math.clamp(t + STEP_SIZE, 0.0, 1.0);
                        const p = s.curve.getPointAtT(t);
                        s.length += (p.sub(prevPos)).length();
                        prevPos = p;
                    }

                    totalLength += s.length;
                }

                // Calculate at which values of t the segments start and end.

                var distanceTravelled: f32 = 0.0;

                var i: usize = 0;
                while (i < segmentCount) : (i += 1) {
                    var s = &curvePath.segments.items[i];
                    s.startT = distanceTravelled / totalLength;
                    distanceTravelled += s.length;

                    if (i != 0) {
                        curvePath.segments.items[i - 1].endT = s.startT;
                    }

                    if (i == segmentCount - 1) {
                        s.endT = 1.0;
                    }
                }

                return totalLength;
            }
        }

        // Ported from Java code here: https://www.stkent.com/2015/07/03/building-smooth-paths-using-bezier-curves.html
        //----------------------------------------------------
        // The MIT License (MIT)

        // Copyright (c) 2015-2023 Stuart Kent

        // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
        // associated documentation files (the "Software"), to deal in the Software without restriction,
        // including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense,
        // and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
        // subject to the following conditions:

        // The above copyright notice and this permission notice shall be included in all copies or substantial
        // portions of the Software.

        // THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT
        // LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
        // IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
        // LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
        // WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        //----------------------------------------------------

        fn computeControlPoints(self: *Self, n: usize, knots: []const T) void {
            self.constructTargetVector(n, knots);
            self.constructLowerDiagonalVector(n - 1);
            self.constructMainDiagonalVector(n);
            self.constructUpperDiagonalVector(n - 1);

            // forward sweep for control points c_i,0:
            self.newUpperDiagBuffer[0] = self.upperDiagBuffer[0] / self.mainDiagBuffer[0];
            self.newTargetBuffer[0] = self.targetBuffer[0].multiplyFloat(1.0 / self.mainDiagBuffer[0]);

            {
                var i: usize = 1;
                while (i < n - 1) : (i += 1) {
                    self.newUpperDiagBuffer[i] = self.upperDiagBuffer[i] / (self.mainDiagBuffer[i] - self.lowerDiagBuffer[i - 1] * self.newUpperDiagBuffer[i - 1]);
                }
            }

            {
                var i: usize = 1;
                while (i < n) : (i += 1) {
                    const targetScale = 1.0 / (self.mainDiagBuffer[i] - self.lowerDiagBuffer[i - 1] * self.newUpperDiagBuffer[i - 1]);
                    self.newTargetBuffer[i] = (self.targetBuffer[i].sub(self.newTargetBuffer[i - 1].multiplyFloat(self.lowerDiagBuffer[i - 1]))).multiplyFloat(targetScale);
                }
            }

            // backward sweep for control points c_i,0:
            self.resultBuffer[n - 1] = self.newTargetBuffer[n - 1];

            {
                var i: i32 = @as(i32, @intCast(n)) - 2;
                while (i >= 0) : (i -= 1) {
                    const ui: usize = @intCast(i);
                    self.resultBuffer[ui] = self.newTargetBuffer[ui].sub(self.resultBuffer[ui + 1].multiplyFloat(self.newUpperDiagBuffer[ui]));
                }
            }

            // calculate remaining control points c_i,1 directly:
            {
                var i: usize = 0;
                while (i < n - 1) : (i += 1) {
                    self.resultBuffer[n + i] = (knots[i + 1].multiplyFloat(2.0)).sub(self.resultBuffer[i + 1]);
                }
            }

            self.resultBuffer[2 * n - 1] = (knots[n].add(self.resultBuffer[n - 1])).multiplyFloat(0.5);
        }

        fn constructTargetVector(self: *Self, n: usize, knots: []const T) void {
            self.targetBuffer[0] = knots[0].add(knots[1].multiplyFloat(2.0));

            var i: usize = 1;
            while (i < n - 1) : (i += 1) {
                self.targetBuffer[i] = ((knots[i].multiplyFloat(2.0)).add(knots[i + 1])).multiplyFloat(2.0);
            }

            self.targetBuffer[n - 1] = (knots[n - 1].multiplyFloat(8.0)).add(knots[n]);
        }

        fn constructLowerDiagonalVector(self: *Self, n: usize) void {
            var i: usize = 0;
            while (i < n - 1) : (i += 1) {
                self.lowerDiagBuffer[i] = 1.0;
            }

            self.lowerDiagBuffer[n - 1] = 2.0;
        }

        fn constructMainDiagonalVector(self: *Self, n: usize) void {
            self.mainDiagBuffer[0] = 2.0;

            var i: usize = 1;
            while (i < n - 1) : (i += 1) {
                self.mainDiagBuffer[i] = 4.0;
            }

            self.mainDiagBuffer[n - 1] = 7.0;
        }

        fn constructUpperDiagonalVector(self: *Self, n: usize) void {
            var i: usize = 0;
            while (i < n) : (i += 1) {
                self.upperDiagBuffer[i] = 1.0;
            }
        }
    };
}
