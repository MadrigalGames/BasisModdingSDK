// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

// MouseButtonLeft and MouseButtonDefault_ commented out since Zig doesn't like multiple tags using the same value.
pub const ImGuiPopupFlags = enum(i32) {
    None = 0,
    //MouseButtonLeft = 0, // For BeginPopupContext*(): open on Left Mouse release. Guaranteed to always be == 0 (same as ImGuiMouseButton_Left)
    MouseButtonRight = 1, // For BeginPopupContext*(): open on Right Mouse release. Guaranteed to always be == 1 (same as ImGuiMouseButton_Right)
    MouseButtonMiddle = 2, // For BeginPopupContext*(): open on Middle Mouse release. Guaranteed to always be == 2 (same as ImGuiMouseButton_Middle)
    MouseButtonMask_ = 0x1F,
    //MouseButtonDefault_ = 1,
    NoReopen = 1 << 5, // For OpenPopup*(), BeginPopupContext*(): don't reopen same popup if already open (won't reposition, won't reinitialize navigation)
    //NoReopenAlwaysNavInit = 1 << 6, // For OpenPopup*(), BeginPopupContext*(): focus and initialize navigation even when not reopening.
    NoOpenOverExistingPopup = 1 << 7, // For OpenPopup*(), BeginPopupContext*(): don't open if there's already a popup at the same level of the popup stack
    NoOpenOverItems = 1 << 8, // For BeginPopupContextWindow(): don't return true when hovering items, only when hovering empty space
    AnyPopupId = 1 << 10, // For IsPopupOpen(): ignore the ImGuiID parameter and test for any popup.
    AnyPopupLevel = 1 << 11, // For IsPopupOpen(): search/test at any level of the popup stack (default test in the current level)

    AnyPopup = (1 << 10) | (1 << 11), //ImGuiPopupFlags_AnyPopupId | ImGuiPopupFlags_AnyPopupLevel,

    pub fn asInt(self: ImGuiPopupFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImGuiWindowFlags = enum(i32) {
    None = 0,
    NoTitleBar = 1 << 0, // Disable title-bar
    NoResize = 1 << 1, // Disable user resizing with the lower-right grip
    NoMove = 1 << 2, // Disable user moving the window
    NoScrollbar = 1 << 3, // Disable scrollbars (window can still scroll with mouse or programmatically)
    NoScrollWithMouse = 1 << 4, // Disable user vertically scrolling with mouse wheel. On child window, mouse wheel will be forwarded to the parent unless NoScrollbar is also set.
    NoCollapse = 1 << 5, // Disable user collapsing window by double-clicking on it. Also referred to as Window Menu Button (e.g. within a docking node).
    AlwaysAutoResize = 1 << 6, // Resize every window to its content every frame
    NoBackground = 1 << 7, // Disable drawing background color (WindowBg, etc.) and outside border. Similar as using SetNextWindowBgAlpha(0.0f).
    NoSavedSettings = 1 << 8, // Never load/save settings in .ini file
    NoMouseInputs = 1 << 9, // Disable catching mouse, hovering test with pass through.
    MenuBar = 1 << 10, // Has a menu-bar
    HorizontalScrollbar = 1 << 11, // Allow horizontal scrollbar to appear (off by default). You may use SetNextWindowContentSize(ImVec2(width,0.0f)); prior to calling Begin() to specify width. Read code in imgui_demo in the "Horizontal Scrolling" section.
    NoFocusOnAppearing = 1 << 12, // Disable taking focus when transitioning from hidden to visible state
    NoBringToFrontOnFocus = 1 << 13, // Disable bringing window to front when taking focus (e.g. clicking on it or programmatically giving it focus)
    AlwaysVerticalScrollbar = 1 << 14, // Always show vertical scrollbar (even if ContentSize.y < Size.y)
    AlwaysHorizontalScrollbar = 1 << 15, // Always show horizontal scrollbar (even if ContentSize.x < Size.x)
    NoNavInputs = 1 << 16, // No keyboard/gamepad navigation within the window
    NoNavFocus = 1 << 17, // No focusing toward this window with keyboard/gamepad navigation (e.g. skipped by CTRL+TAB)
    UnsavedDocument = 1 << 18, // Display a dot next to the title. When used in a tab/docking context, tab is selected when clicking the X + closure is not assumed (will wait for user to stop submitting the tab). Otherwise closure is assumed when pressing the X, so if you keep submitting the tab may reappear at end of tab bar.

    NoNav = (1 << 16) | (1 << 17), //ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,
    NoDecoration = (1 << 0) | (1 << 1) | (1 << 3) | (1 << 5), //ImGuiWindowFlags_NoTitleBar | ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoScrollbar | ImGuiWindowFlags_NoCollapse,
    NoInputs = (1 << 9) | (1 << 16) | (1 << 17), //ImGuiWindowFlags_NoMouseInputs | ImGuiWindowFlags_NoNavInputs | ImGuiWindowFlags_NoNavFocus,

    pub fn asInt(self: ImGuiWindowFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImGuiTreeNodeFlags = enum(i32) {
    None = 0,
    Selected = 1 << 0, // Draw as selected
    Framed = 1 << 1, // Draw frame with background (e.g. for CollapsingHeader)
    AllowOverlap = 1 << 2, // Hit testing to allow subsequent widgets to overlap this one
    NoTreePushOnOpen = 1 << 3, // Don't do a TreePush() when open (e.g. for CollapsingHeader) = no extra indent nor pushing on ID stack
    NoAutoOpenOnLog = 1 << 4, // Don't automatically and temporarily open node when Logging is active (by default logging will automatically open tree nodes)
    DefaultOpen = 1 << 5, // Default node to be open
    OpenOnDoubleClick = 1 << 6, // Open on double-click instead of simple click (default for multi-select unless any _OpenOnXXX behavior is set explicitly). Both behaviors may be combined.
    OpenOnArrow = 1 << 7, // Open when clicking on the arrow part (default for multi-select unless any _OpenOnXXX behavior is set explicitly). Both behaviors may be combined.
    Leaf = 1 << 8, // No collapsing, no arrow (use as a convenience for leaf nodes).
    Bullet = 1 << 9, // Display a bullet instead of arrow. IMPORTANT: node can still be marked open/close if you don't set the _Leaf flag!
    FramePadding = 1 << 10, // Use FramePadding (even for an unframed text node) to vertically align text baseline to regular widget height. Equivalent to calling AlignTextToFramePadding() before the node.
    SpanAvailWidth = 1 << 11, // Extend hit box to the right-most edge, even if not framed. This is not the default in order to allow adding other items on the same line without using AllowOverlap mode.
    SpanFullWidth = 1 << 12, // Extend hit box to the left-most and right-most edges (cover the indent area).
    SpanLabelWidth = 1 << 13, // Narrow hit box + narrow hovering highlight, will only cover the label text.
    SpanAllColumns = 1 << 14, // Frame will span all columns of its container table (label will still fit in current column)
    LabelSpanAllColumns = 1 << 15, // Label will span all columns of its container table
    //NoScrollOnOpen     = 1 << 16,  // FIXME: TODO: Disable automatic scroll on TreePop() if node got just open and contents is not visible
    NavLeftJumpsBackHere = 1 << 17, // (WIP) Nav: left direction may move to this TreeNode() from any of its child (items submitted between TreeNode and TreePop)

    CollapsingHeader = (1 << 1) | (1 << 3) | (1 << 4), //ImGuiTreeNodeFlags_Framed | ImGuiTreeNodeFlags_NoTreePushOnOpen | ImGuiTreeNodeFlags_NoAutoOpenOnLog,

    pub fn asInt(self: ImGuiTreeNodeFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImGuiHoveredFlags = enum(i32) {
    None = 0, // Return true if directly over the item/window, not obstructed by another window, not obstructed by an active popup or modal blocking inputs under them.
    ChildWindows = 1 << 0, // IsWindowHovered() only: Return true if any children of the window is hovered
    RootWindow = 1 << 1, // IsWindowHovered() only: Test from root window (top most parent of the current hierarchy)
    AnyWindow = 1 << 2, // IsWindowHovered() only: Return true if any window is hovered
    NoPopupHierarchy = 1 << 3, // IsWindowHovered() only: Do not consider popup hierarchy (do not treat popup emitter as parent of popup) (when used with _ChildWindows or _RootWindow)
    //DockHierarchy = 1 << 4, // IsWindowHovered() only: Consider docking hierarchy (treat dockspace host as parent of docked window) (when used with _ChildWindows or _RootWindow)
    AllowWhenBlockedByPopup = 1 << 5, // Return true even if a popup window is normally blocking access to this item/window
    //AllowWhenBlockedByModal = 1 << 6, // Return true even if a modal popup window is normally blocking access to this item/window. FIXME-TODO: Unavailable yet.
    AllowWhenBlockedByActiveItem = 1 << 7, // Return true even if an active item is blocking access to this item/window. Useful for Drag and Drop patterns.
    AllowWhenOverlappedByItem = 1 << 8, // IsItemHovered() only: Return true even if the item uses AllowOverlap mode and is overlapped by another hoverable item.
    AllowWhenOverlappedByWindow = 1 << 9, // IsItemHovered() only: Return true even if the position is obstructed or overlapped by another window
    AllowWhenDisabled = 1 << 10, // IsItemHovered() only: Return true even if the item is disabled
    NoNavOverride = 1 << 11, // Disable using gamepad/keyboard navigation state when active, always query mouse.
    AllowWhenOverlapped = (1 << 8) | (1 << 9), // ImGuiHoveredFlags_AllowWhenOverlappedByItem | ImGuiHoveredFlags_AllowWhenOverlappedByWindow,
    RectOnly = (1 << 5) | (1 << 7) | (1 << 8) | (1 << 9), // ImGuiHoveredFlags_AllowWhenBlockedByPopup | ImGuiHoveredFlags_AllowWhenBlockedByActiveItem | ImGuiHoveredFlags_AllowWhenOverlapped,
    RootAndChildWindows = (1 << 1) | (1 << 0), // ImGuiHoveredFlags_RootWindow | ImGuiHoveredFlags_ChildWindows,

    // Tooltips mode
    ForTooltip = 1 << 12, // Shortcut for standard flags when using IsItemHovered() + SetTooltip() sequence.

    // Hovering delays (for tooltips)
    Stationary = 1 << 13, // Require mouse to be stationary for style.HoverStationaryDelay (~0.15 sec) _at least one time_. After this, can move on same item/window. Using the stationary test tends to reduces the need for a long delay.
    DelayNone = 1 << 14, // IsItemHovered() only: Return true immediately (default). As this is the default you generally ignore this.
    DelayShort = 1 << 15, // IsItemHovered() only: Return true after style.HoverDelayShort elapsed (~0.15 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item).
    DelayNormal = 1 << 16, // IsItemHovered() only: Return true after style.HoverDelayNormal elapsed (~0.40 sec) (shared between items) + requires mouse to be stationary for style.HoverStationaryDelay (once per item).
    NoSharedDelay = 1 << 17, // IsItemHovered() only: Disable shared delay system where moving from one item to the next keeps the previous timer for a short time (standard for tooltips with long delays)

    pub fn asInt(self: ImGuiHoveredFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImGuiCond = enum(i32) {
    None = 0, // No condition (always set the variable), same as _Always
    Always = 1 << 0, // No condition (always set the variable), same as _None
    Once = 1 << 1, // Set the variable once per runtime session (only the first call will succeed)
    FirstUseEver = 1 << 2, // Set the variable if the object/window has no persistently saved data (no entry in .ini file)
    Appearing = 1 << 3, // Set the variable if the object/window is appearing after being hidden/inactive (or the first time)

    pub fn asInt(self: ImGuiCond) i32 {
        return @intFromEnum(self);
    }
};

pub const ImGuiSliderFlags = enum(i32) {
    None = 0,
    Logarithmic = 1 << 5, // Make the widget logarithmic (linear otherwise). Consider using ImGuiSliderFlags_NoRoundToFormat with this if using a format-string with small amount of digits.
    NoRoundToFormat = 1 << 6, // Disable rounding underlying value to match precision of the display format string (e.g. %.3f values are rounded to those 3 digits).
    NoInput = 1 << 7, // Disable CTRL+Click or Enter key allowing to input text directly into the widget.
    WrapAround = 1 << 8, // Enable wrapping around from max to min and from min to max. Only supported by DragXXX() functions for now.
    ClampOnInput = 1 << 9, // Clamp value to min/max bounds when input manually with CTRL+Click. By default CTRL+Click allows going out of bounds.
    ClampZeroRange = 1 << 10, // Clamp even if min==max==0.0f. Otherwise due to legacy reason DragXXX functions don't clamp with those values. When your clamping limits are dynamic you almost always want to use it.
    NoSpeedTweaks = 1 << 11, // Disable keyboard modifiers altering tweak speed. Useful if you want to alter tweak speed yourself based on your own logic.
    AlwaysClamp = (1 << 9) | (1 << 10), //ImGuiSliderFlags_ClampOnInput | ImGuiSliderFlags_ClampZeroRange,
    //InvalidMask_       = 0x7000000F,   // [Internal] We treat using those bits as being potentially a 'float power' argument from the previous API that has got miscast to this enum, and will trigger an assert if needed.

    pub fn asInt(self: ImGuiSliderFlags) i32 {
        return @intFromEnum(self);
    }
};

pub const ImGuiCol = enum(i32) {
    Text,
    TextDisabled,
    WindowBg, // Background of normal windows
    ChildBg, // Background of child windows
    PopupBg, // Background of popups, menus, tooltips windows
    Border,
    BorderShadow,
    FrameBg, // Background of checkbox, radio button, plot, slider, text input
    FrameBgHovered,
    FrameBgActive,
    TitleBg, // Title bar
    TitleBgActive, // Title bar when focused
    TitleBgCollapsed, // Title bar when collapsed
    MenuBarBg,
    ScrollbarBg,
    ScrollbarGrab,
    ScrollbarGrabHovered,
    ScrollbarGrabActive,
    CheckMark, // Checkbox tick and RadioButton circle
    SliderGrab,
    SliderGrabActive,
    Button,
    ButtonHovered,
    ButtonActive,
    Header, // Header* colors are used for CollapsingHeader, TreeNode, Selectable, MenuItem
    HeaderHovered,
    HeaderActive,
    Separator,
    SeparatorHovered,
    SeparatorActive,
    ResizeGrip, // Resize grip in lower-right and lower-left corners of windows.
    ResizeGripHovered,
    ResizeGripActive,
    TabHovered, // Tab background, when hovered
    Tab, // Tab background, when tab-bar is focused & tab is unselected
    TabSelected, // Tab background, when tab-bar is focused & tab is selected
    TabSelectedOverline, // Tab horizontal overline, when tab-bar is focused & tab is selected
    TabDimmed, // Tab background, when tab-bar is unfocused & tab is unselected
    TabDimmedSelected, // Tab background, when tab-bar is unfocused & tab is selected
    TabDimmedSelectedOverline, //..horizontal overline, when tab-bar is unfocused & tab is selected
    PlotLines,
    PlotLinesHovered,
    PlotHistogram,
    PlotHistogramHovered,
    TableHeaderBg, // Table header background
    TableBorderStrong, // Table outer and header borders (prefer using Alpha=1.0 here)
    TableBorderLight, // Table inner borders (prefer using Alpha=1.0 here)
    TableRowBg, // Table row background (even rows)
    TableRowBgAlt, // Table row background (odd rows)
    TextLink, // Hyperlink color
    TextSelectedBg,
    DragDropTarget, // Rectangle highlighting a drop target
    NavCursor, // Color of keyboard/gamepad navigation cursor/rectangle, when visible
    NavWindowingHighlight, // Highlight window when using CTRL+TAB
    NavWindowingDimBg, // Darken/colorize entire screen behind the CTRL+TAB window list, when active
    ModalWindowDimBg, // Darken/colorize entire screen behind a modal window, when one is active
    COUNT,

    pub fn asInt(self: ImGuiCol) i32 {
        return @intFromEnum(self);
    }
};

pub fn begin(name: []const u8, flags: i32) bool {
    const interopName = basis.string.toInteropString(name);
    return basis.bindings.api.ImGui_begin(&interopName, flags) == 1;
}

pub fn beginEx(name: []const u8, p_open: *bool, flags: i32) bool {
    const interopName = basis.string.toInteropString(name);
    return basis.bindings.api.ImGui_beginEx(&interopName, p_open, flags) == 1;
}

pub fn end() void {
    basis.bindings.api.ImGui_end();
}

pub fn beginMenu(name: []const u8, enabled: bool) bool {
    const interopName = basis.string.toInteropString(name);
    return basis.bindings.api.ImGui_beginMenu(&interopName, if (enabled) 1 else 0) == 1;
}

pub fn endMenu() void {
    basis.bindings.api.ImGui_endMenu();
}

pub fn menuItem(label: []const u8, selected: bool, enabled: bool) bool {
    const interopLabel = basis.string.toInteropString(label);
    return basis.bindings.api.ImGui_menuItem(&interopLabel, if (selected) 1 else 0, if (enabled) 1 else 0) == 1;
}

pub fn openPopup(id: []const u8, popupFlags: ImGuiPopupFlags) void {
    const interopID = basis.string.toInteropString(id);
    const f = popupFlags.asInt();
    basis.bindings.api.ImGui_openPopup(&interopID, f);
}

pub fn beginPopup(id: []const u8, flags: ImGuiWindowFlags) bool {
    const interopID = basis.string.toInteropString(id);
    const f = flags.asInt();
    return if (basis.bindings.api.ImGui_beginPopup(&interopID, f) == 1) return true else false;
}

pub fn endPopup() void {
    basis.bindings.api.ImGui_endPopup();
}

pub fn pushStyleColor(idx: ImGuiCol, col: basis.Color) void {
    const i = idx.asInt();
    const interopColor = col.toInterop();
    basis.bindings.api.ImGui_pushStyleColor(i, &interopColor);
}

pub fn popStyleColor(count: i32) void {
    basis.bindings.api.ImGui_popStyleColor(count);
}

pub fn separator() void {
    basis.bindings.api.ImGui_separator();
}

pub fn text(txt: []const u8) void {
    const interopText = basis.string.toInteropString(txt);
    basis.bindings.api.ImGui_text(&interopText);
}

pub fn textColored(col: basis.Color, txt: []const u8) void {
    const interopColor = col.toInterop();
    const interopText = basis.string.toInteropString(txt);
    basis.bindings.api.ImGui_textColored(&interopColor, &interopText);
}

pub fn sameline() void {
    // These are the default parameter values to ImGui::SameLine().
    const offsetFromStartX = 0.0;
    const spacingW = -1.0;
    basis.bindings.api.ImGui_sameline(offsetFromStartX, spacingW);
}

pub fn collapsingHeader(label: []const u8, flags: ImGuiTreeNodeFlags) bool {
    const interopLabel = basis.string.toInteropString(label);
    const f = flags.asInt();
    return if (basis.bindings.api.ImGui_collapsingHeader(&interopLabel, f) == 1) return true else false;
}

pub fn button(label: []const u8, size: basis.math.Vec2) bool {
    const interopLabel = basis.string.toInteropString(label);
    const interopSize = size.toInterop();
    return if (basis.bindings.api.ImGui_button(&interopLabel, &interopSize) == 1) return true else false;
}

pub fn isItemHovered(flags: ImGuiHoveredFlags) bool {
    const f = flags.asInt();
    return if (basis.bindings.api.ImGui_isItemHovered(f) == 1) return true else false;
}

pub fn setTooltip(label: []const u8) void {
    const interopLabel = basis.string.toInteropString(label);
    basis.bindings.api.ImGui_setTooltip(&interopLabel);
}

pub fn endTooltip() void {
    basis.bindings.api.ImGui_endTooltip();
}

pub fn setNextWindowPos(pos: basis.math.Vec2, cond: ImGuiCond, pivot: basis.math.Vec2) void {
    const c = cond.asInt();
    const interopPos = pos.toInterop();
    const interopPivot = pivot.toInterop();
    basis.bindings.api.ImGui_setNextWindowPos(&interopPos, c, &interopPivot);
}

pub fn setNextWindowSize(size: basis.math.Vec2, cond: ImGuiCond) void {
    const c = cond.asInt();
    const interopSize = size.toInterop();
    basis.bindings.api.ImGui_setNextWindowSize(&interopSize, c);
}

pub fn setNextWindowBgAlpha(alpha: f32) void {
    basis.bindings.api.ImGui_setNextWindowBgAlpha(alpha);
}

pub fn beginListBox(label: []const u8, size: basis.math.Vec2) bool {
    const interopLabel = basis.string.toInteropString(label);
    const interopSize = size.toInterop();
    return if (basis.bindings.api.ImGui_beginListBox(&interopLabel, &interopSize) == 1) return true else false;
}

pub fn endListBox() void {
    basis.bindings.api.ImGui_endListBox();
}

pub fn radioButton(label: []const u8, v: *i32, v_button: i32) bool {
    const interopLabel = basis.string.toInteropString(label);
    return if (basis.bindings.api.ImGui_radioButton(&interopLabel, v, v_button) == 1) return true else false;
}

pub fn getScrollX() f32 {
    return basis.bindings.api.ImGui_getScrollX();
}

pub fn getScrollY() f32 {
    return basis.bindings.api.ImGui_getScrollY();
}

pub fn setScrollX(scrollX: f32) void {
    basis.bindings.api.ImGui_setScrollX(scrollX);
}

pub fn setScrollY(scrollY: f32) void {
    basis.bindings.api.ImGui_setScrollY(scrollY);
}

pub fn getScrollMaxX() f32 {
    return basis.bindings.api.ImGui_getScrollMaxX();
}

pub fn getScrollMaxY() f32 {
    return basis.bindings.api.ImGui_getScrollMaxY();
}

pub fn setScrollHereX(centerXRatio: f32) void {
    basis.bindings.api.ImGui_setScrollHereX(centerXRatio);
}

pub fn setScrollHereY(centerYRatio: f32) void {
    basis.bindings.api.ImGui_setScrollHereY(centerYRatio);
}

pub fn setScrollFromPosX(localX: f32, centerXRatio: f32) void {
    basis.bindings.api.ImGui_setScrollFromPosX(localX, centerXRatio);
}

pub fn setScrollFromPosY(localY: f32, centerYRatio: f32) void {
    basis.bindings.api.ImGui_setScrollFromPosY(localY, centerYRatio);
}

pub fn dragFloat(label: []const u8, v: *f32, v_speed: f32, v_min: f32, v_max: f32, format: []const u8, flags: ImGuiSliderFlags) bool {
    const interopLabel = basis.string.toInteropString(label);
    const interopFormat = basis.string.toInteropString(format);
    return if (basis.bindings.api.ImGui_dragFloat(&interopLabel, v, v_speed, v_min, v_max, &interopFormat, flags.asInt()) == 1) true else false;
}

pub fn dragInt(label: []const u8, v: *i32, v_speed: f32, v_min: i32, v_max: i32, format: []const u8, flags: ImGuiSliderFlags) bool {
    const interopLabel = basis.string.toInteropString(label);
    const interopFormat = basis.string.toInteropString(format);
    return if (basis.bindings.api.ImGui_dragInt(&interopLabel, v, v_speed, v_min, v_max, &interopFormat, flags.asInt()) == 1) true else false;
}

pub fn sliderFloat(label: []const u8, v: *f32, v_min: f32, v_max: f32, format: []const u8, flags: ImGuiSliderFlags) bool {
    const interopLabel = basis.string.toInteropString(label);
    const interopFormat = basis.string.toInteropString(format);
    return if (basis.bindings.api.ImGui_sliderFloat(&interopLabel, v, v_min, v_max, &interopFormat, flags.asInt()) == 1) true else false;
}

pub fn sliderInt(label: []const u8, v: *i32, v_min: i32, v_max: i32, format: []const u8, flags: ImGuiSliderFlags) bool {
    const interopLabel = basis.string.toInteropString(label);
    const interopFormat = basis.string.toInteropString(format);
    return if (basis.bindings.api.ImGui_sliderInt(&interopLabel, v, v_min, v_max, &interopFormat, flags.asInt()) == 1) true else false;
}
