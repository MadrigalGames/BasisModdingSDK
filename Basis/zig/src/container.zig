// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

/// Given a slice and a value to match against, returns the index
/// of the first element in the slice which has the given value,
/// or null if no such element was found.
pub fn indexByValue(
    comptime T: type,
    slice: []const T,
    value: T,
) ?usize {
    const index: ?usize = for (slice, 0..) |e, i| {
        if (e == value) {
            break i;
        }
    } else null;

    return index;
}

/// Given a slice of struct instances, a field name and a value
/// to match against, returns the index of the first element in
/// the slice where the field has the given value, or null if no
/// such element was found.
pub fn indexByFieldValue(
    comptime T: type,
    comptime fieldName: []const u8,
    slice: []const T,
    fieldValue: anytype,
) ?usize {
    const index: ?usize = for (slice, 0..) |e, i| {
        if (@field(e, fieldName) == fieldValue) {
            break i;
        }
    } else null;

    return index;
}

test "Find index by field value" {
    const Thing = struct {
        boolean: bool,
        value: i32,
    };

    const a = std.testing.allocator;
    {
        var list = basis.ArrayList(Thing).init(a);
        defer list.deinit();

        try std.testing.expectEqual(null, indexByFieldValue(Thing, "value", list.items, 123));

        try list.append(Thing{ .boolean = false, .value = 123 });
        try list.append(Thing{ .boolean = false, .value = 234 });
        try list.append(Thing{ .boolean = true, .value = 345 });
        try list.append(Thing{ .boolean = false, .value = 456 });

        try std.testing.expectEqual(0, indexByFieldValue(Thing, "value", list.items, 123));
        try std.testing.expectEqual(3, indexByFieldValue(Thing, "value", list.items, 456));
        try std.testing.expectEqual(2, indexByFieldValue(Thing, "boolean", list.items, true));
    }
}
