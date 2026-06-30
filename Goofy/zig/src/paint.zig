// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const goofy = @import("goofy.zig");
const basis = @import("basis");

pub const Paint = struct {
    const Self = @This();

    xform: [6]f32 = @splat(0.0),
    extent: [2]f32 = @splat(0.0),
    radius: f32 = 0.0,
    feather: f32 = 0.0,
    innerColor: [4]f32 = @splat(0.0),
    outerColor: [4]f32 = @splat(0.0),
    image: i32 = 0,

    //----------------------------------------------------

    pub fn initLinearGradient(sx: f32, sy: f32, ex: f32, ey: f32, icol: basis.Color, ocol: basis.Color) Self {
        // This is a Zig port of the C-function nvgLinearGradient(). The NanoVG context
        // parameter in the C-version isn't used, so we don't include it here.

        var p: Self = .{};

        const Large = 1e5;

        // Calculate transform aligned to the line
        var dx = ex - sx;
        var dy = ey - sy;
        const d = @sqrt(dx * dx + dy * dy);
        if (d > 0.0001) {
            dx /= d;
            dy /= d;
        } else {
            dx = 0.0;
            dy = 1.0;
        }

        p.xform[0] = dy;
        p.xform[1] = -dx;
        p.xform[2] = dx;
        p.xform[3] = dy;
        p.xform[4] = sx - dx * Large;
        p.xform[5] = sy - dy * Large;

        p.extent[0] = Large;
        p.extent[1] = Large + d * 0.5;

        p.radius = 0.0;

        p.feather = @max(1.0, d);

        icol.toFloatArray(&p.innerColor);
        ocol.toFloatArray(&p.outerColor);

        return p;
    }

    pub fn initRadialGradient(cx: f32, cy: f32, inr: f32, outr: f32, icol: basis.Color, ocol: basis.Color) Self {
        // This is a Zig port of the C-function nvgRadialGradient(). The NanoVG context
        // parameter in the C-version isn't used, so we don't include it here.

        var p: Self = .{};

        const r = (inr + outr) * 0.5;
        const f = (outr - inr);

        goofy.nvg_transform.transformIdentity(&p.xform);
        p.xform[4] = cx;
        p.xform[5] = cy;

        p.extent[0] = r;
        p.extent[1] = r;

        p.radius = r;

        p.feather = @max(1.0, f);

        icol.toFloatArray(&p.innerColor);
        ocol.toFloatArray(&p.outerColor);

        return p;
    }

    pub fn initBoxGradient(x: f32, y: f32, w: f32, h: f32, r: f32, f: f32, icol: basis.Color, ocol: basis.Color) Self {
        // This is a Zig port of the C-function nvgBoxGradient(). The NanoVG context
        // parameter in the C-version isn't used, so we don't include it here.

        var p: Self = .{};

        goofy.nvg_transform.transformIdentity(&p.xform);
        p.xform[4] = x + w * 0.5;
        p.xform[5] = y + h * 0.5;

        p.extent[0] = w * 0.5;
        p.extent[1] = h * 0.5;

        p.radius = r;

        p.feather = @max(1.0, f);

        icol.toFloatArray(&p.innerColor);
        ocol.toFloatArray(&p.outerColor);

        return p;
    }

    pub fn initImagePattern(ox: f32, oy: f32, ex: f32, ey: f32, angle: f32, image: i32, alpha: f32) Self {
        // This is a Zig port of the C-function nvgImagePattern(). The NanoVG context
        // parameter in the C-version isn't used, so we don't include it here.

        var p: Self = .{};

        goofy.nvg_transform.transformRotate(&p.xform, angle);
        p.xform[4] = ox;
        p.xform[5] = oy;

        p.extent[0] = ex;
        p.extent[1] = ey;

        p.image = image;

        p.innerColor[0] = 1.0;
        p.innerColor[1] = 1.0;
        p.innerColor[2] = 1.0;
        p.innerColor[3] = alpha;

        p.outerColor[0] = 1.0;
        p.outerColor[1] = 1.0;
        p.outerColor[2] = 1.0;
        p.outerColor[3] = alpha;

        return p;
    }

    //----------------------------------------------------

    pub fn toInterop(self: *const Self) goofy.bindings.InteropPaint {
        return goofy.bindings.InteropPaint{
            .xform = self.xform,
            .extent = self.extent,
            .radius = self.radius,
            .feather = self.feather,
            .innerColor = self.innerColor,
            .outerColor = self.outerColor,
            .image = self.image,
        };
    }

    pub fn fromInterop(interop: *const goofy.bindings.InteropPaint) Self {
        return Self{
            .xform = interop.xform,
            .extent = interop.extent,
            .radius = interop.radius,
            .feather = interop.feather,
            .innerColor = interop.innerColor,
            .outerColor = interop.outerColor,
            .image = interop.image,
        };
    }
};
