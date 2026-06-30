// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UIRenderContext = goofy.UIRenderContext;
pub const Color = basis.Color;
//----------------------------------------------------

pub const LineCap = enum(i32) {
    Butt = 0,
    Round = 1,
    Square = 2,
};

pub const LineJoin = enum(i32) {
    Miter = 4,
    Round = 1,
    Bevel = 3,
};

pub const Winding = enum(i32) {
    CCW = 1, // Winding for solid shapes
    CW = 2, // Winding for holes
};

pub const Align = enum(i32) {
    // Horizontal align
    Left = (1 << 0), // Default, align text horizontally to left.
    Center = (1 << 1), // Align text horizontally to center.
    Right = (1 << 2), // Align text horizontally to right.
    // Vertical align
    Top = (1 << 3), // Align text vertically to top.
    Middle = (1 << 4), // Align text vertically to middle.
    Bottom = (1 << 5), // Align text vertically to bottom.
    Baseline = (1 << 6), // Default, align text vertically to baseline.

    pub fn asInt(self: Align) i32 {
        return @intFromEnum(self);
    }
};

pub const ImageFlags = enum(i32) {
    GenerateMipMaps = (1 << 0),
    RepeatX = (1 << 1),
    RepeatY = (1 << 2),
    FlipY = (1 << 3),
    Premultiplied = (1 << 4),
    Nearest = (1 << 5),
    BW = (1 << 6), // Added for Basis. Render the image in black/white (grayscale).

    pub fn asInt(self: ImageFlags) i32 {
        return @intFromEnum(self);
    }
};

//----------------------------------------------------

// State Handling:

pub fn save(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgSave(getNVGCtxtCppPtr(ctxt));
}

pub fn restore(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgRestore(getNVGCtxtCppPtr(ctxt));
}

pub fn reset(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgReset(getNVGCtxtCppPtr(ctxt));
}

// Render styles:

pub fn shapeAntiAlias(ctxt: anytype, enabled: bool) void {
    goofy.bindings.api.NanoVG_nvgShapeAntiAlias(getNVGCtxtCppPtr(ctxt), if (enabled) 1 else 0);
}

pub fn strokeColor(ctxt: anytype, color: Color) void {
    const interopColor = color.toInterop();
    goofy.bindings.api.NanoVG_nvgStrokeColor(getNVGCtxtCppPtr(ctxt), &interopColor);
}

pub fn strokePaint(ctxt: anytype, paint: goofy.Paint) void {
    const interopPaint = paint.toInterop();
    goofy.bindings.api.NanoVG_nvgStrokePaint(getNVGCtxtCppPtr(ctxt), &interopPaint);
}

pub fn fillColor(ctxt: anytype, color: Color) void {
    const interopColor = color.toInterop();
    goofy.bindings.api.NanoVG_nvgFillColor(getNVGCtxtCppPtr(ctxt), &interopColor);
}

pub fn fillPaint(ctxt: anytype, paint: goofy.Paint) void {
    const interopPaint = paint.toInterop();
    goofy.bindings.api.NanoVG_nvgFillPaint(getNVGCtxtCppPtr(ctxt), &interopPaint);
}

pub fn miterLimit(ctxt: anytype, limit: f32) void {
    goofy.bindings.api.NanoVG_nvgMiterLimit(getNVGCtxtCppPtr(ctxt), limit);
}

pub fn strokeWidth(ctxt: anytype, width: f32) void {
    goofy.bindings.api.NanoVG_nvgStrokeWidth(getNVGCtxtCppPtr(ctxt), width);
}

pub fn lineCap(ctxt: anytype, cap: LineCap) void {
    const capInt: i32 = @intFromEnum(cap);
    goofy.bindings.api.NanoVG_nvgLineCap(getNVGCtxtCppPtr(ctxt), capInt);
}

pub fn lineJoin(ctxt: anytype, join: LineJoin) void {
    const joinInt: i32 = @intFromEnum(join);
    goofy.bindings.api.NanoVG_nvgLineJoin(getNVGCtxtCppPtr(ctxt), joinInt);
}

pub fn globalAlpha(ctxt: anytype, alpha: f32) void {
    goofy.bindings.api.NanoVG_nvgGlobalAlpha(getNVGCtxtCppPtr(ctxt), alpha);
}

// Transforms:

pub fn resetTransform(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgResetTransform(getNVGCtxtCppPtr(ctxt));
}

