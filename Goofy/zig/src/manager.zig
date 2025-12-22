// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

const UIViewPtr = goofy.UIViewPtr;

const TypeID = basis.typeinfo.TypeID;

pub fn setAspectRatio(aspectRatio: f32) void {
    goofy.bindings.api.GoofyManager_setAspectRatio(aspectRatio);
}

pub fn setFitMode(mode: goofy.UIFitMode) void {
    goofy.bindings.api.GoofyManager_setFitMode(@intFromEnum(mode));
}

pub fn createView(name: []const u8) UIViewPtr {
    const interopName = basis.string.toInteropString(name);
    const cppPtr = goofy.bindings.api.GoofyManager_createView(&interopName);
    return UIViewPtr.initFromCppPtr(cppPtr);
}

pub fn createViewWithScript(name: []const u8, script: []const u8) UIViewPtr {
    const interopName = basis.string.toInteropString(name);
    const interopScript = basis.string.toInteropString(script);
    const cppPtr = goofy.bindings.api.GoofyManager_createViewWithScript(&interopName, &interopScript);
    return UIViewPtr.initFromCppPtr(cppPtr);
}

pub fn destroyView(view: UIViewPtr) void {
    goofy.bindings.api.GoofyManager_destroyView(view.cppPtr);
}

pub fn pushViewOntoStack(view: UIViewPtr) void {
    goofy.bindings.api.GoofyManager_pushViewOntoStack(view.cppPtr);
}

pub fn pushModalViewOntoStack(view: UIViewPtr) void {
    goofy.bindings.api.GoofyManager_pushModalViewOntoStack(view.cppPtr);
}

pub fn removeViewFromStack(view: UIViewPtr) void {
    goofy.bindings.api.GoofyManager_removeViewFromStack(view.cppPtr);
}

pub fn clearViewStack() void {
    goofy.bindings.api.GoofyManager_clearViewStack();
}

pub fn createFont(name: []const u8, ttfFile: []const u8) goofy.FontHandle {
    const interopName = basis.string.toInteropString(name);
    const interopTtfFile = basis.string.toInteropString(ttfFile);
    return goofy.bindings.api.GoofyManager_createFont(&interopName, &interopTtfFile);
}

pub fn registerAction(actionName: []const u8) void {
    const interopName = basis.string.toInteropString(actionName);
    goofy.bindings.api.GoofyManager_registerAction(&interopName);
}

pub fn fireAction(actionName: []const u8) void {
    const interopName = basis.string.toInteropString(actionName);
    goofy.bindings.api.GoofyManager_fireAction(&interopName);
}

pub fn setActionCallback(actionName: []const u8, callback: basis.bindings.FP_void) void {
    const interopName = basis.string.toInteropString(actionName);
    goofy.bindings.api.GoofyManager_setActionCallback(&interopName, callback);
}

pub fn clearActionCallback(actionName: []const u8) void {
    const interopName = basis.string.toInteropString(actionName);
    goofy.bindings.api.GoofyManager_clearActionCallback(&interopName);
}

pub fn registerProperty(comptime T: type, propertyName: []const u8, initialValue: T) void {
    const interopName = basis.string.toInteropString(propertyName);
    const valueTypeID = basis.typeinfo.getTypeID(T);

    var initialValueBuffer: [32]u8 = undefined;
    var stream = basis.BinaryWriteStream.init(&initialValueBuffer, true);

    switch (T) {
        i8, u8, i16, u16, i32, u32, i64, u64 => {
            stream.putInt(T, initialValue);
        },
        f32 => {
            stream.putFloat(initialValue);
        },
        bool => {
            stream.putBool(initialValue);
        },
        basis.math.Vec2, basis.math.Vec3, basis.math.Vec4, basis.Color => {
            stream.put(T, initialValue);
        },
        else => @compileError("Invalid Goofy property value type: " ++ @typeName(T) ++ "."),
    }

    const initialValueBufferLength: u32 = @intCast(stream.cursorPosition);

    goofy.bindings.api.GoofyManager_registerProperty(&interopName, @intFromEnum(valueTypeID), &initialValueBuffer, initialValueBufferLength);
}

pub fn getPropertyType(propertyName: []const u8) TypeID {
    const interopName = basis.string.toInteropString(propertyName);
    const i = goofy.bindings.api.GoofyManager_getPropertyType(&interopName);
    return @as(TypeID, @enumFromInt(i));
}

