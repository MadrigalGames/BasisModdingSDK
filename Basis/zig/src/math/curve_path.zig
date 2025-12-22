// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const cubic_bezier_curve = @import("cubic_bezier_curve.zig");

const Allocator = std.mem.Allocator;

pub fn CurvePath(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Curve = cubic_bezier_curve.CubicBezierCurve(T);

        pub const CurveSegment = struct {
            curve: Curve,
            length: f32,
            startT: f32,
            endT: f32,
        };

        pub const LUTSample = struct {
            position: T,
            direction: T,
            t: f32,
        };

        //----------------------------------------------------

        allocator: Allocator = undefined,
        segments: basis.ArrayList(CurveSegment) = undefined,
        lookupTable: basis.ArrayList(LUTSample) = undefined,

        //----------------------------------------------------

        pub fn init(allocator: Allocator) Self {
            return Self{
                .allocator = allocator,
                .segments = basis.ArrayList(CurveSegment).init(allocator),
                .lookupTable = basis.ArrayList(LUTSample).init(allocator),
            };
        }

        pub fn deinit(self: *Self) void {
            self.segments.deinit();
            self.lookupTable.deinit();
        }

        //----------------------------------------------------

        /// Builds the lookup table by sampling the bezier curves.
        /// Suggested values: sampleDistance = 0.5, tStep = 0.0001.
        pub fn buildLookupTable(self: *Self, sampleDistance: f32, tStep: f32) !void {
            var distances = basis.ArrayList(f32).init(self.allocator);
            defer distances.deinit();

            self.lookupTable.clearAndFree();

            var workSample: LUTSample = undefined;
            var lastStoredPosition: T = undefined;

            // Store the sample at t 0.

            workSample.t = 0.0;
            self.sampleBezier(workSample.t, &workSample.position, &workSample.direction);

            try self.lookupTable.append(workSample);
            lastStoredPosition = workSample.position;
            try distances.append(0.0);

            // Advance along the path storing the position and direction whenever the distance
            // to the last stored sample is large enough.

            while (workSample.t < 1.0) : (workSample.t += tStep) {
                self.sampleBezier(workSample.t, &workSample.position, &workSample.direction);
                const distance = workSample.position.sub(lastStoredPosition).length();

                if (workSample.t > 0.999) {
                    // We hit the end of the path (or went past it).
                    // Exit the loop. The last sample is added below.
                    break;
                } else {
                    // Still on the path, check if the distance to the previous sample is large enough.
                    if (distance >= sampleDistance) {
                        try self.lookupTable.append(workSample);
                        lastStoredPosition = workSample.position;
                        try distances.append(distance);
                    }
                }
            }

            // Add the last sample, at 1.0.

            workSample.t = 1.0;
            self.sampleBezier(workSample.t, &workSample.position, &workSample.direction);
            const lastDistance = workSample.position.sub(lastStoredPosition).length();
            try self.lookupTable.append(workSample);
            try distances.append(lastDistance);

            // Calculate the T values for the LUT samples across the whole path.
            var totalDistance: f32 = 0.0;
            for (distances.items) |d| {
                totalDistance += d;
            }

            for (self.lookupTable.items, 0..) |*lutSample, i| {
                var distanceToThisSample: f32 = 0.0;

                var j: usize = 0;
                while (j <= i) : (j += 1) {
                    distanceToThisSample += distances.items[j];
                }

                lutSample.t = distanceToThisSample / totalDistance;
            }
        }

        /// Sample the underlying bezier curves for a position and direction. This gives
        /// exact values for the given value of t, but sampling the path many times with
        /// an increasing value of t is not guaranteed to return positions equally spaced
        /// from each other, due to how bezier curves behave.
        pub fn sampleBezier(self: *const Self, t: f32, position: *T, direction: *T) void {
            const clampedT = std.math.clamp(t, 0.0, 1.0);

            // Find the segment and the t for that segment, ts. Then sample the position and direction.

            for (self.segments.items, 0..) |s, i| {
                if ((clampedT >= s.startT and clampedT < s.endT) or i == self.segments.items.len - 1) {
                    const ts = basis.math.remapFloat(clampedT, s.startT, s.endT, 0.0, 1.0);

                    position.* = s.curve.getPointAtT(ts);

                    direction.* = s.curve.getDerivativeAtT(ts);
                    direction.normalize();

                    return;
                }
            }
        }

        /// Sample the lookup table (if one has been built) for a position and direction.
        /// This gives interpolated values for the given value of t, ie. the result is
        /// an approximation of the mathematical value. However, the lookup table is
        /// built such that samples have equal distance between them which makes these
        /// values good for animations along the path.
        pub fn sampleLookupTable(self: *const Self, t: f32, position: *T, direction: *T) void {
            if (self.lookupTable.items.len == 0) {
                return;
            }

            // TODO: Change this to a binary search.

            for (self.lookupTable.items, 0..) |sample, i| {
                if (sample.t >= t) {
                    if (i == 0) {
                        // First sample.
                        position.* = sample.position;
                        direction.* = sample.direction;
                    } else {
                        const prevSample = self.lookupTable.items[i - 1];
                        const ts = basis.math.remapFloat(t, prevSample.t, sample.t, 0.0, 1.0);

                        position.* = T.lerp(ts, prevSample.position, sample.position);
                        direction.* = T.lerp(ts, prevSample.direction, sample.direction);
                        direction.normalize();
                    }

                    return;
                }
            }
        }

        //----------------------------------------------------

        pub fn debugDraw(self: *const Self, drawControlPoints: bool, drawLookupTablePositions: bool, pathColor: basis.Color) void {
            // Debug drawing is currently only implemented for Vec3s.
            if (T == basis.math.Vec3) {
                self.debugDraw3D(drawControlPoints, drawLookupTablePositions, pathColor);
            }
        }

        //----------------------------------------------------

        pub fn deserialize(self: *Self, stream: *basis.BinaryReadStream) void {
            self.segments.clearRetainingCapacity();
            self.lookupTable.clearRetainingCapacity();

            {
                const segmentCount = stream.getInt(u32);
                self.segments.ensureTotalCapacity(segmentCount) catch unreachable;

                var i: u32 = 0;
                while (i < segmentCount) : (i += 1) {
                    var s: *CurveSegment = self.segments.addOneAssumeCapacity();

                    s.curve.startPoint = stream.get(T);
                    s.curve.startPointTangent = stream.get(T);
                    s.curve.endPoint = stream.get(T);
                    s.curve.endPointTangent = stream.get(T);

                    s.length = stream.getFloat();
                    s.startT = stream.getFloat();
                    s.endT = stream.getFloat();
                }
            }

            {
                const lutSampleCount = stream.getInt(u32);
                self.lookupTable.ensureTotalCapacity(lutSampleCount) catch unreachable;

                var i: u32 = 0;
                while (i < lutSampleCount) : (i += 1) {
                    var s: *LUTSample = self.lookupTable.addOneAssumeCapacity();

                    s.position = stream.get(T);
                    s.direction = stream.get(T);
                    s.t = stream.getFloat();
                }
            }
        }

        pub fn serialize(self: Self, stream: *basis.BinaryWriteStream) void {
            const segmentCount: u32 = @intCast(self.segments.items.len);
            stream.putInt(u32, segmentCount);

            for (self.segments.items) |s| {
                stream.put(T, s.curve.startPoint);
                stream.put(T, s.curve.startPointTangent);
                stream.put(T, s.curve.endPoint);
                stream.put(T, s.curve.endPointTangent);

                stream.putFloat(s.length);
                stream.putFloat(s.startT);
                stream.putFloat(s.endT);
            }

            const lutSampleCount: u32 = @intCast(self.lookupTable.items.len);
            stream.putInt(u32, lutSampleCount);

            for (self.lookupTable.items) |s| {
                stream.put(T, s.position);
                stream.put(T, s.direction);
                stream.putFloat(s.t);
            }
        }

        //----------------------------------------------------

        fn debugDraw3D(self: *const Self, drawControlPoints: bool, drawLookupTablePositions: bool, pathColor: basis.Color) void {
            const StartCpColor = basis.Color.init(0, 255, 0);
            const EndCpColor = basis.Color.init(255, 0, 0);
            const LutColor = basis.Color.White;

            for (self.segments.items) |s| {
                const Resolution = 30.0;
                const StepSize = 1.0 / Resolution;

                var t: f32 = 0.0;
                var prevPos: T = s.curve.getPointAtT(t);

                while (t < 1.0) {
                    t = std.math.clamp(t + StepSize, 0.0, 1.0);
                    const p = s.curve.getPointAtT(t);
                    basis.debug_draw.drawLine3D(prevPos, p, pathColor);
                    prevPos = p;
                }

                if (drawControlPoints) {
                    basis.debug_draw.drawSphere(s.curve.startPointTangent, 0.5, StartCpColor);
                    basis.debug_draw.drawLine3D(s.curve.startPoint, s.curve.startPointTangent, StartCpColor);

                    basis.debug_draw.drawSphere(s.curve.endPointTangent, 0.5, EndCpColor);
                    basis.debug_draw.drawLine3D(s.curve.endPoint, s.curve.endPointTangent, EndCpColor);
                }
            }

            if (drawLookupTablePositions) {
                for (self.lookupTable.items) |s| {
                    basis.debug_draw.drawSphere(s.position, 0.5, LutColor);
                }
            }
        }
    };
}
