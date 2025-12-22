// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

// This is a pretty nice way to bind Zig functionality to AngelScript,
// however, it got evident pretty fast that we don't expose all of the
// things we need to Zig, meaning most of the std functionality needs
// to come from C++ after all.

// Anyway, leaving this in here as commented-out, if it is of use later...

// pub fn registerStdMethods(
//     comptime T: type,
//     registration: basis.angelscript.ComponentRegistration,
// ) void {
//     const ctxtType = std.meta.fieldInfo(T, .context).type;

//     if (@hasDecl(ctxtType, "onClient")) {
//         const m = onClient(T);
//         registration.registerComponentMethod(m.Decl, &m.call);
//     }

//     if (@hasDecl(ctxtType, "onServer")) {
//         const m = onServer(T);
//         registration.registerComponentMethod(m.Decl, &m.call);
//     }
// }

// fn onClient(comptime T: type) type {
//     return struct {
//         pub const Decl = "bool onClient()";

//         pub fn call(selfIntPtr: basis.IntPtr) callconv(.c) bool {
//             const self: *const T = @ptrFromInt(selfIntPtr);
//             return self.context.onClient();
//         }
//     };
// }

// fn onServer(comptime T: type) type {
//     return struct {
//         pub const Decl = "bool onServer()";

//         pub fn call(selfIntPtr: basis.IntPtr) callconv(.c) bool {
//             const self: *const T = @ptrFromInt(selfIntPtr);
//             return self.context.onServer();
//         }
//     };
// }
