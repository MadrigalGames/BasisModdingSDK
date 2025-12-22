// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Allocator = std.mem.Allocator;

const Vec3 = basis.math.Vec3;
const Vec4 = basis.math.Vec4;
const Quaternion = basis.math.Quaternion;
const StringHash = basis.string.StringHash;

pub const FirstGameMessageCategory: i32 = 100;
pub const FirstGameMessage: i32 = 1000;

// This is u32 on the C++ side but since we are dealing with imported
// C headers it is safest to assume that the messages are treated as
// signed 32-bit integers in Zig.
pub const Message = i32;

pub fn castToMessage(value: anytype) i32 {
    return switch (@typeInfo(@TypeOf(value))) {
        .int => @as(i32, @intCast(value)),
        else => @intFromEnum(value),
    };
}

pub fn castToMessageCategory(value: anytype) i32 {
    return castToMessage(value);
}

pub const MessageParametersPtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    pub fn init(cppPtr: basis.CppPtr) MessageParametersPtr {
        return MessageParametersPtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn addInt(self: *const Self, i: i32) void {
        basis.bindings.api.MessageParameters_addInt(self.cppPtr, i);
    }

    pub fn getInt(self: *const Self) i32 {
        return basis.bindings.api.MessageParameters_getInt(self.cppPtr);
    }

    pub fn addUint(self: *const Self, i: u32) void {
        basis.bindings.api.MessageParameters_addUint(self.cppPtr, i);
    }

    pub fn getUint(self: *const Self) u32 {
        return basis.bindings.api.MessageParameters_getUint(self.cppPtr);
    }

    pub fn addUint64(self: *const Self, i: u64) void {
        basis.bindings.api.MessageParameters_addUint64(self.cppPtr, i);
    }

    pub fn getUint64(self: *const Self) u64 {
        return basis.bindings.api.MessageParameters_getUint64(self.cppPtr);
    }

    pub fn addFloat(self: *const Self, f: f32) void {
        basis.bindings.api.MessageParameters_addFloat(self.cppPtr, f);
    }

    pub fn getFloat(self: *const Self) f32 {
        return basis.bindings.api.MessageParameters_getFloat(self.cppPtr);
    }

    pub fn addVec3(self: *const Self, v: basis.math.Vec3) void {
        const i = Vec3.toInterop(v);
        basis.bindings.api.MessageParameters_addVec3(self.cppPtr, &i);
    }

    pub fn getVec3(self: *const Self) basis.math.Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.MessageParameters_getVec3(self.cppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn addVec4(self: *const Self, v: basis.math.Vec4) void {
        const i = Vec4.toInterop(v);
        basis.bindings.api.MessageParameters_addVec4(self.cppPtr, &i);
    }

    pub fn getVec4(self: *const Self) basis.math.Vec4 {
        var interop: basis.bindings.InteropVec4 = undefined;
        basis.bindings.api.MessageParameters_getVec4(self.cppPtr, &interop);
        return Vec4.fromInterop(interop);
    }

    pub fn addQuaternion(self: *const Self, v: basis.math.Quaternion) void {
        const i = Quaternion.toInterop(v);
        basis.bindings.api.MessageParameters_addQuaternion(self.cppPtr, &i);
    }

    pub fn getQuaternion(self: *const Self) basis.math.Quaternion {
        var interop: basis.bindings.InteropQuaternion = undefined;
        basis.bindings.api.MessageParameters_getQuaternion(self.cppPtr, &interop);
        return Quaternion.fromInterop(interop);
    }

    pub fn addString(self: *const Self, v: []const u8) void {
        const interopV = basis.string.toInteropString(v);
        basis.bindings.api.MessageParameters_addString(self.cppPtr, &interopV);
    }

    pub fn getString(self: *const Self) []const u8 {
        var valueInteropString: basis.bindings.InteropString = undefined;
        basis.bindings.api.MessageParameters_getString(self.cppPtr, &valueInteropString);
        return valueInteropString.ptr[0..valueInteropString.len];
    }
};

// Message nodes are generic messaging objects that can send and receive messages
// from/in any part of the code. Use the createMessageNode() methods of the
// client/server to create a message node, and use the deinit() method of the node
// object to destroy it when it is no longer needed. Message node addresses need to
// be stable and thus they are always created on the heap.
pub const MessageNode = struct {
    const Self = @This();

    pub const MessageReceivedDelegate = basis.delegate.VoidDelegate3(Message, StringHash, MessageParametersPtr);

    cppPtr: basis.CppPtr,
    allocator: Allocator,
    onMessageReceived: ?MessageReceivedDelegate = null,

    pub fn deinit(self: *Self) void {
        basis.bindings.api.MessageNode_destroy(self.cppPtr); // Destroy the node on the C++ side.
        self.allocator.destroy(self); // Destroy the node on the Zig side.
    }

    pub fn subscribeToMessageCategory(self: *const Self, cat: anytype) void {
        const value = castToMessageCategory(cat);
        basis.bindings.api.MessageNode_subscribeToMessageCategory(self.cppPtr, value);
    }

    pub fn allocMsgParams(self: *const Self) MessageParametersPtr {
        return MessageParametersPtr.init(basis.bindings.api.MessageNode_allocMsgParams(self.cppPtr));
    }

    pub fn sendMessage(self: *const Self, message: anytype) void {
        const value = castToMessage(message);
        basis.bindings.api.MessageNode_sendMessage(self.cppPtr, value, 0);
    }

    pub fn sendMessageWithParams(self: *const Self, message: anytype, parameters: MessageParametersPtr) void {
        const value = castToMessage(message);
        basis.bindings.api.MessageNode_sendMessage(self.cppPtr, value, parameters.cppPtr);
    }
};
