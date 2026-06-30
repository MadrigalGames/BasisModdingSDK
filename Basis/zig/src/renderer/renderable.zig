// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

pub const RenderablePtr = struct {
    const Self = @This();
    cppPtr: basis.CppPtr,

    pub fn initNull() Self {
        return Self{ .cppPtr = 0 };
    }

    // TODO: Add a method here for getting the renderable type + some methods to "cast"
    // the renderable into a sub type such as a MeshInstance. The pointer casting should
    // probably happen on the C++ side and we can then just return a new MeshInstancePtr
    // with the correctly cast cpp ptr.

    // pub fn setVisible(self: *const Self, visible: bool) void {
    //     basis.bindings.api.Renderable_setVisible(self.cppPtr, visible);
    // }

    // pub fn isVisible(self: *const Self) bool {
    //     return basis.bindings.api.Renderable_isVisible(self.cppPtr);
    // }
};
