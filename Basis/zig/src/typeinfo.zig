// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const TypeID = enum(i32) {
    BASIS_TYPE_INVALID = 0,
    BASIS_TYPE_FLOAT = 1,
    BASIS_TYPE_DOUBLE = 2,
    BASIS_TYPE_INT8 = 3,
    BASIS_TYPE_UINT8 = 4,
    BASIS_TYPE_INT16 = 5,
    BASIS_TYPE_UINT16 = 6,
    BASIS_TYPE_INT32 = 7,
    BASIS_TYPE_UINT32 = 8,
    BASIS_TYPE_INT64 = 9,
    BASIS_TYPE_UINT64 = 10,
    BASIS_TYPE_BOOL = 11,
    BASIS_TYPE_STRING = 12,
    BASIS_TYPE_RESOURCE_REF = 13,
    BASIS_TYPE_VEC2 = 14,
    BASIS_TYPE_VEC3 = 15,
    BASIS_TYPE_VEC4 = 16,
    BASIS_TYPE_MAT4 = 17,
    BASIS_TYPE_QUATERNION = 18,
    BASIS_TYPE_GAME_OBJECT_TRANSFORM = 19,
    BASIS_TYPE_COLOR = 20,
    BASIS_TYPE_NAMED_VALUE_COLLECTION = 21,
    BASIS_TYPE_VEC2_INT = 22,
    BASIS_TYPE_VEC3_INT = 23,
    BASIS_TYPE_SCRIPT_CODE = 24,
    BASIS_TYPE_GAME_OBJECT_REF = 25,
    BASIS_TYPE_EMPTY = 26,
    BASIS_TYPE_ENUM = 27,
    BASIS_TYPE_MAT43 = 28,
    BASIS_TYPE_MAT3 = 29,

    pub fn asInt(self: TypeID) i32 {
        return @intFromEnum(self);
    }
};

pub const ResourceTypeID = enum(i32) {
    Unknown = 0,
    RawDataFile = 1,
    Curve = 2,
    JsonDocument = 3,
    Material = 4,
    Texture = 5,
    ShaderProgram = 6,
    Mesh = 7,
    ParticleSystem = 8,
    VideoClip = 9,

    pub fn asInt(self: ResourceTypeID) i32 {
        return @intFromEnum(self);
    }
};

pub fn getTypeID(comptime T: type) TypeID {
    switch (T) {
        f32 => return TypeID.BASIS_TYPE_FLOAT,
        f64 => return TypeID.BASIS_TYPE_DOUBLE,

        i8 => return TypeID.BASIS_TYPE_INT8,
        u8 => return TypeID.BASIS_TYPE_UINT8,
        i16 => return TypeID.BASIS_TYPE_INT16,
        u16 => return TypeID.BASIS_TYPE_UINT16,
        i32 => return TypeID.BASIS_TYPE_INT32,
        u32 => return TypeID.BASIS_TYPE_UINT32,
        i64 => return TypeID.BASIS_TYPE_INT64,
        u64 => return TypeID.BASIS_TYPE_UINT64,
        bool => return TypeID.BASIS_TYPE_BOOL,

        basis.math.Vec2 => return TypeID.BASIS_TYPE_VEC2,
        basis.math.Vec3 => return TypeID.BASIS_TYPE_VEC3,
        basis.math.Vec4 => return TypeID.BASIS_TYPE_VEC4,
        basis.math.Quaternion => return TypeID.BASIS_TYPE_QUATERNION,
        basis.math.Mat43 => return TypeID.BASIS_TYPE_MAT43,
        basis.Color => return TypeID.BASIS_TYPE_COLOR,
        basis.game_object.GameObjectRef => return TypeID.BASIS_TYPE_GAME_OBJECT_REF,

        else => return TypeID.BASIS_TYPE_INVALID,
    }
}

pub fn getResourceTypeID(comptime T: type) ResourceTypeID {
    switch (T) {
        basis.resources.RawDataFilePtr => return ResourceTypeID.RawDataFile,
        basis.resources.JsonResourcePtr => return ResourceTypeID.JsonDocument,
        basis.resources.MaterialResourcePtr => return ResourceTypeID.Material,
        basis.resources.TextureResourcePtr => return ResourceTypeID.Texture,
        basis.resources.MeshResourcePtr => return ResourceTypeID.Mesh,

        else => return ResourceTypeID.Unknown,
    }
}
