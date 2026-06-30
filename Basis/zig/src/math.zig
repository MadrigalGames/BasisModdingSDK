// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const scene_node = @import("math/scene_node.zig");

pub const Vec2 = @import("math/vec2.zig").Vec2;
pub const Vec3 = @import("math/vec3.zig").Vec3;
pub const Vec4 = @import("math/vec4.zig").Vec4;
pub const Vec2Int = @import("math/vec2int.zig").Vec2Int;
pub const Vec3Int = @import("math/vec3int.zig").Vec3Int;
pub const Quaternion = @import("math/quaternion.zig").Quaternion;
pub const SceneNodePtr = scene_node.SceneNodePtr;
pub const Mat43 = @import("math/mat43.zig").Mat43;
pub const Mat4 = @import("math/mat4.zig").Mat4;
pub const TransformInterpolator = @import("math/interpolation.zig").TransformInterpolator;
pub const VectorInterpolator = @import("math/interpolation.zig").VectorInterpolator;
pub const QuaternionInterpolator = @import("math/interpolation.zig").QuaternionInterpolator;
pub const FloatInterpolator = @import("math/interpolation.zig").FloatInterpolator;
pub const InterpolatedTransform = @import("math/interpolated_transform.zig").InterpolatedTransform;
pub const AABB = @import("math/aabb.zig").AABB;
pub const AABB2D = @import("math/aabb2d.zig").AABB2D;
pub const CubicBezierCurve2D = @import("math/cubic_bezier_curve.zig").CubicBezierCurve(Vec2);
pub const CubicBezierCurve3D = @import("math/cubic_bezier_curve.zig").CubicBezierCurve(Vec3);
pub const CurvePath = @import("math/curve_path.zig").CurvePath;
pub const CurvePath2D = CurvePath(Vec2);
pub const CurvePath3D = CurvePath(Vec3);
pub const CurvePathCalculator = @import("math/curve_path_calculator.zig").CurvePathCalculator;
pub const CurvePathCalculator2D = CurvePathCalculator(Vec2);
pub const CurvePathCalculator3D = CurvePathCalculator(Vec3);
pub const FixedLookupTable = @import("math/fixed_lookup_table.zig").FixedLookupTable;
pub const Plane = @import("math/plane.zig").Plane;

pub const Prng = std.Random.DefaultPrng;

pub const CoordinateSpace = enum(i32) {
    Local = 0,
    Parent = 1,
    World = 2,
};

pub const Pi = std.math.pi;
pub const HalfPi = std.math.pi * 0.5;
pub const TwoPi = std.math.tau;

pub const LargestNumber = 3.402823466e+38;
pub const SmallestNumber = 1.175494351e-38;

pub const LargeNumber = 1.0e+20;

//----------------------------------------------------

// Shorthand ctors:

pub fn vec2(x: f32, y: f32) Vec2 {
    return Vec2.init(x, y);
}

pub fn vec2Int(x: i32, y: i32) Vec2Int {
    return Vec2Int.init(x, y);
}

pub fn vec3(x: f32, y: f32, z: f32) Vec3 {
    return Vec3.init(x, y, z);
}

pub fn vec3Int(x: i32, y: i32, z: i32) Vec3Int {
    return Vec3Int.init(x, y, z);
}

pub fn vec4(x: f32, y: f32, z: f32, w: f32) Vec4 {
    return Vec4.init(x, y, z, w);
}

//----------------------------------------------------

pub fn floatsAlmostEqual(v1: f32, v2: f32) bool {
    return std.math.approxEqAbs(f32, v1, v2, 0.000001);
}

pub fn floatsAlmostEqualEpsilon(v1: f32, v2: f32, epsilon: f32) bool {
    return std.math.approxEqAbs(f32, v1, v2, epsilon);
}

