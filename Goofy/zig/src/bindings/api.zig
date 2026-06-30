// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const builtin = @import("builtin");
const basis = @import("basis");
const goofy = @import("../goofy.zig");

const isWasm = basis.build_options.buildAsWASM;

const access = if (isWasm)
    @import("wasm_extern_functions.zig")
else
    .{}; // TODO: Replace this with some module that contains the DLL interface.

// class GoofyManager

pub fn GoofyManager_setAspectRatio(aspectRatio: f32) void {
    if (isWasm) {
        access.GoofyManager_setAspectRatio_WASM(aspectRatio);
    } else {
        goofy.bindings.fp._GoofyManager_setAspectRatio(aspectRatio);
    }
}

pub fn GoofyManager_setFitMode(fitMode: u32) void {
    if (isWasm) {
        access.GoofyManager_setFitMode_WASM(fitMode);
    } else {
        goofy.bindings.fp._GoofyManager_setFitMode(fitMode);
    }
}

pub fn GoofyManager_createView(name: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.GoofyManager_createView_WASM(name.*.ptr, name.*.len);
    } else {
        return goofy.bindings.fp._GoofyManager_createView(name);
    }
}

pub fn GoofyManager_createViewWithScript(name: [*c]const basis.bindings.InteropString, script: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.GoofyManager_createViewWithScript_WASM(name.*.ptr, name.*.len, script.*.ptr, script.*.len);
    } else {
        return goofy.bindings.fp._GoofyManager_createViewWithScript(name, script);
    }
}

pub fn GoofyManager_destroyView(viewCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyManager_destroyView_WASM(viewCppPtr);
    } else {
        goofy.bindings.fp._GoofyManager_destroyView(viewCppPtr);
    }
}

pub fn GoofyManager_pushViewOntoStack(viewCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyManager_pushViewOntoStack_WASM(viewCppPtr);
    } else {
        goofy.bindings.fp._GoofyManager_pushViewOntoStack(viewCppPtr);
    }
}

pub fn GoofyManager_pushModalViewOntoStack(viewCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyManager_pushModalViewOntoStack_WASM(viewCppPtr);
    } else {
        goofy.bindings.fp._GoofyManager_pushModalViewOntoStack(viewCppPtr);
    }
}

pub fn GoofyManager_removeViewFromStack(viewCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyManager_removeViewFromStack_WASM(viewCppPtr);
    } else {
        goofy.bindings.fp._GoofyManager_removeViewFromStack(viewCppPtr);
    }
}

pub fn GoofyManager_clearViewStack() void {
    if (isWasm) {
        access.GoofyManager_clearViewStack_WASM();
    } else {
        goofy.bindings.fp._GoofyManager_clearViewStack();
    }
}

pub fn GoofyManager_createFont(name: [*c]const basis.bindings.InteropString, ttfFile: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        return access.GoofyManager_createFont_WASM(name.*.ptr, name.*.len, ttfFile.*.ptr, ttfFile.*.len);
    } else {
        return goofy.bindings.fp._GoofyManager_createFont(name, ttfFile);
    }
}

pub fn GoofyManager_registerAction(actionName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GoofyManager_registerAction_WASM(actionName.*.ptr, actionName.*.len);
    } else {
        goofy.bindings.fp._GoofyManager_registerAction(actionName);
    }
}

pub fn GoofyManager_fireAction(actionName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GoofyManager_fireAction_WASM(actionName.*.ptr, actionName.*.len);
    } else {
        goofy.bindings.fp._GoofyManager_fireAction(actionName);
    }
}

pub fn GoofyManager_setActionCallback(actionName: [*c]const basis.bindings.InteropString, callback: basis.bindings.FP_void) void {
    if (isWasm) {
        const callbackIntPtr: basis.IntPtr = @intFromPtr(callback);
        access.GoofyManager_setActionCallback_WASM(actionName.*.ptr, actionName.*.len, @intCast(callbackIntPtr));
    } else {
        goofy.bindings.fp._GoofyManager_setActionCallback(actionName, callback);
    }
}

pub fn GoofyManager_clearActionCallback(actionName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GoofyManager_clearActionCallback_WASM(actionName.*.ptr, actionName.*.len);
    } else {
        goofy.bindings.fp._GoofyManager_clearActionCallback(actionName);
    }
}

pub fn GoofyManager_registerProperty(propertyName: [*c]const basis.bindings.InteropString, valueType: c_int, initialValueBuffer: [*]const u8, initialValueBufferLength: u32) void {
    if (isWasm) {
        access.GoofyManager_registerProperty_WASM(propertyName.*.ptr, propertyName.*.len, valueType, initialValueBuffer, initialValueBufferLength);
    } else {
        goofy.bindings.fp._GoofyManager_registerProperty(propertyName, valueType, initialValueBuffer, initialValueBufferLength);
    }
}

pub fn GoofyManager_getPropertyType(propertyName: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        return access.GoofyManager_getPropertyType_WASM(propertyName.*.ptr, propertyName.*.len);
    } else {
        return goofy.bindings.fp._GoofyManager_getPropertyType(propertyName);
    }
}

