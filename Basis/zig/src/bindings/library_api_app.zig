// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const InteropTypedPtr = basis.bindings.InteropTypedPtr;
const AppInterface = basis.app_interface.AppInterface;

// App interface. Used when building the library as an app, ie. not as a mod.

//----------------------------------------------------

export fn App_onAppStartup(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.onAppStartup();
}

export fn App_beforeAppShutdown(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.beforeAppShutdown();
}

export fn App_onServerCreated(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.onServerCreated();
}

export fn App_beforeServerDestroyed(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.beforeServerDestroyed();
}

export fn App_initClientGameFlow(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.initClientGameFlow();
}

export fn App_initServerGameFlow(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.initServerGameFlow();
}

export fn App_setAppInputMappings(appInterfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.setInputMappings();
}

export fn App_clientUpdate(appInterfaceIntPtr: basis.IntPtr64, deltaTime: f32) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.onClientUpdate(deltaTime);
}

export fn App_serverUpdate(appInterfaceIntPtr: basis.IntPtr64, deltaTime: f32) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.onServerUpdate(deltaTime);
}

export fn App_clientTick(appInterfaceIntPtr: basis.IntPtr64, tickDeltaTime: f32) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.onClientTick(tickDeltaTime);
}

export fn App_serverTick(appInterfaceIntPtr: basis.IntPtr64, tickDeltaTime: f32) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.onServerTick(tickDeltaTime);
}

export fn App_registerAngelScriptTypes(appInterfaceIntPtr: basis.IntPtr64, regPtr: basis.CppPtr) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    const reg = basis.angelscript.TypeRegistration.init(regPtr);
    appInterfacePtr.registerAngelScriptTypes(reg);
}

export fn App_createClientPlayerController(appInterfaceIntPtr: basis.IntPtr64, contextCppPtr: InteropTypedPtr, hostID: i32) basis.IntPtr64 {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    const cpc = appInterfacePtr.createClientPlayerController(contextCppPtr, hostID);
    return basis.bindings.hostIntPtrFromLib(cpc);
}

export fn App_destroyClientPlayerController(appInterfaceIntPtr: basis.IntPtr64, interfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.destroyClientPlayerController(basis.bindings.libIntPtrFromHost(interfaceIntPtr));
}

export fn App_createServerPlayerController(appInterfaceIntPtr: basis.IntPtr64, contextCppPtr: InteropTypedPtr, hostID: i32) basis.IntPtr64 {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    const spc = appInterfacePtr.createServerPlayerController(contextCppPtr, hostID);
    return basis.bindings.hostIntPtrFromLib(spc);
}

export fn App_destroyServerPlayerController(appInterfaceIntPtr: basis.IntPtr64, interfaceIntPtr: basis.IntPtr64) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    appInterfacePtr.destroyServerPlayerController(basis.bindings.libIntPtrFromHost(interfaceIntPtr));
}

export fn App_setDefaultConfigOptions(appInterfaceIntPtr: basis.IntPtr64, configOptionsPtr: basis.CppPtr) void {
    var appInterfacePtr = castIntPtr(AppInterface, appInterfaceIntPtr);
    const configOptions = basis.config_options.ConfigOptionsPtr{ .cppPtr = configOptionsPtr };
    appInterfacePtr.setDefaultConfigOptions(configOptions);
}

//----------------------------------------------------

fn castIntPtr(comptime T: type, intPtr: basis.IntPtr64) *T {
    const ptr: *T = @ptrFromInt(basis.bindings.libIntPtrFromHost(intPtr));
    return ptr;
}
