// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Vec4 = basis.math.Vec4;
const Quaternion = basis.math.Quaternion;

pub const Mat43 = struct {
    //x: Vec3, // _11, _12, _13
    //y: Vec3, // _21, _22, _23
    //z: Vec3, // _31, _32, _33
    //t: Vec3, // _41, _42, _43

    _11: f32,
    _12: f32,
    _13: f32,

    _21: f32,
    _22: f32,
    _23: f32,

    _31: f32,
    _32: f32,
    _33: f32,

    _41: f32,
    _42: f32,
    _43: f32,

    pub const Identity = init(
        Vec3.init(1.0, 0.0, 0.0),
        Vec3.init(0.0, 1.0, 0.0),
        Vec3.init(0.0, 0.0, 1.0),
        Vec3.init(0.0, 0.0, 0.0),
    );

    pub fn init(x: Vec3, y: Vec3, z: Vec3, t: Vec3) Mat43 {
        return Mat43{
            ._11 = x.x,
            ._12 = x.y,
            ._13 = x.z,

            ._21 = y.x,
            ._22 = y.y,
            ._23 = y.z,

            ._31 = z.x,
            ._32 = z.y,
            ._33 = z.z,

            ._41 = t.x,
            ._42 = t.y,
            ._43 = t.z,
        };
    }

    pub fn getX(self: Mat43) Vec3 {
        return Vec3.init(self._11, self._12, self._13);
    }

    pub fn getY(self: Mat43) Vec3 {
        return Vec3.init(self._21, self._22, self._23);
    }

    pub fn getZ(self: Mat43) Vec3 {
        return Vec3.init(self._31, self._32, self._33);
    }

    pub fn getT(self: Mat43) Vec3 {
        return Vec3.init(self._41, self._42, self._43);
    }

    pub fn getX4(self: Mat43) Vec4 {
        return Vec4.init(self._11, self._12, self._13, 0.0);
    }

    pub fn getY4(self: Mat43) Vec4 {
        return Vec4.init(self._21, self._22, self._23, 0.0);
    }

    pub fn getZ4(self: Mat43) Vec4 {
        return Vec4.init(self._31, self._32, self._33, 0.0);
    }

    pub fn getT4(self: Mat43) Vec4 {
        return Vec4.init(self._41, self._42, self._43, 1.0);
    }

    pub fn fromLocalAxesPosition(localX: Vec3, localY: Vec3, localZ: Vec3, position: Vec3) Mat43 {
        return Mat43{
            ._11 = localX.x,
            ._12 = localX.y,
            ._13 = localX.z,

            ._21 = localY.x,
            ._22 = localY.y,
            ._23 = localY.z,

            ._31 = localZ.x,
            ._32 = localZ.y,
            ._33 = localZ.z,

            ._41 = position.x,
            ._42 = position.y,
            ._43 = position.z,
        };
    }

    pub fn fromOrientationPosition(orientation: Quaternion, position: Vec3) Mat43 {
        //const ww: f32 = 2.0 * orientation.w;
        const xx: f32 = 2.0 * orientation.x;
        const yy: f32 = 2.0 * orientation.y;
        const zz: f32 = 2.0 * orientation.z;

        return Mat43{
            ._11 = 1.0 - (yy * orientation.y + zz * orientation.z),
            ._12 = yy * orientation.x - zz * orientation.w,
            ._13 = zz * orientation.x + yy * orientation.w,

            ._21 = yy * orientation.x + zz * orientation.w,
            ._22 = 1.0 - (xx * orientation.x + zz * orientation.z),
            ._23 = zz * orientation.y - xx * orientation.w,

            ._31 = zz * orientation.x - yy * orientation.w,
            ._32 = zz * orientation.y + xx * orientation.w,
            ._33 = 1.0 - (xx * orientation.x + yy * orientation.y),

            ._41 = position.x,
            ._42 = position.y,
            ._43 = position.z,
        };
    }

    pub fn inverse(self: Mat43) Mat43 {
        var v0: f32 = self._31 * self._42 - self._32 * self._41;
        var v1: f32 = self._31 * self._43 - self._33 * self._41;
        var v2: f32 = self._31;
        var v3: f32 = self._32 * self._43 - self._33 * self._42;
        var v4: f32 = self._32;
        var v5: f32 = self._33;

        const t00: f32 = (v5 * self._22 - v4 * self._23);
        const t10: f32 = -(v5 * self._21 - v2 * self._23);
        const t20: f32 = (v4 * self._21 - v2 * self._22);
        const t30: f32 = -(v3 * self._21 - v1 * self._22 + v0 * self._23);

        const invDet: f32 = 1.0 / (t00 * self._11 + t10 * self._12 + t20 * self._13);

        const d00: f32 = t00 * invDet;
        const d10: f32 = t10 * invDet;
        const d20: f32 = t20 * invDet;
        const d30: f32 = t30 * invDet;

        const d01: f32 = -(v5 * self._12 - v4 * self._13) * invDet;
        const d11: f32 = (v5 * self._11 - v2 * self._13) * invDet;
        const d21: f32 = -(v4 * self._11 - v2 * self._12) * invDet;
        const d31: f32 = (v3 * self._11 - v1 * self._12 + v0 * self._13) * invDet;

        v0 = self._21 * self._42 - self._22 * self._41;
        v1 = self._21 * self._43 - self._23 * self._41;
        v2 = self._21;
        v3 = self._22 * self._43 - self._23 * self._42;
        v4 = self._22;
        v5 = self._23;

        const d02: f32 = (v5 * self._12 - v4 * self._13) * invDet;
        const d12: f32 = -(v5 * self._11 - v2 * self._13) * invDet;
        const d22: f32 = (v4 * self._11 - v2 * self._12) * invDet;
        const d32: f32 = -(v3 * self._11 - v1 * self._12 + v0 * self._13) * invDet;

        return Mat43{
            ._11 = d00,
            ._12 = d01,
            ._13 = d02,

            ._21 = d10,
            ._22 = d11,
            ._23 = d12,

            ._31 = d20,
            ._32 = d21,
            ._33 = d22,

            ._41 = d30,
            ._42 = d31,
            ._43 = d32,
        };
    }

    pub fn concatenate(self: Mat43, m: Mat43) Mat43 {
        var r = Mat43.Identity;

        r._11 = self._11 * m._11 + self._12 * m._21 + self._13 * m._31;
        r._12 = self._11 * m._12 + self._12 * m._22 + self._13 * m._32;
        r._13 = self._11 * m._13 + self._12 * m._23 + self._13 * m._33;

        r._21 = self._21 * m._11 + self._22 * m._21 + self._23 * m._31;
        r._22 = self._21 * m._12 + self._22 * m._22 + self._23 * m._32;
        r._23 = self._21 * m._13 + self._22 * m._23 + self._23 * m._33;

        r._31 = self._31 * m._11 + self._32 * m._21 + self._33 * m._31;
        r._32 = self._31 * m._12 + self._32 * m._22 + self._33 * m._32;
        r._33 = self._31 * m._13 + self._32 * m._23 + self._33 * m._33;

        r._41 = self._41 * m._11 + self._42 * m._21 + self._43 * m._31 + m._41;
        r._42 = self._41 * m._12 + self._42 * m._22 + self._43 * m._32 + m._42;
        r._43 = self._41 * m._13 + self._42 * m._23 + self._43 * m._33 + m._43;

        return r;
    }

    pub fn transformPoint(self: Mat43, v: Vec3) Vec3 {
        const x = self._11 * v.x + self._21 * v.y + self._31 * v.z + self._41;
        const y = self._12 * v.x + self._22 * v.y + self._32 * v.z + self._42;
        const z = self._13 * v.x + self._23 * v.y + self._33 * v.z + self._43;
        return Vec3.init(x, y, z);
    }

    pub fn transformDirection(self: Mat43, v: Vec3) Vec3 {
        const x = self._11 * v.x + self._21 * v.y + self._31 * v.z;
        const y = self._12 * v.x + self._22 * v.y + self._32 * v.z;
        const z = self._13 * v.x + self._23 * v.y + self._33 * v.z;
        return Vec3.init(x, y, z);
    }

    pub fn transform(self: Mat43, v: Vec4) Vec4 {
        const x = self._11 * v.x + self._21 * v.y + self._31 * v.z + self._41 * v.w;
        const y = self._12 * v.x + self._22 * v.y + self._32 * v.z + self._42 * v.w;
        const z = self._13 * v.x + self._23 * v.y + self._33 * v.z + self._43 * v.w;
        const w = v.w;
        return Vec4.init(x, y, z, w);
    }

    pub fn setTranslation(self: *Mat43, t: Vec3) void {
        self._41 = t.x;
        self._42 = t.y;
        self._43 = t.z;
    }

    pub fn initRotationX(angle: f32) Mat43 {
        const sinAngle = @sin(angle);
        const cosAngle = @cos(angle);

        return Mat43{
            ._11 = 1.0,
            ._12 = 0.0,
            ._13 = 0.0,

            ._21 = 0.0,
            ._22 = cosAngle,
            ._23 = sinAngle,

            ._31 = 0.0,
            ._32 = -sinAngle,
            ._33 = cosAngle,

            ._41 = 0.0,
            ._42 = 0.0,
            ._43 = 0.0,
        };
    }

    pub fn initRotationY(angle: f32) Mat43 {
        const sinAngle = @sin(angle);
        const cosAngle = @cos(angle);

        return Mat43{
            ._11 = cosAngle,
            ._12 = 0.0,
            ._13 = -sinAngle,

            ._21 = 0.0,
            ._22 = 1.0,
            ._23 = 0.0,

            ._31 = sinAngle,
            ._32 = 0.0,
            ._33 = cosAngle,

            ._41 = 0.0,
            ._42 = 0.0,
            ._43 = 0.0,
        };
    }

    pub fn initRotationZ(angle: f32) Mat43 {
        const sinAngle = @sin(angle);
        const cosAngle = @cos(angle);

        return Mat43{
            ._11 = cosAngle,
            ._12 = sinAngle,
            ._13 = 0.0,

            ._21 = -sinAngle,
            ._22 = cosAngle,
            ._23 = 0.0,

            ._31 = 0.0,
            ._32 = 0.0,
            ._33 = 1.0,

            ._41 = 0.0,
            ._42 = 0.0,
            ._43 = 0.0,
        };
    }

    pub fn fromEulerAnglesXYZ(eulerAngles: Vec3) Mat43 {
        const x = Mat43.initRotationX(eulerAngles.x);
        const y = Mat43.initRotationY(eulerAngles.y);
        const z = Mat43.initRotationZ(eulerAngles.z);

        return x.concatenate(y).concatenate(z);
    }

    pub fn lookAt(self: *Mat43, eyePos: Vec3, lookAtPos: Vec3, upDir: Vec3) void {
        const eyeDirection = lookAtPos.sub(eyePos);
        self.lookTo(eyeDirection, upDir);
    }

    pub fn lookTo(self: *Mat43, eyeDir: Vec3, upDir: Vec3) void {
        var r2 = eyeDir;
        r2.normalize();

        var r0 = upDir.cross(r2);
        r0.normalize();

        const r1 = r2.cross(r0);

        self._11 = r0.x;
        self._12 = r0.y;
        self._13 = r0.z;
        self._21 = r1.x;
        self._22 = r1.y;
        self._23 = r1.z;
        self._31 = r2.x;
        self._32 = r2.y;
        self._33 = r2.z;
        self._41 = 0.0;
        self._42 = 0.0;
        self._43 = 0.0;
    }

    pub fn lookAtSafe(self: *Mat43, eyePos: Vec3, lookAtPos: Vec3, upDir: Vec3) void {
        const eyeDirection = lookAtPos.sub(eyePos);
        self.lookToSafe(eyeDirection, upDir);
    }

    pub fn lookToSafe(self: *Mat43, eyeDir: Vec3, upDir: Vec3) void {
        // Check if the upDir and eyeDir are parallel. If they are, we need to alter upDir a little.

        var ed = eyeDir;
        ed.normalize();

        var ud = upDir;
        ud.normalize();

        if (@abs(ed.dot(ud)) >= 0.999) {
            const ONE_DEGREE_IN_RADIANS = 0.0174533;
            const q = Quaternion.initRotationX(ONE_DEGREE_IN_RADIANS); // Rotate one degree around X.
            ud = q.applyRotationTo(ud);
        }

        self.lookTo(ed, ud);
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Mat43, stream: *basis.BinaryReadStream) void {
        self._11 = stream.getFloat();
        self._12 = stream.getFloat();
        self._13 = stream.getFloat();

        self._21 = stream.getFloat();
        self._22 = stream.getFloat();
        self._23 = stream.getFloat();

        self._31 = stream.getFloat();
        self._32 = stream.getFloat();
        self._33 = stream.getFloat();

        self._41 = stream.getFloat();
        self._42 = stream.getFloat();
        self._43 = stream.getFloat();
    }

    pub fn serialize(self: Mat43, stream: *basis.BinaryWriteStream) void {
        stream.putFloat(self._11);
        stream.putFloat(self._12);
        stream.putFloat(self._13);

        stream.putFloat(self._21);
        stream.putFloat(self._22);
        stream.putFloat(self._23);

        stream.putFloat(self._31);
        stream.putFloat(self._32);
        stream.putFloat(self._33);

        stream.putFloat(self._41);
        stream.putFloat(self._42);
        stream.putFloat(self._43);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Mat43) basis.bindings.InteropMat43 {
        return basis.bindings.InteropMat43{
            ._11 = self._11,
            ._12 = self._12,
            ._13 = self._13,

            ._21 = self._21,
            ._22 = self._22,
            ._23 = self._23,

            ._31 = self._31,
            ._32 = self._32,
            ._33 = self._33,

            ._41 = self._41,
            ._42 = self._42,
            ._43 = self._43,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropMat43) Mat43 {
        return Mat43{
            ._11 = interop._11,
            ._12 = interop._12,
            ._13 = interop._13,
            ._21 = interop._21,
            ._22 = interop._22,
            ._23 = interop._23,
            ._31 = interop._31,
            ._32 = interop._32,
            ._33 = interop._33,
            ._41 = interop._41,
            ._42 = interop._42,
            ._43 = interop._43,
        };
    }
};
