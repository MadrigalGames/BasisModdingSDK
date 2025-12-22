// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

const MessageNode = basis.messaging.MessageNode;

/// Zig doesn't have type inheritance in the OO sense, so here is a poor man's
/// "base class" implementing some of the methods supported by both the client
/// and server type. Add more methods as needed.
pub const HostPtr = struct {
    const Self = @This();
    pub const Null = initNull();

    cppPtr: basis.CppPtr,
    allocator: Allocator,
    isClient: bool,

    //----------------------------------------------------

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .allocator = undefined,
            .isClient = false,
        };
    }

    pub fn init(clientOrServer: anytype) Self {
        var cppPtr: basis.CppPtr = 0;
        var allocator: std.mem.Allocator = undefined;
        var isClient: bool = false;

        switch (@TypeOf(clientOrServer)) {
            basis.host.ClientPtr => {
                cppPtr = clientOrServer.cppPtr;
                allocator = clientOrServer.allocator;
                isClient = true;
            },
            basis.host.ServerPtr => {
                cppPtr = clientOrServer.cppPtr;
                allocator = clientOrServer.allocator;
                isClient = false;
            },
            basis.host.HostPtr => {
                cppPtr = clientOrServer.cppPtr;
                allocator = clientOrServer.allocator;
                isClient = clientOrServer.isClient;
            },
            else => {
                @compileError("Unsupported host type: '" ++ @typeName(@TypeOf(clientOrServer)) ++ "'");
            },
        }

        return Self{
            .cppPtr = cppPtr,
            .allocator = allocator,
            .isClient = isClient,
        };
    }

    //----------------------------------------------------

    pub fn addRPCListener(self: *const Self, f: basis.network.OnRPCReceivedFnPtr, userData: basis.IntPtr) basis.CppPtr {
        if (self.isClient) {
            return self.toClient().addRPCListener(f, userData);
        } else {
            return self.toServer().addRPCListener(f, userData);
        }
    }

    pub fn removeRPCListener(self: *const Self, listenerPtr: basis.CppPtr) void {
        if (self.isClient) {
            self.toClient().removeRPCListener(listenerPtr);
        } else {
            self.toServer().removeRPCListener(listenerPtr);
        }
    }

    pub fn sendNetworkMessageToHostID(self: *const Self, data: []const u8, reliable: bool, hostID: i32) void {
        if (self.isClient) {
            self.toClient().sendNetworkMessageToHostID(data, reliable, hostID);
        } else {
            self.toServer().sendNetworkMessageToHostID(data, reliable, hostID);
        }
    }

    pub fn sendNetworkMessageToPeer(self: *const Self, data: []const u8, reliable: bool, peerCppPtr: basis.CppPtr) void {
        if (self.isClient) {
            self.toClient().sendNetworkMessageToPeer(data, reliable, peerCppPtr);
        } else {
            self.toServer().sendNetworkMessageToPeer(data, reliable, peerCppPtr);
        }
    }

    pub fn createMessageNode(self: *const Self, messageNodeName: []const u8) *MessageNode {
        if (self.isClient) {
            return self.toClient().createMessageNode(messageNodeName);
        } else {
            return self.toServer().createMessageNode(messageNodeName);
        }
    }

    pub fn getGameSession(self: *const Self) basis.game_session.GameSessionPtr {
        if (self.isClient) {
            return self.toClient().getGameSession();
        } else {
            return self.toServer().getGameSession();
        }
    }

    pub fn getGameState(self: *const Self) basis.game_state.GameStatePtr {
        if (self.isClient) {
            return self.toClient().getGameState();
        } else {
            return self.toServer().getGameState();
        }
    }

    pub fn getHostID(self: *const Self) i32 {
        if (self.isClient) {
            return self.toClient().getHostID();
        } else {
            return basis.network.ServerHostID;
        }
    }

    // TODO: Add more methods here as needed...

    //----------------------------------------------------

    // Casting to Client or Server:

    pub fn toClient(self: *const Self) basis.host.ClientPtr {
        basis.assert(@src(), self.isClient);
        return basis.host.ClientPtr{ .cppPtr = self.cppPtr, .allocator = self.allocator };
    }

    pub fn toServer(self: *const Self) basis.host.ServerPtr {
        basis.assert(@src(), !self.isClient);
        return basis.host.ServerPtr{ .cppPtr = self.cppPtr, .allocator = self.allocator };
    }
};

pub fn errorIfNotClientOrServer(clientOrServer: anytype) void {
    switch (@TypeOf(clientOrServer)) {
        basis.host.ClientPtr => {},
        basis.host.ServerPtr => {},
        else => {
            @compileError("Not client or server: '" ++ @typeName(@TypeOf(clientOrServer)) ++ "'");
        },
    }
}
