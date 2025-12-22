// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

const AppInterface = basis.app_interface.AppInterface;

const FlowStateInterface = basis.flow_state_interface.FlowStateInterface;

const GameObjectCreationParametersPtr = basis.game_object.GameObjectCreationParametersPtr;

const ClientPtr = basis.host.ClientPtr;
const ServerPtr = basis.host.ServerPtr;

const ConfigOptionsPtr = basis.config_options.ConfigOptionsPtr;

pub const FlowStateFlags = enum(i32) {
    None = 0,
    BailOut = 1 << 0,
};

pub const AppMode = enum(i32) {
    AppModeGame = 0,
    AppModeLevelEditor,
    AppModeAssetBrowser,
};

// Convenience functions for creating/destroying apps:

pub fn create(comptime T: type, allocator: Allocator) *T {
    basis.bindings.api.init(allocator);

    var appPtr: *T = allocator.create(T) catch |err| {
        basis.fatalErrorWithFormat(@src(), "Error creating the app instance: {s}", .{@errorName(err)});
        return undefined;
    };
    const cppPtr = basis.bindings.api.App_createApp(
        basis.library_api.getZigLibCppPtr(),
        @intFromPtr(&appPtr.interface),
    );

    appPtr.* = T.init(AppInterface.make(T, appPtr), allocator, cppPtr);
    appPtr.postInit() catch |err| {
        basis.fatalErrorWithFormat(@src(), "Error in postInit(): {s}", .{@errorName(err)});
    };
    return appPtr;
}

pub fn destroy(app: anytype) void {
    const allocator = app.allocator;
    app.deinit();
    allocator.destroy(app);

    basis.bindings.api.deinit();
}

//----------------------------------------------------