pub fn transform(ctxt: anytype, a: f32, b: f32, c: f32, d: f32, e: f32, f: f32) void {
    goofy.bindings.api.NanoVG_nvgTransform(getNVGCtxtCppPtr(ctxt), a, b, c, d, e, f);
}

pub fn translate(ctxt: anytype, x: f32, y: f32) void {
    goofy.bindings.api.NanoVG_nvgTranslate(getNVGCtxtCppPtr(ctxt), x, y);
}

pub fn rotate(ctxt: anytype, angle: f32) void {
    goofy.bindings.api.NanoVG_nvgRotate(getNVGCtxtCppPtr(ctxt), angle);
}

pub fn skewX(ctxt: anytype, angle: f32) void {
    goofy.bindings.api.NanoVG_nvgSkewX(getNVGCtxtCppPtr(ctxt), angle);
}

pub fn skewY(ctxt: anytype, angle: f32) void {
    goofy.bindings.api.NanoVG_nvgSkewY(getNVGCtxtCppPtr(ctxt), angle);
}

pub fn scale(ctxt: anytype, x: f32, y: f32) void {
    goofy.bindings.api.NanoVG_nvgScale(getNVGCtxtCppPtr(ctxt), x, y);
}

pub fn currentTransform(ctxt: anytype, xform: []f32) void {
    var tempXform: [6]f32 = undefined;
    goofy.bindings.api.NanoVG_nvgCurrentTransform(getNVGCtxtCppPtr(ctxt), &tempXform);

    for (0..6) |i| {
        xform[i] = tempXform[i];
    }
}

// Paints:

// We don't need these. The Paint type has init functions for creating paints.

// pub fn linearGradient(
//     ctxt: UIRenderContext,
//     sx: f32,
//     sy: f32,
//     ex: f32,
//     ey: f32,
//     icol: basis.Color,
//     ocol: basis.Color,
// ) goofy.Paint {
//     var interopPaint: goofy.bindings.InteropPaint = undefined;

//     const interopICol = icol.toInterop();
//     const interopOCol = ocol.toInterop();

//     goofy.bindings.api.NanoVG_nvgLinearGradient(
//         getNVGCtxtCppPtr(ctxt),
//         sx,
//         sy,
//         ex,
//         ey,
//         &interopICol,
//         &interopOCol,
//         &interopPaint,
//     );

//     return goofy.Paint.fromInterop(&interopPaint);
// }

// pub fn imagePattern(
//     ctxt: UIRenderContext,
//     ox: f32,
//     oy: f32,
//     ex: f32,
//     ey: f32,
//     angle: f32,
//     image: i32,
//     alpha: f32,
// ) goofy.Paint {
//     var interopPaint: goofy.bindings.InteropPaint = undefined;

//     goofy.bindings.api.NanoVG_nvgImagePattern(
//         getNVGCtxtCppPtr(ctxt),
//         ox,
//         oy,
//         ex,
//         ey,
//         angle,
//         image,
//         alpha,
//         &interopPaint,
//     );

//     return goofy.Paint.fromInterop(&interopPaint);
// }

// Scissoring:

pub fn scissor(ctxt: anytype, x: f32, y: f32, w: f32, h: f32) void {
    goofy.bindings.api.NanoVG_nvgScissor(getNVGCtxtCppPtr(ctxt), x, y, w, h);
}

pub fn intersectScissor(ctxt: anytype, x: f32, y: f32, w: f32, h: f32) void {
    goofy.bindings.api.NanoVG_nvgIntersectScissor(getNVGCtxtCppPtr(ctxt), x, y, w, h);
}

pub fn resetScissor(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgResetScissor(getNVGCtxtCppPtr(ctxt));
}

// Paths:

pub fn beginPath(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgBeginPath(getNVGCtxtCppPtr(ctxt));
}

pub fn moveTo(ctxt: anytype, x: f32, y: f32) void {
    goofy.bindings.api.NanoVG_nvgMoveTo(getNVGCtxtCppPtr(ctxt), x, y);
}

pub fn lineTo(ctxt: anytype, x: f32, y: f32) void {
    goofy.bindings.api.NanoVG_nvgLineTo(getNVGCtxtCppPtr(ctxt), x, y);
}

pub fn bezierTo(ctxt: anytype, c1x: f32, c1y: f32, c2x: f32, c2y: f32, x: f32, y: f32) void {
    goofy.bindings.api.NanoVG_nvgBezierTo(getNVGCtxtCppPtr(ctxt), c1x, c1y, c2x, c2y, x, y);
}

