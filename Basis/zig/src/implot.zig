// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const ImAxis = enum(i32) {
    // horizontal axes
    X1 = 0, // enabled by default
    X2, // disabled by default
    X3, // disabled by default
    // vertical axes
    Y1, // enabled by default
    Y2, // disabled by default
    Y3, // disabled by default
    // bookkeeping
    COUNT,

    pub fn asInt(self: ImAxis) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotFlags = enum(i32) {
    None = 0, // default
    NoTitle = 1 << 0, // the plot title will not be displayed (titles are also hidden if preceded by double hashes, e.g. "##MyPlot")
    NoLegend = 1 << 1, // the legend will not be displayed
    NoMouseText = 1 << 2, // the mouse position, in plot coordinates, will not be displayed inside of the plot
    NoInputs = 1 << 3, // the user will not be able to interact with the plot
    NoMenus = 1 << 4, // the user will not be able to open context menus
    NoBoxSelect = 1 << 5, // the user will not be able to box-select
    NoFrame = 1 << 6, // the ImGui frame will not be rendered
    Equal = 1 << 7, // x and y axes pairs will be constrained to have the same units/pixel
    Crosshairs = 1 << 8, // the default mouse cursor will be replaced with a crosshair when hovered
    CanvasOnly = (1 << 0) | (1 << 1) | (1 << 4) | (1 << 5) | (1 << 2), // ImPlotFlags_NoTitle | ImPlotFlags_NoLegend | ImPlotFlags_NoMenus | ImPlotFlags_NoBoxSelect | ImPlotFlags_NoMouseText

    pub fn asInt(self: ImPlotFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotAxisFlags = enum(i32) {
    None = 0, // default
    NoLabel = 1 << 0, // the axis label will not be displayed (axis labels are also hidden if the supplied string name is nullptr)
    NoGridLines = 1 << 1, // no grid lines will be displayed
    NoTickMarks = 1 << 2, // no tick marks will be displayed
    NoTickLabels = 1 << 3, // no text labels will be displayed
    NoInitialFit = 1 << 4, // axis will not be initially fit to data extents on the first rendered frame
    NoMenus = 1 << 5, // the user will not be able to open context menus with right-click
    NoSideSwitch = 1 << 6, // the user will not be able to switch the axis side by dragging it
    NoHighlight = 1 << 7, // the axis will not have its background highlighted when hovered or held
    Opposite = 1 << 8, // axis ticks and labels will be rendered on the conventionally opposite side (i.e, right or top)
    Foreground = 1 << 9, // grid lines will be displayed in the foreground (i.e. on top of data) instead of the background
    Invert = 1 << 10, // the axis will be inverted
    AutoFit = 1 << 11, // axis will be auto-fitting to data extents
    RangeFit = 1 << 12, // axis will only fit points if the point is in the visible range of the **orthogonal** axis
    PanStretch = 1 << 13, // panning in a locked or constrained state will cause the axis to stretch if possible
    LockMin = 1 << 14, // the axis minimum value will be locked when panning/zooming
    LockMax = 1 << 15, // the axis maximum value will be locked when panning/zooming
    Lock = (1 << 14) | (1 << 15), //ImPlotAxisFlags_LockMin | ImPlotAxisFlags_LockMax,
    NoDecorations = (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3), //ImPlotAxisFlags_NoLabel | ImPlotAxisFlags_NoGridLines | ImPlotAxisFlags_NoTickMarks | ImPlotAxisFlags_NoTickLabels,
    AuxDefault = (1 << 1) | (1 << 8), //ImPlotAxisFlags_NoGridLines | ImPlotAxisFlags_Opposite,

    pub fn asInt(self: ImPlotAxisFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotMarker = enum(i32) {
    None = -2, // no marker
    Auto = -1, // automatic marker selection
    Circle = 0, // a circle marker (default)
    Square, // a square maker
    Diamond, // a diamond marker
    Up, // an upward-pointing triangle marker
    Down, // an downward-pointing triangle marker
    Left, // an leftward-pointing triangle marker
    Right, // an rightward-pointing triangle marker
    Cross, // a cross marker (not fill-able)
    Plus, // a plus marker (not fill-able)
    Asterisk, // a asterisk marker (not fill-able)
    COUNT,

    pub fn asInt(self: ImPlotMarker) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotItemFlags = enum(i32) {
    None = 0,
    NoLegend = 1 << 0, // the item won't have a legend entry displayed
    NoFit = 1 << 1, // the item won't be considered for plot fits

    pub fn asInt(self: ImPlotItemFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotDragToolFlags = enum(i32) {
    None = 0, // default
    NoCursors = 1 << 0, // drag tools won't change cursor icons when hovered or held
    NoFit = 1 << 1, // the drag tool won't be considered for plot fits
    NoInputs = 1 << 2, // lock the tool from user inputs
    Delayed = 1 << 3, // tool rendering will be delayed one frame; useful when applying position-constraints

    pub fn asInt(self: ImPlotDragToolFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotLocation = enum(i32) {
    Center = 0, // center-center
    North = 1 << 0, // top-center
    South = 1 << 1, // bottom-center
    West = 1 << 2, // center-left
    East = 1 << 3, // center-right
    NorthWest = (1 << 0) | (1 << 2), // top-left
    NorthEast = (1 << 0) | (1 << 3), // top-right
    SouthWest = (1 << 1) | (1 << 2), // bottom-left
    SouthEast = (1 << 1) | (1 << 3), // bottom-right

    pub fn asInt(self: ImPlotLocation) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotCond = enum(i32) {
    None = 0, // No condition (always set the variable), same as _Always
    Always = (1 << 0), // No condition (always set the variable)
    Once = (1 << 1), // Set the variable once per runtime session (only the first call will succeed)

    pub fn asInt(self: ImPlotCond) i32 {
        return @intFromEnum(self);
    }
};

pub const ImPlotLegendFlags = enum(i32) {
    None = 0, // default
    NoButtons = 1 << 0, // legend icons will not function as hide/show buttons
    NoHighlightItem = 1 << 1, // plot items will not be highlighted when their legend entry is hovered
    NoHighlightAxis = 1 << 2, // axes will not be highlighted when legend entries are hovered (only relevant if x/y-axis count > 1)
    NoMenus = 1 << 3, // the user will not be able to open context menus with right-click
    Outside = 1 << 4, // legend will be rendered outside of the plot area
    Horizontal = 1 << 5, // legend entries will be displayed horizontally
    Sort = 1 << 6, // legend entries will be displayed in alphabetical order
    Reverse = 1 << 7, // legend entries will be displayed in reverse order

    pub fn asInt(self: ImPlotLegendFlags) i32 {
        return @intFromEnum(self);
    }
};

//----------------------------------------------------

pub const AutoColor = basis.Color.Transparent;
pub const ImPlotAuto = -1;

//----------------------------------------------------

pub const ImPlotSpec = struct {
    lineColor: basis.Color = AutoColor, // line color (applies to lines, bar edges); IMPLOT_AUTO_COL will use next Colormap color or current item color
    lineWeight: f32 = 1.0, // line weight in pixels (applies to lines, bar edges, marker edges)
    fillColor: basis.Color = AutoColor, // fill color (applies to shaded regions, bar faces); IMPLOT_AUTO_COL will use next Colormap color or current item color
    fillAlpha: f32 = 1.0, // alpha multiplier (applies to FillColor and MarkerFillColor)
    marker: ImPlotMarker = .None, // marker type; specify ImPlotMarker_Auto to use the next unused marker
    markerSize: f32 = 4.0, // size of markers (radius) *in pixels*
    markerLineColor: basis.Color = AutoColor, // marker edge color; IMPLOT_AUTO_COL will use LineColor
    markerFillColor: basis.Color = AutoColor, // marker face color; IMPLOT_AUTO_COL will use LineColor
    size: f32 = 4.0, // size of error bar whiskers (width or height), and digital bars (height) *in pixels*
    offset: i32 = 0, // data index offset
    stride: i32 = ImPlotAuto, // data stride in bytes; ImPlotAuto will result in sizeof(T) where T is the type passed to PlotX
    flags: ImPlotItemFlags = .None, // optional item flags; can be composed from common ImPlotItemFlags and/or specialized ImPlotXFlags

    pub fn serialize(self: ImPlotSpec, stream: *basis.BinaryWriteStream) void {
        stream.put(basis.Color, self.lineColor);
        stream.putFloat(self.lineWeight);
        stream.put(basis.Color, self.fillColor);
        stream.putFloat(self.fillAlpha);
        stream.putInt(i32, self.marker.asInt());
        stream.putFloat(self.markerSize);
        stream.put(basis.Color, self.markerLineColor);
        stream.put(basis.Color, self.markerFillColor);
        stream.putFloat(self.size);
        stream.putInt(i32, self.offset);
        stream.putInt(i32, self.stride);
        stream.putInt(i32, self.flags.asInt());
    }
};

//----------------------------------------------------

pub fn beginPlot(title_id: []const u8, size: basis.math.Vec2, flags: i32) bool {
    const interopTitle = basis.string.toInteropString(title_id);
    const interopSize = basis.math.Vec2.toInterop(size);
    return basis.bindings.api.ImPlot_beginPlot(&interopTitle, &interopSize, flags) == 1;
}

pub fn endPlot() void {
    basis.bindings.api.ImPlot_endPlot();
}

pub fn setupAxis(axis: ImAxis, label: []const u8, flags: i32) void {
    const interopLabel = basis.string.toInteropString(label);
    basis.bindings.api.ImPlot_setupAxis(axis.asInt(), &interopLabel, flags);
}

pub fn setupAxisLimits(axis: ImAxis, v_min: f32, v_max: f32, cond: ImPlotCond) void {
    basis.bindings.api.ImPlot_setupAxisLimits(axis.asInt(), v_min, v_max, cond.asInt());
}

pub fn setupLegend(location: ImPlotLocation, flags: i32) void {
    basis.bindings.api.ImPlot_setupLegend(location.asInt(), flags);
}

pub fn plotLine(label_id: []const u8, xs: []const f32, ys: []const f32) void {
    const interopLabel = basis.string.toInteropString(label_id);
    basis.assert(@src(), xs.len == ys.len);
    basis.bindings.api.ImPlot_plotLine(&interopLabel, xs.ptr, ys.ptr, @intCast(xs.len));
}

pub fn plotLineEx(label_id: []const u8, xs: []const f32, ys: []const f32, spec: ImPlotSpec) void {
    var specDataBuffer: [128]u8 = undefined;
    var stream = basis.BinaryWriteStream.init(&specDataBuffer, true);
    stream.put(ImPlotSpec, spec);

    const interopLabel = basis.string.toInteropString(label_id);
    basis.assert(@src(), xs.len == ys.len);
    basis.bindings.api.ImPlot_plotLineEx(&interopLabel, xs.ptr, ys.ptr, @intCast(xs.len), &specDataBuffer[0], @intCast(stream.cursorPosition));
}

pub fn plotScatter(label_id: []const u8, xs: []const f32, ys: []const f32) void {
    const interopLabel = basis.string.toInteropString(label_id);
    basis.assert(@src(), xs.len == ys.len);
    basis.bindings.api.ImPlot_plotScatter(&interopLabel, xs.ptr, ys.ptr, @intCast(xs.len));
}

pub fn plotScatterEx(label_id: []const u8, xs: []const f32, ys: []const f32, spec: ImPlotSpec) void {
    var specDataBuffer: [128]u8 = undefined;
    var stream = basis.BinaryWriteStream.init(&specDataBuffer, true);
    stream.put(ImPlotSpec, spec);

    const interopLabel = basis.string.toInteropString(label_id);
    basis.assert(@src(), xs.len == ys.len);
    basis.bindings.api.ImPlot_plotScatterEx(&interopLabel, xs.ptr, ys.ptr, @intCast(xs.len), &specDataBuffer[0], @intCast(stream.cursorPosition));
}

pub fn dragPoint(id: i32, x: *f64, y: *f64, col: basis.Color, size: f32, flags: i32, out_clicked: *bool, out_hovered: *bool, out_held: *bool) bool {
    const interopColor = basis.Color.toInterop(col);
    return basis.bindings.api.ImPlot_dragPoint(id, x, y, &interopColor, size, flags, out_clicked, out_hovered, out_held) == 1;
}
