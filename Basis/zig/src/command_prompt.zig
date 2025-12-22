// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub fn parseCommand(command: []const u8) void {
    const interopCommand = basis.string.toInteropString(command);
    basis.bindings.api.CommandPrompt_parseCommand(&interopCommand);
}

pub fn fmtAndParseCommand(comptime fmt: []const u8, args: anytype) !void {
    var stringBuffer: [1024]u8 = undefined;

    const command = try std.fmt.bufPrint(&stringBuffer, fmt, args);

    const interopCommand = basis.string.toInteropString(command);
    basis.bindings.api.CommandPrompt_parseCommand(&interopCommand);
}

pub fn registerIntValue(
    namespace: []const u8,
    name: []const u8,
    setCallback: basis.bindings.FP_void_i32,
    getCallback: basis.bindings.FP_i32,
    onServer: bool,
    helpText: []const u8,
) void {
    const interopNamespace = basis.string.toInteropString(namespace);
    const interopName = basis.string.toInteropString(name);
    const interopHelpText = basis.string.toInteropString(helpText);
    basis.bindings.api.CommandPrompt_registerIntValue(&interopNamespace, &interopName, setCallback, getCallback, if (onServer) 1 else 0, &interopHelpText);
}

pub fn registerFloatValue(
    namespace: []const u8,
    name: []const u8,
    setCallback: basis.bindings.FP_void_f32,
    getCallback: basis.bindings.FP_f32,
    onServer: bool,
    helpText: []const u8,
) void {
    const interopNamespace = basis.string.toInteropString(namespace);
    const interopName = basis.string.toInteropString(name);
    const interopHelpText = basis.string.toInteropString(helpText);
    basis.bindings.api.CommandPrompt_registerFloatValue(&interopNamespace, &interopName, setCallback, getCallback, if (onServer) 1 else 0, &interopHelpText);
}

pub fn registerBoolValue(
    namespace: []const u8,
    name: []const u8,
    setCallback: basis.bindings.FP_void_bool,
    getCallback: basis.bindings.FP_bool,
    onServer: bool,
    helpText: []const u8,
) void {
    const interopNamespace = basis.string.toInteropString(namespace);
    const interopName = basis.string.toInteropString(name);
    const interopHelpText = basis.string.toInteropString(helpText);
    basis.bindings.api.CommandPrompt_registerBoolValue(&interopNamespace, &interopName, setCallback, getCallback, if (onServer) 1 else 0, &interopHelpText);
}

pub fn registerFunction(
    namespace: []const u8,
    name: []const u8,
    callback: basis.bindings.FP_void,
    paramTypes: []const basis.typeinfo.TypeID,
    onServer: bool,
    helpText: []const u8,
) void {
    const interopNamespace = basis.string.toInteropString(namespace);
    const interopName = basis.string.toInteropString(name);
    const interopHelpText = basis.string.toInteropString(helpText);

    var intParams: [4]i32 = undefined;
    for (paramTypes, 0..) |paramType, i| {
        intParams[i] = paramType.asInt();
    }
    const paramCount: u32 = @intCast(paramTypes.len);

    basis.bindings.api.CommandPrompt_registerFunction(&interopNamespace, &interopName, callback, &intParams[0], paramCount, if (onServer) 1 else 0, &interopHelpText);
}

pub fn unregister(namespace: []const u8, name: []const u8) void {
    const interopNamespace = basis.string.toInteropString(namespace);
    const interopName = basis.string.toInteropString(name);

    basis.bindings.api.CommandPrompt_unregister(&interopNamespace, &interopName);
}

pub fn outputLine(comptime fmt: []const u8, args: anytype) void {
    var stringBuffer: [256]u8 = undefined;

    const data = std.fmt.bufPrint(&stringBuffer, fmt, args) catch return;
    const interopData = basis.string.toInteropString(data);

    basis.bindings.api.CommandPrompt_outputLine(&interopData);
}

pub fn outputErrorLine(comptime fmt: []const u8, args: anytype) void {
    var stringBuffer: [256]u8 = undefined;

    const data = std.fmt.bufPrint(&stringBuffer, fmt, args) catch return;
    const interopData = basis.string.toInteropString(data);

    basis.bindings.api.CommandPrompt_outputErrorLine(&interopData);
}

pub fn getIntParameter() i32 {
    return basis.bindings.api.CommandPrompt_getIntParameter();
}

pub fn getFloatParameter() f32 {
    return basis.bindings.api.CommandPrompt_getFloatParameter();
}

pub fn getBoolParameter() bool {
    return basis.bindings.api.CommandPrompt_getBoolParameter() == 1;
}

pub fn getStringParameter() []const u8 {
    var str: basis.bindings.InteropString = undefined;
    basis.bindings.api.CommandPrompt_getStringParameter(&str);
    return str.ptr[0..str.len];
}