pub fn vec2sAlmostEqual(v1: Vec2, v2: Vec2) bool {
    return std.math.approxEqAbs(f32, v1.x, v2.x, 0.000001) and
        std.math.approxEqAbs(f32, v1.y, v2.y, 0.000001);
}

pub fn vec3sAlmostEqual(v1: Vec3, v2: Vec3) bool {
    return std.math.approxEqAbs(f32, v1.x, v2.x, 0.000001) and
        std.math.approxEqAbs(f32, v1.y, v2.y, 0.000001) and
        std.math.approxEqAbs(f32, v1.z, v2.z, 0.000001);
}

//----------------------------------------------------

pub fn lerp(p: f32, f0: f32, f1: f32) f32 {
    return f0 + p * (f1 - f0);
}

pub fn smoothStep(p: f32, f0: f32, f1: f32) f32 {
    return lerp((p * p) * (3.0 - 2.0 * p), f0, f1);
}

//----------------------------------------------------

pub fn remapFloat(p: f32, oldMin: f32, oldMax: f32, newMin: f32, newMax: f32) f32 {
    // oldMin cannot be larger than oldMax, but newMin can be larger than newMax.
    if (oldMin > oldMax) {
        return remapFloat(p, oldMax, oldMin, newMax, newMin);
    }

    const clampedP = std.math.clamp(p, oldMin, oldMax);
    return newMin + (clampedP - oldMin) * (newMax - newMin) / (oldMax - oldMin);
}

pub fn getRandomFloat(random: std.Random, min: f32, max: f32) f32 {
    const r = random.float(f32);
    return min + r * (max - min);
}

/// Return a new pseudo-RNG, initialized with random bytes provided by the OS.
pub fn initNewPrng() Prng {
    // The original code. This doesn't work on WASM without WASI support.
    // var seed: u64 = undefined;
    // std.posix.getrandom(std.mem.asBytes(&seed)) catch |err| {
    //     basis.assertf(@src(), false, "Error getting random bytes for Prng: {s}", .{@errorName(err)});
    // };

    // The new code. We get the random bytes from the C++ side.
    const seed = basis.bindings.api.Core_getRandomSeed();

    return Prng.init(seed);
}

//----------------------------------------------------

pub fn rotateVec2(p: Vec2, origin: Vec2, angle: f32) Vec2 {
    const x = std.math.cos(angle) * (p.x - origin.x) - std.math.sin(angle) * (p.y - origin.y) + origin.x;
    const y = std.math.sin(angle) * (p.x - origin.x) + std.math.cos(angle) * (p.y - origin.y) + origin.y;
    return Vec2.init(x, y);
}

// Checks if two 2D lines intersect. If out is given, it is set to the point along lineB (0-1) where the intersection occurs.
pub fn intersectLines2D(lineAStart: Vec2, lineAEnd: Vec2, lineBStart: Vec2, lineBEnd: Vec2, out: ?*f32) bool {
    const a = lineAEnd.sub(lineAStart);
    const b = lineBEnd.sub(lineBStart);

    const f = a.perpDot(b);
    if (floatsAlmostEqual(f, 0.0)) {
        // Lines are parallel.
        return false;
    }

    const c = lineBEnd.sub(lineAEnd);
    const aa = a.perpDot(c);
    const bb = b.perpDot(c);

    if (f < 0.0) {
        if (aa > 0.0) return false;
        if (bb > 0.0) return false;
        if (aa < f) return false;
        if (bb < f) return false;
    } else {
        if (aa < 0.0) return false;
        if (bb < 0.0) return false;
        if (aa > f) return false;
        if (bb > f) return false;
    }

    if (out) |o| {
        o.* = 1.0 - (aa / f);
    }

    return true;
}

//----------------------------------------------------

/// A version of acos that checks for invalid x values and returns safe values regardless.
pub fn safeAcos(x: f32) f32 {
    if (x <= -1.0) {
        return Pi;
    }

    if (x >= 1.0) {
        return 0.0;
    }

    return std.math.acos(x);
}
