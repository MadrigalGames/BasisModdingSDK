// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;

pub const Plane = struct {
    a: f32,
    b: f32,
    c: f32,
    d: f32,

    pub fn initFromOriginAndNormal(origin: Vec3, normal: Vec3) Plane {
        basis.assertd(
            @src(),
            basis.math.floatsAlmostEqual(normal.squaredLength(), 1.0),
            "The normal is not of unit length.",
        );

        return Plane{
            .a = normal.x,
            .b = normal.y,
            .c = normal.z,
            .d = -(origin.x * normal.x + origin.y * normal.y + origin.z * normal.z),
        };
    }

    //----------------------------------------------------

    pub fn getNormal(self: Plane) Vec3 {
        return Vec3.init(self.a, self.b, self.c);
    }

    pub fn getOrigin(self: Plane) Vec3 {
        return Vec3.init(self.a, self.b, self.c).multiplyFloat(-self.d);
    }

    pub fn getSignedDistanceToPoint(self: Plane, p: Vec3) f32 {
        const v = p.sub(self.getOrigin());
        return Vec3.init(self.a, self.b, self.c).dot(v);
    }

    pub fn project(self: Plane, p: Vec3) Vec3 {
        const normal = Vec3.init(self.a, self.b, self.c);
        const dist = self.getSignedDistanceToPoint(p);
        return p.sub(normal.multiplyFloat(dist));
    }
};