pub const AppContext = struct {
    const Self = @This();

    allocator: Allocator,
    cppPtr: basis.CppPtr,

    // The game flow SMs are lazily created in getClientGameFlowStateMachine()
    // and getServerGameFlowStateMachine() but can be accessed directly after
    // being created.
    clientGameFlowStateMachine: ?basis.state_machine.StateMachine = null,
    serverGameFlowStateMachine: ?basis.state_machine.StateMachine = null,

    createGameCallback: ?basis.common.CompletionCallback = null,
    leaveGameCallback: ?basis.common.CompletionCallback = null,

    cachedAppMode: ?AppMode = null,

    pub fn init(allocator: Allocator, cppPtr: basis.CppPtr) Self {
        basis.resources.resource_manager.init(allocator);

        basis.debug_overlay.init(allocator);

        return Self{
            .allocator = allocator,
            .cppPtr = cppPtr,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.clientGameFlowStateMachine) |*sm| {
            sm.deinit();
            self.clientGameFlowStateMachine = null;
        }

        if (self.serverGameFlowStateMachine) |*sm| {
            sm.deinit();
            self.serverGameFlowStateMachine = null;
        }

        basis.debug_overlay.deinit();

        basis.resources.resource_manager.deinit();
    }

    pub fn getAppMode(self: *Self) AppMode {
        if (self.cachedAppMode) |appMode| {
            return appMode;
        }

        self.cachedAppMode = @enumFromInt(basis.bindings.api.App_getAppMode(self.cppPtr));
        return self.cachedAppMode.?;
    }

    pub fn getClient(self: *const Self) ClientPtr {
        return ClientPtr{
            .cppPtr = basis.bindings.api.App_getClient(self.cppPtr),
            .allocator = self.allocator,
        };
    }

    pub fn getServer(self: *const Self) ServerPtr {
        return ServerPtr{
            .cppPtr = basis.bindings.api.App_getServer(self.cppPtr),
            .allocator = self.allocator,
        };
    }

    pub fn registerMessage(self: *const Self, message: anytype, category: anytype) void {
        basis.bindings.api.App_registerMessage(self.cppPtr, @intFromEnum(message), @intFromEnum(category));
    }

    // Input:

    pub fn addInput(self: *const Self, inputID: anytype, inputType: basis.input.InputType) void {
        basis.bindings.api.App_addInput(self.cppPtr, @intFromEnum(inputID), @intFromEnum(inputType));
    }

    pub fn getInputBufferSize(self: *const Self) u32 {
        return basis.bindings.api.App_getInputBufferSize(self.cppPtr);
    }

    pub fn clearInputMappings(self: *const Self) void {
        basis.bindings.api.App_clearInputMappings(self.cppPtr);
    }

    pub fn mapInput(
        self: *const Self,
        inputID: anytype,
        source: basis.input.InputSource,
        contextID: anytype,
        valueMultiplier: f32,
    ) void {
        self.mapInputWithFlags(
            inputID,
            source,
            contextID,
            valueMultiplier,
            basis.input.InputMappingFlags.None.asInt(),
        );
    }

    pub fn mapInputWithFlags(
        self: *const Self,
        inputID: anytype,
        source: basis.input.InputSource,
        contextID: anytype,
        valueMultiplier: f32,
        flags: i32,
    ) void {
        basis.bindings.api.App_mapInput(
            self.cppPtr,
            @intFromEnum(inputID),
            @intFromEnum(source),
            @intFromEnum(contextID),
            valueMultiplier,
            flags,
        );
    }

    pub fn mapKeyboardInput(
        self: *const Self,
        inputID: anytype,
        keyCode: basis.input.KeyCode,
        contextID: anytype,
    ) void {
        self.mapKeyboardInputWithFlags(
            inputID,
            keyCode,
            contextID,
            basis.input.InputMappingFlags.None.asInt(),
        );
    }

    pub fn mapKeyboardInputWithFlags(
        self: *const Self,
        inputID: anytype,
        keyCode: basis.input.KeyCode,
        contextID: anytype,
        flags: i32,
    ) void {
        basis.bindings.api.App_mapKeyboardInput(
            self.cppPtr,
            @intFromEnum(inputID),
            @intFromEnum(keyCode),
            @intFromEnum(contextID),
            flags,
        );
    }

    pub fn mapMouseButtonInput(
        self: *const Self,
        inputID: anytype,
        mouseButton: basis.input.MouseButtonID,
        contextID: anytype,
    ) void {
        self.mapMouseButtonInputWithFlags(
            inputID,
            mouseButton,
            contextID,
            basis.input.InputMappingFlags.None.asInt(),
        );
    }

    pub fn mapMouseButtonInputWithFlags(
        self: *const Self,
        inputID: anytype,
        mouseButton: basis.input.MouseButtonID,
        contextID: anytype,
        flags: i32,
    ) void {
        basis.bindings.api.App_mapMouseButtonInput(
            self.cppPtr,
            @intFromEnum(inputID),
            @intFromEnum(mouseButton),
            @intFromEnum(contextID),
            flags,
        );
    }

    pub fn mapGamepadButtonInput(
        self: *const Self,
        inputID: anytype,
        gamepadButton: basis.input.GamepadButton,
        contextID: anytype,
    ) void {
        self.mapGamepadButtonInputWithFlags(
            inputID,
            gamepadButton,
            contextID,
            basis.input.InputMappingFlags.None.asInt(),
        );
    }

    pub fn mapGamepadButtonInputWithFlags(
        self: *const Self,
        inputID: anytype,
        gamepadButton: basis.input.GamepadButton,
        contextID: anytype,
        flags: i32,
    ) void {
        basis.bindings.api.App_mapGamepadButtonInput(
            self.cppPtr,
            @intFromEnum(inputID),
            @intFromEnum(gamepadButton),
            @intFromEnum(contextID),
            flags,
        );
    }

    // Game flow:

    // The game flow state machines are created the first time getClientGameFlowStateMachine() or
    // getServerGameFlowStateMachine() is called. After that, the same SM is returned for subsequent calls.

    pub fn getClientGameFlowStateMachine(self: *Self) *basis.state_machine.StateMachine {
        if (self.clientGameFlowStateMachine) |*sm| {
            return sm;
        }

        self.clientGameFlowStateMachine = basis.state_machine.StateMachine.init(
            self.allocator,
            basis.bindings.api.App_getClientGameFlowStateMachine(self.cppPtr),
        );

        return &(self.clientGameFlowStateMachine.?);
    }

    pub fn getServerGameFlowStateMachine(self: *Self) *basis.state_machine.StateMachine {
        if (self.serverGameFlowStateMachine) |*sm| {
            return sm;
        }

        self.serverGameFlowStateMachine = basis.state_machine.StateMachine.init(
            self.allocator,
            basis.bindings.api.App_getServerGameFlowStateMachine(self.cppPtr),
        );

        return &(self.serverGameFlowStateMachine.?);
    }

    // Game session creation:

    /// Creates a local server, connects to the game, joins it as the creator
    /// and starts loading into the given level, with the given layers and
    /// session objects. Must be called on the client.
    pub fn createAndLoadSPGame(
        self: *Self,
        gameName: []const u8,
        levelPath: []const u8,
        layers: [][]const u8,
        sessionObjects: []const GameObjectCreationParametersPtr,
        continuous: bool,
        callback: basis.common.CompletionCallback,
    ) void {
        const gameNameInteropString = basis.string.toInteropString(gameName);
        const levelPathInteropString = basis.string.toInteropString(levelPath);

        var layerInteropStrings: [32]basis.bindings.InteropString = undefined;
        var sessionObjectCppPtrs: [32]basis.CppPtr = undefined;

        for (layers, 0..) |layer, i| {
            layerInteropStrings[i] = basis.string.toInteropString(layer);
        }

        for (sessionObjects, 0..) |obj, i| {
            sessionObjectCppPtrs[i] = obj.cppPtr;
        }

        self.createGameCallback = callback;

        basis.bindings.api.App_createAndLoadSPGame(
            self.cppPtr,
            &gameNameInteropString,
            &levelPathInteropString,
            &layerInteropStrings,
            @as(u32, @intCast(layers.len)),
            &sessionObjectCppPtrs,
            @as(u32, @intCast(sessionObjects.len)),
            if (continuous) 1 else 0,
            onSPGameCreated,
            basis.bindings.hostIntPtrFromLib(@intFromPtr(self)),
        );
    }

    /// Creates a local server, connects to the game and joins it as the creator.
    /// Must be called on the client.
    pub fn createSPGame(
        self: *Self,
        gameName: []const u8,
        continuous: bool,
        callback: basis.common.CompletionCallback,
    ) void {
        const gameNameInteropString = basis.string.toInteropString(gameName);

        self.createGameCallback = callback;

        basis.bindings.api.App_createSPGame(
            self.cppPtr,
            &gameNameInteropString,
            if (continuous) 1 else 0,
            onSPGameCreated,
            basis.bindings.hostIntPtrFromLib(@intFromPtr(self)),
        );
    }

    /// Starts loading into the given level, with the given layers and
    /// session objects. Before calling this, a game must already have
    /// been created and joined, eg. with a call to createSPGame().
    /// Must be called on the client.
    pub fn loadSPGame(
        self: *Self,
        levelPath: []const u8,
        layers: []const []const u8,
        sessionObjects: []const GameObjectCreationParametersPtr,
    ) void {
        const levelPathInteropString = basis.string.toInteropString(levelPath);

        var layerInteropStrings: [32]basis.bindings.InteropString = undefined;
        var sessionObjectCppPtrs: [32]basis.CppPtr = undefined;

        for (layers, 0..) |layer, i| {
            layerInteropStrings[i] = basis.string.toInteropString(layer);
        }

        for (sessionObjects, 0..) |obj, i| {
            sessionObjectCppPtrs[i] = obj.cppPtr;
        }

        basis.bindings.api.App_loadSPGame(
            self.cppPtr,
            &levelPathInteropString,
            &layerInteropStrings,
            @as(u32, @intCast(layers.len)),
            &sessionObjectCppPtrs,
            @as(u32, @intCast(sessionObjects.len)),
        );
    }

    /// Leaves the current game session, and optionally disconnects from
    /// the server completely. Must be called on the client.
    pub fn leaveGame(
        self: *Self,
        alsoDisconnectFromServer: bool,
        callback: basis.common.CompletionCallback,
    ) void {
        self.leaveGameCallback = callback;

        basis.bindings.api.App_leaveGame(
            self.cppPtr,
            if (alsoDisconnectFromServer) 1 else 0,
            onGameLeft,
            basis.bindings.hostIntPtrFromLib(@intFromPtr(self)),
        );
    }

    //----------------------------------------------------

    fn onSPGameCreated(context: basis.IntPtr64, resultCode: i32) callconv(.c) void {
        const self = @as(*Self, @ptrFromInt(basis.bindings.libIntPtrFromHost(context)));
        const result = @as(basis.common.ResultCode, @enumFromInt(resultCode));

        if (self.createGameCallback) |cb| {
            cb.call(result);
        }
    }

    fn onGameLeft(context: basis.IntPtr64, resultCode: i32) callconv(.c) void {
        const self = @as(*Self, @ptrFromInt(basis.bindings.libIntPtrFromHost(context)));
        const result = @as(basis.common.ResultCode, @enumFromInt(resultCode));

        if (self.leaveGameCallback) |cb| {
            cb.call(result);
        }
    }
};

// Functions not belonging to an app (context) pointer:

pub fn isLocalServerRunning() bool {
    return if (basis.bindings.api.App_isLocalServerRunning() == 1) true else false;
}

pub fn isServerThreadRunning() bool {
    return if (basis.bindings.api.App_isServerThreadRunning() == 1) true else false;
}

pub fn hasCommandLineParameter(parameter: []const u8) bool {
    const parameterInteropString = basis.string.toInteropString(parameter);
    return if (basis.bindings.api.App_hasCommandLineParameter(&parameterInteropString) == 1) true else false;
}

pub fn getCommandLineParameter(parameter: []const u8) []const u8 {
    const parameterInteropString = basis.string.toInteropString(parameter);
    var valueInteropString: basis.bindings.InteropString = undefined;
    basis.bindings.api.App_getCommandLineParameter(&parameterInteropString, &valueInteropString);
    return valueInteropString.ptr[0..valueInteropString.len];
}

pub fn getConfigOptions() ConfigOptionsPtr {
    return ConfigOptionsPtr{ .cppPtr = basis.bindings.api.App_getConfigOptions() };
}
