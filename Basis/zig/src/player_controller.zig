// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const Allocator = std.mem.Allocator;

const IntPtr = basis.IntPtr;
const Message = basis.messaging.Message;
const MessageParametersPtr = basis.messaging.MessageParametersPtr;
const StringHash = basis.string.StringHash;
const ClientPtr = basis.host.ClientPtr;
const ServerPtr = basis.host.ServerPtr;

// Convenience functions for creating/destroying player controllers:

pub fn createController(
    comptime T: type,
    allocator: Allocator,
    io: std.Io,
    contextCppPtr: basis.bindings.InteropTypedPtr,
    hostID: i32,
) *PlayerControllerInterface {
    var ctrlPtr: *T = allocator.create(T) catch @panic("OOM");

    const typeNameHash = comptime basis.typeinfo.getNameHashFromType(T);

    ctrlPtr.* = T.init(
        PlayerControllerInterface.make(T, ctrlPtr, typeNameHash),
        allocator,
        io,
        contextCppPtr,
        hostID,
    );
    if (@hasDecl(T, "postInit")) {
        ctrlPtr.postInit();
    }

    return &ctrlPtr.interface;
}

pub fn destroyController(comptime T: type, allocator: Allocator, interfaceIntPtr: basis.IntPtr) void {
    const interfacePtr = @as(*PlayerControllerInterface, @ptrFromInt(interfaceIntPtr));
    var ctrlPtr: *T = @alignCast(@fieldParentPtr("interface", interfacePtr));

    if (@hasDecl(T, "deinit")) {
        ctrlPtr.deinit();
    }
    allocator.destroy(ctrlPtr);
}

pub const PlayerControllerInterface = struct {
    const Self = @This();

    object: IntPtr = 0,
    typeNameHash: u32 = 0,
    vTable: *const VirtualTable = undefined,

    const VirtualTable = struct {
        update: *const fn (*Self, f32) void,
        tick: *const fn (*Self, f32) void,
        onMessageReceived: *const fn (*Self, Message, StringHash, MessageParametersPtr) void,
        beforeHotReload: *const fn (*Self) void,
        afterHotReload: *const fn (*Self) void,
    };

    //----------------------------------------------------

    // Note that we have to supply "self" as the first parameter here manually.

    pub fn update(self: *Self, deltaTime: f32) void {
        self.vTable.update(self, deltaTime);
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) void {
        self.vTable.tick(self, tickDeltaTime);
    }

    pub fn onMessageReceived(
        self: *Self,
        message: Message,
        senderNameHash: StringHash,
        parameters: MessageParametersPtr,
    ) void {
        self.vTable.onMessageReceived(self, message, senderNameHash, parameters);
    }

    pub fn beforeHotReload(self: *Self) void {
        self.vTable.beforeHotReload(self);
    }

    pub fn afterHotReload(self: *Self) void {
        self.vTable.afterHotReload(self);
    }

    //----------------------------------------------------

    pub fn make(comptime T: type, controllerPtr: *T, typeNameHash: u32) Self {
        var self = Self{
            .object = @intFromPtr(controllerPtr),
            .vTable = undefined,
            .typeNameHash = typeNameHash,
        };
        self.setupVTable(T);
        return self;
    }

    pub fn setupVTable(_self: *Self, comptime T: type) void {
        _self.vTable = &.{
            .update = struct {
                fn wrapCall(self: *Self, deltaTime: f32) void {
                    if (@hasDecl(T, "update")) {
                        var typedController = @as(*T, @ptrFromInt(self.object));
                        typedController.update(deltaTime);
                    }
                }
            }.wrapCall,
            .tick = struct {
                fn wrapCall(self: *Self, tickDeltaTime: f32) void {
                    if (@hasDecl(T, "tick")) {
                        var typedController = @as(*T, @ptrFromInt(self.object));
                        typedController.tick(tickDeltaTime);
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
                        var typedController = @as(*T, @ptrFromInt(self.object));
                        typedController.onMessageReceived(message, senderNameHash, parameters);
                    }
                }
            }.wrapCall,
            .beforeHotReload = struct {
                fn wrapCall(self: *Self) void {
                    if (@hasDecl(T, "beforeHotReload")) {
                        var typedController = @as(*T, @ptrFromInt(self.object));
                        typedController.beforeHotReload();
                    }
                }
            }.wrapCall,
            .afterHotReload = struct {
                fn wrapCall(self: *Self) void {
                    if (@hasDecl(T, "afterHotReload")) {
                        var typedController = @as(*T, @ptrFromInt(self.object));
                        typedController.afterHotReload();
                    }
                }
            }.wrapCall,
        };
    }
};

