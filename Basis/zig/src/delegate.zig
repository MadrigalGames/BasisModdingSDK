// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

const DelegateError = error{
    NotBound,
};

// Delegates with no return value:

pub fn VoidDelegate0() type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn () void;
        const MethodPtr = *const fn (receiver: basis.IntPtr) void;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr) void {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    memberFunction(recvPtr);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self) void {
            if (self.funcPtr) |p| {
                p();
            } else if (self.methodPtr) |p| {
                p(self.receiver);
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn VoidDelegate1(comptime T0: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0) void;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0) void;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0) void {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    memberFunction(recvPtr, param0);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0) void {
            if (self.funcPtr) |p| {
                p(param0);
            } else if (self.methodPtr) |p| {
                p(self.receiver, param0);
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn VoidDelegate2(comptime T0: type, comptime T1: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0, param1: T1) void;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0, param1: T1) void;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0, param1: T1) void {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    memberFunction(recvPtr, param0, param1);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0, param1: T1) void {
            if (self.funcPtr) |p| {
                p(param0, param1);
            } else if (self.methodPtr) |p| {
                p(self.receiver, param0, param1);
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn VoidDelegate3(comptime T0: type, comptime T1: type, comptime T2: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0, param1: T1, param2: T2) void;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0, param1: T1, param2: T2) void;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0, param1: T1, param2: T2) void {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    memberFunction(recvPtr, param0, param1, param2);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0, param1: T1, param2: T2) void {
            if (self.funcPtr) |p| {
                p(param0, param1, param2);
            } else if (self.methodPtr) |p| {
                p(self.receiver, param0, param1, param2);
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn VoidDelegate4(comptime T0: type, comptime T1: type, comptime T2: type, comptime T3: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0, param1: T1, param2: T2, param3: T3) void;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0, param1: T1, param2: T2, param3: T3) void;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0, param1: T1, param2: T2, param3: T3) void {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    memberFunction(recvPtr, param0, param1, param2, param3);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0, param1: T1, param2: T2, param3: T3) void {
            if (self.funcPtr) |p| {
                p(param0, param1, param2, param3);
            } else if (self.methodPtr) |p| {
                p(self.receiver, param0, param1, param2, param3);
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

// Delegates with a return value:

pub fn RetDelegate0(comptime Ret: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn () Ret;
        const MethodPtr = *const fn (receiver: basis.IntPtr) Ret;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr) Ret {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    return memberFunction(recvPtr);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self) !Ret {
            if (self.funcPtr) |p| {
                return p();
            } else if (self.methodPtr) |p| {
                return p(self.receiver);
            } else {
                return DelegateError.NotBound;
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn RetDelegate1(comptime T0: type, comptime Ret: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0) Ret;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0) Ret;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0) Ret {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    return memberFunction(recvPtr, param0);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0) !Ret {
            if (self.funcPtr) |p| {
                return p(param0);
            } else if (self.methodPtr) |p| {
                return p(self.receiver, param0);
            } else {
                return DelegateError.NotBound;
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn RetDelegate2(comptime T0: type, comptime T1: type, comptime Ret: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0, param1: T1) Ret;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0, param1: T1) Ret;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0, param1: T1) Ret {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    return memberFunction(recvPtr, param0, param1);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0, param1: T1) !Ret {
            if (self.funcPtr) |p| {
                return p(param0, param1);
            } else if (self.methodPtr) |p| {
                return p(self.receiver, param0, param1);
            } else {
                return DelegateError.NotBound;
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn RetDelegate3(comptime T0: type, comptime T1: type, comptime T2: type, comptime Ret: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0, param1: T1, param2: T2) Ret;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0, param1: T1, param2: T2) Ret;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0, param1: T1, param2: T2) Ret {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    return memberFunction(recvPtr, param0, param1, param2);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0, param1: T1, param2: T2) !Ret {
            if (self.funcPtr) |p| {
                return p(param0, param1, param2);
            } else if (self.methodPtr) |p| {
                return p(self.receiver, param0, param1, param2);
            } else {
                return DelegateError.NotBound;
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}

pub fn RetDelegate4(comptime T0: type, comptime T1: type, comptime T2: type, comptime T3: type, comptime Ret: type) type {
    return struct {
        const Self = @This();
        const FuncPtr = *const fn (param0: T0, param1: T1, param2: T2, param3: T3) Ret;
        const MethodPtr = *const fn (receiver: basis.IntPtr, param0: T0, param1: T1, param2: T2, param3: T3) Ret;

        receiver: basis.IntPtr = 0,
        funcPtr: ?FuncPtr = null,
        methodPtr: ?MethodPtr = null,

        pub fn initFn(comptime function: anytype) Self {
            return Self{
                .funcPtr = function,
            };
        }

        pub fn initMethod(receiver: anytype, comptime receiverType: type, comptime memberFunction: anytype) Self {
            const wrapped = struct {
                pub fn wrapCall(recv: basis.IntPtr, param0: T0, param1: T1, param2: T2, param3: T3) Ret {
                    const recvPtr = @as(*receiverType, @ptrFromInt(recv));
                    return memberFunction(recvPtr, param0, param1, param2, param3);
                }
            }.wrapCall;

            return Self{
                .receiver = @intFromPtr(receiver),
                .methodPtr = wrapped,
            };
        }

        pub fn call(self: *const Self, param0: T0, param1: T1, param2: T2, param3: T3) !Ret {
            if (self.funcPtr) |p| {
                return p(param0, param1, param2, param3);
            } else if (self.methodPtr) |p| {
                return p(self.receiver, param0, param1, param2, param3);
            } else {
                return DelegateError.NotBound;
            }
        }

        pub fn eql(self: *const Self, other: Self) bool {
            if (self.receiver != other.receiver) {
                return false;
            }

            if (self.funcPtr) |selfFunc| {
                if (other.funcPtr) |otherFunc| {
                    return selfFunc == otherFunc;
                } else {
                    return false;
                }
            }

            if (self.methodPtr) |selfMethod| {
                if (other.methodPtr) |otherMethod| {
                    return selfMethod == otherMethod;
                } else {
                    return false;
                }
            }

            return false;
        }
    };
}
