// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

const Message = basis.messaging.Message;
const MessageParametersPtr = basis.messaging.MessageParametersPtr;
const StringHash = basis.string.StringHash;

pub const FlowStateInterface = struct {
    const Self = @This();
    object: basis.IntPtr = undefined,
    vTable: *const VirtualTable = undefined,

    const VirtualTable = struct {
        //postInit: *const fn (*Self) void,
        deinit: *const fn (*Self) void,
        onEnter: *const fn (*Self) void,
        onExit: *const fn (*Self) void,
        update: *const fn (*Self, f32) void,
        isLoadingComplete: *const fn (*const Self) bool,
        onMessageReceived: *const fn (*Self, Message, StringHash, MessageParametersPtr) void,

        // Special function which, given an allocator, deallocates
        // the typed object this interface belongs to.
        destroy: *const fn (*Self, Allocator) void,
    };

    //----------------------------------------------------

    // Note that we have to supply "self" as the first parameter here manually.

    // pub fn postInit(self: *Self) void {
    //     self.vTable.postInit(self);
    // }

    pub fn deinit(self: *Self) void {
        self.vTable.deinit(self);
    }

    pub fn onEnter(self: *Self) void {
        self.vTable.onEnter(self);
    }

    pub fn onExit(self: *Self) void {
        self.vTable.onExit(self);
    }

    pub fn update(self: *Self, deltaTime: f32) void {
        self.vTable.update(self, deltaTime);
    }

    pub fn isLoadingComplete(self: *const Self) bool {
        return self.vTable.isLoadingComplete(self);
    }

    pub fn onMessageReceived(
        self: *Self,
        message: Message,
        senderNameHash: StringHash,
        parameters: MessageParametersPtr,
    ) void {
        self.vTable.onMessageReceived(self, message, senderNameHash, parameters);
    }

    pub fn destroy(self: *Self, allocator: Allocator) void {
        self.vTable.destroy(self, allocator);
    }

    //----------------------------------------------------

    pub fn make(comptime T: type, flowStatePtr: anytype) Self {
        return Self{
            .object = @intFromPtr(flowStatePtr),
            .vTable = &.{
                // .postInit = struct {
                //     fn wrapCall(self: *Self) void {
                //         if (@hasDecl(T, "postInit")) {
                //             var typedFlowState = @as(*T, @ptrFromInt(self.object));
                //             typedFlowState.postInit();
                //         }
                //     }
                // }.wrapCall,
                .deinit = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "deinit")) {
                            var typedFlowState = @as(*T, @ptrFromInt(self.object));
                            typedFlowState.deinit();
                        }
                    }
                }.wrapCall,
                .onEnter = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "onEnter")) {
                            var typedFlowState = @as(*T, @ptrFromInt(self.object));
                            typedFlowState.onEnter();
                        }
                    }
                }.wrapCall,
                .onExit = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "onExit")) {
                            var typedFlowState = @as(*T, @ptrFromInt(self.object));
                            typedFlowState.onExit();
                        }
                    }
                }.wrapCall,
                .update = struct {
                    fn wrapCall(self: *Self, deltaTime: f32) void {
                        if (@hasDecl(T, "update")) {
                            var typedFlowState = @as(*T, @ptrFromInt(self.object));
                            typedFlowState.update(deltaTime);
                        }
                    }
                }.wrapCall,
                .isLoadingComplete = struct {
                    fn wrapCall(self: *const Self) bool {
                        if (@hasDecl(T, "isLoadingComplete")) {
                            var typedFlowState = @as(*T, @ptrFromInt(self.object));
                            return typedFlowState.isLoadingComplete();
                        } else {
                            return true;
                        }
                    }
                }.wrapCall,
                .onMessageReceived = struct {
                    fn wrapCall(
                        self: *Self,
                        message: Message,
                        senderNameHash: StringHash,
                        parameters: MessageParametersPtr,
                    ) void {
                        if (@hasDecl(T, "onMessageReceived")) {
                            var typedFlowState = @as(*T, @ptrFromInt(self.object));
                            typedFlowState.onMessageReceived(message, senderNameHash, parameters) catch |err| {
                                basis.assertf(@src(), false, "Error in FlowState onMessageReceived(): {s}", .{@errorName(err)});
                            };
                        }
                    }
                }.wrapCall,
                .destroy = struct {
                    fn wrapCall(self: *Self, allocator: Allocator) void {
                        const typedFlowState = @as(*T, @ptrFromInt(self.object));
                        allocator.destroy(typedFlowState);
                    }
                }.wrapCall,
            },
        };
    }
};
