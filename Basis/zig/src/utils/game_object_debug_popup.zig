// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const imgui = basis.imgui;

//----------------------------------------------------

pub const GlobalData = struct {
    debugTargetObject: ?basis.game_object.GameObjectPtr = null,
};

const popupID = "debug_object_popup";

//----------------------------------------------------

pub fn show(targetObject: basis.game_object.GameObjectPtr) void {
    basis.g.game_object_debug_popup.debugTargetObject = targetObject;
    imgui.openPopup(popupID, imgui.ImGuiPopupFlags.None);
}

pub fn update(comptime DebugComponentType: type) !void {
    const localServerRunning = basis.app.isLocalServerRunning();

    if (imgui.beginPopup(popupID, imgui.ImGuiWindowFlags.None)) {
        basis.assert(@src(), basis.g.game_object_debug_popup.debugTargetObject != null);
        var debugTarget = basis.g.game_object_debug_popup.debugTargetObject.?;

        const debugComponent: ?*DebugComponentType = debugTarget.getComponent(DebugComponentType);

        const targetName = debugTarget.getName();

        imgui.pushStyleColor(imgui.ImGuiCol.TextDisabled, basis.Color.init(255, 255, 0));
        _ = imgui.menuItem(targetName, false, false);
        imgui.popStyleColor(1);
        imgui.separator();

        if (imgui.beginMenu("Copy to clipboard...", true)) {
            if (imgui.menuItem("Name", false, true)) {
                if (basis.os_utility.writeStringToClipboard(debugTarget.getName())) {
                    basis.debug_overlay.debugTrace("Copied \"{s}\" to the clipboard", .{debugTarget.getName()});
                } else {
                    basis.debug_overlay.debugWarning("Unable to open clipboard", .{});
                }
            }

            if (imgui.menuItem("Type", false, true)) {
                if (basis.os_utility.writeStringToClipboard(debugTarget.getType())) {
                    basis.debug_overlay.debugTrace("Copied \"{s}\" to the clipboard", .{debugTarget.getType()});
                } else {
                    basis.debug_overlay.debugWarning("Unable to open clipboard", .{});
                }
            }

            imgui.endMenu();
        }

        if (imgui.beginMenu("Actions...", true)) {
            imgui.pushStyleColor(imgui.ImGuiCol.Text, basis.Color.init(255, 0, 0));
            imgui.pushStyleColor(imgui.ImGuiCol.TextDisabled, basis.Color.init(150, 0, 0));
            if (imgui.menuItem("Destroy GameObject", false, localServerRunning)) {
                try basis.command_prompt.fmtAndParseCommand("gamestate.destroyobject(\"{s}\")", .{targetName});
            }
            imgui.popStyleColor(2);

            if (debugComponent) |dbgCmp| {
                dbgCmp.drawActionSubmenu(localServerRunning);
            }

            imgui.endMenu();
        }

        if (debugComponent) |dbgCmp| {
            dbgCmp.drawPopupContent(localServerRunning);
        }

        imgui.endPopup();
    }
}
