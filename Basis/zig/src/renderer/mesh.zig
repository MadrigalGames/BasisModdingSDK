// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const vertex_formats = basis.renderer.vertex_formats;

const Vec3 = basis.math.Vec3;
const AABB = basis.math.AABB;

pub const MeshPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn getLodLevelCount(self: *const Self) u8 {
        return basis.bindings.api.Mesh_getLodLevelCount(self.cppPtr);
    }

    pub fn getLodLevel(self: *const Self, lodLevelIndex: u8) LodLevelPtr {
        const cppPtr = basis.bindings.api.Mesh_getLodLevel(self.cppPtr, lodLevelIndex);
        return LodLevelPtr{ .cppPtr = cppPtr };
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.Mesh_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        basis.bindings.api.Mesh_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};

//----------------------------------------------------

pub const LodLevelPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn getSubMeshCount(self: *const Self) u8 {
        return basis.bindings.api.MeshLodLevel_getSubMeshCount(self.cppPtr);
    }

    pub fn setSubMeshCount(self: *const Self, count: u8) void {
        basis.bindings.api.MeshLodLevel_setSubMeshCount(self.cppPtr, count);
    }

    pub fn getSubMesh(self: *const Self, subMeshIndex: u8) SubMeshPtr {
        const cppPtr = basis.bindings.api.MeshLodLevel_getSubMesh(self.cppPtr, subMeshIndex);
        return SubMeshPtr{ .cppPtr = cppPtr };
    }

    pub fn getBounds(self: *const Self) AABB {
        var interopMin: basis.bindings.InteropVec3 = undefined;
        var interopMax: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.MeshLodLevel_getBounds(self.cppPtr, &interopMin, &interopMax);
        return AABB{
            .min = Vec3.fromInterop(interopMin),
            .max = Vec3.fromInterop(interopMax),
            .hasPoints = true,
        };
    }

    pub fn setBounds(self: *const Self, bounds: AABB) void {
        const interopMin = bounds.min.toInterop();
        const interopMax = bounds.max.toInterop();
        basis.bindings.api.MeshLodLevel_setBounds(self.cppPtr, &interopMin, &interopMax);
    }
};

pub const SubMeshPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    //----------------------------------------------------

    pub fn getVertexFormatType(self: *const Self) vertex_formats.VertexFormatType {
        const typeInt = basis.bindings.api.MeshSubMesh_getVertexFormatType(self.cppPtr);
        return @enumFromInt(typeInt);
    }

    pub fn getVertexCount(self: *const Self) u32 {
        return basis.bindings.api.MeshSubMesh_getVertexCount(self.cppPtr);
    }

    pub fn setVertexCount(self: *const Self, count: u32) void {
        basis.bindings.api.MeshSubMesh_setVertexCount(self.cppPtr, count);
    }

    pub fn getIndexCount(self: *const Self) u32 {
        return basis.bindings.api.MeshSubMesh_getIndexCount(self.cppPtr);
    }

    pub fn setIndexCount(self: *const Self, count: u32) void {
        basis.bindings.api.MeshSubMesh_setIndexCount(self.cppPtr, count);
    }

    pub fn getVertices(self: *const Self) []u8 {
        var bufferSize: u32 = 0;
        const bufferAddress = basis.bindings.api.MeshSubMesh_getVertices(self.cppPtr, &bufferSize);

        if (bufferSize == 0) {
            return &[_]u8{}; // Empty slice
        }

        return bufferAddress[0..bufferSize];
    }

    pub fn getIndices(self: *const Self) []u16 {
        var bufferSize: u32 = 0;
        const bufferAddress = basis.bindings.api.MeshSubMesh_getIndices(self.cppPtr, &bufferSize);

        if (bufferSize == 0) {
            return &[_]u16{}; // Empty slice
        }

        return bufferAddress[0..bufferSize];
    }
};
