// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("../basis.zig");

const BinaryWriteStream = basis.binary_stream.BinaryWriteStream;
const BinaryReadStream = basis.binary_stream.BinaryReadStream;

const String = basis.String;
const GameObjectRef = basis.game_object.GameObjectRef;

pub const ExposedPropertyType = enum(i32) {
    Property = 0,
    Button,
    Category,

    pub fn asInt(self: ExposedPropertyType) i32 {
        return @intFromEnum(self);
    }
};

pub fn Property(
    comptime parentType: type,
    comptime T: type,
    comptime fieldName: []const u8,
    comptime defaultValue: T,
    comptime versionAdded: i32,
    comptime options: []const u8,
) type {
    switch (@typeInfo(T)) {
        .@"enum" => {
            // Enum field.
            return struct {
                pub const PropertyType = ExposedPropertyType.Property;
                pub const DataType = basis.typeinfo.TypeID.BASIS_TYPE_ENUM;
                pub const Name = fieldName;
                pub const Options = options;
                pub const VersionAdded = versionAdded;

                pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
                    reader.processEnum(T, fieldName, defaultValue, versionAdded, options);
                }

                pub fn writeValue(parent: *parentType, value: u32) void {
                    @field(parent.*, fieldName) = @as(T, @enumFromInt(value));
                }

                pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
                    const value: u32 = @intFromEnum(@field(parent.*, fieldName));
                    stream.putInt(u32, value);
                }

                pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
                    const value: u32 = stream.getInt(u32);
                    @field(parent.*, fieldName) = @as(T, @enumFromInt(value));
                }

                pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
                    _ = allocator;
                    stream.putInt(u32, @intFromEnum(defaultValue));
                }
            };
        },
        else => {
            // Non-enum field.
            return struct {
                pub const PropertyType = ExposedPropertyType.Property;
                pub const DataType = basis.typeinfo.getTypeID(T);
                pub const Name = fieldName;
                pub const Options = options;
                pub const VersionAdded = versionAdded;

                pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
                    reader.processProperty(T, fieldName, defaultValue, versionAdded, options);
                }

                pub fn writeValue(parent: *parentType, value: T) void {
                    @field(parent.*, fieldName) = value;
                }

                pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
                    switch (T) {
                        f64 => @compileError("Exposed properties of type f64 not currently supported."),
                        []const u8, String => @compileError("For exposed properties of type string, use StringProperty() instead of Property()."),
                        f32 => {
                            const value = @field(parent.*, fieldName);
                            stream.putFloat(value);
                        },
                        i8, u8, i16, u16, i32, u32, i64, u64 => {
                            const value = @field(parent.*, fieldName);
                            stream.putInt(T, value);
                        },
                        bool => {
                            const value = @field(parent.*, fieldName);
                            stream.putBool(value);
                        },
                        else => {
                            const value = @field(parent.*, fieldName);
                            stream.put(T, value);
                        },
                    }
                }

                pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
                    switch (T) {
                        f64 => @compileError("Exposed properties of type f64 not currently supported."),
                        []const u8, String => @compileError("For exposed properties of type string, use StringProperty() instead of Property()."),
                        f32 => {
                            @field(parent.*, fieldName) = stream.getFloat();
                        },
                        i8, u8, i16, u16, i32, u32, i64, u64 => {
                            @field(parent.*, fieldName) = stream.getInt(T);
                        },
                        bool => {
                            @field(parent.*, fieldName) = stream.getBool();
                        },
                        else => {
                            @field(parent.*, fieldName) = stream.get(T);
                        },
                    }
                }

                pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
                    _ = allocator;
                    switch (T) {
                        f64 => @compileError("Exposed properties of type f64 not currently supported."),
                        []const u8, String => @compileError("For exposed properties of type string, use StringProperty() instead of Property()."),
                        f32 => {
                            stream.putFloat(defaultValue);
                        },
                        i8, u8, i16, u16, i32, u32, i64, u64 => {
                            stream.putInt(T, defaultValue);
                        },
                        bool => {
                            stream.putBool(defaultValue);
                        },
                        else => {
                            stream.put(T, defaultValue);
                        },
                    }
                }
            };
        },
    }
}

pub fn StringProperty(
    comptime parentType: type,
    comptime fieldName: []const u8,
    comptime defaultValue: []const u8,
    comptime versionAdded: i32,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Property;
        pub const DataType = basis.typeinfo.TypeID.BASIS_TYPE_STRING;
        pub const Name = fieldName;
        pub const Options = options;
        pub const VersionAdded = versionAdded;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processString(fieldName, defaultValue, versionAdded, options);
        }

        pub fn writeValue(parent: *parentType, value: []const u8) void {
            if (@field(parent.*, fieldName).set(value)) {} else |err| {
                basis.assertf(@src(), false, "Error setting exposed string property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            }
        }

        pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
            stream.putString(@field(parent.*, fieldName).str());
        }

        pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
            const str: *String = &@field(parent.*, fieldName);
            if (stream.deserializeString(str)) {} else |err| {
                basis.assertf(@src(), false, "Error deserializing exposed string property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            }
        }

        pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
            _ = allocator;
            stream.putString(defaultValue);
        }
    };
}

