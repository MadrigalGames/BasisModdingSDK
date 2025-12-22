// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;
const Mat43 = basis.math.Mat43;

pub const PhysicsTransform = struct {
    position: Vec3,
    orientation: Quaternion,

    pub const Identity = init(Vec3.Zero, Quaternion.Identity);

    pub fn init(position: Vec3, orientation: Quaternion) PhysicsTransform {
        return PhysicsTransform{
            .position = position,
            .orientation = orientation,
        };
    }

    pub fn initFromMatrix(matrix: Mat43) PhysicsTransform {
        const pos = matrix.getT();
        const ori = Quaternion.initFromRotationMatrix(matrix);

        return PhysicsTransform{
            .position = pos,
            .orientation = ori,
        };
    }
};