pub fn quadTo(ctxt: anytype, cx: f32, cy: f32, x: f32, y: f32) void {
    goofy.bindings.api.NanoVG_nvgQuadTo(getNVGCtxtCppPtr(ctxt), cx, cy, x, y);
}

pub fn arcTo(ctxt: anytype, x1: f32, y1: f32, x2: f32, y2: f32, radius: f32) void {
    goofy.bindings.api.NanoVG_nvgArcTo(getNVGCtxtCppPtr(ctxt), x1, y1, x2, y2, radius);
}

pub fn closePath(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgClosePath(getNVGCtxtCppPtr(ctxt));
}

pub fn pathWinding(ctxt: anytype, winding: Winding) void {
    const windingInt: i32 = @intFromEnum(winding);
    goofy.bindings.api.NanoVG_nvgPathWinding(getNVGCtxtCppPtr(ctxt), windingInt);
}

pub fn arc(ctxt: anytype, cx: f32, cy: f32, r: f32, a0: f32, a1: f32, dir: i32) void {
    goofy.bindings.api.NanoVG_nvgArc(getNVGCtxtCppPtr(ctxt), cx, cy, r, a0, a1, dir);
}

pub fn rect(ctxt: anytype, x: f32, y: f32, w: f32, h: f32) void {
    goofy.bindings.api.NanoVG_nvgRect(getNVGCtxtCppPtr(ctxt), x, y, w, h);
}

pub fn roundedRect(ctxt: anytype, x: f32, y: f32, w: f32, h: f32, r: f32) void {
    goofy.bindings.api.NanoVG_nvgRoundedRect(getNVGCtxtCppPtr(ctxt), x, y, w, h, r);
}

pub fn roundedRectVarying(
    ctxt: UIRenderContext,
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    radTopLeft: f32,
    radTopRight: f32,
    radBottomRight: f32,
    radBottomLeft: f32,
) void {
    goofy.bindings.api.NanoVG_nvgRoundedRectVarying(
        getNVGCtxtCppPtr(ctxt),
        x,
        y,
        w,
        h,
        radTopLeft,
        radTopRight,
        radBottomRight,
        radBottomLeft,
    );
}

pub fn ellipse(ctxt: anytype, cx: f32, cy: f32, rx: f32, ry: f32) void {
    goofy.bindings.api.NanoVG_nvgEllipse(getNVGCtxtCppPtr(ctxt), cx, cy, rx, ry);
}

pub fn circle(ctxt: anytype, cx: f32, cy: f32, r: f32) void {
    goofy.bindings.api.NanoVG_nvgCircle(getNVGCtxtCppPtr(ctxt), cx, cy, r);
}

pub fn fill(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgFill(getNVGCtxtCppPtr(ctxt));
}

pub fn stroke(ctxt: anytype) void {
    goofy.bindings.api.NanoVG_nvgStroke(getNVGCtxtCppPtr(ctxt));
}

// Text:

pub fn findFont(ctxt: anytype, name: []const u8) i32 {
    const interopName = basis.string.toInteropString(name);
    return goofy.bindings.api.NanoVG_nvgFindFont(getNVGCtxtCppPtr(ctxt), &interopName);
}

pub fn fontSize(ctxt: anytype, size: f32) void {
    goofy.bindings.api.NanoVG_nvgFontSize(getNVGCtxtCppPtr(ctxt), size);
}

pub fn fontBlur(ctxt: anytype, blur: f32) void {
    goofy.bindings.api.NanoVG_nvgFontBlur(getNVGCtxtCppPtr(ctxt), blur);
}

pub fn textLetterSpacing(ctxt: anytype, spacing: f32) void {
    goofy.bindings.api.NanoVG_nvgTextLetterSpacing(getNVGCtxtCppPtr(ctxt), spacing);
}

pub fn textLineHeight(ctxt: anytype, lineHeight: f32) void {
    goofy.bindings.api.NanoVG_nvgTextLineHeight(getNVGCtxtCppPtr(ctxt), lineHeight);
}

pub fn textAlign(ctxt: anytype, a: i32) void {
    goofy.bindings.api.NanoVG_nvgTextAlign(getNVGCtxtCppPtr(ctxt), a);
}

pub fn fontFaceId(ctxt: anytype, font: i32) void {
    goofy.bindings.api.NanoVG_nvgFontFaceId(getNVGCtxtCppPtr(ctxt), font);
}

