// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec2 = basis.math.Vec2;
const Vec3 = basis.math.Vec3;
const Vec4 = basis.math.Vec4;

const BinaryReadStream = basis.BinaryReadStream;
const BinaryWriteStream = basis.BinaryWriteStream;

pub const VertexFormatType = enum(i32) {
    Unknown = 0,

    Position,

    PositionColor,
    PositionColorTexcoord,

    PositionNormalColor,

    PositionNormalColorTexcoord,
    PositionNormalColorTexcoords2,
    PositionNormalColorTexcoords3,

    PositionNormalTexcoord,
    PositionNormalTexcoords2,
    PositionNormalTexcoords3,

    PositionTangentBinormalNormalTexcoord,
    PositionTangentBinormalNormalTexcoords2,
    PositionTangentBinormalNormalTexcoords3,

    PositionTextureBoundsY,

    PositionNormal,

    Count,

    pub fn asInt(self: VertexFormatType) i32 {
        return @intFromEnum(self);
    }
};

//----------------------------------------------------

pub const VertexPosition = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
    }
};

pub const VertexPositionColor = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    color: Vec4,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.color = stream.get(Vec4);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec4, self.color);
    }
};

pub const VertexPositionColorTexcoord = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    color: Vec4,
    texcoord: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.color = stream.get(Vec4);
        self.texcoord = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec4, self.color);
        stream.put(Vec2, self.texcoord);
    }
};

pub const VertexPositionNormalColor = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    color: Vec4,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.color = stream.get(Vec4);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec4, self.color);
    }
};

pub const VertexPositionNormalColorTexcoord = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    color: Vec4,
    texcoord: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.color = stream.get(Vec4);
        self.texcoord = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec4, self.color);
        stream.put(Vec2, self.texcoord);
    }
};

pub const VertexPositionNormalColorTexcoords2 = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    color: Vec4,
    texcoord0: Vec2,
    texcoord1: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.color = stream.get(Vec4);
        self.texcoord0 = stream.get(Vec2);
        self.texcoord1 = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec4, self.color);
        stream.put(Vec2, self.texcoord0);
        stream.put(Vec2, self.texcoord1);
    }
};

pub const VertexPositionNormalColorTexcoords3 = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    color: Vec4,
    texcoord0: Vec2,
    texcoord1: Vec2,
    texcoord2: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.color = stream.get(Vec4);
        self.texcoord0 = stream.get(Vec2);
        self.texcoord1 = stream.get(Vec2);
        self.texcoord2 = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec4, self.color);
        stream.put(Vec2, self.texcoord0);
        stream.put(Vec2, self.texcoord1);
        stream.put(Vec2, self.texcoord2);
    }
};

pub const VertexPositionNormalTexcoord = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    texcoord: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.texcoord = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec2, self.texcoord);
    }
};

pub const VertexPositionNormalTexcoords2 = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    texcoord0: Vec2,
    texcoord1: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.texcoord0 = stream.get(Vec2);
        self.texcoord1 = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec2, self.texcoord0);
        stream.put(Vec2, self.texcoord1);
    }
};

pub const VertexPositionNormalTexcoords3 = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,
    texcoord0: Vec2,
    texcoord1: Vec2,
    texcoord2: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.texcoord0 = stream.get(Vec2);
        self.texcoord1 = stream.get(Vec2);
        self.texcoord2 = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
        stream.put(Vec2, self.texcoord0);
        stream.put(Vec2, self.texcoord1);
        stream.put(Vec2, self.texcoord2);
    }
};

pub const VertexPositionTangentBinormalNormalTexcoord = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    tangent: Vec3,
    binormal: Vec3,
    normal: Vec3,
    texcoord: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.tangent = stream.get(Vec3);
        self.binormal = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.texcoord = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.tangent);
        stream.put(Vec3, self.binormal);
        stream.put(Vec3, self.normal);
        stream.put(Vec2, self.texcoord);
    }
};

pub const VertexPositionTangentBinormalNormalTexcoords2 = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    tangent: Vec3,
    binormal: Vec3,
    normal: Vec3,
    texcoord0: Vec2,
    texcoord1: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.tangent = stream.get(Vec3);
        self.binormal = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.texcoord0 = stream.get(Vec2);
        self.texcoord1 = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.tangent);
        stream.put(Vec3, self.binormal);
        stream.put(Vec3, self.normal);
        stream.put(Vec2, self.texcoord0);
        stream.put(Vec2, self.texcoord1);
    }
};

pub const VertexPositionTangentBinormalNormalTexcoords3 = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    tangent: Vec3,
    binormal: Vec3,
    normal: Vec3,
    texcoord0: Vec2,
    texcoord1: Vec2,
    texcoord2: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.tangent = stream.get(Vec3);
        self.binormal = stream.get(Vec3);
        self.normal = stream.get(Vec3);
        self.texcoord0 = stream.get(Vec2);
        self.texcoord1 = stream.get(Vec2);
        self.texcoord2 = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.tangent);
        stream.put(Vec3, self.binormal);
        stream.put(Vec3, self.normal);
        stream.put(Vec2, self.texcoord0);
        stream.put(Vec2, self.texcoord1);
        stream.put(Vec2, self.texcoord2);
    }
};

pub const VertexPositionTextureBoundsY = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    texcoord: Vec2,
    boundsY: Vec2,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.texcoord = stream.get(Vec2);
        self.boundsY = stream.get(Vec2);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec2, self.texcoord);
        stream.put(Vec2, self.boundsY);
    }
};

pub const VertexPositionNormal = struct {
    const Self = @This();

    //----------------------------------------------------

    position: Vec3,
    normal: Vec3,

    //----------------------------------------------------

    pub fn deserialize(
        self: *Self,
        stream: *BinaryReadStream,
    ) void {
        self.position = stream.get(Vec3);
        self.normal = stream.get(Vec3);
    }

    pub fn serialize(
        self: *const Self,
        stream: *BinaryWriteStream,
    ) void {
        stream.put(Vec3, self.position);
        stream.put(Vec3, self.normal);
    }
};
