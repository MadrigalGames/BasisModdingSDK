// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const vertex_formats = basis.renderer.vertex_formats;

pub const IndexType = u16;

pub const MeshGeometryPtr = struct {
    const Self = @This();
    //----------------------------------------------------

    cppPtr: basis.CppPtr,
    ownsMemory: bool,

    //----------------------------------------------------

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .ownsMemory = false,
        };
    }

    pub fn initNew() Self {
        return Self{
            .cppPtr = basis.bindings.api.MeshGeometry_newGeometry(),
            .ownsMemory = true,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.ownsMemory) {
            basis.bindings.api.MeshGeometry_deleteGeometry(self.cppPtr);
        }

        self.cppPtr = 0;
        self.ownsMemory = false;
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    //----------------------------------------------------

    pub fn clear(self: *const Self) void {
        basis.bindings.api.MeshGeometry_clear(self.cppPtr);
    }

    pub fn addLodLevel(self: *const Self) MeshGeometryLodLevelPtr {
        const cppPtr = basis.bindings.api.MeshGeometry_addLodLevel(self.cppPtr);
        return MeshGeometryLodLevelPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn getLodLevel(self: *const Self, lodLevelIndex: u8) MeshGeometryLodLevelPtr {
        const cppPtr = basis.bindings.api.MeshGeometry_getLodLevel(self.cppPtr, lodLevelIndex);
        return MeshGeometryLodLevelPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn getLodLevelCount(self: *const Self) u8 {
        return basis.bindings.api.MeshGeometry_getLodLevelCount(self.cppPtr);
    }
};

//----------------------------------------------------

pub const MeshGeometryLodLevelPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn clear(self: *const Self) void {
        basis.bindings.api.MeshGeometryLodLevel_clear(self.cppPtr);
    }

    pub fn addSubMesh(self: *const Self, vertexFormatType: vertex_formats.VertexFormatType) MeshGeometrySubMeshPtr {
        const cppPtr = basis.bindings.api.MeshGeometryLodLevel_addSubMesh(self.cppPtr, @intFromEnum(vertexFormatType));
        return MeshGeometrySubMeshPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn getSubMesh(self: *const Self, subMeshIndex: u8) MeshGeometrySubMeshPtr {
        const cppPtr = basis.bindings.api.MeshGeometryLodLevel_getSubMesh(self.cppPtr, subMeshIndex);
        return MeshGeometrySubMeshPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn getSubMeshCount(self: *const Self) u8 {
        return basis.bindings.api.MeshGeometryLodLevel_getSubMeshCount(self.cppPtr);
    }
};

pub const MeshGeometrySubMeshPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn clear(self: *const Self) void {
        basis.bindings.api.MeshGeometrySubMesh_clear(self.cppPtr);
    }

    pub fn addIndex(self: *const Self, index: IndexType) void {
        basis.bindings.api.MeshGeometrySubMesh_addIndex(self.cppPtr, index);
    }

    pub fn addIndexAny(self: *const Self, index: anytype) void {
        self.addIndex(@intCast(index));
    }

    pub fn addFace(self: *const Self, index0: IndexType, index1: IndexType, index2: IndexType) void {
        basis.bindings.api.MeshGeometrySubMesh_addFace(self.cppPtr, index0, index1, index2);
    }

    pub fn addFaceAny(self: *const Self, index0: anytype, index1: anytype, index2: anytype) void {
        self.addFace(@intCast(index0), @intCast(index1), @intCast(index2));
    }

    pub fn addVertex(self: *const Self, vertex: anytype) void {
        var buffer: [128]u8 = undefined;
        var stream = basis.BinaryWriteStream.init(&buffer, true);

        stream.put(@TypeOf(vertex), vertex);

        const ptr: [*c]const u8 = &buffer[0];
        const len: u32 = @intCast(stream.cursorPosition);

        basis.bindings.api.MeshGeometrySubMesh_addVertex(self.cppPtr, ptr, len);
    }

    pub fn getVertexFormatType(self: *const Self) vertex_formats.VertexFormatType {
        const typeInt = basis.bindings.api.MeshGeometrySubMesh_getVertexFormatType(self.cppPtr);
        return @enumFromInt(typeInt);
    }

    pub fn getVertexCount(self: *const Self) u32 {
        return basis.bindings.api.MeshGeometrySubMesh_getVertexCount(self.cppPtr);
    }

    pub fn getIndexCount(self: *const Self) u32 {
        return basis.bindings.api.MeshGeometrySubMesh_getIndexCount(self.cppPtr);
    }
};
