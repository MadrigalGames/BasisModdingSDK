// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

/// Given the type of an object, and a pointer to an instance of that type,
/// this function calls deinit() on all struct and ptr-to-struct fields on
/// the given object. Only calls deinit() functions returning void and taking
/// a single self parameter.
pub fn deinitMembers(comptime T: type, ptr: *T) void {
    callFunctionOnMembers(T, ptr, "deinit");
}

/// Same as deinitMembers() but allows calling any function.
pub fn callFunctionOnMembers(comptime T: type, ptr: *T, comptime functionName: []const u8) void {
    callFunctionOnMembersWithExclusionList(T, ptr, functionName, .{});
}

/// Same as callFunctionOnMembers() but allows speciying a list of fields to
/// not call the function on.
pub fn callFunctionOnMembersWithExclusionList(
    comptime T: type,
    ptr: *T,
    comptime functionName: []const u8,
    comptime excluding: anytype,
) void {
    switch (@typeInfo(T)) {
        .@"struct" => |structInfo| {
            inline for (structInfo.fields) |field| {
                if (!inExclusionList(field.name, excluding)) {
                    switch (@typeInfo(field.type)) {
                        .@"struct" => {
                            callFunctionOnStructField(T, field.type, field.name, false, functionName, ptr);
                        },
                        .pointer => |pointer| {
                            callFunctionOnStructField(T, pointer.child, field.name, true, functionName, ptr);
                        },
                        else => {},
                    }
                }
            }
        },
        else => {
            @compileError("Can't call a function on a " ++ @typeName(T) ++ ".");
        },
    }
}

//----------------------------------------------------

fn inExclusionList(comptime name: []const u8, comptime excluding: anytype) bool {
    inline for (excluding) |excl| {
        if (std.mem.eql(u8, name, excl)) {
            return true;
        }
    }

    return false;
}

fn callFunctionOnStructField(
    comptime ParentStructType: type,
    comptime StructFieldType: type,
    comptime fieldName: []const u8,
    comptime fieldIsPtr: bool,
    comptime functionName: []const u8,
    parentPtr: *ParentStructType,
) void {
    if (@hasDecl(StructFieldType, functionName)) {
        const declType: type = @TypeOf(@field(StructFieldType, functionName));

        switch (@typeInfo(declType)) {
            .@"fn" => |f| {
                // We are only concerned with functions taking a single self
                // parameter (by ptr or by value) and returning void.
                if (f.return_type != null and
                    f.return_type.? == void and
                    f.params.len == 1 and
                    f.params[0].type != null)
                {
                    const selfIsPtr = switch (@typeInfo(f.params[0].type.?)) {
                        .pointer => true,
                        else => false,
                    };

                    const fptr = @field(StructFieldType, functionName);

                    if (selfIsPtr and !fieldIsPtr) {
                        var fieldRef = @field(parentPtr.*, fieldName);
                        @call(.auto, fptr, .{&fieldRef});
                    } else if (!selfIsPtr and fieldIsPtr) {
                        const fieldRef = @field(parentPtr.*, fieldName);
                        @call(.auto, fptr, .{fieldRef.*});
                    } else {
                        const fieldRef = @field(parentPtr.*, fieldName);
                        @call(.auto, fptr, .{fieldRef});
                    }
                }
            },
            else => {},
        }
    }
}