pub fn GoofyManager_getPropertyValue(propertyName: [*c]const basis.bindings.InteropString, valueType: c_int, valueBuffer: [*c]u8, valueBufferLength: u32) void {
    if (isWasm) {
        access.GoofyManager_getPropertyValue_WASM(propertyName.*.ptr, propertyName.*.len, valueType, valueBuffer, valueBufferLength);
    } else {
        goofy.bindings.fp._GoofyManager_getPropertyValue(propertyName, valueType, valueBuffer, valueBufferLength);
    }
}

pub fn GoofyManager_setPropertyValue(propertyName: [*c]const basis.bindings.InteropString, valueType: c_int, valueBuffer: [*c]const u8, valueBufferLength: u32) void {
    if (isWasm) {
        access.GoofyManager_setPropertyValue_WASM(propertyName.*.ptr, propertyName.*.len, valueType, valueBuffer, valueBufferLength);
    } else {
        goofy.bindings.fp._GoofyManager_setPropertyValue(propertyName, valueType, valueBuffer, valueBufferLength);
    }
}

pub fn GoofyManager_registerStringProperty(propertyName: [*c]const basis.bindings.InteropString, initialValue: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GoofyManager_registerStringProperty_WASM(propertyName.*.ptr, propertyName.*.len, initialValue.*.ptr, initialValue.*.len);
    } else {
        goofy.bindings.fp._GoofyManager_registerStringProperty(propertyName, initialValue);
    }
}

pub fn GoofyManager_getStringPropertyValue(propertyName: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyManager_getStringPropertyValue not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyManager_getStringPropertyValue(propertyName, value);
    }
}

pub fn GoofyManager_setStringPropertyValue(propertyName: [*c]const basis.bindings.InteropString, value: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyManager_setStringPropertyValue not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyManager_setStringPropertyValue(propertyName, value);
    }
}

pub fn GoofyManager_setZigEventHandlingEnabled(enabled: c_int) void {
    if (isWasm) {
        access.GoofyManager_setZigEventHandlingEnabled_WASM(enabled);
    } else {
        goofy.bindings.fp._GoofyManager_setZigEventHandlingEnabled(enabled);
    }
}

pub fn GoofyManager_setPeripheryColor(color: [*c]const basis.bindings.InteropColor, inFront: c_int) void {
    if (isWasm) {
        @compileError("GoofyManager_setPeripheryColor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyManager_setPeripheryColor(color, inFront);
    }
}

pub fn GoofyManager_clearPeripheryColor() void {
    if (isWasm) {
        @compileError("GoofyManager_clearPeripheryColor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyManager_clearPeripheryColor();
    }
}

pub fn GoofyManager_getNVGcontext() basis.CppPtr {
    if (isWasm) {
        @compileError("GoofyManager_getNVGcontext not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._GoofyManager_getNVGcontext();
    }
}

pub fn GoofyManager_getUIPosFromPixelPos(pixelPos: [*c]const basis.bindings.InteropVec2, uiPos: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        @compileError("GoofyManager_getUIPosFromPixelPos not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyManager_getUIPosFromPixelPos(pixelPos, uiPos);
    }
}

// ===============================

// class GoofySkins

pub fn GoofySkins_registerSkin(skinName: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        access.GoofySkins_registerSkin_WASM(skinName.*.ptr, skinName.*.len);
    } else {
        goofy.bindings.fp._GoofySkins_registerSkin(skinName);
    }
}

pub fn GoofySkins_setButtonRenderCallback(skinName: [*c]const basis.bindings.InteropString, callback: goofy.bindings.InteropButtonRenderCallback) void {
    if (isWasm) {
        @compileError("GoofySkins_setButtonRenderCallback not implemented for WASM yet.");
        //GoofySkin button render callbacks currently not supported on WASM. Need to figure out how to pass all the data to WASM...
    } else {
        goofy.bindings.fp._GoofySkins_setButtonRenderCallback(skinName, callback);
    }
}

pub fn GoofySkins_setSpinBoxRenderCallback(skinName: [*c]const basis.bindings.InteropString, callback: goofy.bindings.InteropSpinBoxRenderCallback) void {
    if (isWasm) {
        @compileError("GoofySkins_setSpinBoxRenderCallback not implemented for WASM yet.");
        //GoofySkin button render callbacks currently not supported on WASM. Need to figure out how to pass all the data to WASM...
    } else {
        goofy.bindings.fp._GoofySkins_setSpinBoxRenderCallback(skinName, callback);
    }
}

// ===============================

// class NanoVG

pub fn NanoVG_nvgSave(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgSave not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgSave(ctxt);
    }
}

pub fn NanoVG_nvgRestore(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgRestore not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgRestore(ctxt);
    }
}

pub fn NanoVG_nvgReset(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgReset not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgReset(ctxt);
    }
}

pub fn NanoVG_nvgShapeAntiAlias(ctxt: basis.CppPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgShapeAntiAlias not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgShapeAntiAlias(ctxt, enabled);
    }
}

pub fn NanoVG_nvgStrokeColor(ctxt: basis.CppPtr, color: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("NanoVG_nvgStrokeColor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgStrokeColor(ctxt, color);
    }
}

