// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const Allocator = std.mem.Allocator;

// Types currently supported:
// BASIS_TYPE_FLOAT
// BASIS_TYPE_DOUBLE
// BASIS_TYPE_INT32
// BASIS_TYPE_UINT32
// BASIS_TYPE_INT16
// BASIS_TYPE_UINT16
// BASIS_TYPE_INT8
// BASIS_TYPE_UINT8
// BASIS_TYPE_BOOL
// BASIS_TYPE_VEC2
// BASIS_TYPE_VEC3
// BASIS_TYPE_VEC4
// BASIS_TYPE_QUATERNION
// BASIS_TYPE_MAT43

pub fn PropagatedValueHandle(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        pvPtr: *PropagatedValue(T),

        pub fn init(allocator: Allocator, ptr: *PropagatedValue(T)) PropagatedValueHandle(T) {
            return PropagatedValueHandle(T){
                .allocator = allocator,
                .pvPtr = ptr,
            };
        }

        pub fn deinit(self: *Self) void {
            self.allocator.destroy(self.pvPtr);
        }

        pub fn set(self: *const Self, val: T) void {
            self.pvPtr.set(val);
        }

        pub fn setDontPropagate(self: *Self, val: T) void {
            self.pvPtr.setDontPropagate(val);
        }

        pub fn get(self: *const Self) T {
            return self.pvPtr.value;
        }

        pub fn setValueChangedCallback(self: *Self, cb: PropagatedValue(T).Callback) void {
            self.pvPtr.onValueChanged = cb;
        }

        pub fn clearValueChangedCallback(self: *Self) void {
            self.pvPtr.onValueChanged = null;
        }
    };
}

