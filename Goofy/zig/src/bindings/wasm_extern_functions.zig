// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const basis = @import("basis");

// GoofyManager:

pub extern "env" fn GoofyManager_setAspectRatio_WASM(aspectRatio: f32) void;
pub extern "env" fn GoofyManager_setFitMode_WASM(fitMode: u32) void;
pub extern "env" fn GoofyManager_createView_WASM(namePtr: [*]const u8, nameLength: u32) basis.CppPtr;
pub extern "env" fn GoofyManager_createViewWithScript_WASM(namePtr: [*]const u8, nameLength: u32, scriptPtr: [*]const u8, scriptLength: u32) basis.CppPtr;
pub extern "env" fn GoofyManager_destroyView_WASM(viewCppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyManager_pushViewOntoStack_WASM(viewCppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyManager_pushModalViewOntoStack_WASM(viewCppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyManager_removeViewFromStack_WASM(viewCppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyManager_clearViewStack_WASM() void;
pub extern "env" fn GoofyManager_createFont_WASM(namePtr: [*]const u8, nameLength: u32, ttfFilePtr: [*]const u8, ttfFileLength: u32) i32;
pub extern "env" fn GoofyManager_registerAction_WASM(actionNamePtr: [*]const u8, actionNameLength: u32) void;
pub extern "env" fn GoofyManager_fireAction_WASM(actionNamePtr: [*]const u8, actionNameLength: u32) void;
pub extern "env" fn GoofyManager_setActionCallback_WASM(actionNamePtr: [*]const u8, actionNameLength: u32, callback: basis.WasmFuncPtr) void;
pub extern "env" fn GoofyManager_clearActionCallback_WASM(actionNamePtr: [*]const u8, actionNameLength: u32) void;
pub extern "env" fn GoofyManager_registerProperty_WASM(propertyNamePtr: [*]const u8, propertyNameLength: u32, valueType: i32, initialValueBuffer: [*]const u8, initialValueBufferLength: u32) void;
pub extern "env" fn GoofyManager_getPropertyType_WASM(propertyNamePtr: [*]const u8, propertyNameLength: u32) i32;
pub extern "env" fn GoofyManager_getPropertyValue_WASM(propertyNamePtr: [*]const u8, propertyNameLength: u32, valueType: c_int, valuePtr: [*c]u8, valueLength: u32) void;
pub extern "env" fn GoofyManager_setPropertyValue_WASM(propertyNamePtr: [*]const u8, propertyNameLength: u32, valueType: c_int, valuePtr: [*c]const u8, valueLength: u32) void;
pub extern "env" fn GoofyManager_registerStringProperty_WASM(propertyNamePtr: [*]const u8, propertyNameLength: u32, initialValuePtr: [*c]const u8, initialValueLength: u32) void; // [*c] used here to allow empty strings.
//pub extern "env" fn GoofyManager_getStringPropertyValue_WASM(propertyName: [*c]const basis.bindings.InteropString, value: [*c]basis.bindings.InteropString) void;
//pub extern "env" fn GoofyManager_setStringPropertyValue_WASM(propertyName: [*c]const basis.bindings.InteropString, value: [*c]const basis.bindings.InteropString) void;
pub extern "env" fn GoofyManager_setZigEventHandlingEnabled_WASM(enabled: i32) void;

// GoofySkins:

pub extern "env" fn GoofySkins_registerSkin_WASM(skinNamePtr: [*]const u8, skinNameLength: u32) void;
//pub extern "env" fn GoofySkins_setButtonRenderCallback_WASM(skinName: [*c]const basis.bindings.InteropString, callback: basis.bindings.InteropButtonRenderCallback) void;

// class NanoVG:

//pub extern "env" fn NanoVG_nvgSave_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgRestore_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgReset_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgShapeAntiAlias_WASM(ctx: u64, enabled: c_int) void;
//pub extern "env" fn NanoVG_nvgStrokeColor_WASM(ctx: u64, color: [*c]const basis.bindings.InteropColor) void;
//pub extern "env" fn NanoVG_nvgFillColor_WASM(ctx: u64, color: [*c]const basis.bindings.InteropColor) void;
//pub extern "env" fn NanoVG_nvgMiterLimit_WASM(ctx: u64, limit: f32) void;
//pub extern "env" fn NanoVG_nvgStrokeWidth_WASM(ctx: u64, size: f32) void;
//pub extern "env" fn NanoVG_nvgLineCap_WASM(ctx: u64, cap: c_int) void;
//pub extern "env" fn NanoVG_nvgLineJoin_WASM(ctx: u64, join: c_int) void;
//pub extern "env" fn NanoVG_nvgGlobalAlpha_WASM(ctx: u64, alpha: f32) void;
//pub extern "env" fn NanoVG_nvgResetTransform_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgTransform_WASM(ctx: u64, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32) void;
//pub extern "env" fn NanoVG_nvgTranslate_WASM(ctx: u64, x: f32, y: f32) void;
//pub extern "env" fn NanoVG_nvgRotate_WASM(ctx: u64, angle: f32) void;
//pub extern "env" fn NanoVG_nvgSkewX_WASM(ctx: u64, angle: f32) void;
//pub extern "env" fn NanoVG_nvgSkewY_WASM(ctx: u64, angle: f32) void;
//pub extern "env" fn NanoVG_nvgScale_WASM(ctx: u64, x: f32, y: f32) void;
//pub extern "env" fn NanoVG_nvgCurrentTransform_WASM(ctx: u64, xform: [*c]f32) void;
//pub extern "env" fn NanoVG_nvgScissor_WASM(ctx: u64, x: f32, y: f32, w: f32, h: f32) void;
//pub extern "env" fn NanoVG_nvgIntersectScissor_WASM(ctx: u64, x: f32, y: f32, w: f32, h: f32) void;
//pub extern "env" fn NanoVG_nvgResetScissor_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgBeginPath_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgMoveTo_WASM(ctx: u64, x: f32, y: f32) void;
//pub extern "env" fn NanoVG_nvgLineTo_WASM(ctx: u64, x: f32, y: f32) void;
//pub extern "env" fn NanoVG_nvgBezierTo_WASM(ctx: u64, c1x: f32, c1y: f32, c2x: f32, c2y: f32, x: f32, y: f32) void;
//pub extern "env" fn NanoVG_nvgQuadTo_WASM(ctx: u64, cx: f32, cy: f32, x: f32, y: f32) void;
//pub extern "env" fn NanoVG_nvgArcTo_WASM(ctx: u64, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32) void;
//pub extern "env" fn NanoVG_nvgClosePath_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgPathWinding_WASM(ctx: u64, dir: c_int) void;
//pub extern "env" fn NanoVG_nvgArc_WASM(ctx: u64, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: c_int) void;
//pub extern "env" fn NanoVG_nvgRect_WASM(ctx: u64, x: f32, y: f32, w: f32, h: f32) void;
//pub extern "env" fn NanoVG_nvgRoundedRect_WASM(ctx: u64, x: f32, y: f32, w: f32, h: f32, r: f32) void;
//pub extern "env" fn NanoVG_nvgRoundedRectVarying_WASM(ctx: u64, x: f32, y: f32, w: f32, h: f32, radTopLeft: f32, radTopRight: f32, radBottomRight: f32, radBottomLeft: f32) void;
//pub extern "env" fn NanoVG_nvgEllipse_WASM(ctx: u64, cx: f32, cy: f32, rx: f32, ry: f32) void;
//pub extern "env" fn NanoVG_nvgCircle_WASM(ctx: u64, cx: f32, cy: f32, r: f32) void;
//pub extern "env" fn NanoVG_nvgFill_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgStroke_WASM(ctx: u64) void;
//pub extern "env" fn NanoVG_nvgFindFont_WASM(ctx: u64, namePtr: [*]const u8, nameLength: u32) c_int;
//pub extern "env" fn NanoVG_nvgFontSize_WASM(ctx: u64, size: f32) void;
//pub extern "env" fn NanoVG_nvgFontBlur_WASM(ctx: u64, blur: f32) void;
//pub extern "env" fn NanoVG_nvgTextLetterSpacing_WASM(ctx: u64, spacing: f32) void;
//pub extern "env" fn NanoVG_nvgTextLineHeight_WASM(ctx: u64, lineHeight: f32) void;
//pub extern "env" fn NanoVG_nvgTextAlign_WASM(ctx: u64, alignment: c_int) void;
//pub extern "env" fn NanoVG_nvgFontFaceId_WASM(ctx: u64, font: c_int) void;
//pub extern "env" fn NanoVG_nvgFontFace_WASM(ctx: u64, font: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn NanoVG_nvgText_WASM(ctx: u64, x: f32, y: f32, string: [*c]const basis.bindings.InteropString) f32;
//pub extern "env" fn NanoVG_nvgTextBox_WASM(ctx: u64, x: f32, y: f32, breakRowWidth: f32, string: [*c]const basis.bindings.InteropString) void;
//pub extern "env" fn NanoVG_nvgTextBounds_WASM(ctx: u64, x: f32, y: f32, string: [*c]const basis.bindings.InteropString, bounds: [*c]f32) f32;
//pub extern "env" fn NanoVG_nvgTextMetrics_WASM(ctx: u64, ascender: [*c]f32, descender: [*c]f32, lineh: [*c]f32) void;
//pub extern "env" fn NanoVG_nvgTextSubset_WASM(ctx: u64, x: f32, y: f32, string: [*c]const basis.bindings.InteropString, charStart: c_int, charCount: c_int) f32;
//pub extern "env" fn NanoVG_nvgTextBoxSubset_WASM(ctx: u64, x: f32, y: f32, breakRowWidth: f32, string: [*c]const basis.bindings.InteropString, charStart: c_int, charCount: c_int) void;
//pub extern "env" fn NanoVG_nvgTextCountRows_WASM(ctx: u64, string: [*c]const basis.bindings.InteropString, breakRowWidth: f32) c_int;

// class GoofyUIView:

pub extern "env" fn GoofyUIView_getWidget_WASM(cppPtr: basis.CppPtr, namePtr: [*]const u8, nameLength: u32) basis.CppPtr;
pub extern "env" fn GoofyUIView_requestFocusChange_WASM(cppPtr: basis.CppPtr, widgetcppPtr: basis.CppPtr, widgetType: u32) void;
pub extern "env" fn GoofyUIView_setRecreationCallbackEnabled_WASM(cppPtr: basis.CppPtr, enabled: c_int) void;
pub extern "env" fn GoofyUIView_setRaiseNavDirEvents_WASM(cppPtr: basis.CppPtr, raiseEvents: c_int) void;
pub extern "env" fn GoofyUIView_setRaiseMouseEvents_WASM(cppPtr: basis.CppPtr, raiseEvents: c_int) void;

// class GoofyUIWidget:

pub extern "env" fn GoofyUIWidget_setPosition_WASM(cppPtr: basis.CppPtr, widgetType: u32, posX: f32, posY: f32) void;
pub extern "env" fn GoofyUIWidget_getPosX_WASM(cppPtr: basis.CppPtr, widgetType: u32) f32;
pub extern "env" fn GoofyUIWidget_getPosY_WASM(cppPtr: basis.CppPtr, widgetType: u32) f32;
pub extern "env" fn GoofyUIWidget_setSize_WASM(cppPtr: basis.CppPtr, widgetType: u32, width: f32, height: f32) void;
pub extern "env" fn GoofyUIWidget_getWidth_WASM(cppPtr: basis.CppPtr, widgetType: u32) f32;
pub extern "env" fn GoofyUIWidget_getHeight_WASM(cppPtr: basis.CppPtr, widgetType: u32) f32;
pub extern "env" fn GoofyUIWidget_setVisible_WASM(cppPtr: basis.CppPtr, widgetType: u32, visible: bool) void;
pub extern "env" fn GoofyUIWidget_isVisible_WASM(cppPtr: basis.CppPtr, widgetType: u32) c_int;
pub extern "env" fn GoofyUIWidget_setEnabled_WASM(cppPtr: basis.CppPtr, widgetType: u32, enabled: bool) void;
pub extern "env" fn GoofyUIWidget_isEnabled_WASM(cppPtr: basis.CppPtr, widgetType: u32) c_int;

// class GoofyUILabel:

//pub extern "env" fn GoofyUILabel_setRawText_WASM(cppPtr: basis.CppPtr, text: [*c]const basis.bindings.InteropString) void;

// class GoofyUICanvas:

//pub extern "env" fn GoofyUICanvas_setRenderCallbackEnabled_WASM(cppPtr: basis.CppPtr, enabled: c_int) void;
//pub extern "env" fn GoofyUICanvas_getUserData_WASM(cppPtr: basis.CppPtr, data: [*c]basis.bindings.InteropVec4) void;

// class GoofyUIImageBox:

pub extern "env" fn GoofyUIImageBox_play_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyUIImageBox_pause_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyUIImageBox_stop_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofyUIImageBox_jumpToEnd_WASM(cppPtr: basis.CppPtr) void;

// class GoofySVGImage:

pub extern "env" fn GoofySVGImage_newImage_WASM() basis.CppPtr;
pub extern "env" fn GoofySVGImage_deleteImage_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGImage_getWidth_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn GoofySVGImage_getHeight_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn GoofySVGImage_loadImage_WASM(cppPtr: basis.CppPtr, rawDataFileCppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGImage_render_WASM(
    cppPtr: basis.CppPtr,
    nvgCppCtxt: basis.CppPtr,
    screenWidth: f32,
    screenHeight: f32,
    pixelRectMinX: f32,
    pixelRectMinY: f32,
    pixelRectMaxX: f32,
    pixelRectMaxY: f32,
    rectMinX: f32,
    rectMinY: f32,
    rectMaxX: f32,
    rectMaxY: f32,
) void;
pub extern "env" fn GoofySVGImage_renderUnstretched_WASM(
    cppPtr: basis.CppPtr,
    nvgCppCtxt: basis.CppPtr,
    screenWidth: f32,
    screenHeight: f32,
    pixelRectMinX: f32,
    pixelRectMinY: f32,
    pixelRectMaxX: f32,
    pixelRectMaxY: f32,
    positionX: f32,
    positionY: f32,
    width: f32,
    pivot: u32,
) void;
pub extern "env" fn GoofySVGImage_renderInPixelRect_WASM(
    cppPtr: basis.CppPtr,
    nvgCppCtxt: basis.CppPtr,
    screenWidth: f32,
    screenHeight: f32,
    pixelRectMinX: f32,
    pixelRectMinY: f32,
    pixelRectMaxX: f32,
    pixelRectMaxY: f32,
    rectMinX: f32,
    rectMinY: f32,
    rectMaxX: f32,
    rectMaxY: f32,
) void;

// class GoofySVGAnimationPlayer:

pub extern "env" fn GoofySVGAnimationPlayer_newPlayer_WASM() basis.CppPtr;
pub extern "env" fn GoofySVGAnimationPlayer_deletePlayer_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGAnimationPlayer_getWidth_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn GoofySVGAnimationPlayer_getHeight_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn GoofySVGAnimationPlayer_setDeltaTimeLimitEnabled_WASM(cppPtr: basis.CppPtr, enabled: bool) void;
pub extern "env" fn GoofySVGAnimationPlayer_loadAnimation_WASM(cppPtr: basis.CppPtr, rawDataFilecppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGAnimationPlayer_render_WASM(
    cppPtr: basis.CppPtr,
    nvgCppCtxt: basis.CppPtr,
    screenWidth: f32,
    screenHeight: f32,
    pixelRectMinX: f32,
    pixelRectMinY: f32,
    pixelRectMaxX: f32,
    pixelRectMaxY: f32,
    rectMinX: f32,
    rectMinY: f32,
    rectMaxX: f32,
    rectMaxY: f32,
) void;
pub extern "env" fn GoofySVGAnimationPlayer_renderUnstretched_WASM(
    cppPtr: basis.CppPtr,
    nvgCppCtxt: basis.CppPtr,
    screenWidth: f32,
    screenHeight: f32,
    pixelRectMinX: f32,
    pixelRectMinY: f32,
    pixelRectMaxX: f32,
    pixelRectMaxY: f32,
    positionX: f32,
    positionY: f32,
    width: f32,
    pivot: u32,
) void;
pub extern "env" fn GoofySVGAnimationPlayer_play_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGAnimationPlayer_pause_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGAnimationPlayer_stop_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGAnimationPlayer_jumpToEnd_WASM(cppPtr: basis.CppPtr) void;
pub extern "env" fn GoofySVGAnimationPlayer_setLooping_WASM(cppPtr: basis.CppPtr, looping: bool) void;
pub extern "env" fn GoofySVGAnimationPlayer_update_WASM(cppPtr: basis.CppPtr, deltaTime: f32) void;
pub extern "env" fn GoofySVGAnimationPlayer_getState_WASM(cppPtr: basis.CppPtr) u32;
pub extern "env" fn GoofySVGAnimationPlayer_getCurrentTime_WASM(cppPtr: basis.CppPtr) f32;
pub extern "env" fn GoofySVGAnimationPlayer_setCurrentTime_WASM(cppPtr: basis.CppPtr, time: f32) void;
