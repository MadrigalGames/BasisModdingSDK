// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const ServerHostID: i32 = 0;
pub const UnsetHostID: i32 = -1;
pub const AllJoinedClientsHostID: i32 = -2;
pub const LobbyServerHostID: i32 = -3;

// The first RPC channel which is available for the game to use.
pub const FirstGameRPCChannel = 1000;

pub const RPCFunctionID = i32;
pub const RPCCallCounter = u8;
pub const RPCChannelID = u16;

pub const PipeID = u64;

pub const RPCResult = void; // The return type of an RPC with out parameters.
pub const RPCVoid = void; // The return type of an RPC without out parameters.

pub const NetworkMessageType = enum(u8) {
    None = 0,
    RPC = 1,
    Input = 2,
    Pipe = 3,

    pub fn asInt(self: NetworkMessageType) u8 {
        return @intFromEnum(self);
    }
};

pub const PipeDirection = enum(i32) {
    ServerToClient = 0,
    // TODO: Some day we will support these too...
    //ClientToServer,
    //Bidirectional,

    pub fn asInt(self: PipeDirection) i32 {
        return @intFromEnum(self);
    }
};

// Parameters: Data buffer, data length, peer cppPtr, user data.
pub const OnRPCReceivedFnPtr = *const fn ([*c]u8, usize, basis.CppPtr, basis.IntPtr) callconv(.c) void;

pub const propagated_value = @import("network/propagated_value.zig");

pub const PropagatedValue = propagated_value.PropagatedValue;
pub const PropagatedValueHandle = propagated_value.PropagatedValueHandle;

pub const PropagatedAction = propagated_value.PropagatedAction;
pub const PropagatedActionHandle = propagated_value.PropagatedActionHandle;