pub fn NanoVG_nvgStrokePaint(ctxt: basis.CppPtr, paint: [*c]const goofy.bindings.InteropPaint) void {
    if (isWasm) {
        @compileError("NanoVG_nvgStrokePaint not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgStrokePaint(ctxt, paint);
    }
}

pub fn NanoVG_nvgFillColor(ctxt: basis.CppPtr, color: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFillColor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFillColor(ctxt, color);
    }
}

pub fn NanoVG_nvgFillPaint(ctxt: basis.CppPtr, paint: [*c]const goofy.bindings.InteropPaint) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFillPaint not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFillPaint(ctxt, paint);
    }
}

pub fn NanoVG_nvgMiterLimit(ctxt: basis.CppPtr, limit: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgMiterLimit not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgMiterLimit(ctxt, limit);
    }
}

pub fn NanoVG_nvgStrokeWidth(ctxt: basis.CppPtr, size: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgStrokeWidth not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgStrokeWidth(ctxt, size);
    }
}

pub fn NanoVG_nvgLineCap(ctxt: basis.CppPtr, cap: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgLineCap not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgLineCap(ctxt, cap);
    }
}

pub fn NanoVG_nvgLineJoin(ctxt: basis.CppPtr, join: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgLineJoin not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgLineJoin(ctxt, join);
    }
}

pub fn NanoVG_nvgGlobalAlpha(ctxt: basis.CppPtr, alpha: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgGlobalAlpha not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgGlobalAlpha(ctxt, alpha);
    }
}

pub fn NanoVG_nvgResetTransform(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgResetTransform not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgResetTransform(ctxt);
    }
}

pub fn NanoVG_nvgTransform(ctxt: basis.CppPtr, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTransform not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTransform(ctxt, a, b, c, d, e, f);
    }
}

pub fn NanoVG_nvgTranslate(ctxt: basis.CppPtr, x: f32, y: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTranslate not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTranslate(ctxt, x, y);
    }
}

pub fn NanoVG_nvgRotate(ctxt: basis.CppPtr, angle: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgRotate not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgRotate(ctxt, angle);
    }
}

pub fn NanoVG_nvgSkewX(ctxt: basis.CppPtr, angle: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgSkewX not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgSkewX(ctxt, angle);
    }
}

pub fn NanoVG_nvgSkewY(ctxt: basis.CppPtr, angle: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgSkewY not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgSkewY(ctxt, angle);
    }
}

pub fn NanoVG_nvgScale(ctxt: basis.CppPtr, x: f32, y: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgScale not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgScale(ctxt, x, y);
    }
}

pub fn NanoVG_nvgCurrentTransform(ctxt: basis.CppPtr, xform: [*c]f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgCurrentTransform not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgCurrentTransform(ctxt, xform);
    }
}

// We don't need these. The Paint type has init functions for creating paints.

// pub fn NanoVG_nvgLinearGradient(
//     ctxt: basis.CppPtr,
//     sx: f32,
//     sy: f32,
//     ex: f32,
//     ey: f32,
//     icol: [*c]const basis.bindings.InteropColor,
//     ocol: [*c]const basis.bindings.InteropColor,
//     paint: [*c]goofy.bindings.InteropPaint,
// ) void {
//     if (isWasm) {
//         @compileError("NanoVG_nvgLinearGradient not implemented for WASM yet.");
//     } else {
//         goofy.bindings.fp._NanoVG_nvgLinearGradient(ctxt, sx, sy, ex, ey, icol, ocol, paint);
//     }
// }

// pub fn NanoVG_nvgImagePattern(
//     ctxt: basis.CppPtr,
//     ox: f32,
//     oy: f32,
//     ex: f32,
//     ey: f32,
//     angle: f32,
//     image: c_int,
//     alpha: f32,
//     paint: [*c]goofy.bindings.InteropPaint,
// ) void {
//     if (isWasm) {
//         @compileError("NanoVG_nvgImagePattern not implemented for WASM yet.");
//     } else {
//         goofy.bindings.fp._NanoVG_nvgImagePattern(ctxt, ox, oy, ex, ey, angle, image, alpha, paint);
//     }
// }

pub fn NanoVG_nvgScissor(ctxt: basis.CppPtr, x: f32, y: f32, w: f32, h: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgScissor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgScissor(ctxt, x, y, w, h);
    }
}

pub fn NanoVG_nvgIntersectScissor(ctxt: basis.CppPtr, x: f32, y: f32, w: f32, h: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgIntersectScissor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgIntersectScissor(ctxt, x, y, w, h);
    }
}

pub fn NanoVG_nvgResetScissor(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgResetScissor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgResetScissor(ctxt);
    }
}

pub fn NanoVG_nvgBeginPath(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgBeginPath not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgBeginPath(ctxt);
    }
}

pub fn NanoVG_nvgMoveTo(ctxt: basis.CppPtr, x: f32, y: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgMoveTo not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgMoveTo(ctxt, x, y);
    }
}

pub fn NanoVG_nvgLineTo(ctxt: basis.CppPtr, x: f32, y: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgLineTo not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgLineTo(ctxt, x, y);
    }
}

pub fn NanoVG_nvgBezierTo(ctxt: basis.CppPtr, c1x: f32, c1y: f32, c2x: f32, c2y: f32, x: f32, y: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgBezierTo not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgBezierTo(ctxt, c1x, c1y, c2x, c2y, x, y);
    }
}