pub fn PropagatedValue(comptime T: type) type {
    return struct {
        const Self = @This();

        pub const Callback = basis.delegate.VoidDelegate3(T, bool, f64);

        // The pointer to the C++ PV.
        pvCppPtr: basis.CppPtr,

        // The value of this PV.
        value: T,

        // The value-changed callback for this PV.
        onValueChanged: ?Callback = null,

        pub fn init(context: anytype, name: []const u8, reliablePropagation: bool, immediatePropagation: bool, initialValue: T) PropagatedValueHandle(T) {
            const pvPtr = context.allocator.create(PropagatedValue(T)) catch unreachable;
            const cppPtr = createInCpp(context, @intFromPtr(pvPtr), name, reliablePropagation, immediatePropagation, initialValue) catch unreachable;

            pvPtr.* = PropagatedValue(T){
                .pvCppPtr = cppPtr,
                .value = initialValue,
            };

            return PropagatedValueHandle(T).init(context.allocator, pvPtr);
        }

        pub fn set(self: *Self, val: T) void {
            setInCpp(self.pvCppPtr, val);
        }

        pub fn setDontPropagate(self: *Self, val: T) void {
            self.value = val;
        }

        pub fn propagate(self: *Self) void {
            setInCpp(self.pvCppPtr, self.value);
        }

        pub fn _setPropagated(self: *Self, val: T, localChange: bool, valueTime: f64) void {
            self.value = val;

            if (self.onValueChanged) |cb| {
                cb.call(self.value, localChange, valueTime);
            }
        }

        fn createInCpp(context: anytype, pvPtr: basis.IntPtr, name: []const u8, reliablePropagation: bool, immediatePropagation: bool, initialValue: T) !basis.CppPtr {
            const interopName = basis.string.toInteropString(name);

            switch (T) {
                f32 => return basis.bindings.api.PropagatedValue_createFloat(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                f64 => return basis.bindings.api.PropagatedValue_createDouble(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                i8 => return basis.bindings.api.PropagatedValue_createInt8(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                u8 => return basis.bindings.api.PropagatedValue_createUint8(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                i16 => return basis.bindings.api.PropagatedValue_createInt16(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                u16 => return basis.bindings.api.PropagatedValue_createUint16(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                i32 => return basis.bindings.api.PropagatedValue_createInt32(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                u32 => return basis.bindings.api.PropagatedValue_createUint32(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                i64 => return basis.bindings.api.PropagatedValue_createInt64(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                u64 => return basis.bindings.api.PropagatedValue_createUint64(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                bool => return basis.bindings.api.PropagatedValue_createBool(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, initialValue),
                basis.math.Vec2 => {
                    const v = initialValue.toInterop();
                    return basis.bindings.api.PropagatedValue_createVec2(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, &v);
                },
                basis.math.Vec3 => {
                    const v = initialValue.toInterop();
                    return basis.bindings.api.PropagatedValue_createVec3(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, &v);
                },
                basis.math.Vec4 => {
                    const v = initialValue.toInterop();
                    return basis.bindings.api.PropagatedValue_createVec4(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, &v);
                },
                basis.math.Quaternion => {
                    const q = initialValue.toInterop();
                    return basis.bindings.api.PropagatedValue_createQuaternion(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, &q);
                },
                basis.math.Mat43 => {
                    const m = initialValue.toInterop();
                    return basis.bindings.api.PropagatedValue_createMat43(context.cppPtr, pvPtr, &interopName, reliablePropagation, immediatePropagation, &m);
                },
                else => @compileError("Unsupported type in PV."),
            }
        }

        fn setInCpp(pvCppPtr: basis.CppPtr, value: T) void {
            switch (T) {
                f32 => basis.bindings.api.PropagatedValue_setFloat(pvCppPtr, value),
                f64 => basis.bindings.api.PropagatedValue_setDouble(pvCppPtr, value),
                i8 => basis.bindings.api.PropagatedValue_setInt8(pvCppPtr, value),
                u8 => basis.bindings.api.PropagatedValue_setUint8(pvCppPtr, value),
                i16 => basis.bindings.api.PropagatedValue_setInt16(pvCppPtr, value),
                u16 => basis.bindings.api.PropagatedValue_setUint16(pvCppPtr, value),
                i32 => basis.bindings.api.PropagatedValue_setInt32(pvCppPtr, value),
                u32 => basis.bindings.api.PropagatedValue_setUint32(pvCppPtr, value),
                i64 => basis.bindings.api.PropagatedValue_setInt64(pvCppPtr, value),
                u64 => basis.bindings.api.PropagatedValue_setUint64(pvCppPtr, value),
                bool => basis.bindings.api.PropagatedValue_setBool(pvCppPtr, value),
                basis.math.Vec2 => {
                    const v = value.toInterop();
                    basis.bindings.api.PropagatedValue_setVec2(pvCppPtr, &v);
                },
                basis.math.Vec3 => {
                    const v = value.toInterop();
                    basis.bindings.api.PropagatedValue_setVec3(pvCppPtr, &v);
                },
                basis.math.Vec4 => {
                    const v = value.toInterop();
                    basis.bindings.api.PropagatedValue_setVec4(pvCppPtr, &v);
                },
                basis.math.Quaternion => {
                    const q = value.toInterop();
                    basis.bindings.api.PropagatedValue_setQuaternion(pvCppPtr, &q);
                },
                basis.math.Mat43 => {
                    const m = value.toInterop();
                    basis.bindings.api.PropagatedValue_setMat43(pvCppPtr, &m);
                },
                else => @compileError("Unsupported type in PV."),
            }
        }
    };
}

//----------------------------------------------------

pub const PropagatedActionHandle = struct {
    const Self = @This();
    allocator: Allocator,
    paPtr: *PropagatedAction,

    pub fn init(allocator: Allocator, ptr: *PropagatedAction) Self {
        return Self{ .allocator = allocator, .paPtr = ptr };
    }

    pub fn deinit(self: *Self) void {
        self.allocator.destroy(self.paPtr);
    }

    pub fn fire(self: *const Self) void {
        self.paPtr.fire();
    }

    pub fn setActionFiredCallback(self: *Self, cb: PropagatedAction.Callback) void {
        self.paPtr.onActionFired = cb;
    }
};

pub const PropagatedAction = struct {
    const Self = @This();

    pub const Callback = basis.delegate.VoidDelegate2(bool, f64);

    // The pointer to the C++ PA.
    paCppPtr: basis.CppPtr,

    // The action-fired callback for this PA.
    onActionFired: ?Callback = null,

    pub fn init(context: anytype, name: []const u8, reliablePropagation: bool, immediatePropagation: bool) PropagatedActionHandle {
        const paPtr = context.allocator.create(PropagatedAction) catch unreachable;
        const interopName = basis.string.toInteropString(name);
        const cppPtr = basis.bindings.api.PropagatedValue_createAction(context.cppPtr, @intFromPtr(paPtr), &interopName, reliablePropagation, immediatePropagation);

        paPtr.* = PropagatedAction{ .paCppPtr = cppPtr };

        return PropagatedActionHandle.init(context.allocator, paPtr);
    }

    pub fn fire(self: *Self) void {
        basis.bindings.api.PropagatedValue_fireAction(self.paCppPtr);
    }

    pub fn _firePropagated(self: *Self, localChange: bool, valueTime: f64) void {
        if (self.onActionFired) |cb| {
            cb.call(localChange, valueTime);
        }
    }
};
