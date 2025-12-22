// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec4 = basis.math.Vec4;

pub const Mat4 = struct {
    _11: f32,
    _12: f32,
    _13: f32,
    _14: f32,

    _21: f32,
    _22: f32,
    _23: f32,
    _24: f32,

    _31: f32,
    _32: f32,
    _33: f32,
    _34: f32,

    _41: f32,
    _42: f32,
    _43: f32,
    _44: f32,

    pub const Identity = init(
        Vec4.init(1.0, 0.0, 0.0, 0.0),
        Vec4.init(0.0, 1.0, 0.0, 0.0),
        Vec4.init(0.0, 0.0, 1.0, 0.0),
        Vec4.init(0.0, 0.0, 0.0, 1.0),
    );

    pub fn init(x: Vec4, y: Vec4, z: Vec4, t: Vec4) Mat4 {
        return Mat4{
            ._11 = x.x,
            ._12 = x.y,
            ._13 = x.z,
            ._14 = x.w,

            ._21 = y.x,
            ._22 = y.y,
            ._23 = y.z,
            ._24 = y.w,

            ._31 = z.x,
            ._32 = z.y,
            ._33 = z.z,
            ._34 = z.w,

            ._41 = t.x,
            ._42 = t.y,
            ._43 = t.z,
            ._44 = t.w,
        };
    }

    pub fn initFromMat43(m: basis.math.Mat43) Mat4 {
        return Mat4{
            ._11 = m._11,
            ._12 = m._12,
            ._13 = m._13,
            ._14 = 0.0,

            ._21 = m._21,
            ._22 = m._22,
            ._23 = m._23,
            ._24 = 0.0,

            ._31 = m._31,
            ._32 = m._32,
            ._33 = m._33,
            ._34 = 0.0,

            ._41 = m._41,
            ._42 = m._42,
            ._43 = m._43,
            ._44 = 1.0,
        };
    }

    pub fn inverse(self: Mat4) Mat4 {
        var v0: f32 = self._31 * self._42 - self._32 * self._41;
        var v1: f32 = self._31 * self._43 - self._33 * self._41;
        var v2: f32 = self._31 * self._44 - self._34 * self._41;
        var v3: f32 = self._32 * self._43 - self._33 * self._42;
        var v4: f32 = self._32 * self._44 - self._34 * self._42;
        var v5: f32 = self._33 * self._44 - self._34 * self._43;

        const t00 = (v5 * self._22 - v4 * self._23 + v3 * self._24);
        const t10 = -(v5 * self._21 - v2 * self._23 + v1 * self._24);
        const t20 = (v4 * self._21 - v2 * self._22 + v0 * self._24);
        const t30 = -(v3 * self._21 - v1 * self._22 + v0 * self._23);

        const invDet: f32 = 1.0 / (t00 * self._11 + t10 * self._12 + t20 * self._13 + t30 * self._14);

        const d00: f32 = t00 * invDet;
        const d10: f32 = t10 * invDet;
        const d20: f32 = t20 * invDet;
        const d30: f32 = t30 * invDet;

        const d01: f32 = -(v5 * self._12 - v4 * self._13 + v3 * self._14) * invDet;
        const d11: f32 = (v5 * self._11 - v2 * self._13 + v1 * self._14) * invDet;
        const d21: f32 = -(v4 * self._11 - v2 * self._12 + v0 * self._14) * invDet;
        const d31: f32 = (v3 * self._11 - v1 * self._12 + v0 * self._13) * invDet;

        v0 = self._21 * self._42 - self._22 * self._41;
        v1 = self._21 * self._43 - self._23 * self._41;
        v2 = self._21 * self._44 - self._24 * self._41;
        v3 = self._22 * self._43 - self._23 * self._42;
        v4 = self._22 * self._44 - self._24 * self._42;
        v5 = self._23 * self._44 - self._24 * self._43;

        const d02 = (v5 * self._12 - v4 * self._13 + v3 * self._14) * invDet;
        const d12 = -(v5 * self._11 - v2 * self._13 + v1 * self._14) * invDet;
        const d22 = (v4 * self._11 - v2 * self._12 + v0 * self._14) * invDet;
        const d32 = -(v3 * self._11 - v1 * self._12 + v0 * self._13) * invDet;

        v0 = self._32 * self._21 - self._31 * self._22;
        v1 = self._33 * self._21 - self._31 * self._23;
        v2 = self._34 * self._21 - self._31 * self._24;
        v3 = self._33 * self._22 - self._32 * self._23;
        v4 = self._34 * self._22 - self._32 * self._24;
        v5 = self._34 * self._23 - self._33 * self._24;

        const d03: f32 = -(v5 * self._12 - v4 * self._13 + v3 * self._14) * invDet;
        const d13: f32 = (v5 * self._11 - v2 * self._13 + v1 * self._14) * invDet;
        const d23: f32 = -(v4 * self._11 - v2 * self._12 + v0 * self._14) * invDet;
        const d33: f32 = (v3 * self._11 - v1 * self._12 + v0 * self._13) * invDet;

        return Mat4{
            ._11 = d00,
            ._12 = d01,
            ._13 = d02,
            ._14 = d03,

            ._21 = d10,
            ._22 = d11,
            ._23 = d12,
            ._24 = d13,

            ._31 = d20,
            ._32 = d21,
            ._33 = d22,
            ._34 = d23,

            ._41 = d30,
            ._42 = d31,
            ._43 = d32,
            ._44 = d33,
        };
    }

    pub fn transform(self: Mat4, v: Vec4) Vec4 {
        const x = self._11 * v.x + self._21 * v.y + self._31 * v.z + self._41 * v.w;
        const y = self._12 * v.x + self._22 * v.y + self._32 * v.z + self._42 * v.w;
        const z = self._13 * v.x + self._23 * v.y + self._33 * v.z + self._43 * v.w;
        const w = self._14 * v.x + self._24 * v.y + self._34 * v.z + self._44 * v.w;
        return Vec4.init(x, y, z, w);
    }

    pub fn transpose(self: Mat4) Mat4 {
        return Mat4{
            ._11 = self._11,
            ._12 = self._21,
            ._13 = self._31,
            ._14 = self._41,
            ._21 = self._12,
            ._22 = self._22,
            ._23 = self._32,
            ._24 = self._42,
            ._31 = self._13,
            ._32 = self._23,
            ._33 = self._33,
            ._34 = self._43,
            ._41 = self._14,
            ._42 = self._24,
            ._43 = self._34,
            ._44 = self._44,
        };
    }

    pub fn setTranslation(self: *Mat4, t: basis.math.Vec3) void {
        self._41 = t.x;
        self._42 = t.y;
        self._43 = t.z;
    }

    //----------------------------------------------------

    pub fn deserialize(self: *Mat4, stream: *basis.BinaryReadStream) void {
        self._11 = stream.getFloat();
        self._12 = stream.getFloat();
        self._13 = stream.getFloat();
        self._14 = stream.getFloat();

        self._21 = stream.getFloat();
        self._22 = stream.getFloat();
        self._23 = stream.getFloat();
        self._24 = stream.getFloat();

        self._31 = stream.getFloat();
        self._32 = stream.getFloat();
        self._33 = stream.getFloat();
        self._34 = stream.getFloat();

        self._41 = stream.getFloat();
        self._42 = stream.getFloat();
        self._43 = stream.getFloat();
        self._44 = stream.getFloat();
    }

    pub fn serialize(self: Mat4, stream: *basis.BinaryWriteStream) void {
        stream.putFloat(self._11);
        stream.putFloat(self._12);
        stream.putFloat(self._13);
        stream.putFloat(self._14);

        stream.putFloat(self._21);
        stream.putFloat(self._22);
        stream.putFloat(self._23);
        stream.putFloat(self._24);

        stream.putFloat(self._31);
        stream.putFloat(self._32);
        stream.putFloat(self._33);
        stream.putFloat(self._34);

        stream.putFloat(self._41);
        stream.putFloat(self._42);
        stream.putFloat(self._43);
        stream.putFloat(self._44);
    }

    //----------------------------------------------------

    pub fn toInterop(self: Mat4) basis.bindings.InteropMat4 {
        return basis.bindings.InteropMat4{
            ._11 = self._11,
            ._12 = self._12,
            ._13 = self._13,
            ._14 = self._14,

            ._21 = self._21,
            ._22 = self._22,
            ._23 = self._23,
            ._24 = self._24,

            ._31 = self._31,
            ._32 = self._32,
            ._33 = self._33,
            ._34 = self._34,

            ._41 = self._41,
            ._42 = self._42,
            ._43 = self._43,
            ._44 = self._44,
        };
    }

    pub fn fromInterop(interop: basis.bindings.InteropMat4) Mat4 {
        return Mat4{
            ._11 = interop._11,
            ._12 = interop._12,
            ._13 = interop._13,
            ._14 = interop._14,

            ._21 = interop._21,
            ._22 = interop._22,
            ._23 = interop._23,
            ._24 = interop._24,

            ._31 = interop._31,
            ._32 = interop._32,
            ._33 = interop._33,
            ._34 = interop._34,

            ._41 = interop._41,
            ._42 = interop._42,
            ._43 = interop._43,
            ._44 = interop._44,
        };
    }
};
