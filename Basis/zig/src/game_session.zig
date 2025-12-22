// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Allocator = std.mem.Allocator;

pub const GameSessionType = enum(i32) {
    SinglePlayer = 0,
    LanGame = 1,
    InternetGame = 2,
    LevelEditor = 3,
    AssetBrowser = 4,
    Unknown = -1,
};

pub const ClientProxy = struct {
    const Self = @This();
    hostID: i32,

    pub fn initNull() Self {
        return Self{ .hostID = 0 };
    }

    pub fn initFromHostID(hostID: i32) ClientProxy {
        return ClientProxy{ .hostID = hostID };
    }

    pub fn fromInterop(interop: basis.bindings.InteropClientProxy) ClientProxy {
        return ClientProxy{ .hostID = interop.hostID };
    }
};

pub const GameSessionPtr = struct {
    const Self = @This();
    pub const Null = initNull();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    pub fn getSessionType(self: *const Self) GameSessionType {
        const i = basis.bindings.api.GameSession_getSessionType(self.cppPtr);
        return @as(GameSessionType, @enumFromInt(i));
    }

    pub fn isToolSession(self: *const Self) bool {
        const t = self.getSessionType();
        return (t == GameSessionType.LevelEditor or t == GameSessionType.AssetBrowser);
    }

    // Returns the number of clients connected to the server game session.
    // Returns 0 when called on a client.
    pub fn getClientCount(self: *const Self) u32 {
        return basis.bindings.api.GameSession_getClientCount(self.cppPtr);
    }

    // Gets a client proxy, given the client's index.
    // Returns a null proxy when called on a client.
    pub fn getClient(self: *const Self, clientIndex: u32) ClientProxy {
        var interop: basis.bindings.InteropClientProxy = undefined;
        basis.bindings.api.GameSession_getClient(self.cppPtr, clientIndex, &interop);
        return ClientProxy.fromInterop(interop);
    }

    pub fn isPaused(self: *const Self) bool {
        return basis.bindings.api.GameSession_isPaused(self.cppPtr) == 1;
    }

    // When called on a client, requests pausing/unpausing the game.
    // Has no effect when called on the server.
    pub fn requestPause(self: *Self, paused: bool) void {
        return basis.bindings.api.GameSession_requestPause(self.cppPtr, if (paused) 1 else 0);
    }

    pub fn getLevelData(self: *const Self) basis.level_data.LevelDataPtr {
        return basis.level_data.LevelDataPtr{
            .cppPtr = basis.bindings.api.GameSession_getLevelData(self.cppPtr),
        };
    }

    pub fn isContinuousSession(self: *const Self) bool {
        const continuous = basis.bindings.api.GameSession_isContinuousSession(self.cppPtr);
        return if (continuous == 1) true else false;
    }
};