pub fn NanoVG_nvgQuadTo(ctxt: basis.CppPtr, cx: f32, cy: f32, x: f32, y: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgQuadTo not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgQuadTo(ctxt, cx, cy, x, y);
    }
}

pub fn NanoVG_nvgArcTo(ctxt: basis.CppPtr, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgArcTo not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgArcTo(ctxt, x1, y1, x2, y2, radius);
    }
}

pub fn NanoVG_nvgClosePath(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgClosePath not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgClosePath(ctxt);
    }
}

pub fn NanoVG_nvgPathWinding(ctxt: basis.CppPtr, dir: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgPathWinding not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgPathWinding(ctxt, dir);
    }
}

pub fn NanoVG_nvgArc(ctxt: basis.CppPtr, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgArc not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgArc(ctxt, cx, cy, r, a0, a1, dir);
    }
}

pub fn NanoVG_nvgRect(ctxt: basis.CppPtr, x: f32, y: f32, w: f32, h: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgRect not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgRect(ctxt, x, y, w, h);
    }
}

pub fn NanoVG_nvgRoundedRect(ctxt: basis.CppPtr, x: f32, y: f32, w: f32, h: f32, r: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgRoundedRect not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgRoundedRect(ctxt, x, y, w, h, r);
    }
}

pub fn NanoVG_nvgRoundedRectVarying(ctxt: basis.CppPtr, x: f32, y: f32, w: f32, h: f32, radTopLeft: f32, radTopRight: f32, radBottomRight: f32, radBottomLeft: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgRoundedRectVarying not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgRoundedRectVarying(ctxt, x, y, w, h, radTopLeft, radTopRight, radBottomRight, radBottomLeft);
    }
}

pub fn NanoVG_nvgEllipse(ctxt: basis.CppPtr, cx: f32, cy: f32, rx: f32, ry: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgEllipse not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgEllipse(ctxt, cx, cy, rx, ry);
    }
}

pub fn NanoVG_nvgCircle(ctxt: basis.CppPtr, cx: f32, cy: f32, r: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgCircle not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgCircle(ctxt, cx, cy, r);
    }
}

pub fn NanoVG_nvgFill(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFill not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFill(ctxt);
    }
}

pub fn NanoVG_nvgStroke(ctxt: basis.CppPtr) void {
    if (isWasm) {
        @compileError("NanoVG_nvgStroke not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgStroke(ctxt);
    }
}

pub fn NanoVG_nvgFindFont(ctxt: basis.CppPtr, name: [*c]const basis.bindings.InteropString) c_int {
    if (isWasm) {
        @compileError("NanoVG_nvgFindFont not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgFindFont(ctxt, name);
    }
}

pub fn NanoVG_nvgFontSize(ctxt: basis.CppPtr, size: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFontSize not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFontSize(ctxt, size);
    }
}

pub fn NanoVG_nvgFontBlur(ctxt: basis.CppPtr, blur: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFontBlur not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFontBlur(ctxt, blur);
    }
}

pub fn NanoVG_nvgTextLetterSpacing(ctxt: basis.CppPtr, spacing: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTextLetterSpacing not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTextLetterSpacing(ctxt, spacing);
    }
}

pub fn NanoVG_nvgTextLineHeight(ctxt: basis.CppPtr, lineHeight: f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTextLineHeight not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTextLineHeight(ctxt, lineHeight);
    }
}

pub fn NanoVG_nvgTextAlign(ctxt: basis.CppPtr, alignment: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTextAlign not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTextAlign(ctxt, alignment);
    }
}

pub fn NanoVG_nvgFontFaceId(ctxt: basis.CppPtr, font: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFontFaceId not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFontFaceId(ctxt, font);
    }
}

pub fn NanoVG_nvgFontFace(ctxt: basis.CppPtr, font: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("NanoVG_nvgFontFace not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgFontFace(ctxt, font);
    }
}

pub fn NanoVG_nvgText(ctxt: basis.CppPtr, x: f32, y: f32, string: [*c]const basis.bindings.InteropString) f32 {
    if (isWasm) {
        @compileError("NanoVG_nvgText not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgText(ctxt, x, y, string);
    }
}

pub fn NanoVG_nvgTextBox(ctxt: basis.CppPtr, x: f32, y: f32, breakRowWidth: f32, string: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTextBox not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTextBox(ctxt, x, y, breakRowWidth, string);
    }
}

pub fn NanoVG_nvgTextBounds(ctxt: basis.CppPtr, x: f32, y: f32, string: [*c]const basis.bindings.InteropString, bounds: [*c]f32) f32 {
    if (isWasm) {
        @compileError("NanoVG_nvgTextBounds not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgTextBounds(ctxt, x, y, string, bounds);
    }
}

pub fn NanoVG_nvgTextMetrics(ctxt: basis.CppPtr, ascender: [*c]f32, descender: [*c]f32, lineh: [*c]f32) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTextMetrics not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTextMetrics(ctxt, ascender, descender, lineh);
    }
}

