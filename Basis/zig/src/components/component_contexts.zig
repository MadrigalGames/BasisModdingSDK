// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Vec3 = basis.math.Vec3;
const Quaternion = basis.math.Quaternion;
const Mat43 = basis.math.Mat43;
const Color = basis.Color;
const MessageParametersPtr = basis.messaging.MessageParametersPtr;

const GameObjectPtr = basis.game_object.GameObjectPtr;

pub const GameObjectComponent = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    io: std.Io,
    cppPtr: basis.bindings.InteropTypedPtr,
    transform: TransformApi,
    editor: EditorApi,
    _isOnClient: bool,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, cppPtr: basis.bindings.InteropTypedPtr, _onClient: bool) Self {
        return Self{
            .allocator = allocator,
            .io = io,
            .cppPtr = cppPtr,
            .transform = TransformApi.init(cppPtr),
            .editor = EditorApi.init(cppPtr),
            ._isOnClient = _onClient,
        };
    }

    pub fn getName(self: *const Self) []const u8 {
        var str: basis.bindings.InteropString = undefined;
        basis.bindings.api.ComponentContext_getName(self.cppPtr, &str);
        return str.ptr[0..str.len];
    }

    pub fn onClient(self: *const Self) bool {
        return self._isOnClient;
    }

    pub fn onServer(self: *const Self) bool {
        return !self._isOnClient;
    }

    pub fn inEditor(self: *const Self) bool {
        return basis.bindings.api.ComponentContext_inEditor(self.cppPtr);
    }

    pub fn getClient(self: *const Self) basis.host.ClientPtr {
        const clientCppPtr = basis.bindings.api.ComponentContext_getClient(self.cppPtr);
        return basis.host.ClientPtr{
            .cppPtr = clientCppPtr,
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getServer(self: *const Self) basis.host.ServerPtr {
        const serverCppPtr = basis.bindings.api.ComponentContext_getServer(self.cppPtr);
        return basis.host.ServerPtr{
            .cppPtr = serverCppPtr,
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getHost(self: *const Self) basis.host.HostPtr {
        return if (self.onClient())
            basis.host.HostPtr.init(self.getClient())
        else
            basis.host.HostPtr.init(self.getServer());
    }

    // pub fn setNeedsUpdate(self: *Self, needsUpdate: bool) void {
    //     basis.bindings.api.ComponentContext_setNeedsUpdate(self.cppPtr, if (needsUpdate) 1 else 0);
    // }

    // pub fn setNeedsPreTick(self: *Self, needsPreTick: bool) void {
    //     basis.bindings.api.ComponentContext_setNeedsPreTick(self.cppPtr, if (needsPreTick) 1 else 0);
    // }

    // pub fn setNeedsTick(self: *Self, needsTick: bool) void {
    //     basis.bindings.api.ComponentContext_setNeedsTick(self.cppPtr, if (needsTick) 1 else 0);
    // }

    pub fn getGameObject(self: *const Self) GameObjectPtr {
        const objectCppPtr = basis.bindings.api.ComponentContext_getGameObject(self.cppPtr);
        return GameObjectPtr{ .cppPtr = objectCppPtr };
    }

    pub fn subscribeToMessageCategory(self: *const Self, cat: anytype) void {
        const value = basis.messaging.castToMessageCategory(cat);
        basis.bindings.api.ComponentContext_subscribeToMessageCategory(self.cppPtr, value);
    }

    pub fn allocMsgParams(self: *const Self) MessageParametersPtr {
        return MessageParametersPtr.init(basis.bindings.api.ComponentContext_allocMsgParams(self.cppPtr));
    }

    pub fn sendMessage(self: *const Self, message: anytype) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.ComponentContext_sendMessage(self.cppPtr, value, 0);
    }

    pub fn sendMessageWithParams(self: *const Self, message: anytype, parameters: MessageParametersPtr) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.ComponentContext_sendMessage(self.cppPtr, value, parameters.cppPtr);
    }

    pub fn getPhysicsEngine(self: *const Self) basis.physics.PhysicsEnginePtr {
        const cppPtr = basis.bindings.api.ComponentContext_getPhysicsEnginePtr(self.cppPtr);
        return basis.physics.PhysicsEnginePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn getPrimaryPhysicsScene(self: *const Self) basis.physics.PhysicsScenePtr {
        const sceneCppPtr = basis.bindings.api.ComponentContext_getPrimaryPhysicsScene(self.cppPtr);
        return basis.physics.PhysicsScenePtr{ .cppPtr = sceneCppPtr };
    }

    pub fn getRenderer(self: *const Self) basis.renderer.RendererPtr {
        basis.assertd(@src(), self.onClient(), "Trying to access the renderer on the server.");
        const rendererCppPtr = basis.bindings.api.ComponentContext_getRenderer(self.cppPtr);
        return basis.renderer.RendererPtr{ .cppPtr = rendererCppPtr };
    }

    pub fn getGameSession(self: *const Self) basis.game_session.GameSessionPtr {
        const gameSessionCppPtr = basis.bindings.api.ComponentContext_getGameSession(self.cppPtr);
        return basis.game_session.GameSessionPtr{ .cppPtr = gameSessionCppPtr };
    }

    pub fn getGameState(self: *const Self) basis.game_state.GameStatePtr {
        const gameStateCppPtr = basis.bindings.api.ComponentContext_getGameState(self.cppPtr);
        return basis.game_state.GameStatePtr{ .allocator = self.allocator, .cppPtr = gameStateCppPtr };
    }

    pub fn registerPipe(self: *const Self, pipename: []const u8, direction: basis.network.PipeDirection, reliable: bool) basis.network.PipeID {
        const interopName = basis.string.toInteropString(pipename);
        return basis.bindings.api.ComponentContext_registerPipe(self.cppPtr, &interopName, direction.asInt(), reliable);
    }

    pub fn writeToPipe(self: *const Self, pipe: basis.network.PipeID, data: []const u8) void {
        const ptr: [*c]const u8 = &data[0];
        const len: u32 = @intCast(data.len);
        basis.bindings.api.ComponentContext_writeToPipe(self.cppPtr, pipe, ptr, len);
    }

    pub fn callScriptOnTick(self: *const Self, tickDeltaTime: f32) void {
        basis.bindings.api.ComponentContext_callScriptOnTick(self.cppPtr, tickDeltaTime);
    }

    pub fn getScriptFunctionByDecl(self: *const Self, decl: []const u8) basis.angelscript.AngelScriptFunctionPtr {
        const interopDecl = basis.string.toInteropString(decl);
        const cppPtr = basis.bindings.api.ComponentContext_getScriptFunctionByDecl(self.cppPtr, &interopDecl);
        return basis.angelscript.AngelScriptFunctionPtr{ .cppPtr = cppPtr };
    }

    pub fn getScriptFunctionByASFuncPtr(self: *const Self, funcPtr: basis.angelscript.CallbackHandle) basis.angelscript.AngelScriptFunctionPtr {
        const cppPtr = basis.bindings.api.ComponentContext_getScriptFunctionByASFuncPtr(self.cppPtr, funcPtr);
        return basis.angelscript.AngelScriptFunctionPtr{ .cppPtr = cppPtr };
    }

    pub fn setScriptGlobalHandle(self: *const Self, handleName: []const u8, value: basis.CppPtr) void {
        const interopName = basis.string.toInteropString(handleName);
        basis.bindings.api.ComponentContext_setScriptGlobalHandle(self.cppPtr, &interopName, value);
    }
};

pub const AvatarTrackingComponent = struct {
    const Self = @This();

    allocator: std.mem.Allocator,
    io: std.Io,
    cppPtr: basis.bindings.InteropTypedPtr,
    transform: TransformApi,
    editor: EditorApi,
    _isOnClient: bool,

    pub fn init(allocator: std.mem.Allocator, io: std.Io, cppPtr: basis.bindings.InteropTypedPtr, _onClient: bool) Self {
        return Self{
            .allocator = allocator,
            .io = io,
            .cppPtr = cppPtr,
            .transform = TransformApi.init(cppPtr),
            .editor = EditorApi.init(cppPtr),
            ._isOnClient = _onClient,
        };
    }

    pub fn getName(self: *const Self) []const u8 {
        var str: basis.bindings.InteropString = undefined;
        basis.bindings.api.ComponentContext_getName(self.cppPtr, &str);
        return str.ptr[0..str.len];
    }

    pub fn onClient(self: *const Self) bool {
        return self._isOnClient;
    }

    pub fn onServer(self: *const Self) bool {
        return !self._isOnClient;
    }

    pub fn inEditor(self: *const Self) bool {
        return basis.bindings.api.ComponentContext_inEditor(self.cppPtr);
    }

    pub fn getClient(self: *const Self) basis.host.ClientPtr {
        const clientCppPtr = basis.bindings.api.ComponentContext_getClient(self.cppPtr);
        return basis.host.ClientPtr{
            .cppPtr = clientCppPtr,
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getServer(self: *const Self) basis.host.ServerPtr {
        const serverCppPtr = basis.bindings.api.ComponentContext_getServer(self.cppPtr);
        return basis.host.ServerPtr{
            .cppPtr = serverCppPtr,
            .allocator = self.allocator,
            .io = self.io,
        };
    }

    pub fn getHost(self: *const Self) basis.host.HostPtr {
        return if (self.onClient())
            basis.host.HostPtr.init(self.getClient())
        else
            basis.host.HostPtr.init(self.getServer());
    }

    pub fn getGameObject(self: *const Self) GameObjectPtr {
        const objectCppPtr = basis.bindings.api.ComponentContext_getGameObject(self.cppPtr);
        return GameObjectPtr{ .cppPtr = objectCppPtr };
    }

    pub fn subscribeToMessageCategory(self: *const Self, cat: anytype) void {
        const value = basis.messaging.castToMessageCategory(cat);
        basis.bindings.api.ComponentContext_subscribeToMessageCategory(self.cppPtr, value);
    }

    pub fn allocMsgParams(self: *const Self) MessageParametersPtr {
        return MessageParametersPtr.init(basis.bindings.api.ComponentContext_allocMsgParams(self.cppPtr));
    }

    pub fn sendMessage(self: *const Self, message: anytype) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.ComponentContext_sendMessage(self.cppPtr, value, 0);
    }

    pub fn sendMessageWithParams(self: *const Self, message: anytype, parameters: MessageParametersPtr) void {
        const value = basis.messaging.castToMessage(message);
        basis.bindings.api.ComponentContext_sendMessage(self.cppPtr, value, parameters.cppPtr);
    }

    pub fn getPhysicsEngine(self: *const Self) basis.physics.PhysicsEnginePtr {
        const cppPtr = basis.bindings.api.ComponentContext_getPhysicsEnginePtr(self.cppPtr);
        return basis.physics.PhysicsEnginePtr{
            .cppPtr = cppPtr,
        };
    }

    pub fn getPrimaryPhysicsScene(self: *const Self) basis.physics.PhysicsScenePtr {
        const sceneCppPtr = basis.bindings.api.ComponentContext_getPrimaryPhysicsScene(self.cppPtr);
        return basis.physics.PhysicsScenePtr{ .cppPtr = sceneCppPtr };
    }

    pub fn getRenderer(self: *const Self) basis.renderer.RendererPtr {
        basis.assertd(@src(), self.onClient(), "Trying to access the renderer on the server.");
        const rendererCppPtr = basis.bindings.api.ComponentContext_getRenderer(self.cppPtr);
        return basis.renderer.RendererPtr{ .cppPtr = rendererCppPtr };
    }

    pub fn getGameSession(self: *const Self) basis.game_session.GameSessionPtr {
        const gameSessionCppPtr = basis.bindings.api.ComponentContext_getGameSession(self.cppPtr);
        return basis.game_session.GameSessionPtr{ .cppPtr = gameSessionCppPtr };
    }

    pub fn getGameState(self: *const Self) basis.game_state.GameStatePtr {
        const gameStateCppPtr = basis.bindings.api.ComponentContext_getGameState(self.cppPtr);
        return basis.game_state.GameStatePtr{ .allocator = self.allocator, .cppPtr = gameStateCppPtr };
    }

    pub fn registerPipe(self: *const Self, pipename: []const u8, direction: basis.network.PipeDirection, reliable: bool) basis.network.PipeID {
        const interopName = basis.string.toInteropString(pipename);
        return basis.bindings.api.ComponentContext_registerPipe(self.cppPtr, &interopName, direction.asInt(), reliable);
    }

    pub fn writeToPipe(self: *const Self, pipe: basis.network.PipeID, data: []const u8) void {
        const ptr: [*c]const u8 = &data[0];
        const len: u32 = @intCast(data.len);
        basis.bindings.api.ComponentContext_writeToPipe(self.cppPtr, pipe, ptr, len);
    }

    pub fn callScriptOnTick(self: *const Self, tickDeltaTime: f32) void {
        basis.bindings.api.ComponentContext_callScriptOnTick(self.cppPtr, tickDeltaTime);
    }

    pub fn getScriptFunctionByDecl(self: *const Self, decl: []const u8) basis.angelscript.AngelScriptFunctionPtr {
        const interopDecl = basis.string.toInteropString(decl);
        const cppPtr = basis.bindings.api.ComponentContext_getScriptFunctionByDecl(self.cppPtr, &interopDecl);
        return basis.angelscript.AngelScriptFunctionPtr{ .cppPtr = cppPtr };
    }

    pub fn getScriptFunctionByASFuncPtr(self: *const Self, funcPtr: basis.angelscript.CallbackHandle) basis.angelscript.AngelScriptFunctionPtr {
        const cppPtr = basis.bindings.api.ComponentContext_getScriptFunctionByASFuncPtr(self.cppPtr, funcPtr);
        return basis.angelscript.AngelScriptFunctionPtr{ .cppPtr = cppPtr };
    }

    pub fn setScriptGlobalHandle(self: *const Self, handleName: []const u8, value: basis.CppPtr) void {
        const interopName = basis.string.toInteropString(handleName);
        basis.bindings.api.ComponentContext_setScriptGlobalHandle(self.cppPtr, &interopName, value);
    }

    pub fn isClientLocalAvatar(self: *const Self) bool {
        return basis.bindings.api.ComponentContext_isClientLocalAvatar(self.cppPtr);
    }

    pub fn getAvatarHostID(self: *const Self) i32 {
        return basis.bindings.api.ComponentContext_getAvatarHostID(self.cppPtr);
    }

    pub fn canReadInput(self: *const Self) bool {
        if (self.isClientLocalAvatar()) return true;
        if (self.onServer() and self.getAvatarHostID() != -1) return true;
        return false;
    }

    pub fn getInputRange(self: *const Self, inputID: anytype) f32 {
        const value = intOrEnumToU16(inputID);
        return basis.bindings.api.ComponentContext_getInputRange(self.cppPtr, value);
    }

    pub fn getInputState(self: *const Self, inputID: anytype) bool {
        const value = intOrEnumToU16(inputID);
        return basis.bindings.api.ComponentContext_getInputState(self.cppPtr, value);
    }

    pub fn getInputAction(self: *const Self, inputID: anytype) bool {
        const value = intOrEnumToU16(inputID);
        return basis.bindings.api.ComponentContext_getInputAction(self.cppPtr, value);
    }
};

pub const TransformApi = struct {
    const Self = @This();

    contextCppPtr: basis.bindings.InteropTypedPtr,

    pub fn init(contextCppPtr: basis.bindings.InteropTypedPtr) Self {
        return Self{
            .contextCppPtr = contextCppPtr,
        };
    }

    pub fn getPosition(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.ComponentContext_getPosition(self.contextCppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn setPosition(self: *const Self, position: Vec3) void {
        const pos = Vec3.toInterop(position);
        basis.bindings.api.ComponentContext_setPosition(self.contextCppPtr, &pos);
    }

    pub fn getOrientation(self: *const Self) Quaternion {
        var interop: basis.bindings.InteropQuaternion = undefined;
        basis.bindings.api.ComponentContext_getOrientation(self.contextCppPtr, &interop);
        return Quaternion.fromInterop(interop);
    }

    pub fn setOrientation(self: *const Self, orientation: Quaternion) void {
        const pos = Quaternion.toInterop(orientation);
        basis.bindings.api.ComponentContext_setOrientation(self.contextCppPtr, &pos);
    }

    pub fn getLinearVelocity(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.ComponentContext_getLinearVelocity(self.contextCppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn getAngularVelocity(self: *const Self) Vec3 {
        var interop: basis.bindings.InteropVec3 = undefined;
        basis.bindings.api.ComponentContext_getAngularVelocity(self.contextCppPtr, &interop);
        return Vec3.fromInterop(interop);
    }

    pub fn setTransform(self: *const Self, position: Vec3, orientation: Quaternion, teleport: bool) void {
        const pos = Vec3.toInterop(position);
        const ori = Quaternion.toInterop(orientation);
        basis.bindings.api.ComponentContext_setTransform(self.contextCppPtr, &pos, &ori, teleport);
    }

    pub fn setTransformWithVelocities(self: *const Self, position: Vec3, orientation: Quaternion, linearVelocity: Vec3, angularVelocity: Vec3, teleport: bool) void {
        const pos = Vec3.toInterop(position);
        const ori = Quaternion.toInterop(orientation);
        const linVel = Vec3.toInterop(linearVelocity);
        const angVel = Vec3.toInterop(angularVelocity);
        basis.bindings.api.ComponentContext_setTransformWithVelocities(self.contextCppPtr, &pos, &ori, &linVel, &angVel, teleport);
    }

    pub fn getWorldMatrix(self: *const Self) Mat43 {
        var interop: basis.bindings.InteropMat43 = undefined;
        basis.bindings.api.ComponentContext_getWorldMatrix(self.contextCppPtr, &interop);
        return Mat43.fromInterop(interop);
    }

    pub fn getRenderSceneNode(self: *const Self) basis.math.SceneNodePtr {
        return basis.math.SceneNodePtr.initFromCppPtr(basis.bindings.api.ComponentContext_getRenderSceneNode(self.contextCppPtr));
    }

    pub fn getCharacterController(self: *const Self) basis.physics.CharacterControllerPtr {
        return basis.physics.CharacterControllerPtr{
            .cppPtr = basis.bindings.api.ComponentContext_getCharacterController(self.contextCppPtr),
        };
    }

    pub fn getPhysicsActor(self: *const Self) basis.physics.PhysicsActorPtr {
        var actorCppPtr: basis.CppPtr = 0;
        var actorTypeInt: u32 = 0;

        const res = basis.bindings.api.ComponentContext_getPhysicsActor(self.contextCppPtr, &actorCppPtr, &actorTypeInt);
        basis.assert(@src(), res == 1);

        return basis.physics.PhysicsActorPtr{ .cppPtr = actorCppPtr, .actorType = @as(basis.physics.PhysicsActorType, @enumFromInt(actorTypeInt)) };
    }
};

pub const EditorApi = struct {
    const Self = @This();

    contextCppPtr: basis.bindings.InteropTypedPtr,

    pub fn init(contextCppPtr: basis.bindings.InteropTypedPtr) EditorApi {
        return EditorApi{
            .contextCppPtr = contextCppPtr,
        };
    }

    pub fn flushExposedProperties(self: *const Self) void {
        basis.bindings.api.ComponentContext_flushExposedProperties(self.contextCppPtr);
    }

    pub fn getParentGameObject(self: *const Self) GameObjectPtr {
        const cppPtr = basis.bindings.api.ComponentContext_getParentGameObject(self.contextCppPtr);
        return GameObjectPtr{ .cppPtr = cppPtr };
    }
};

// Helper functions:

fn intOrEnumToU16(value: anytype) u16 {
    // switch (@typeInfo(@TypeOf(value))) {
    //     .int => {
    //         return @intCast(u16, value);
    //     },
    //     else => {
    //         return @enumToInt(value);
    //     },
    // }

    return switch (@typeInfo(@TypeOf(value))) {
        .int => @as(u16, @intCast(value)),
        else => @intFromEnum(value),
    };
}
