// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");

pub const library_api = @import("library_api.zig");
pub const bindings = @import("bindings.zig");
pub const manager = @import("manager.zig");
pub const view = @import("view.zig");
pub const render_context = @import("render_context.zig");
pub const nvg = @import("nvg.zig");
pub const nvg_transform = @import("nvg_transform.zig");
pub const skin = @import("skin.zig");
pub const svg_image = @import("svg_image.zig");
pub const svg_animation_player = @import("svg_animation_player.zig");

pub const widget = @import("widget.zig");
pub const button = @import("button.zig");
pub const canvas = @import("canvas.zig");
pub const imagebox = @import("imagebox.zig");
pub const label = @import("label.zig");
pub const spin_box = @import("spin_box.zig");
pub const user_widget = @import("user_widget.zig");
pub const paint = @import("paint.zig");

// Enums:

pub const UIFitMode = enum(u32) {
    Fill = 0, // The UI will fill the entire screen, getting stretched if needed.
    Contain, // The UI will maintain its aspect ratio and will be scaled to fit inside the screen.
    //Cover, // The UI will maintain its aspect ratio and will be clipped if needed.
};

pub const UIPositionType = enum(u32) {
    Unknown = 0,
    Absolute,
    Relative,
};

pub const UIWidgetType = enum(u32) {
    Unknown = 0,
    Button,
    Rectangle,
    Label,
    Canvas,
    ImageBox,
    VerticalStack,
    VideoPlayer,
    SpinBox,
    UserWidget,
};

pub const UINavDirection = enum(u32) {
    Up = 0,
    Down,
    Left,
    Right,

    Count,
};

pub const UIWidgetStateFlags = enum(u32) {
    None = 0,
    Focused = (1 << 0),
    Pressed = (1 << 1),
    Pressed2 = (1 << 2), // Eg. for widgets that have multiple buttons.
    Disabled = (1 << 3),

    pub fn asInt(self: UIWidgetStateFlags) u32 {
        return @intFromEnum(self);
    }
};

pub const UIEvent = enum(u32) {
    None = 0,
    FocusMoved,
    FocusMovedByUserInput,
    ButtonClicked,
    UILanguageChanged,

    // Nav dir events are only raised if setRaiseNavDirEvents(true) has been called on the UI view.
    NavDir, // Dir = event args int0

    // Mouse events are only raised if setRaiseMouseEvents(true) has been called on the UI view.
    MouseMoved, // x = event args float0, y = event args float1
    MousePressed, // button = event args int0, x = event args float0, y = event args float1
    MouseReleased, // button = event args int0, x = event args float0, y = event args float1
    MouseWheelMoved, // amount = event args float0

    // More...

    Count,
};

pub const UIEventArgs = struct {
    float0: f32,
    float1: f32,
    int0: i32,
    int1: i32,

    pub const Empty = UIEventArgs{ .float0 = 0.0, .float1 = 0.0, .int0 = 0, .int1 = 0 };
};

pub const UIPivot = enum(u32) {
    UpLeft = 0,
    UpRight,
    UpCenter,
    DownLeft,
    DownRight,
    DownCenter,
    CenterLeft,
    CenterRight,
    Center,
};

// Keep in sync with C++!
pub const LanguageID = enum(i32) {
    English = 0,
    French = 1,
    Italian = 2,
    German = 3,
    Spanish = 4,
    Swedish = 5,
};

// Types:

pub const UIWidgetPtr = widget.UIWidgetPtr;
pub const UIButtonPtr = button.UIButtonPtr;
pub const UICanvasPtr = canvas.UICanvasPtr;
pub const UIImageBoxPtr = imagebox.UIImageBoxPtr;
pub const UILabelPtr = label.UILabelPtr;
pub const UISpinBoxPtr = spin_box.UISpinBoxPtr;
pub const UIUserWidgetPtr = user_widget.UIUserWidgetPtr;

pub const UIViewPtr = view.UIViewPtr;
pub const UIRenderContext = render_context.UIRenderContext;

pub const SVGAnimationPlayerPtr = svg_animation_player.SVGAnimationPlayerPtr;
pub const SVGImagePtr = svg_image.SVGImagePtr;

pub const Paint = paint.Paint;

pub const FontHandle = i32;

// Initialization and deinitialization:

pub fn init(allocator: std.mem.Allocator) void {
    canvas.initCallbackMap(allocator);
    view.initCallbackMap(allocator);
    user_widget.initCallbackMap(allocator);
}

pub fn deinit() void {
    canvas.deinitCallbackMap();
    view.deinitCallbackMap();
    user_widget.deinitCallbackMap();
}

// Misc:

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = library_api;
    _ = bindings.generated_bind_functions;
}

pub fn forceAnalysis() void {
    const modules = .{
        library_api,
        bindings,
        manager,
        view,
        render_context,
        nvg,
        nvg_transform,
        skin,
        svg_image,
        svg_animation_player,
        widget,
        button,
        canvas,
        imagebox,
        label,
        spin_box,
        user_widget,
        paint,
    };

    inline for (modules) |module| {
        std.testing.refAllDeclsRecursive(module);
    }
}