pub fn NanoVG_nvgTextSubset(ctxt: basis.CppPtr, x: f32, y: f32, string: [*c]const basis.bindings.InteropString, charStart: c_int, charCount: c_int) f32 {
    if (isWasm) {
        @compileError("NanoVG_nvgTextSubset not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgTextSubset(ctxt, x, y, string, charStart, charCount);
    }
}

pub fn NanoVG_nvgTextBoxSubset(ctxt: basis.CppPtr, x: f32, y: f32, breakRowWidth: f32, string: [*c]const basis.bindings.InteropString, charStart: c_int, charCount: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgTextBoxSubset not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgTextBoxSubset(ctxt, x, y, breakRowWidth, string, charStart, charCount);
    }
}

pub fn NanoVG_nvgTextCountRows(ctxt: basis.CppPtr, string: [*c]const basis.bindings.InteropString, breakRowWidth: f32) c_int {
    if (isWasm) {
        @compileError("NanoVG_nvgTextCountRows not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgTextCountRows(ctxt, string, breakRowWidth);
    }
}

pub fn NanoVG_nvgCreateImageFromTextureResource(ctxt: basis.CppPtr, textureResourceCppPtr: basis.CppPtr, imageFlags: c_int) i32 {
    if (isWasm) {
        @compileError("NanoVG_nvgCreateImageFromTextureResource not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgCreateImageFromTextureResource(ctxt, textureResourceCppPtr, imageFlags);
    }
}

pub fn NanoVG_nvgImageSize(ctxt: basis.CppPtr, image: c_int, w: [*c]c_int, h: [*c]c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgImageSize not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgImageSize(ctxt, image, w, h);
    }
}

pub fn NanoVG_nvgDeleteImage(ctxt: basis.CppPtr, image: c_int) void {
    if (isWasm) {
        @compileError("NanoVG_nvgDeleteImage not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._NanoVG_nvgDeleteImage(ctxt, image);
    }
}

pub fn NanoVG_nvgSetIGNAmount(ctxt: basis.CppPtr, amount: f32) f32 {
    if (isWasm) {
        @compileError("NanoVG_nvgSetIGNAmount not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._NanoVG_nvgSetIGNAmount(ctxt, amount);
    }
}

// ===============================

// class GoofyUIView

pub fn GoofyUIView_getWidget(cppPtr: basis.CppPtr, name: [*c]const basis.bindings.InteropString) basis.CppPtr {
    if (isWasm) {
        return access.GoofyUIView_getWidget_WASM(cppPtr, name.*.ptr, name.*.len);
    } else {
        return goofy.bindings.fp._GoofyUIView_getWidget(cppPtr, name);
    }
}

pub fn GoofyUIView_requestFocusChange(cppPtr: basis.CppPtr, widgetCppPtr: basis.CppPtr, widgetType: u32) void {
    if (isWasm) {
        access.GoofyUIView_requestFocusChange_WASM(cppPtr, widgetCppPtr, widgetType);
    } else {
        goofy.bindings.fp._GoofyUIView_requestFocusChange(cppPtr, widgetCppPtr, widgetType);
    }
}

pub fn GoofyUIView_setRecreationCallbackEnabled(cppPtr: basis.CppPtr, enabled: c_int) void {
    if (isWasm) {
        access.GoofyUIView_setRecreationCallbackEnabled_WASM(cppPtr, enabled);
    } else {
        goofy.bindings.fp._GoofyUIView_setRecreationCallbackEnabled(cppPtr, enabled);
    }
}

pub fn GoofyUIView_setRaiseNavDirEvents(cppPtr: basis.CppPtr, raiseEvents: c_int) void {
    if (isWasm) {
        access.GoofyUIView_setRaiseNavDirEvents_WASM(cppPtr, raiseEvents);
    } else {
        goofy.bindings.fp._GoofyUIView_setRaiseNavDirEvents(cppPtr, raiseEvents);
    }
}

pub fn GoofyUIView_setRaiseMouseEvents(cppPtr: basis.CppPtr, raiseEvents: c_int) void {
    if (isWasm) {
        access.GoofyUIView_setRaiseMouseEvents_WASM(cppPtr, raiseEvents);
    } else {
        goofy.bindings.fp._GoofyUIView_setRaiseMouseEvents(cppPtr, raiseEvents);
    }
}

// ===============================

// class GoofyUIWidget

pub fn GoofyUIWidget_getName(cppPtr: basis.CppPtr, widgetType: u32, str: [*c]basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyUIWidget_getName not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUIWidget_getName(cppPtr, widgetType, str);
    }
}

pub fn GoofyUIWidget_setPosition(cppPtr: basis.CppPtr, widgetType: u32, pos: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        access.GoofyUIWidget_setPosition_WASM(cppPtr, widgetType, pos.*.x, pos.*.y);
    } else {
        goofy.bindings.fp._GoofyUIWidget_setPosition(cppPtr, widgetType, pos);
    }
}

pub fn GoofyUIWidget_getPosition(cppPtr: basis.CppPtr, widgetType: u32, pos: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        pos.*.x = access.GoofyUIWidget_getPosX_WASM(cppPtr, widgetType);
        pos.*.y = access.GoofyUIWidget_getPosY_WASM(cppPtr, widgetType);
    } else {
        goofy.bindings.fp._GoofyUIWidget_getPosition(cppPtr, widgetType, pos);
    }
}

