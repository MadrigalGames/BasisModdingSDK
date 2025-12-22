// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");
const basis = @import("basis.zig");

pub const api = @import("bindings/api.zig");

// TODO: Move these to api.zig when we no longer refer to them directly.
pub const generated_types = @import("bindings/generated_types.zig");
pub const generated_bind_functions = @import("bindings/generated_bind_functions.zig");
pub const generated_function_pointers = @import("bindings/generated_function_pointers.zig");

pub const physics_interop_types = @import("physics/interop_types.zig");

// Shorthand form to make using the generated function pointers a bit less cumbersome.
pub const fp = generated_function_pointers;

//////////////////////////////////
// Pointer conversions.
//////////////////////////////////

// Convert from an int pointer on the host, which is always 64-bit, to an int pointer
// on the library side, which can be either 32- or 64-bit.
pub fn libIntPtrFromHost(hostPtr: basis.IntPtr64) basis.IntPtr {
    return switch (builtin.cpu.arch) {
        .wasm32 => @intCast(hostPtr),
        else => hostPtr,
    };
}

// The reverse of libIntPtrFromHost().
pub fn hostIntPtrFromLib(hostPtr: basis.IntPtr) basis.IntPtr64 {
    return switch (builtin.cpu.arch) {
        .wasm32 => @intCast(hostPtr),
        else => hostPtr,
    };
}

//////////////////////////////////
// Function pointers.
//////////////////////////////////

pub const basis_zig_component_reg_cb = *const fn (
    basis.bindings.InteropTypedPtr, // zigLibCppPtr
    [*c]const basis.bindings.InteropString, // typeName
    u32, // typeNameHash
    [*c]const basis.bindings.InteropString, // contextTypeName
    u32, // updateSortingKey
    basis.IntPtr64, // factoryInterfacePtr
    u32, // flags
) callconv(.c) void;

// Common function pointers:
pub const FP_void = *const fn () callconv(.c) void;
pub const FP_void_i32 = *const fn (i32) callconv(.c) void;
pub const FP_void_bool = *const fn (bool) callconv(.c) void;
pub const FP_void_f32 = *const fn (f32) callconv(.c) void;
pub const FP_void_IntPtr64_i32 = *const fn (basis.IntPtr64, i32) callconv(.c) void;

pub const FP_i32 = *const fn () callconv(.c) i32;
pub const FP_bool = *const fn () callconv(.c) bool;
pub const FP_f32 = *const fn () callconv(.c) f32;

pub const FP_i32_IntPtr_IntPtr_u32 = *const fn (basis.IntPtr, basis.IntPtr, u32) callconv(.c) i32;
pub const FP_i32_IntPtr_IntPtr_u32_Vec3_Vec3 = *const fn (basis.IntPtr, basis.IntPtr, u32, *const InteropVec3, *const InteropVec3) callconv(.c) i32;
pub const FP_i32_IntPtr_IntPtr64_u32 = *const fn (basis.IntPtr, basis.IntPtr64, u32) callconv(.c) i32;
pub const FP_i32_IntPtr_IntPtr64_u32_Vec3_Vec3 = *const fn (basis.IntPtr, basis.IntPtr64, u32, *const InteropVec3, *const InteropVec3) callconv(.c) i32;
// Add more here...

pub fn make_FP_void(func: anytype) FP_void {
    return struct {
        fn wrapCall() callconv(.c) void {
            func();
        }
    }.wrapCall;
}

//////////////////////////////////
// Interop types.
//////////////////////////////////

pub const CppZigPointerPair = extern struct {
    cpp: usize = 0,
    zig: usize = 0,
};

pub const InteropVec2 = extern struct {
    x: f32,
    y: f32,
};

pub const InteropVec3 = extern struct {
    x: f32,
    y: f32,
    z: f32,
};

pub const InteropVec4 = extern struct {
    x: f32,
    y: f32,
    z: f32,
    w: f32,
};

pub const InteropQuaternion = extern struct {
    w: f32,
    x: f32,
    y: f32,
    z: f32,
};

pub const InteropMat43 = extern struct {
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
};

pub const InteropMat4 = extern struct {
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
};

pub const InteropColor = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};

pub const InteropTypedPtr = extern struct {
    ptr: basis.IntPtr64,
    type: u32,
};

pub const InteropClientProxy = extern struct {
    hostID: i32,
};

pub const PhysicsInteropRayCastResult = extern struct {
    hitPoint: InteropVec3,
    hitPointNormal: InteropVec3,
    distance: f32,
    hitGameObjectCppPtr: usize,
    hitPhysicsActorCppPtr: usize,
    hitPhysicsActorType: u32,
};

pub const RendererInteropRayCastResult = extern struct {
    hitPoint: InteropVec3,
    hitPointNormal: InteropVec3,
    hitObject: usize,
};

pub const InteropString = extern struct {
    ptr: [*c]const u8,
    len: u32,
};

pub const InteropBuffer = extern struct {
    ptr: [*c]u8,
    capacity: u32,
    len: u32,
};

pub const InteropLooseFileMapping = extern struct {
    sourceFilePath: InteropString,
    resourcePath: InteropString,
    resourceType: i32,
};

pub const InteropExposedPropertyMeta = extern struct {
    exposedPropertyType: i32,
    typeID: i32,
    versionAdded: i32,
    defaultValueBufferOffset: i32,

    // Since interop types cannot contain pointers to be usable with WASM
    // we don't store InteropStrings here, but instead offsets + lengths into
    // a separate string buffer.

    //name: InteropString,
    nameStartOffset: u32,
    nameLength: u32,

    //options: InteropString,
    optionsStartOffset: u32,
    optionsLength: u32,
};

pub const InteropNavMeshQueryFilter = extern struct {
    areaCost: [64]f32,
    includeFlags: u16,
    excludeFlags: u16,
};

pub const InteropVehCtrlDesc = physics_interop_types.InteropVehCtrlDesc;
pub const InteropVehInputData = physics_interop_types.InteropVehInputData;
pub const InteropVehStateInfo = physics_interop_types.InteropVehStateInfo;
pub const InteropVehWheelStateInfo = physics_interop_types.InteropVehWheelStateInfo;
pub const InteropCollisionData = physics_interop_types.InteropCollisionData;
