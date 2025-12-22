// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

const FlowStateInterface = basis.flow_state_interface.FlowStateInterface;

pub const StateMachine = struct {
    const Self = @This();
    const FlowStateList = basis.ArrayList(*FlowStateInterface);

    allocator: Allocator,
    cppPtr: basis.CppPtr,

    flowStates: FlowStateList,

    pub fn init(allocator: Allocator, cppPtr: basis.CppPtr) Self {
        return Self{
            .allocator = allocator,
            .cppPtr = cppPtr,
            .flowStates = FlowStateList.init(allocator),
        };
    }

    pub fn deinit(self: *Self) void {
        // Make sure the actual flow states are deleted here before emptying the array list.
        for (self.flowStates.items) |element| {
            element.destroy(self.allocator);
        }

        self.flowStates.deinit();
    }

    pub fn registerFlowState(
        self: *Self,
        stateName: []const u8,
        comptime T: type,
        flags: anytype,
    ) void {
        var statePtr: *T = self.allocator.create(T) catch unreachable;
        var flowStateCppPtr: basis.bindings.InteropTypedPtr = undefined;

        const interopName = basis.string.toInteropString(stateName);

        const flagsInt: i32 = @intFromEnum(flags);

        // Register the state ptr and the name with the C++ side here and get back the cppPtr.
        basis.bindings.api.StateMachine_registerFlowState(
            basis.library_api.getZigLibCppPtr(),
            self.cppPtr,
            &interopName,
            @intFromPtr(&statePtr.interface),
            flagsInt,
            &flowStateCppPtr,
        );

        if (T.init(FlowStateInterface.make(T, statePtr), self.allocator, flowStateCppPtr)) |state| {
            statePtr.* = state;
        } else |err| {
            basis.fatalErrorWithFormat(@src(), "Error initializing flow state: {s}", .{@errorName(err)});
        }

        self.flowStates.append(&statePtr.interface) catch unreachable;

        if (@hasDecl(T, "postInit")) {
            statePtr.postInit();
        }
    }

    pub fn setCallbacksForGroup(
        self: *Self,
        groupName: []const u8,
        enterCallback: basis.bindings.FP_void,
        exitCallback: basis.bindings.FP_void,
    ) void {
        const interopName = basis.string.toInteropString(groupName);

        basis.bindings.api.StateMachine_setCallbacksForGroup(
            self.cppPtr,
            &interopName,
            enterCallback,
            exitCallback,
        );
    }

    pub fn clearCallbacksForGroup(
        self: *Self,
        groupName: []const u8,
    ) void {
        const interopName = basis.string.toInteropString(groupName);

        basis.bindings.api.StateMachine_clearCallbacksForGroup(
            self.cppPtr,
            &interopName,
        );
    }
};
