// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const script_code = @import("angelscript/script_code.zig");
pub const type_registration = @import("angelscript/type_registration.zig");
pub const component_registration = @import("angelscript/component_registration.zig");
// Not used at the moment:
//pub const std_methods = @import("angelscript/std_methods.zig");
pub const script_function = @import("angelscript/script_function.zig");

pub const ScriptCode = script_code.ScriptCode;
pub const TypeRegistration = type_registration.TypeRegistration;
pub const ComponentRegistration = component_registration.ComponentRegistration;
pub const AngelScriptFunctionPtr = script_function.AngelScriptFunctionPtr;

//----------------------------------------------------

pub const StringRefConstIn = usize; // Parameter of type: "const string &in"
pub const StringRefOut = usize; // Parameter of type: "string &out"

pub const CallbackHandle = usize; // Parameter of type "Callback@" or similar.

pub const GameObjectRefConstIn = usize; // Parameter of type: "const gameobject &in"
pub const GameObjectRefOut = usize; // Parameter of type: "gameobject &out"

pub const ColorRefConstIn = usize; // Parameter of type: "const Color &in"
pub const ColorRefOut = usize; // Parameter of type: "Color &out"

//----------------------------------------------------

/// Used to cast a pointerPairAddress into a Zig component of the
/// given type, eg. for use as the self pointer in a bound function.
pub fn getComponentSelf(comptime T: type, pointerPairAddress: usize) *T {
    const pointerPair: *const basis.bindings.CppZigPointerPair = @ptrFromInt(pointerPairAddress);
    return @ptrFromInt(pointerPair.zig);
}

//----------------------------------------------------

/// Get the string value of a "const string &in" parameter in a bound function.
pub fn getStringRefConstIn(p: StringRefConstIn) []const u8 {
    var valueInteropString: basis.bindings.InteropString = undefined;
    basis.bindings.api.AngelScriptUtils_getStringRefConstIn(p, &valueInteropString);
    return valueInteropString.ptr[0..valueInteropString.len];
}

/// Set the string value of a "string &out" parameter in a bound function.
pub fn setStringRefOut(p: StringRefOut, val: []const u8) void {
    const valueInteropString = basis.string.toInteropString(val);
    basis.bindings.api.AngelScriptUtils_setStringRefOut(p, &valueInteropString);
}

/// Get the string value (object name) of a "const gameobject &in" parameter in a bound function.
pub fn getGameObjectRefConstIn(p: StringRefConstIn) []const u8 {
    var valueInteropString: basis.bindings.InteropString = undefined;
    basis.bindings.api.AngelScriptUtils_getGameObjectRefConstIn(p, &valueInteropString);
    return valueInteropString.ptr[0..valueInteropString.len];
}

/// Get the string hash value (object name hash) of a "const gameobject &in" parameter in a bound function.
pub fn getHashFromGameObjectRefConstIn(p: StringRefConstIn) basis.StringHash {
    return basis.bindings.api.AngelScriptUtils_getHashFromGameObjectRefConstIn(p);
}

/// Set the string value (object name) of a "gameobject &out" parameter in a bound function.
pub fn setGameObjectRefOut(p: StringRefOut, val: []const u8) void {
    const valueInteropString = basis.string.toInteropString(val);
    basis.bindings.api.AngelScriptUtils_setGameObjectRefOut(p, &valueInteropString);
}

/// Get the value of a "const Color &in" parameter in a bound function.
pub fn getColorRefConstIn(p: ColorRefConstIn) basis.Color {
    var valueInteropColor: basis.bindings.InteropColor = undefined;
    basis.bindings.api.AngelScriptUtils_getColorRefConstIn(p, &valueInteropColor);
    return basis.Color.fromInterop(valueInteropColor);
}

/// Set the value of a "Color &out" parameter in a bound function.
pub fn setColorRefOut(p: ColorRefOut, val: basis.Color) void {
    const valueInteropColor = val.toInterop();
    basis.bindings.api.AngelScriptUtils_setColorRefOut(p, &valueInteropColor);
}

//----------------------------------------------------

/// Calls AddRef() on a asIScriptFunction* represented by a CallbackHandle.
pub fn addRefToASFuncPtr(funcPtr: basis.angelscript.CallbackHandle) void {
    basis.bindings.api.AngelScriptUtils_addRefToASFuncPtr(funcPtr);
}

/// Calls Release() on a asIScriptFunction* represented by a CallbackHandle.
pub fn releaseASFuncPtr(funcPtr: basis.angelscript.CallbackHandle) void {
    basis.bindings.api.AngelScriptUtils_releaseASFuncPtr(funcPtr);
}