pub fn GoofyUIWidget_setSize(cppPtr: basis.CppPtr, widgetType: u32, size: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        access.GoofyUIWidget_setSize_WASM(cppPtr, widgetType, size.*.x, size.*.y);
    } else {
        goofy.bindings.fp._GoofyUIWidget_setSize(cppPtr, widgetType, size);
    }
}

pub fn GoofyUIWidget_getSize(cppPtr: basis.CppPtr, widgetType: u32, size: [*c]basis.bindings.InteropVec2) void {
    if (isWasm) {
        size.*.x = access.GoofyUIWidget_getWidth_WASM(cppPtr, widgetType);
        size.*.y = access.GoofyUIWidget_getHeight_WASM(cppPtr, widgetType);
    } else {
        goofy.bindings.fp._GoofyUIWidget_getSize(cppPtr, widgetType, size);
    }
}

pub fn GoofyUIWidget_setVisible(cppPtr: basis.CppPtr, widgetType: u32, visible: bool) void {
    if (isWasm) {
        access.GoofyUIWidget_setVisible_WASM(cppPtr, widgetType, visible);
    } else {
        goofy.bindings.fp._GoofyUIWidget_setVisible(cppPtr, widgetType, if (visible) 1 else 0);
    }
}

pub fn GoofyUIWidget_isVisible(cppPtr: basis.CppPtr, widgetType: u32) c_int {
    if (isWasm) {
        return access.GoofyUIWidget_isVisible_WASM(cppPtr, widgetType);
    } else {
        return goofy.bindings.fp._GoofyUIWidget_isVisible(cppPtr, widgetType);
    }
}

pub fn GoofyUIWidget_setEnabled(cppPtr: basis.CppPtr, widgetType: u32, enabled: bool) void {
    if (isWasm) {
        access.GoofyUIWidget_setEnabled_WASM(cppPtr, widgetType, enabled);
    } else {
        goofy.bindings.fp._GoofyUIWidget_setEnabled(cppPtr, widgetType, if (enabled) 1 else 0);
    }
}

pub fn GoofyUIWidget_isEnabled(cppPtr: basis.CppPtr, widgetType: u32) c_int {
    if (isWasm) {
        return access.GoofyUIWidget_isEnabled_WASM(cppPtr, widgetType);
    } else {
        return goofy.bindings.fp._GoofyUIWidget_isEnabled(cppPtr, widgetType);
    }
}

// ===============================

// class GoofyUILabel

pub fn GoofyUILabel_setRawText(cppPtr: basis.CppPtr, text: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyUILabel_setRawText not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUILabel_setRawText(cppPtr, text);
    }
}

pub fn GoofyUILabel_setLocalizedText(cppPtr: basis.CppPtr, locID: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyUILabel_setLocalizedText not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUILabel_setLocalizedText(cppPtr, locID);
    }
}

pub fn GoofyUILabel_setColor(cppPtr: basis.CppPtr, color: [*c]const basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("GoofyUILabel_setColor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUILabel_setColor(cppPtr, color);
    }
}

pub fn GoofyUILabel_getColor(cppPtr: basis.CppPtr, color: [*c]basis.bindings.InteropColor) void {
    if (isWasm) {
        @compileError("GoofyUILabel_getColor not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUILabel_getColor(cppPtr, color);
    }
}

// ===============================

// class GoofyUIButton

pub fn GoofyUIButton_setRawText(cppPtr: basis.CppPtr, text: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyUIButton_setRawText not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUIButton_setRawText(cppPtr, text);
    }
}

pub fn GoofyUIButton_setLocalizedText(cppPtr: basis.CppPtr, locID: [*c]const basis.bindings.InteropString) void {
    if (isWasm) {
        @compileError("GoofyUIButton_setLocalizedText not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUIButton_setLocalizedText(cppPtr, locID);
    }
}

// ===============================

// class GoofyUICanvas

pub fn GoofyUICanvas_setRenderCallbackEnabled(cppPtr: basis.CppPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("GoofyUICanvas_setRenderCallbackEnabled not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUICanvas_setRenderCallbackEnabled(cppPtr, enabled);
    }
}

pub fn GoofyUICanvas_getUserData(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropVec4) void {
    if (isWasm) {
        @compileError("GoofyUICanvas_getUserData not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUICanvas_getUserData(cppPtr, data);
    }
}

// ===============================

// class GoofyUIImageBox

pub fn GoofyUIImageBox_play(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyUIImageBox_play_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofyUIImageBox_play(cppPtr);
    }
}

pub fn GoofyUIImageBox_pause(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyUIImageBox_pause_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofyUIImageBox_pause(cppPtr);
    }
}

pub fn GoofyUIImageBox_stop(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyUIImageBox_stop_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofyUIImageBox_stop(cppPtr);
    }
}

pub fn GoofyUIImageBox_jumpToEnd(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofyUIImageBox_jumpToEnd_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofyUIImageBox_jumpToEnd(cppPtr);
    }
}

// ===============================

// class GoofyUISpinBox

