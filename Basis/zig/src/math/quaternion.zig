// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Mat43 = basis.math.Mat43;

pub const Quaternion = struct {
    w: f32,
    x: f32,
    y: f32,
    z: f32,

    pub const Identity = init(1.0, 0.0, 0.0, 0.0);

    pub fn init(w: f32, x: f32, y: f32, z: f32) Quaternion {
        return Quaternion{
            .w = w,
            .x = x,
            .y = y,
            .z = z,
        };
    }

    pub fn initFromRotationMatrix(m: Mat43) Quaternion {
        var q = Quaternion.Identity;
        q.fromRotationMatrix(m);
        return q;
    }

    pub fn initFromAngleAxis(theta: f32, axis: Vec3) Quaternion {
        const normalizedAxis = axis.normalized();

        // Compute the half angle and its sin.
        const thetaOver2 = theta * 0.5;
        const sinThetaOver2 = std.math.sin(thetaOver2);

        // Set the values.
        return Quaternion{
            .w = std.math.cos(thetaOver2),
            .x = normalizedAxis.x * sinThetaOver2,
            .y = normalizedAxis.y * sinThetaOver2,
            .z = normalizedAxis.z * sinThetaOver2,
        };
    }

    pub fn initRotationX(theta: f32) Quaternion {
        var q = Quaternion.Identity;
        q.setRotationX(theta);
        return q;
    }

    pub fn initRotationY(theta: f32) Quaternion {
        var q = Quaternion.Identity;
        q.setRotationY(theta);
        return q;
    }

    pub fn initRotationZ(theta: f32) Quaternion {
        var q = Quaternion.Identity;
        q.setRotationZ(theta);
        return q;
    }

    pub fn initFromSlice(slice: []const f32) Quaternion {
        return Quaternion{
            .w = slice[0],
            .x = slice[1],
            .y = slice[2],
            .z = slice[3],
        };
    }

    //----------------------------------------------------

    pub fn setRotationX(self: *Quaternion, theta: f32) void {
        const thetaOver2 = theta * 0.5;

        self.w = std.math.cos(thetaOver2);
        self.x = std.math.sin(thetaOver2);
        self.y = 0.0;
        self.z = 0.0;
    }

    pub fn setRotationY(self: *Quaternion, theta: f32) void {
        const thetaOver2 = theta * 0.5;

        self.w = std.math.cos(thetaOver2);
        self.x = 0.0;
        self.y = std.math.sin(thetaOver2);
        self.z = 0.0;
    }

    pub fn setRotationZ(self: *Quaternion, theta: f32) void {
        const thetaOver2 = theta * 0.5;

        self.w = std.math.cos(thetaOver2);
        self.x = 0.0;
        self.y = 0.0;
        self.z = std.math.sin(thetaOver2);
    }

    //----------------------------------------------------

    pub fn length(self: Quaternion) f32 {
        return std.math.sqrt(self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z);
    }

    pub fn normalize(self: *Quaternion) void {
        // Get length.
        const len = self.length();

        // Check for bogus length, to protect against divide by zero.
        basis.assertd(@src(), len > 0.0, "Negative length in quaternion.");

        // Normalize.
        const oneOverLen = 1.0 / len;
        self.w *= oneOverLen;
        self.x *= oneOverLen;
        self.y *= oneOverLen;
        self.z *= oneOverLen;
    }

    pub fn dot(self: Quaternion, rhs: Quaternion) f32 {
        return self.w * rhs.w + self.x * rhs.x + self.y * rhs.y + self.z * rhs.z;
    }

    pub fn fromRotationMatrix(self: *Quaternion, m: Mat43) void {
        // Algorithm in Ken Shoemake's article in 1987 SIGGRAPH course notes article "Quaternion Calculus and Fast Animation".

        const trace = m._11 + m._22 + m._33;

        // Matrix becomes unstable if the trace is too small.
        if (trace > 0.0) {
            var root = std.math.sqrt(trace + 1.0);
            self.w = 0.5 * root;
            root = 0.5 / root;
            self.x = (m._23 - m._32) * root;
            self.y = (m._31 - m._13) * root;
            self.z = (m._12 - m._21) * root;
        } else {
            // Create a temp array that allows indexing into the vector part of the quaternion.
            const V: [3]*f32 = .{ &self.x, &self.y, &self.z };

            // Create a temp struct holding the rotation part of the matrix, for easy indexing below.
            const tempRot = [3][3]f32{
                [_]f32{ m._11, m._12, m._13 },
                [_]f32{ m._21, m._22, m._23 },
                [_]f32{ m._31, m._32, m._33 },
            };

            var i: usize = 0;
            var j: usize = 1;
            var k: usize = 2;

            if (tempRot[1][1] > tempRot[0][0]) {
                // The second trace component is larger than the first.
                i = 1;
                j = 2;
                k = 0;
            }

            if (tempRot[2][2] > tempRot[i][i]) {
                // The third trace component is larger than the first or second.
                i = 2;
                j = 0;
                k = 1;
            }

            var root = std.math.sqrt(tempRot[i][i] - tempRot[j][j] - tempRot[k][k] + 1.0);

            V[i].* = 0.5 * root;

            root = 0.5 / root;
            self.w = (tempRot[j][k] - tempRot[k][j]) * root;

            V[j].* = (tempRot[j][i] + tempRot[i][j]) * root;
            V[k].* = (tempRot[k][i] + tempRot[i][k]) * root;
        }
    }

    pub fn slerp(t: f32, q0: Quaternion, q1: Quaternion) Quaternion {
        // From 3D Math Primer for Games and Graphics Development:

        // Check for out-of range parameter and return edge points if so

        if (t <= 0.0) return q0;
        if (t >= 1.0) return q1;

        // Compute "cosine of angle between quaternions" using dot product

        var cosOmega: f32 = q0.dot(q1);

        // If negative dot, use -q1. Two quaternions q and -q
        // represent the same rotation, but may produce
        // different slerp. We chose q or -q to rotate using
        // the acute angle.

        var q1w: f32 = q1.w;
        var q1x: f32 = q1.x;
        var q1y: f32 = q1.y;
        var q1z: f32 = q1.z;

        if (cosOmega < 0.0) {
            q1w = -q1w;
            q1x = -q1x;
            q1y = -q1y;
            q1z = -q1z;
            cosOmega = -cosOmega;
        }

        // We should have two unit quaternions, so dot should be <= 1.0

        //BASIS_ASSERT(cosOmega < 1.1);

        // Compute interpolation fraction, checking for quaternions almost exactly the same

        var k0: f32 = 0.0;
        var k1: f32 = 0.0;
        if (cosOmega > 0.9999) {
            // Very close - just use linear interpolation, which will protect against a divide by zero

            k0 = 1.0 - t;
            k1 = t;
        } else {
            // Compute the sin of the angle using the trig identity sin^2(omega) + cos^2(omega) = 1

            const sinOmega: f32 = std.math.sqrt(1.0 - cosOmega * cosOmega);

            // Compute the angle from its sin and cosine

            const omega: f32 = std.math.atan2(sinOmega, cosOmega);

            // Compute inverse of denominator, so we only have to divide once

            const oneOverSinOmega: f32 = 1.0 / sinOmega;

            // Compute interpolation parameters

            k0 = std.math.sin((1.0 - t) * omega) * oneOverSinOmega;
            k1 = std.math.sin(t * omega) * oneOverSinOmega;
        }

        // Interpolate
        return Quaternion{
            .x = k0 * q0.x + k1 * q1x,
            .y = k0 * q0.y + k1 * q1y,
            .z = k0 * q0.z + k1 * q1z,
            .w = k0 * q0.w + k1 * q1w,
        };
    }

    pub fn fromLocalAxes(self: *Quaternion, localX: Vec3, localY: Vec3, localZ: Vec3) void {
        const m: Mat43 = Mat43.fromLocalAxesPosition(localX, localY, localZ, Vec3.Zero);
        self.fromRotationMatrix(m);
    }

    pub fn conjugate(self: Quaternion) Quaternion {
        // Same rotation amount. Opposite axis of rotation.
        return Quaternion{
            .w = self.w,
            .x = -self.x,
            .y = -self.y,
            .z = -self.z,
        };
    }

    pub fn inverse(self: Quaternion) Quaternion {
        const norm = self.w * self.w + self.x * self.x + self.y * self.y + self.z * self.z;

        if (norm > 0.0) {
            const oneOverNorm = 1.0 / norm;
            return Quaternion.init(self.w * oneOverNorm, -self.x * oneOverNorm, -self.y * oneOverNorm, -self.z * oneOverNorm);
        } else {
            basis.assertd(@src(), false, "Error inverting quaternion!");
            return Identity; // Error fallback.
        }
    }

    pub fn concatenate(self: Quaternion, q: Quaternion) Quaternion {
        // The rotations occur in order from right to left.

        return Quaternion{
            .w = self.w * q.w - self.x * q.x - self.y * q.y - self.z * q.z,
            .x = self.w * q.x + self.x * q.w + self.y * q.z - self.z * q.y,
            .y = self.w * q.y + self.y * q.w + self.z * q.x - self.x * q.z,
            .z = self.w * q.z + self.z * q.w + self.x * q.y - self.y * q.x,
        };
    }

    pub fn applyRotationTo(self: Quaternion, direction: Vec3) Vec3 {
        var v = direction;
        const oldLen = v.normalizeAndReturnPrevLength();

        const vecQuat = Quaternion{
            .w = 0.0,
            .x = v.x,
            .y = v.y,
            .z = v.z,
        };

        var resQuat = vecQuat.concatenate(self.conjugate());
        resQuat = self.concatenate(resQuat);

        return Vec3.init(resQuat.x * oldLen, resQuat.y * oldLen, resQuat.z * oldLen);
    }

    pub fn getRotationAngle(self: Quaternion) f32 {
        // From 3D Math Primer for Games and Graphics Development:

        // Compute the half angle.  Remember that w = cos(theta / 2)

        const thetaOver2 = basis.math.safeAcos(self.w);

        // Return the rotation angle

        return thetaOver2 * 2.0;
    }

    pub fn getRotationAxis(self: Quaternion) Vec3 {
        // From 3D Math Primer for Games and Graphics Development:

        // Compute sin^2(theta/2).  Remember that w = cos(theta/2),
        // and sin^2(x) + cos^2(x) = 1

        const sinThetaOver2Sq = 1.0 - self.w * self.w;

        // Protect against numerical imprecision

        if (sinThetaOver2Sq <= 0.0) {
            // Identity quaternion, or numerical imprecision.  Just
            // return any valid vector, since it doesn't matter

            return Vec3.init(1.0, 0.0, 0.0);
        }

        // Compute 1 / sin(theta/2)
        const oneOverSinThetaOver2 = 1.0 / std.math.sqrt(sinThetaOver2Sq);

        // Return axis of rotation
        return Vec3.init(self.x * oneOverSinThetaOver2, self.y * oneOverSinThetaOver2, self.z * oneOverSinThetaOver2);
    }

    pub fn invert(self: *Quaternion) void {
        const i = self.inverse();
        self.x = i.x;
        self.y = i.y;
        self.z = i.z;
        self.w = i.w;
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Quaternion, stream: *basis.BinaryReadStream) void {
        self.w = stream.getFloat();
        self.x = stream.getFloat();
        self.y = stream.getFloat();
        self.z = stream.getFloat();
    }

    pub fn serialize(self: Quaternion, stream: *basis.BinaryWriteStream) void {
        stream.putFloat(self.w);
        stream.putFloat(self.x);
        stream.putFloat(self.y);
        stream.putFloat(self.z);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Quaternion) basis.bindings.InteropQuaternion {
        return basis.bindings.InteropQuaternion{
            .w = self.w,
            .x = self.x,
            .y = self.y,
            .z = self.z,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropQuaternion) Quaternion {
        return Quaternion{
            .w = interop.w,
            .x = interop.x,
            .y = interop.y,
            .z = interop.z,
        };
    }
};

//----------------------------------------------------

test "Quaternion.fromRotationMatrix matches Quaternion.initRotationY" {
    const theta = std.math.pi / 4.0;
    const qm = Quaternion.initFromRotationMatrix(Mat43.initRotationY(theta));
    const qd = Quaternion.initRotationY(theta);
    const v = Vec3.init(1.0, 2.0, 3.0);
    try std.testing.expect(basis.math.vec3sAlmostEqual(qd.applyRotationTo(v), qm.applyRotationTo(v)));
}

test "Quaternion -> Mat43 -> Quaternion round-trip preserves rotation" {
    const q = Quaternion.initFromAngleAxis(1.2, Vec3.init(0.3, 0.7, 0.5));
    const m = Mat43.fromOrientationPosition(q, Vec3.Zero);
    const qr = Quaternion.initFromRotationMatrix(m);
    const v = Vec3.init(1.0, 2.0, 3.0);
    try std.testing.expect(basis.math.vec3sAlmostEqual(q.applyRotationTo(v), qr.applyRotationTo(v)));
}
