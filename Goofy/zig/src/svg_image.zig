// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const goofy = @import("goofy.zig");

pub const SVGImagePtr = struct {
    const Self = @This();
    pub const Null = initNull();

    cppPtr: basis.CppPtr,
    ownsMemory: bool,

    pub fn initNull() Self {
        return Self{
            .cppPtr = 0,
            .ownsMemory = false,
        };
    }

    pub fn initNew() Self {
        return Self{
            .cppPtr = goofy.bindings.api.GoofySVGImage_newImage(),
            .ownsMemory = true,
        };
    }

    pub fn initFromCppPtr(cppPtr: basis.CppPtr) Self {
        return Self{
            .cppPtr = cppPtr,
            .ownsMemory = false,
        };
    }

    pub fn deinit(self: *Self) void {
        if (self.ownsMemory) {
            goofy.bindings.api.GoofySVGImage_deleteImage(self.cppPtr);
        }

        self.cppPtr = 0;
        self.ownsMemory = false;
    }

    pub fn isNull(self: *const Self) bool {
        return (self.cppPtr == 0);
    }

    //----------------------------------------------------

    pub fn getWidth(self: *const Self) f32 {
        return goofy.bindings.api.GoofySVGImage_getWidth(self.cppPtr);
    }

    pub fn getHeight(self: *const Self) f32 {
        return goofy.bindings.api.GoofySVGImage_getHeight(self.cppPtr);
    }

    pub fn loadImage(self: *const Self, dataFile: basis.resources.RawDataFilePtr) void {
        goofy.bindings.api.GoofySVGImage_loadImage(self.cppPtr, dataFile.cppPtr);
    }

    pub fn render(self: *const Self, ctxt: goofy.UIRenderContext, rect: basis.math.AABB2D) void {
        const interopCtxt = ctxt.toInterop();
        const rectMin = rect.min.toInterop();
        const rectMax = rect.max.toInterop();

        goofy.bindings.api.GoofySVGImage_render(self.cppPtr, &interopCtxt, &rectMin, &rectMax);
    }

    pub fn renderUnstretched(self: *const Self, ctxt: goofy.UIRenderContext, position: basis.math.Vec2, width: f32, pivot: goofy.UIPivot) void {
        const interopCtxt = ctxt.toInterop();
        const interopPos = position.toInterop();

        goofy.bindings.api.GoofySVGImage_renderUnstretched(self.cppPtr, &interopCtxt, &interopPos, width, @intFromEnum(pivot));
    }

    pub fn renderInPixelRect(self: *const Self, ctxt: goofy.UIRenderContext, pixelRect: basis.math.AABB2D) void {
        const interopCtxt = ctxt.toInterop();
        const rectMin = pixelRect.min.toInterop();
        const rectMax = pixelRect.max.toInterop();

        goofy.bindings.api.GoofySVGImage_renderInPixelRect(self.cppPtr, &interopCtxt, &rectMin, &rectMax);
    }
};
