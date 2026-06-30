// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const InteropTypedPtr = basis.bindings.InteropTypedPtr;
const ModControllerInterface = basis.mod_controller_interface.ModControllerInterface;

// Mod controller interface. Used when building the library as a mod.

//----------------------------------------------------

export fn Mod_onAppStartup(modControllerInterfaceIntPtr: basis.IntPtr64) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.onAppStartup();
}

export fn Mod_beforeAppShutdown(modControllerInterfaceIntPtr: basis.IntPtr64) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.beforeAppShutdown();
}

export fn Mod_onServerCreated(modControllerInterfaceIntPtr: basis.IntPtr64) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.onServerCreated();
}

export fn Mod_beforeServerDestroyed(modControllerInterfaceIntPtr: basis.IntPtr64) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.beforeServerDestroyed();
}

export fn Mod_clientUpdate(modControllerInterfaceIntPtr: basis.IntPtr64, deltaTime: f32) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.onClientUpdate(deltaTime);
}

export fn Mod_serverUpdate(modControllerInterfaceIntPtr: basis.IntPtr64, deltaTime: f32) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.onServerUpdate(deltaTime);
}

export fn Mod_clientTick(modControllerInterfaceIntPtr: basis.IntPtr64, tickDeltaTime: f32) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.onClientTick(tickDeltaTime);
}

export fn Mod_serverTick(modControllerInterfaceIntPtr: basis.IntPtr64, tickDeltaTime: f32) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    modControllerInterfacePtr.onServerTick(tickDeltaTime);
}

export fn Mod_registerAngelScriptTypes(modControllerInterfaceIntPtr: basis.IntPtr64, regPtr: basis.CppPtr) void {
    var modControllerInterfacePtr = castIntPtr(ModControllerInterface, modControllerInterfaceIntPtr);
    const reg = basis.angelscript.TypeRegistration.init(regPtr);
    modControllerInterfacePtr.registerAngelScriptTypes(reg);
}

//----------------------------------------------------

fn castIntPtr(comptime T: type, intPtr: basis.IntPtr64) *T {
    const ptr: *T = @ptrFromInt(basis.bindings.libIntPtrFromHost(intPtr));
    return ptr;
}
