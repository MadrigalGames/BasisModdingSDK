// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
//const vhl = @import("vhl.zig");

pub const PIDData = struct {
    p: f32 = 1.0,
    i: f32 = 1.0,
    d: f32 = 1.0,
    min: f32 = -basis.math.LargestNumber,
    max: f32 = basis.math.LargestNumber,
    minIntegral: f32 = -basis.math.LargestNumber,
    maxIntegral: f32 = basis.math.LargestNumber,
    integral: f32 = 0.0,
    prevError: f32 = 0.0,
};

pub fn update(data: *PIDData, err: f32, deltaTime: f32, signChangeIntegralReset: bool) f32 {
    data.integral += err * deltaTime;

    // We allow limiting the integral value to fight integral windup.
    // https://en.wikipedia.org/wiki/Integral_windup
    data.integral = std.math.clamp(data.integral, data.minIntegral, data.maxIntegral);

    const derivative = (err - data.prevError) / deltaTime;

    if (signChangeIntegralReset) {
        // We allow resetting the integral when the error is zero or changes sign.
        // See the last paragraph of the integral windup article above.
        // We seem to be getting nicer results with cruise control and driving AI
        // if we don't zero the term completely but rather halve it.
        if (std.math.approxEqAbs(f32, err, 0.0, 0.000001) or
            (std.math.sign(err) != std.math.sign(data.prevError)))
        {
            //data.integral = 0.0;
            data.integral *= 0.5;
        }
    }

    data.prevError = err;

    const result =
        err * data.p +
        data.integral * data.i +
        derivative * data.d;

    return std.math.clamp(result, data.min, data.max);
}

pub fn clear(data: *PIDData) void {
    data.integral = 0.0;
    data.prevError = 0.0;
}
