// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis.zig");

pub const ExposedPropertyType = @import("exposed_properties/exposed_property_map.zig").ExposedPropertyType;

pub const Property = @import("exposed_properties/exposed_property_map.zig").Property;
pub const StringProperty = @import("exposed_properties/exposed_property_map.zig").StringProperty;
pub const InPlaceStringProperty = @import("exposed_properties/exposed_property_map.zig").InPlaceStringProperty;
pub const ResourceRefProperty = @import("exposed_properties/exposed_property_map.zig").ResourceRefProperty;
pub const GameObjectRefProperty = @import("exposed_properties/exposed_property_map.zig").GameObjectRefProperty;
pub const ScriptCodeProperty = @import("exposed_properties/exposed_property_map.zig").ScriptCodeProperty;
pub const Button = @import("exposed_properties/exposed_property_map.zig").Button;
pub const Category = @import("exposed_properties/exposed_property_map.zig").Category;

pub const ExposedPropertyLayoutReaderPtr = @import("exposed_properties/exposed_property_layout_reader.zig").ExposedPropertyLayoutReaderPtr;
