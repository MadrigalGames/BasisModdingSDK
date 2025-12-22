// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub fn CubicBezierCurve(comptime T: type) type {
    return struct {
        const Self = @This();

        startPoint: T = T.Zero,
        startPointTangent: T = T.Zero,
        endPoint: T = T.Zero,
        endPointTangent: T = T.Zero,

        pub fn set(self: *Self, startPoint: T, startPointTangent: T, endPoint: T, endPointTangent: T) void {
            self.startPoint = startPoint;
            self.startPointTangent = startPointTangent;
            self.endPoint = endPoint;
            self.endPointTangent = endPointTangent;
        }

        /// Get a point on the curve given a value, t, which goes from 0 (at the start point) to 1 (at the end point).
        pub fn getPointAtT(self: *const Self, t: f32) T {
            basis.assertd(@src(), t >= 0.0 and t <= 1.0, "The value of t must be between 0 and 1.");

            const u = 1.0 - t;
            const tt = t * t;
            const uu = u * u;
            const uuu = uu * u;
            const ttt = tt * t;

            var p: T = self.startPoint.multiplyFloat(uuu); // first term
            p = p.add(self.startPointTangent.multiplyFloat(3.0 * uu * t)); // second term
            p = p.add(self.endPointTangent.multiplyFloat(3.0 * u * tt)); // third term
            p = p.add(self.endPoint.multiplyFloat(ttt)); // fourth term

            return p;
        }

        /// Get the first derivative on the curve given a value, t, which goes from 0 (at the start point) to 1 (at the end point).
        pub fn getDerivativeAtT(self: *const Self, t: f32) T {
            basis.assertd(@src(), t >= 0.0 and t <= 1.0, "The value of t must be between 0 and 1.");

            const u = 1.0 - t;
            const tt = t * t;
            const uu = u * u;

            var p: T = self.startPointTangent.sub(self.startPoint).multiplyFloat(uu * 3.0);
            p = p.add(self.endPointTangent.sub(self.startPointTangent).multiplyFloat(t * u * 6.0));
            p = p.add(self.endPoint.sub(self.endPointTangent).multiplyFloat(tt * 3.0));

            return p;
        }
    };
}
