// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const UIRenderContext = struct {
    const Self = @This();
    nvgCtxtCppPtr: basis.CppPtr,
    screenWidth: f32,
    screenHeight: f32,
    pixelRect: basis.math.AABB2D,
    aspect_ratio: f32,

    pub fn init(
        nvgCtxtCppPtr: basis.CppPtr,
        screenWidth: f32,
        screenHeight: f32,
        pixelRect: basis.math.AABB2D,
    ) UIRenderContext {
        return UIRenderContext{
            .nvgCtxtCppPtr = nvgCtxtCppPtr,
            .screenWidth = screenWidth,
            .screenHeight = screenHeight,
            .pixelRect = pixelRect,
            .aspect_ratio = pixelRect.getXSize() / pixelRect.getYSize(),
        };
    }

    pub fn getPixelPosFromUIPos(self: *const Self, uiPos: basis.math.Vec2) basis.math.Vec2 {
        const x = basis.math.lerp(uiPos.x, self.pixelRect.min.x, self.pixelRect.max.x);
        const y = basis.math.lerp(uiPos.y, self.pixelRect.min.y, self.pixelRect.max.y);
        return basis.math.Vec2.init(x, y);
    }

    pub fn getPixelSizeXFromUISize(self: *const Self, uiSize: f32) f32 {
        return self.pixelRect.getXSize() * uiSize;
    }

    pub fn getPixelSizeYFromUISize(self: *const Self, uiSize: f32) f32 {
        return self.pixelRect.getYSize() * uiSize;
    }

    pub fn getPixelSizeFromUISizeVec2(self: *const Self, uiSize: basis.math.Vec2) basis.math.Vec2 {
        const x = basis.math.lerp(uiSize.x, 0.0, self.pixelRect.getXSize());
        const y = basis.math.lerp(uiSize.y, 0.0, self.pixelRect.getYSize());
        return basis.math.Vec2.init(x, y);
    }

    pub fn toInterop(self: *const Self) goofy.bindings.InteropUIRenderContext {
        return goofy.bindings.InteropUIRenderContext{
            .nvgCppCtxt = self.nvgCtxtCppPtr,
            .screenWidth = self.screenWidth,
            .screenHeight = self.screenHeight,
            .pixelRectMinX = self.pixelRect.min.x,
            .pixelRectMinY = self.pixelRect.min.y,
            .pixelRectMaxX = self.pixelRect.max.x,
            .pixelRectMaxY = self.pixelRect.max.y,
        };
    }

    pub fn fromInterop(interop: *const goofy.bindings.InteropUIRenderContext) Self {
        const pixelRect = basis.math.AABB2D.init(
            interop.pixelRectMinX,
            interop.pixelRectMinY,
            interop.pixelRectMaxX,
            interop.pixelRectMaxY,
        );

        return Self.init(
            interop.nvgCppCtxt,
            interop.screenWidth,
            interop.screenHeight,
            pixelRect,
        );
    }
};
