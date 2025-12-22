// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const MeshPtr = basis.renderer.MeshPtr;
const MaterialPtr = basis.renderer.MaterialPtr;

pub const RawDataFilePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn getRawData(self: *const Self) []const u8 {
        var interopData: basis.bindings.InteropString = undefined;
        basis.bindings.api.Resource_getRawData(self.cppPtr, &interopData);
        return interopData.ptr[0..interopData.len];
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.Resource_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        basis.bindings.api.Resource_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};

pub const JsonResourcePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn getJsonData(self: *const Self) []const u8 {
        var interopData: basis.bindings.InteropString = undefined;
        basis.bindings.api.Resource_getRawData(self.cppPtr, &interopData);
        return interopData.ptr[0..interopData.len];
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.Resource_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        basis.bindings.api.Resource_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};

pub const MaterialResourcePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn getSharedMaterial(self: *const Self) MaterialPtr {
        const cppPtr = basis.bindings.api.Resource_getSharedMaterial(self.cppPtr);

        return MaterialPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.Resource_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        basis.bindings.api.Resource_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};

pub const TextureResourcePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.Resource_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        basis.bindings.api.Resource_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};

pub const MeshResourcePtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn getSharedMesh(self: *const Self) MeshPtr {
        const cppPtr = basis.bindings.api.Resource_getSharedMesh(self.cppPtr);

        return MeshPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn hasPhysicsMesh(self: *const Self) bool {
        return if (basis.bindings.api.Resource_hasPhysicsMesh(self.cppPtr) == 1) true else false;
    }

    pub fn getPhysicsMeshData(self: *const Self) []const u8 {
        var interopData: basis.bindings.InteropString = undefined;
        basis.bindings.api.Resource_getPhysicsMeshData(self.cppPtr, &interopData);
        return interopData.ptr[0..interopData.len];
    }

    pub fn addRef(self: *const Self) void {
        basis.bindings.api.Resource_addRef(self.cppPtr);
    }

    pub fn release(self: *const Self) void {
        basis.bindings.api.Resource_release(self.cppPtr);
    }

    pub fn releaseAndZero(self: *Self) void {
        self.release();
        self.cppPtr = 0;
    }
};