pub fn fontFace(ctxt: anytype, name: []const u8) void {
    const interopName = basis.string.toInteropString(name);
    goofy.bindings.api.NanoVG_nvgFontFace(getNVGCtxtCppPtr(ctxt), &interopName);
}

pub fn text(ctxt: anytype, x: f32, y: f32, string: []const u8) f32 {
    const interopString = basis.string.toInteropString(string);
    return goofy.bindings.api.NanoVG_nvgText(getNVGCtxtCppPtr(ctxt), x, y, &interopString);
}

pub fn textBox(ctxt: anytype, x: f32, y: f32, breakRowWidth: f32, string: []const u8) void {
    const interopString = basis.string.toInteropString(string);
    return goofy.bindings.api.NanoVG_nvgTextBox(getNVGCtxtCppPtr(ctxt), x, y, breakRowWidth, &interopString);
}

pub fn textBounds(ctxt: anytype, x: f32, y: f32, string: []const u8, bounds: []f32) f32 {
    const interopString = basis.string.toInteropString(string);
    var tempBounds: [4]f32 = undefined;
    const horizAdvance = goofy.bindings.api.NanoVG_nvgTextBounds(
        getNVGCtxtCppPtr(ctxt),
        x,
        y,
        &interopString,
        &tempBounds,
    );

    for (0..4) |i| {
        bounds[i] = tempBounds[i];
    }

    return horizAdvance;
}

pub fn textMetrics(ctxt: anytype, ascender: ?*f32, descender: ?*f32, lineh: ?*f32) void {
    var tempAscender: f32 = 0.0;
    var tempDescender: f32 = 0.0;
    var tempLineh: f32 = 0.0;

    goofy.bindings.api.NanoVG_nvgTextMetrics(getNVGCtxtCppPtr(ctxt), &tempAscender, &tempDescender, &tempLineh);

    if (ascender) |ptr| {
        ptr.* = tempAscender;
    }

    if (descender) |ptr| {
        ptr.* = tempDescender;
    }

    if (lineh) |ptr| {
        ptr.* = tempLineh;
    }
}

pub fn textSubset(ctxt: anytype, x: f32, y: f32, string: []const u8, charStart: i32, charCount: i32) f32 {
    const interopString = basis.string.toInteropString(string);
    return goofy.bindings.api.NanoVG_nvgTextSubset(getNVGCtxtCppPtr(ctxt), x, y, &interopString, charStart, charCount);
}

pub fn textBoxSubset(ctxt: anytype, x: f32, y: f32, breakRowWidth: f32, string: []const u8, charStart: i32, charCount: i32) void {
    const interopString = basis.string.toInteropString(string);
    return goofy.bindings.api.NanoVG_nvgTextBoxSubset(getNVGCtxtCppPtr(ctxt), x, y, breakRowWidth, &interopString, charStart, charCount);
}

pub fn nvgTextCountRows(ctxt: anytype, string: []const u8, breakRowWidth: f32) usize {
    const interopString = basis.string.toInteropString(string);
    const rowCount = goofy.bindings.api.NanoVG_nvgTextCountRows(getNVGCtxtCppPtr(ctxt), &interopString, breakRowWidth);
    return @intCast(rowCount);
}

pub fn createImageFromTextureResource(ctxt: anytype, textureResource: basis.resources.TextureResourcePtr, imageFlags: i32) i32 {
    return goofy.bindings.api.NanoVG_nvgCreateImageFromTextureResource(getNVGCtxtCppPtr(ctxt), textureResource.cppPtr, imageFlags);
}

pub fn nvgImageSize(ctxt: anytype, image: i32, w: *i32, h: *i32) void {
    goofy.bindings.api.NanoVG_nvgImageSize(getNVGCtxtCppPtr(ctxt), image, w, h);
}

pub fn deleteImage(ctxt: anytype, image: i32) void {
    goofy.bindings.api.NanoVG_nvgDeleteImage(getNVGCtxtCppPtr(ctxt), image);
}

pub fn nvgSetIGNAmount(ctxt: anytype, amount: f32) f32 {
    return goofy.bindings.api.NanoVG_nvgSetIGNAmount(getNVGCtxtCppPtr(ctxt), amount);
}

//----------------------------------------------------

fn getNVGCtxtCppPtr(context: anytype) basis.CppPtr {
    return switch (@TypeOf(context)) {
        UIRenderContext => context.nvgCtxtCppPtr,
        else => context,
    };
}
