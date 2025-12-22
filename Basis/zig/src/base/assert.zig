// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");
const basis = @import("../basis.zig");

// These function try to figure out the source location on their own (Debug conf only.)

// pub fn assert(exp: bool) void {
//     if (!exp) {
//         // We print the stack frame at index 3. On Windows, the frames are like:
//         // 0: The call to windows.ntdll.RtlCaptureStackBackTrace()
//         // 1: The call to std.debug.captureStackTrace()
//         // 2: The call to showAssertMessage()
//         // 3: The call to assert() <-- We want this one!
//         const stack_frame_index = 3;

//         // TODO: Figure out the correct index on other platforms...

//         showAssertMessage("Assert failed.", stack_frame_index);
//     }
// }

// pub fn assertWithMessage(exp: bool, message: []const u8) void {
//     if (!exp) {
//         // We print the stack frame at index 3. On Windows, the frames are like:
//         // 0: The call to windows.ntdll.RtlCaptureStackBackTrace()
//         // 1: The call to std.debug.captureStackTrace()
//         // 2: The call to showAssertMessage()
//         // 3: The call to assertWithMessage() <-- We want this one!
//         const stack_frame_index = 3;

//         // TODO: Figure out the correct index on other platforms...

//         showAssertMessage(message, stack_frame_index);
//     }
// }

// pub fn assertWithFormat(exp: bool, comptime fmt: []const u8, args: anytype) void {
//     if (!exp) {
//         // We print the stack frame at index 3. On Windows, the frames are like:
//         // 0: The call to windows.ntdll.RtlCaptureStackBackTrace()
//         // 1: The call to std.debug.captureStackTrace()
//         // 2: The call to showAssertMessage()
//         // 3: The call to assertWithMessage() <-- We want this one!
//         const stack_frame_index = 3;

//         // TODO: Figure out the correct index on other platforms...

//         var formattedMessageBuffer: [1024]u8 = undefined;

//         const formattedMsg = std.fmt.bufPrint(
//             &formattedMessageBuffer,
//             fmt,
//             args,
//         ) catch unreachable;

//         showAssertMessage(formattedMsg, stack_frame_index);
//     }
// }

//----------------------------------------------------

// These functions accept a SourceLocation which you can get with @src() and
// can display the information in all configurations.

pub fn assert(src: std.builtin.SourceLocation, exp: bool) void {
    if (!exp) {
        showAssertMessageWithSrc("Assert failed.", src);
    }
}

pub fn assertWithMessage(src: std.builtin.SourceLocation, exp: bool, message: []const u8) void {
    if (!exp) {
        showAssertMessageWithSrc(message, src);
    }
}

pub fn assertWithFormat(src: std.builtin.SourceLocation, exp: bool, comptime fmt: []const u8, args: anytype) void {
    if (!exp) {
        var formattedMessageBuffer: [1024]u8 = undefined;

        const formattedMsg = std.fmt.bufPrint(
            &formattedMessageBuffer,
            fmt,
            args,
        ) catch @panic("Assert message buffer too small");

        showAssertMessageWithSrc(formattedMsg, src);
    }
}

//----------------------------------------------------

fn showAssertMessage(message: []const u8, stack_frame_index: usize) void {
    _ = stack_frame_index; // autofix
    var returnCode: i32 = 0;
    var formattedMessageBuffer: [2048]u8 = undefined;
    const interopCaption = basis.string.toInteropString("Assert failed");

    // Printing the stack trace / frame. Only possible in debug builds.
    // Currently commented out as it needs to be patched to work with the new
    // writers (post-writergate) and it is not currently used.

    // if (builtin.mode == .Debug and !basis.build_options.buildAsWASM) {
    //     var addressBuffer: [8]usize = undefined;
    //     var trace = std.builtin.StackTrace{ .instruction_addresses = addressBuffer[0..], .index = 0 };
    //     std.debug.captureStackTrace(null, &trace);

    //     var stackTraceBuffer: [1024]u8 = undefined;
    //     var fbs = std.io.fixedBufferStream(&stackTraceBuffer);
    //     const writer = fbs.writer();

    //     const debug_info = std.debug.getSelfDebugInfo() catch {
    //         @breakpoint();
    //         return;
    //     };

    //     // Print full stack trace:
    //     //var frame_index: usize = 0;
    //     //var frames_left: usize = std.math.min(trace.index, trace.instruction_addresses.len);

    //     // Print only the frame with the given index.
    //     var frame_index: usize = stack_frame_index;
    //     var frames_left: usize = 1;

    //     while (frames_left != 0) : ({
    //         frames_left -= 1;
    //         frame_index = (frame_index + 1) % trace.instruction_addresses.len;
    //     }) {
    //         const return_address = trace.instruction_addresses[frame_index];
    //         std.debug.printSourceAtAddress(debug_info, writer, return_address - 1, std.io.tty.Config.no_color) catch @breakpoint();
    //     }

    //     const formattedMsg = std.fmt.bufPrint(
    //         &formattedMessageBuffer,
    //         "Assertion failed: '{s}'\n\n{s}",
    //         .{ message, fbs.getWritten() },
    //     ) catch unreachable;

    //     const interopMessage = basis.string.toInteropString(formattedMsg);
    //     returnCode = basis.bindings.api.Core_showAssertDialog(&interopMessage, &interopCaption);
    // } else
    {
        const formattedMsg = std.fmt.bufPrint(
            &formattedMessageBuffer,
            "Assertion failed: '{s}'. Run in debug mode to get source location info.",
            .{message},
        ) catch @panic("Assert message buffer too small");

        const interopMessage = basis.string.toInteropString(formattedMsg);
        returnCode = basis.bindings.api.Core_showAssertDialog(&interopMessage, &interopCaption);
    }

    // 1 = Exit, 2 = Break, 3 = Continue, 4 = Ignore.
    // Code 1 (Exit) never gets here, since is handled on the C++ level.

    // TODO: Can we handle case 4 (Ignore) somehow, to avoid showing the same message many times?

    if (returnCode == 2) {
        @breakpoint();
    }
}

fn showAssertMessageWithSrc(message: []const u8, src: std.builtin.SourceLocation) void {
    var returnCode: i32 = 0;
    var formattedMessageBuffer: [2048]u8 = undefined;
    const interopCaption = basis.string.toInteropString("Assert failed");

    const formattedMsg = std.fmt.bufPrint(
        &formattedMessageBuffer,
        "Assertion failed: '{s}'\r\n\r\nFile: {s}:{d}\r\n\r\nFunction: {s}",
        .{ message, src.file, src.line, src.fn_name },
    ) catch @panic("Assert message buffer too small");

    const interopMessage = basis.string.toInteropString(formattedMsg);
    returnCode = basis.bindings.api.Core_showAssertDialog(&interopMessage, &interopCaption);

    // 1 = Exit, 2 = Break, 3 = Continue, 4 = Ignore.
    // Code 1 (Exit) never gets here, since is handled on the C++ level.

    // TODO: Can we handle case 4 (Ignore) somehow, to avoid showing the same message many times?

    if (returnCode == 2) {
        @breakpoint();
    }
}
