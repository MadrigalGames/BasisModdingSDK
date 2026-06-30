// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

const MessageNode = basis.messaging.MessageNode;

pub const ClientPtr = struct {
    const Self = @This();
    pub const Null = initNull();

    cppPtr: basis.CppPtr,
    allocator: Allocator,
    io: std.Io,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .allocator = undefined,
            .io = undefined,
        };
    }

    pub fn isNull(self: *const Self) bool {
        return self.cppPtr == 0;
    }

    pub fn getHostID(self: *const Self) i32 {
        return basis.bindings.api.Client_getHostID(self.cppPtr);
    }

    pub fn isConnected(self: *const Self) bool {
        const conn = basis.bindings.api.Client_isConnected(self.cppPtr);
        return if (conn == 1) true else false;
    }

    pub fn getRenderer(self: *const Self) basis.renderer.RendererPtr {
        const rendererCppPtr = basis.bindings.api.Client_getRenderer(self.cppPtr);
        return basis.renderer.RendererPtr{ .cppPtr = rendererCppPtr };
    }

    pub fn getGameSession(self: *const Self) basis.game_session.GameSessionPtr {
        const gameSessionCppPtr = basis.bindings.api.Client_getGameSession(self.cppPtr);
        return basis.game_session.GameSessionPtr{ .cppPtr = gameSessionCppPtr };
    }

    pub fn getGameState(self: *const Self) basis.game_state.GameStatePtr {
        const gameStateCppPtr = basis.bindings.api.Client_getGameState(self.cppPtr);
        return basis.game_state.GameStatePtr{ .allocator = self.allocator, .cppPtr = gameStateCppPtr };
    }

    pub fn getPhysicsEnginePtr(self: *const Self) basis.CppPtr {
        return basis.bindings.api.Client_getPhysicsEnginePtr(self.cppPtr);
    }

    pub fn getPrimaryPhysicsScene(self: *const Self) basis.physics.PhysicsScenePtr {
        const sceneCppPtr = basis.bindings.api.Client_getPrimaryPhysicsScene(self.cppPtr);
        return basis.physics.PhysicsScenePtr{ .cppPtr = sceneCppPtr };
    }

    pub fn getInterpolationFactor(self: *const Self) f64 {
        return basis.bindings.api.Client_getInterpolationFactor(self.cppPtr);
    }

    pub fn getInterpolationFactor32(self: *const Self) f32 {
        const factor64 = basis.bindings.api.Client_getInterpolationFactor(self.cppPtr);
        return @as(f32, @floatCast(factor64));
    }

    pub fn createMessageNode(self: *const Self, messageNodeName: []const u8) *MessageNode {
        const interopName = basis.string.toInteropString(messageNodeName);
        const messageNodePtr = self.allocator.create(MessageNode) catch @panic("OOM");
        const messageNodeCppPtr = basis.bindings.api.Client_createMessageNode(
            basis.library_api.getZigLibCppPtr(),
            self.cppPtr,
            &interopName,
            @intFromPtr(messageNodePtr),
        );

        messageNodePtr.* = MessageNode{
            .cppPtr = messageNodeCppPtr,
            .allocator = self.allocator,
            .name = basis.String.init_with_contents(self.allocator, messageNodeName) catch @panic("OOM"),
        };

        return messageNodePtr;
    }

    pub fn addRPCListener(self: *const Self, f: basis.network.OnRPCReceivedFnPtr, userData: basis.IntPtr) basis.CppPtr {
        return basis.bindings.api.Client_addRPCListener(self.cppPtr, @intFromPtr(f), userData);
    }

    pub fn removeRPCListener(self: *const Self, listenerPtr: basis.CppPtr) void {
        basis.bindings.api.Client_removeRPCListener(self.cppPtr, listenerPtr);
    }

    pub fn sendNetworkMessageToHostID(self: *const Self, data: []const u8, reliable: bool, hostID: i32) void {
        const ptr: [*c]const u8 = &data[0];
        const len: u32 = @intCast(data.len);
        basis.assertd(@src(), len > 0, "Trying to send zero-length network message.");

        basis.bindings.api.Client_sendNetworkMessageToHostID(self.cppPtr, ptr, len, reliable, hostID);
    }

    pub fn sendNetworkMessageToPeer(self: *const Self, data: []const u8, reliable: bool, peerCppPtr: basis.CppPtr) void {
        const ptr: [*c]const u8 = &data[0];
        const len: u32 = @intCast(data.len);
        basis.assertd(@src(), len > 0, "Trying to send zero-length network message.");

        basis.bindings.api.Client_sendNetworkMessageToPeer(self.cppPtr, ptr, len, reliable, peerCppPtr);
    }
};
