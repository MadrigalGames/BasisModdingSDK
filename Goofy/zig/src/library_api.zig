// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

export fn raiseGoofyEvent(
    eventType: u32,
    viewCppPtr: basis.CppPtr,
    widgetCppPtr: basis.CppPtr,
    float0: f32,
    float1: f32,
    int0: i32,
    int1: i32,
) void {
    goofy.manager._raiseGoofyEvent(
        eventType,
        viewCppPtr,
        widgetCppPtr,
        float0,
        float1,
        int0,
        int1,
    );
}

//----------------------------------------------------

export fn runCanvasRenderCallback(
    renderCtxt: *const goofy.bindings.InteropUIRenderContext,
    canvasCppPtr: basis.CppPtr,
    pixelPos: *const basis.bindings.InteropVec2,
    pixelSize: *const basis.bindings.InteropVec2,
) void {
    goofy.canvas.runRenderCallback(
        renderCtxt,
        canvasCppPtr,
        pixelPos,
        pixelSize,
    );
}

export fn removeCanvasRenderCallback(canvasCppPtr: basis.CppPtr) void {
    goofy.canvas.removeRenderCallback(canvasCppPtr);
}

//----------------------------------------------------

export fn runUserWidgetRenderCallback(
    renderCtxt: *const goofy.bindings.InteropUIRenderContext,
    userWidgetCppPtr: basis.CppPtr,
    pixelPos: *const basis.bindings.InteropVec2,
    pixelSize: *const basis.bindings.InteropVec2,
) void {
    goofy.user_widget.runRenderCallback(
        renderCtxt,
        userWidgetCppPtr,
        pixelPos,
        pixelSize,
    );
}

export fn removeUserWidgetRenderCallback(userWidgetCppPtr: basis.CppPtr) void {
    goofy.user_widget.removeRenderCallback(userWidgetCppPtr);
}

//----------------------------------------------------

export fn runUserWidgetEventCallback(
    userWidgetCppPtr: basis.CppPtr,
    eventType: u32,
    floatData: *const basis.bindings.InteropVec4,
    uintData: u32,
) void {
    goofy.user_widget.runEventCallback(
        userWidgetCppPtr,
        eventType,
        floatData,
        uintData,
    );
}

export fn removeUserWidgetEventCallback(
    userWidgetCppPtr: basis.CppPtr,
) void {
    goofy.user_widget.removeEventCallback(userWidgetCppPtr);
}

//----------------------------------------------------

export fn runViewRecreationCallback(
    viewCppPtr: basis.CppPtr,
    success: bool,
) void {
    goofy.view.runRecreationCallback(viewCppPtr, success);
}

export fn removeViewRecreationCallback(viewCppPtr: basis.CppPtr) void {
    goofy.view.removeRecreationCallback(viewCppPtr);
}
