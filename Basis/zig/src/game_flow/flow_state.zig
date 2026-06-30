// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const FlowStateInterface = basis.program_flow.FlowStateInterface;

const MessageParametersPtr = basis.messaging.MessageParametersPtr;

const ClientPtr = basis.host.ClientPtr;
const ServerPtr = basis.host.ServerPtr;

pub const FlowStateContext = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    io: std.Io,
    cppPtr: basis.bindings.InteropTypedPtr,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, cppPtr: basis.bindings.InteropTypedPtr) Self {
        return Self{
            .allocator = allocator,
            .io = io,
            .cppPtr = cppPtr,
        };
    }

    pub fn startTransition(self: *const Self, name: []const u8) void {
        basis.bindings.api.FlowState_startTransition(self.cppPtr, &name[0], @as(u32, @intCast(name.len)));
    }

    pub fn subscribeToMessageCategory(self: *const Self, cat: anytype) void {
        const value = basis.messaging.castToMessageCategory(cat);
        basis.bindings.api.FlowState_subscribeToMessageCategory(self.cppPtr, value);
    }

    pub fn allocMsgParams(self: *const Self) MessageParametersPtr {
        return MessageParametersPtr.init(basis.bindings.api.FlowState_allocMsgParams(self.cppPtr));
    }

    pub fn sendMessage(self: *const Self, message: anytype) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.FlowState_sendMessage(self.cppPtr, value, 0);
    }

    pub fn sendMessageWithParams(self: *const Self, message: anytype, parameters: MessageParametersPtr) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.FlowState_sendMessage(self.cppPtr, value, parameters.cppPtr);
    }

    pub fn getClient(self: *const Self) ClientPtr {
        return ClientPtr{
            .cppPtr = basis.bindings.api.FlowState_getClient(self.cppPtr),
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getServer(self: *const Self) ServerPtr {
        return ServerPtr{
            .cppPtr = basis.bindings.api.FlowState_getServer(self.cppPtr),
            .allocator = self.allocator,
            .io = self.io,
        };
    }
};