pub fn InPlaceStringProperty(
    comptime parentType: type,
    comptime fieldName: []const u8,
    comptime defaultValue: []const u8,
    comptime versionAdded: i32,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Property;
        pub const DataType = basis.typeinfo.TypeID.BASIS_TYPE_STRING;
        pub const Name = fieldName;
        pub const Options = options;
        pub const VersionAdded = versionAdded;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processString(fieldName, defaultValue, versionAdded, options);
        }

        pub fn writeValue(parent: *parentType, value: []const u8) void {
            if (@field(parent.*, fieldName).set(value)) {} else |err| {
                basis.assertf(@src(), false, "Error setting exposed in-place string property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            }
        }

        pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
            stream.putString(@field(parent.*, fieldName).str());
        }

        pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
            const str = &@field(parent.*, fieldName);
            stream.deserializeInPlaceString(str) catch |err| {
                basis.assertf(@src(), false, "Error deserializing exposed in-place string property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            };
        }

        pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
            _ = allocator;
            stream.putString(defaultValue);
        }
    };
}

pub fn ResourceRefProperty(
    comptime parentType: type,
    comptime fieldName: []const u8,
    comptime resourceTypeID: basis.typeinfo.ResourceTypeID,
    comptime defaultValue: []const u8,
    comptime versionAdded: i32,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Property;
        pub const DataType = basis.typeinfo.TypeID.BASIS_TYPE_RESOURCE_REF;
        pub const Name = fieldName;
        pub const Options = options;
        pub const VersionAdded = versionAdded;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processResourceRef(fieldName, resourceTypeID, defaultValue, versionAdded, options);
        }

        pub fn writeValue(parent: *parentType, value: []const u8) void {
            if (@field(parent.*, fieldName).set(value)) {} else |err| {
                basis.assertf(@src(), false, "Error setting exposed resource ref property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            }
        }

        pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
            stream.putString(@field(parent.*, fieldName).str());
        }

        pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
            const str: *String = &@field(parent.*, fieldName);
            if (stream.deserializeString(str)) {} else |err| {
                basis.assertf(@src(), false, "Error deserializing exposed resource ref property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            }
        }

        pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
            _ = allocator;
            stream.putString(defaultValue);
        }
    };
}

pub fn GameObjectRefProperty(
    comptime parentType: type,
    comptime fieldName: []const u8,
    comptime defaultValue: []const u8,
    comptime versionAdded: i32,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Property;
        pub const DataType = basis.typeinfo.TypeID.BASIS_TYPE_GAME_OBJECT_REF;
        pub const Name = fieldName;
        pub const Options = options;
        pub const VersionAdded = versionAdded;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processGameObjectRef(fieldName, defaultValue, versionAdded, options);
        }

        pub fn writeValue(parent: *parentType, value: []const u8) void {
            if (@field(parent.*, fieldName).set(value)) {} else |err| {
                basis.assertf(@src(), false, "Error setting exposed string property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            }
        }

        pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
            @field(parent.*, fieldName).serialize(stream);
        }

        pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
            var str: *GameObjectRef = &@field(parent.*, fieldName);
            str.deserialize(stream);
        }

        pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
            _ = allocator;
            const hash = basis.string.makeStringHash(defaultValue);
            GameObjectRef.serializeStatic(defaultValue, hash, stream);
        }
    };
}

pub fn ScriptCodeProperty(
    comptime parentType: type,
    comptime fieldName: []const u8,
    comptime template: basis.angelscript.ScriptCode.Template,
    comptime versionAdded: i32,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Property;
        pub const DataType = basis.typeinfo.TypeID.BASIS_TYPE_SCRIPT_CODE;
        pub const Name = fieldName;
        pub const Options = options;
        pub const VersionAdded = versionAdded;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processScriptCode(fieldName, template, versionAdded, options);
        }

        // pub fn writeValue(parent: *parentType, value: basis.angelscript.ScriptCode) void {
        //     @field(parent.*, fieldName) = value;
        // }

        pub fn serializeValue(parent: *parentType, stream: *BinaryWriteStream) void {
            @field(parent.*, fieldName).serialize(stream);
        }

        pub fn deserializeValue(parent: *parentType, stream: *BinaryReadStream) void {
            var sc: *basis.angelscript.ScriptCode = &@field(parent.*, fieldName);
            sc.tryDeserialize(stream) catch |err| {
                basis.assertf(@src(), false, "Error deserializing exposed script code property \"{s}\": {s}", .{ fieldName, @errorName(err) });
            };
        }

        pub fn serializeDefaultValue(stream: *BinaryWriteStream, allocator: std.mem.Allocator) void {
            var sc = basis.angelscript.ScriptCode.initTemplate(allocator, template);
            sc.serialize(stream);
            sc.deinit();
        }
    };
}

pub fn Button(
    comptime actionID: []const u8,
    comptime actionName: []const u8,
    comptime buttonText: []const u8,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Button;
        pub const Name = actionID;
        pub const Options = options;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processButton(actionID, actionName, buttonText, options);
        }

        pub fn getTypeID() basis.typeinfo.TypeID {
            return basis.typeinfo.TypeID.BASIS_TYPE_EMPTY;
        }
    };
}

pub fn Category(
    comptime categoryName: []const u8,
    comptime displayName: []const u8,
    comptime options: []const u8,
) type {
    return struct {
        pub const PropertyType = ExposedPropertyType.Category;
        pub const Name = categoryName;
        pub const Options = options;

        pub fn readLayout(reader: basis.exposed_properties.ExposedPropertyLayoutReaderPtr) void {
            reader.processCategory(categoryName, displayName, options);
        }

        pub fn getTypeID() basis.typeinfo.TypeID {
            return basis.typeinfo.TypeID.BASIS_TYPE_EMPTY;
        }
    };
}