pub fn GoofyUISpinBox_addItem(cppPtr: basis.CppPtr, value: i32, text: [*c]const basis.bindings.InteropString, isLocalized: bool) void {
    if (isWasm) {
        @compileError("GoofyUISpinBox_addItem not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUISpinBox_addItem(cppPtr, value, text, if (isLocalized) 1 else 0);
    }
}

pub fn GoofyUISpinBox_clearItems(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        @compileError("GoofyUISpinBox_clearItems not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUISpinBox_clearItems(cppPtr);
    }
}

pub fn GoofyUISpinBox_setSelectedValue(cppPtr: basis.CppPtr, value: i32) void {
    if (isWasm) {
        @compileError("GoofyUISpinBox_setSelectedValue not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUISpinBox_setSelectedValue(cppPtr, value);
    }
}

pub fn GoofyUISpinBox_getSelectedValue(cppPtr: basis.CppPtr) i32 {
    if (isWasm) {
        @compileError("GoofyUISpinBox_getSelectedValue not implemented for WASM yet.");
    } else {
        return goofy.bindings.fp._GoofyUISpinBox_getSelectedValue(cppPtr);
    }
}

// ===============================

// class GoofyUIUserWidget

pub fn GoofyUIUserWidget_setRenderCallbackEnabled(cppPtr: basis.CppPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("GoofyUIUserWidget_setRenderCallbackEnabled not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUIUserWidget_setRenderCallbackEnabled(cppPtr, enabled);
    }
}

pub fn GoofyUIUserWidget_setEventCallbackEnabled(cppPtr: basis.CppPtr, enabled: c_int) void {
    if (isWasm) {
        @compileError("GoofyUIUserWidget_setEventCallbackEnabled not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUIUserWidget_setEventCallbackEnabled(cppPtr, enabled);
    }
}

pub fn GoofyUIUserWidget_getUserData(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropVec4) void {
    if (isWasm) {
        @compileError("GoofyUIUserWidget_getUserData not implemented for WASM yet.");
    } else {
        goofy.bindings.fp._GoofyUIUserWidget_getUserData(cppPtr, data);
    }
}

// ===============================

// class GoofySVGImage

pub fn GoofySVGImage_newImage() basis.CppPtr {
    if (isWasm) {
        return access.GoofySVGImage_newImage_WASM();
    } else {
        return goofy.bindings.fp._GoofySVGImage_newImage();
    }
}

pub fn GoofySVGImage_deleteImage(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGImage_deleteImage_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofySVGImage_deleteImage(cppPtr);
    }
}

pub fn GoofySVGImage_getWidth(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.GoofySVGImage_getWidth_WASM(cppPtr);
    } else {
        return goofy.bindings.fp._GoofySVGImage_getWidth(cppPtr);
    }
}

pub fn GoofySVGImage_getHeight(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.GoofySVGImage_getHeight_WASM(cppPtr);
    } else {
        return goofy.bindings.fp._GoofySVGImage_getHeight(cppPtr);
    }
}

pub fn GoofySVGImage_loadImage(cppPtr: basis.CppPtr, rawDataFileCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGImage_loadImage_WASM(cppPtr, rawDataFileCppPtr);
    } else {
        goofy.bindings.fp._GoofySVGImage_loadImage(cppPtr, rawDataFileCppPtr);
    }
}

pub fn GoofySVGImage_render(cppPtr: basis.CppPtr, ctxt: [*c]const goofy.bindings.InteropUIRenderContext, rectMin: [*c]const basis.bindings.InteropVec2, rectMax: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        access.GoofySVGImage_render_WASM(
            cppPtr,
            ctxt.*.nvgCppCtxt,
            ctxt.*.screenWidth,
            ctxt.*.screenHeight,
            ctxt.*.pixelRectMinX,
            ctxt.*.pixelRectMinY,
            ctxt.*.pixelRectMaxX,
            ctxt.*.pixelRectMaxY,
            rectMin.*.x,
            rectMin.*.y,
            rectMax.*.x,
            rectMax.*.y,
        );
    } else {
        goofy.bindings.fp._GoofySVGImage_render(cppPtr, ctxt, rectMin, rectMax);
    }
}

pub fn GoofySVGImage_renderUnstretched(cppPtr: basis.CppPtr, ctxt: [*c]const goofy.bindings.InteropUIRenderContext, position: [*c]const basis.bindings.InteropVec2, width: f32, pivot: u32) void {
    if (isWasm) {
        access.GoofySVGImage_renderUnstretched_WASM(
            cppPtr,
            ctxt.*.nvgCppCtxt,
            ctxt.*.screenWidth,
            ctxt.*.screenHeight,
            ctxt.*.pixelRectMinX,
            ctxt.*.pixelRectMinY,
            ctxt.*.pixelRectMaxX,
            ctxt.*.pixelRectMaxY,
            position.*.x,
            position.*.y,
            width,
            pivot,
        );
    } else {
        goofy.bindings.fp._GoofySVGImage_renderUnstretched(cppPtr, ctxt, position, width, pivot);
    }
}