pub const ClientPlayerController = struct {
    const Self = @This();

    cppPtr: basis.bindings.InteropTypedPtr,
    allocator: Allocator,
    io: std.Io,

    pub fn init(cppPtr: basis.bindings.InteropTypedPtr, allocator: Allocator, io: std.Io) ClientPlayerController {
        return ClientPlayerController{
            .cppPtr = cppPtr,
            .allocator = allocator,
            .io = io,
        };
    }

    //----------------------------------------------------

    pub fn getClient(self: *const Self) ClientPtr {
        return ClientPtr{
            .cppPtr = basis.bindings.api.PlayerController_getClient(self.cppPtr),
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getInputRange(self: *const Self, inputID: anytype) f32 {
        return basis.bindings.api.PlayerController_getInputRange(self.cppPtr, @intFromEnum(inputID));
    }

    pub fn getInputState(self: *const Self, inputID: anytype) bool {
        return basis.bindings.api.PlayerController_getInputState(self.cppPtr, @intFromEnum(inputID));
    }

    pub fn getInputAction(self: *const Self, inputID: anytype) bool {
        return basis.bindings.api.PlayerController_getInputAction(self.cppPtr, @intFromEnum(inputID));
    }

    pub fn subscribeToMessageCategory(self: *const Self, cat: anytype) void {
        const value = basis.messaging.castToMessageCategory(cat);
        basis.bindings.api.PlayerController_subscribeToMessageCategory(self.cppPtr, value);
    }

    pub fn allocMsgParams(self: *const Self) MessageParametersPtr {
        return MessageParametersPtr.init(basis.bindings.api.PlayerController_allocMsgParams(self.cppPtr));
    }

    pub fn sendMessage(self: *const Self, message: anytype) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.PlayerController_sendMessage(self.cppPtr, value, 0);
    }

    pub fn sendMessageWithParams(self: *const Self, message: anytype, parameters: MessageParametersPtr) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.PlayerController_sendMessage(self.cppPtr, value, parameters.cppPtr);
    }
};

pub const ServerPlayerController = struct {
    const Self = @This();

    cppPtr: basis.bindings.InteropTypedPtr,
    allocator: Allocator,
    io: std.Io,

    pub fn init(cppPtr: basis.bindings.InteropTypedPtr, allocator: Allocator, io: std.Io) ServerPlayerController {
        return ServerPlayerController{
            .cppPtr = cppPtr,
            .allocator = allocator,
            .io = io,
        };
    }

    //----------------------------------------------------

    pub fn getServer(self: *const Self) ServerPtr {
        return ServerPtr{
            .cppPtr = basis.bindings.api.PlayerController_getServer(self.cppPtr),
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getInputRange(self: *const Self, inputID: anytype) f32 {
        return basis.bindings.api.PlayerController_getInputRange(self.cppPtr, @intFromEnum(inputID));
    }

    pub fn getInputState(self: *const Self, inputID: anytype) bool {
        return basis.bindings.api.PlayerController_getInputState(self.cppPtr, @intFromEnum(inputID));
    }

    pub fn getInputAction(self: *const Self, inputID: anytype) bool {
        return basis.bindings.api.PlayerController_getInputAction(self.cppPtr, @intFromEnum(inputID));
    }

    pub fn subscribeToMessageCategory(self: *const Self, cat: anytype) void {
        const value = basis.messaging.castToMessageCategory(cat);
        basis.bindings.api.PlayerController_subscribeToMessageCategory(self.cppPtr, value);
    }

    pub fn allocMsgParams(self: *const Self) MessageParametersPtr {
        return MessageParametersPtr.init(basis.bindings.api.PlayerController_allocMsgParams(self.cppPtr));
    }

    pub fn sendMessage(self: *const Self, message: anytype) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.PlayerController_sendMessage(self.cppPtr, value, 0);
    }

    pub fn sendMessageWithParams(self: *const Self, message: anytype, parameters: MessageParametersPtr) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.PlayerController_sendMessage(self.cppPtr, value, parameters.cppPtr);
    }
};
