// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const ASTypeReg = basis.angelscript.TypeRegistration;

// A polymorphic interface for Apps.
pub const ModControllerInterface = struct {
    const Self = @This();

    object: basis.IntPtr = undefined,
    vTable: *const VirtualTable = undefined,

    const VirtualTable = struct {
        deinit: *const fn (*Self) void,

        onAppStartup: *const fn (*Self) void,
        beforeAppShutdown: *const fn (*Self) void,

        onServerCreated: *const fn (*Self) void,
        beforeServerDestroyed: *const fn (*Self) void,

        onClientUpdate: *const fn (*Self, f32) void,
        onServerUpdate: *const fn (*Self, f32) void,
        onClientTick: *const fn (*Self, f32) void,
        onServerTick: *const fn (*Self, f32) void,

        registerAngelScriptTypes: *const fn (*Self, ASTypeReg) void,
    };

    //----------------------------------------------------

    // Note that we have to supply "self" as the first parameter here manually.

    pub fn deinit(self: *Self) void {
        self.vTable.deinit(self);
    }

    pub fn onAppStartup(self: *Self) void {
        self.vTable.onAppStartup(self);
    }

    pub fn beforeAppShutdown(self: *Self) void {
        self.vTable.beforeAppShutdown(self);
    }

    pub fn onServerCreated(self: *Self) void {
        self.vTable.onServerCreated(self);
    }

    pub fn beforeServerDestroyed(self: *Self) void {
        self.vTable.beforeServerDestroyed(self);
    }

    pub fn onClientUpdate(self: *Self, deltaTime: f32) void {
        self.vTable.onClientUpdate(self, deltaTime);
    }

    pub fn onServerUpdate(self: *Self, deltaTime: f32) void {
        self.vTable.onServerUpdate(self, deltaTime);
    }

    pub fn onClientTick(self: *Self, tickDeltaTime: f32) void {
        self.vTable.onClientTick(self, tickDeltaTime);
    }

    pub fn onServerTick(self: *Self, tickDeltaTime: f32) void {
        self.vTable.onServerTick(self, tickDeltaTime);
    }

    pub fn registerAngelScriptTypes(self: *Self, reg: ASTypeReg) void {
        self.vTable.registerAngelScriptTypes(self, reg);
    }

    //----------------------------------------------------

    pub fn make(comptime T: type, appPtr: *T) Self {
        return Self{
            .object = @intFromPtr(appPtr),
            .vTable = &.{
                .deinit = struct {
                    fn wrapCall(self: *Self) void {
                        var typedApp = @as(*T, @ptrFromInt(self.object));
                        typedApp.deinit();
                    }
                }.wrapCall,
                .onAppStartup = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "onAppStartup")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.onAppStartup() catch |err| {
                                basis.fatalErrorWithFormat(@src(), "Error in onAppStartup(): {s}", .{@errorName(err)});
                            };
                        }
                    }
                }.wrapCall,
                .beforeAppShutdown = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "beforeAppShutdown")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.beforeAppShutdown();
                        }
                    }
                }.wrapCall,
                .onServerCreated = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "onServerCreated")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.onServerCreated() catch |err| {
                                basis.fatalErrorWithFormat(@src(), "Error in onServerCreated(): {s}", .{@errorName(err)});
                            };
                        }
                    }
                }.wrapCall,
                .beforeServerDestroyed = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "beforeServerDestroyed")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.beforeServerDestroyed();
                        }
                    }
                }.wrapCall,
                .onClientUpdate = struct {
                    fn wrapCall(self: *Self, deltaTime: f32) void {
                        if (@hasDecl(T, "onClientUpdate")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.onClientUpdate(deltaTime);
                        }
                    }
                }.wrapCall,
                .onServerUpdate = struct {
                    fn wrapCall(self: *Self, deltaTime: f32) void {
                        if (@hasDecl(T, "onServerUpdate")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.onServerUpdate(deltaTime);
                        }
                    }
                }.wrapCall,
                .onClientTick = struct {
                    fn wrapCall(self: *Self, tickDeltaTime: f32) void {
                        if (@hasDecl(T, "onClientTick")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.onClientTick(tickDeltaTime);
                        }
                    }
                }.wrapCall,
                .onServerTick = struct {
                    fn wrapCall(self: *Self, tickDeltaTime: f32) void {
                        if (@hasDecl(T, "onServerTick")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.onServerTick(tickDeltaTime);
                        }
                    }
                }.wrapCall,
                .registerAngelScriptTypes = struct {
                    fn wrapCall(self: *Self, reg: ASTypeReg) void {
                        if (@hasDecl(T, "registerAngelScriptTypes")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.registerAngelScriptTypes(reg);
                        }
                    }
                }.wrapCall,
            },
        };
    }
};