pub fn GoofySVGImage_renderInPixelRect(cppPtr: basis.CppPtr, ctxt: [*c]const goofy.bindings.InteropUIRenderContext, rectMin: [*c]const basis.bindings.InteropVec2, rectMax: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        access.GoofySVGImage_renderInPixelRect_WASM(
            cppPtr,
            ctxt.*.nvgCppCtxt,
            ctxt.*.screenWidth,
            ctxt.*.screenHeight,
            ctxt.*.pixelRectMinX,
            ctxt.*.pixelRectMinY,
            ctxt.*.pixelRectMaxX,
            ctxt.*.pixelRectMaxY,
            rectMin.*.x,
            rectMin.*.y,
            rectMax.*.x,
            rectMax.*.y,
        );
    } else {
        goofy.bindings.fp._GoofySVGImage_renderInPixelRect(cppPtr, ctxt, rectMin, rectMax);
    }
}

// ===============================

// class GoofySVGAnimationPlayer

pub fn GoofySVGAnimationPlayer_newPlayer() basis.CppPtr {
    if (isWasm) {
        return access.GoofySVGAnimationPlayer_newPlayer_WASM();
    } else {
        return goofy.bindings.fp._GoofySVGAnimationPlayer_newPlayer();
    }
}

pub fn GoofySVGAnimationPlayer_deletePlayer(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_deletePlayer_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_deletePlayer(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_getWidth(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.GoofySVGAnimationPlayer_getWidth_WASM(cppPtr);
    } else {
        return goofy.bindings.fp._GoofySVGAnimationPlayer_getWidth(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_getHeight(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.GoofySVGAnimationPlayer_getHeight_WASM(cppPtr);
    } else {
        return goofy.bindings.fp._GoofySVGAnimationPlayer_getHeight(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_setDeltaTimeLimitEnabled(cppPtr: basis.CppPtr, enabled: bool) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_setDeltaTimeLimitEnabled_WASM(cppPtr, enabled);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_setDeltaTimeLimitEnabled(cppPtr, if (enabled) 1 else 0);
    }
}

pub fn GoofySVGAnimationPlayer_loadAnimation(cppPtr: basis.CppPtr, rawDataFileCppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_loadAnimation_WASM(cppPtr, rawDataFileCppPtr);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_loadAnimation(cppPtr, rawDataFileCppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_render(cppPtr: basis.CppPtr, ctxt: [*c]const goofy.bindings.InteropUIRenderContext, rectMin: [*c]const basis.bindings.InteropVec2, rectMax: [*c]const basis.bindings.InteropVec2) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_render_WASM(
            cppPtr,
            ctxt.*.nvgCppCtxt,
            ctxt.*.screenWidth,
            ctxt.*.screenHeight,
            ctxt.*.pixelRectMinX,
            ctxt.*.pixelRectMinY,
            ctxt.*.pixelRectMaxX,
            ctxt.*.pixelRectMaxY,
            rectMin.*.x,
            rectMin.*.y,
            rectMax.*.x,
            rectMax.*.y,
        );
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_render(cppPtr, ctxt, rectMin, rectMax);
    }
}

pub fn GoofySVGAnimationPlayer_renderUnstretched(cppPtr: basis.CppPtr, ctxt: [*c]const goofy.bindings.InteropUIRenderContext, position: [*c]const basis.bindings.InteropVec2, width: f32, pivot: u32) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_renderUnstretched_WASM(
            cppPtr,
            ctxt.*.nvgCppCtxt,
            ctxt.*.screenWidth,
            ctxt.*.screenHeight,
            ctxt.*.pixelRectMinX,
            ctxt.*.pixelRectMinY,
            ctxt.*.pixelRectMaxX,
            ctxt.*.pixelRectMaxY,
            position.*.x,
            position.*.y,
            width,
            pivot,
        );
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_renderUnstretched(cppPtr, ctxt, position, width, pivot);
    }
}

pub fn GoofySVGAnimationPlayer_play(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_play_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_play(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_pause(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_pause_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_pause(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_stop(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_stop_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_stop(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_jumpToEnd(cppPtr: basis.CppPtr) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_jumpToEnd_WASM(cppPtr);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_jumpToEnd(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_setLooping(cppPtr: basis.CppPtr, looping: bool) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_setLooping_WASM(cppPtr, looping);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_setLooping(cppPtr, if (looping) 1 else 0);
    }
}

pub fn GoofySVGAnimationPlayer_update(cppPtr: basis.CppPtr, deltaTime: f32) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_update_WASM(cppPtr, deltaTime);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_update(cppPtr, deltaTime);
    }
}

pub fn GoofySVGAnimationPlayer_getState(cppPtr: basis.CppPtr) u32 {
    if (isWasm) {
        return access.GoofySVGAnimationPlayer_getState_WASM(cppPtr);
    } else {
        return goofy.bindings.fp._GoofySVGAnimationPlayer_getState(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_getCurrentTime(cppPtr: basis.CppPtr) f32 {
    if (isWasm) {
        return access.GoofySVGAnimationPlayer_getCurrentTime_WASM(cppPtr);
    } else {
        return goofy.bindings.fp._GoofySVGAnimationPlayer_getCurrentTime(cppPtr);
    }
}

pub fn GoofySVGAnimationPlayer_setCurrentTime(cppPtr: basis.CppPtr, time: f32) void {
    if (isWasm) {
        access.GoofySVGAnimationPlayer_setCurrentTime_WASM(cppPtr, time);
    } else {
        goofy.bindings.fp._GoofySVGAnimationPlayer_setCurrentTime(cppPtr, time);
    }
}

// ===============================