pub fn setPropertyValue(comptime T: type, propertyName: []const u8, value: T) void {
    const interopName = basis.string.toInteropString(propertyName);
    const valueTypeID = basis.typeinfo.getTypeID(T);

    const valueBufferLength: u32 = 32;
    var valueBuffer: [valueBufferLength]u8 = undefined;
    var stream = basis.BinaryWriteStream.init(&valueBuffer, true);

    switch (T) {
        f32 => {
            stream.putFloat(value);
        },
        i8, u8, i16, u16, i32, u32, i64, u64 => {
            stream.putInt(T, value);
        },
        bool => {
            stream.putBool(value);
        },
        basis.math.Vec2, basis.math.Vec3, basis.math.Vec4, basis.Color => {
            stream.put(T, value);
        },
        else => @compileError("Invalid Goofy property value type: " ++ @typeName(T) ++ "."),
    }

    goofy.bindings.api.GoofyManager_setPropertyValue(&interopName, @intFromEnum(valueTypeID), &valueBuffer[0], valueBufferLength);
}

pub fn getPropertyValue(comptime T: type, propertyName: []const u8) T {
    const interopName = basis.string.toInteropString(propertyName);
    const valueTypeID = basis.typeinfo.getTypeID(T);

    const valueBufferLength: u32 = 32;
    var valueBuffer: [valueBufferLength]u8 = undefined;
    var stream = basis.BinaryReadStream.init(&valueBuffer, true);

    goofy.bindings.api.GoofyManager_getPropertyValue(&interopName, @intFromEnum(valueTypeID), &valueBuffer[0], valueBufferLength);

    switch (T) {
        f32 => {
            return stream.getFloat();
        },
        i8, u8, i16, u16, i32, u32, i64, u64 => {
            return stream.getInt(T);
        },
        bool => {
            return stream.getBool();
        },
        basis.math.Vec2, basis.math.Vec3, basis.math.Vec4, basis.Color => {
            return stream.get(T);
        },
        else => @compileError("Invalid Goofy property value type: " ++ @typeName(T) ++ "."),
    }
}

pub fn registerStringProperty(propertyName: []const u8, initialValue: []const u8) void {
    const interopName = basis.string.toInteropString(propertyName);
    const interopInitialValue = basis.string.toInteropString(initialValue);

    goofy.bindings.api.GoofyManager_registerStringProperty(&interopName, &interopInitialValue);
}

pub fn setStringProperty(propertyName: []const u8, value: []const u8) void {
    const interopName = basis.string.toInteropString(propertyName);
    const interopValue = basis.string.toInteropString(value);

    goofy.bindings.api.GoofyManager_setStringPropertyValue(&interopName, &interopValue);
}

pub fn setEventHandlingEnabled(enabled: bool) void {
    goofy.bindings.api.GoofyManager_setZigEventHandlingEnabled(if (enabled) 1 else 0);
}

pub fn setPeripheryColor(color: basis.Color, inFront: bool) void {
    const c = color.toInterop();
    goofy.bindings.api.GoofyManager_setPeripheryColor(&c, if (inFront) 1 else 0);
}

pub fn clearPeripheryColor() void {
    goofy.bindings.api.GoofyManager_clearPeripheryColor();
}

pub fn getNVGcontext() basis.CppPtr {
    return goofy.bindings.api.GoofyManager_getNVGcontext();
}

pub fn getUIPosFromPixelPos(pixelPos: basis.math.Vec2) basis.math.Vec2 {
    const interopPixelPos = pixelPos.toInterop();
    var interopUiPos: basis.bindings.InteropVec2 = undefined;
    goofy.bindings.api.GoofyManager_getUIPosFromPixelPos(&interopPixelPos, &interopUiPos);
    return basis.math.Vec2.fromInterop(interopUiPos);
}

//----------------------------------------------------
// Event handling:

pub const EventCallback = basis.delegate.VoidDelegate4(goofy.UIEvent, goofy.UIViewPtr, basis.CppPtr, goofy.UIEventArgs);

var gEventCallback: EventCallback = .{};

pub fn setEventCallback(cb: EventCallback) void {
    setEventHandlingEnabled(true);
    basis.assertd(
        @src(),
        gEventCallback.funcPtr == null and gEventCallback.methodPtr == null,
        "The Goofy event callback is already set. Trying to set a second time.",
    );
    gEventCallback = cb;
}

pub fn _raiseGoofyEvent(
    eventType: u32,
    viewCppPtr: basis.CppPtr,
    widgetCppPtr: basis.CppPtr,
    float0: f32,
    float1: f32,
    int0: i32,
    int1: i32,
) void {
    const eventTypeAsEnum: goofy.UIEvent = @enumFromInt(eventType);
    const view = goofy.UIViewPtr.initFromCppPtr(viewCppPtr);
    const args = goofy.UIEventArgs{
        .float0 = float0,
        .float1 = float1,
        .int0 = int0,
        .int1 = int1,
    };
    gEventCallback.call(eventTypeAsEnum, view, widgetCppPtr, args);
}
