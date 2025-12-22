// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const ASTypeReg = basis.angelscript.TypeRegistration;

const ConfigOptionsPtr = basis.config_options.ConfigOptionsPtr;

// A polymorphic interface for Apps.
pub const AppInterface = struct {
    const Self = @This();

    object: basis.IntPtr = undefined,
    vTable: *const VirtualTable = undefined,

    const VirtualTable = struct {
        deinit: *const fn (*Self) void,

        onAppStartup: *const fn (*Self) void,
        beforeAppShutdown: *const fn (*Self) void,

        onServerCreated: *const fn (*Self) void,
        beforeServerDestroyed: *const fn (*Self) void,

        initClientGameFlow: *const fn (*Self) void,
        initServerGameFlow: *const fn (*Self) void,
        setInputMappings: *const fn (*Self) void,

        createClientPlayerController: *const fn (*Self, basis.bindings.InteropTypedPtr, i32) basis.IntPtr,
        destroyClientPlayerController: *const fn (*Self, basis.IntPtr) void,
        createServerPlayerController: *const fn (*Self, basis.bindings.InteropTypedPtr, i32) basis.IntPtr,
        destroyServerPlayerController: *const fn (*Self, basis.IntPtr) void,

        onClientUpdate: *const fn (*Self, f32) void,
        onServerUpdate: *const fn (*Self, f32) void,
        onClientTick: *const fn (*Self, f32) void,
        onServerTick: *const fn (*Self, f32) void,

        registerAngelScriptTypes: *const fn (*Self, ASTypeReg) void,

        setDefaultConfigOptions: *const fn (*Self, ConfigOptionsPtr) void,
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

    pub fn initClientGameFlow(self: *Self) void {
        self.vTable.initClientGameFlow(self);
    }

    pub fn initServerGameFlow(self: *Self) void {
        self.vTable.initServerGameFlow(self);
    }

    pub fn setInputMappings(self: *Self) void {
        self.vTable.setInputMappings(self);
    }

    pub fn createClientPlayerController(self: *Self, contextCppPtr: basis.bindings.InteropTypedPtr, hostID: i32) basis.IntPtr {
        return self.vTable.createClientPlayerController(self, contextCppPtr, hostID);
    }

    pub fn destroyClientPlayerController(self: *Self, interfaceIntPtr: basis.IntPtr) void {
        self.vTable.destroyClientPlayerController(self, interfaceIntPtr);
    }

    pub fn createServerPlayerController(self: *Self, contextCppPtr: basis.bindings.InteropTypedPtr, hostID: i32) basis.IntPtr {
        return self.vTable.createServerPlayerController(self, contextCppPtr, hostID);
    }

    pub fn destroyServerPlayerController(self: *Self, interfaceIntPtr: basis.IntPtr) void {
        self.vTable.destroyServerPlayerController(self, interfaceIntPtr);
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

    pub fn setDefaultConfigOptions(self: *Self, configOptions: ConfigOptionsPtr) void {
        self.vTable.setDefaultConfigOptions(self, configOptions);
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
                .initClientGameFlow = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "initClientGameFlow")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.initClientGameFlow();
                        }
                    }
                }.wrapCall,
                .initServerGameFlow = struct {
                    fn wrapCall(self: *Self) void {
                        if (@hasDecl(T, "initServerGameFlow")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.initServerGameFlow();
                        }
                    }
                }.wrapCall,
                .setInputMappings = struct {
                    fn wrapCall(self: *Self) void {
                        var typedApp = @as(*T, @ptrFromInt(self.object));
                        typedApp.setInputMappings();
                    }
                }.wrapCall,
                .createClientPlayerController = struct {
                    fn wrapCall(self: *Self, contextCppPtr: basis.bindings.InteropTypedPtr, hostID: i32) basis.IntPtr {
                        var typedApp = @as(*T, @ptrFromInt(self.object));
                        return typedApp.createClientPlayerController(contextCppPtr, hostID);
                    }
                }.wrapCall,
                .destroyClientPlayerController = struct {
                    fn wrapCall(self: *Self, interfaceIntPtr: basis.IntPtr) void {
                        var typedApp = @as(*T, @ptrFromInt(self.object));
                        typedApp.destroyClientPlayerController(interfaceIntPtr);
                    }
                }.wrapCall,
                .createServerPlayerController = struct {
                    fn wrapCall(self: *Self, contextCppPtr: basis.bindings.InteropTypedPtr, hostID: i32) basis.IntPtr {
                        var typedApp = @as(*T, @ptrFromInt(self.object));
                        return typedApp.createServerPlayerController(contextCppPtr, hostID);
                    }
                }.wrapCall,
                .destroyServerPlayerController = struct {
                    fn wrapCall(self: *Self, interfaceIntPtr: basis.IntPtr) void {
                        var typedApp = @as(*T, @ptrFromInt(self.object));
                        typedApp.destroyServerPlayerController(interfaceIntPtr);
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
                .setDefaultConfigOptions = struct {
                    fn wrapCall(self: *Self, configOptions: ConfigOptionsPtr) void {
                        if (@hasDecl(T, "setDefaultConfigOptions")) {
                            var typedApp = @as(*T, @ptrFromInt(self.object));
                            typedApp.setDefaultConfigOptions(configOptions);
                        }
                    }
                }.wrapCall,
            },
        };
    }
};
