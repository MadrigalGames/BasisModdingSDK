// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const builtin = @import("builtin");

pub const APIVersionNumber = 3;

pub const build_options = @import("basis_build_options");

// Namespaces:

//----------------------------------------------------
// Now using a hand-converted zig file instead of importing the C-header.
// pub const engine_messages = @cImport({
//     @cInclude("BasisEngineMessages.h");
// });
pub const engine_messages = @import("engine_messages.zig");
//----------------------------------------------------

pub const library_api = @import("bindings/library_api.zig");
pub const memory = @import("base/memory.zig");
pub const global_data = @import("global_data.zig");
pub const profiling = @import("base/profiling.zig");
pub const binary_stream = @import("binary_stream.zig");
pub const bindings = @import("bindings.zig");
pub const common = @import("common.zig");
pub const command_prompt = @import("command_prompt.zig");
pub const config_options = @import("config_options.zig");
pub const container = @import("container.zig");
pub const delegate = @import("delegate.zig");
pub const debug_overlay = @import("debug_overlay.zig");
pub const editor = @import("editor.zig");
pub const hot_reload = @import("hot_reload.zig");
pub const app = @import("app/app.zig");
pub const app_interface = @import("app/app_interface.zig");
pub const mod_controller = @import("mod/mod_controller.zig");
pub const mod_controller_interface = @import("mod/mod_controller_interface.zig");
pub const null_io = @import("null_io.zig");
pub const state_machine = @import("game_flow/state_machine.zig");
pub const flow_state = @import("game_flow/flow_state.zig");
pub const flow_state_interface = @import("game_flow/flow_state_interface.zig");
pub const host = @import("host.zig");
pub const player_controller = @import("player_controller.zig");
pub const string = @import("string.zig");
pub const debug_draw = @import("debug_draw.zig");
pub const math = @import("math.zig");
pub const messaging = @import("messaging.zig");
pub const meta = @import("meta.zig");
pub const input = @import("input.zig");
pub const imgui = @import("imgui.zig");
pub const implot = @import("implot.zig");
pub const typeinfo = @import("typeinfo.zig");
pub const network = @import("network.zig");
pub const physics = @import("physics.zig");
pub const resources = @import("resources.zig");
pub const renderer = @import("renderer.zig");
pub const game_object = @import("game_object.zig");
pub const game_session = @import("game_session.zig");
pub const game_state = @import("game_state.zig");
pub const navmesh_runtime = @import("navmesh_runtime.zig");
pub const components = @import("components/components.zig");
pub const component_factory = @import("components/component_factory.zig");
pub const component_contexts = @import("components/component_contexts.zig");
pub const streaming_utils = @import("streaming_utils.zig");
pub const json_helper = @import("json_helper.zig");
pub const utils = @import("utils.zig");
pub const os_utility = @import("os_utility.zig");
pub const level_data = @import("level_data.zig");
pub const exposed_properties = @import("exposed_properties.zig");
pub const angelscript = @import("angelscript.zig");
pub const animation = @import("animation.zig");
pub const serializable_blob = @import("serializable_blob.zig");

// Types:

pub const IntPtr = usize;
pub const IntPtr64 = u64;
pub const CppPtr = u64;
pub const WasmFuncPtr = u32;

pub const BinaryReadStream = binary_stream.BinaryReadStream;
pub const BinaryWriteStream = binary_stream.BinaryWriteStream;
pub const Color = @import("color.zig").Color;
pub const String = string.String;
pub const InPlaceString = @import("in_place_string.zig").InPlaceString;
pub const StringHash = string.StringHash;
pub const SerializableBlob = serializable_blob.SerializableBlob;
pub const RingBuffer = @import("ring_buffer.zig").RingBuffer;

pub const BoundedArray = @import("thirdparty/bounded_array.zig").BoundedArray;
//pub const ArrayList = std.ArrayList;
pub const ArrayList = std.array_list.Managed;
pub const HashMap = std.AutoHashMap;

// Global data ptr:

pub var g: *global_data.LibraryGlobalData = undefined;

// Misc:

// This forces the namespaces/modules to be loaded and the exports to be processed.
comptime {
    _ = library_api;
    _ = bindings.generated_bind_functions;
}

pub const printf = if (build_options.buildAsWASM)
    @import("base/print_on_host.zig").printOnHost
else
    std.debug.print;

// Same as printf but without having to pass .{} as a second argument if no args are used.
pub fn print(comptime str: []const u8) void {
    printf(str, .{});
}

//pub const assert = std.debug.assert;
pub const assert = @import("base/assert.zig").assert;
pub const assertd = @import("base/assert.zig").assertWithMessage;
pub const assertf = @import("base/assert.zig").assertWithFormat;

pub const fatalError = @import("base/fatal_error.zig").fatalError;
pub const fatalErrorWithName = @import("base/fatal_error.zig").fatalErrorWithName;
pub const fatalErrorWithMessage = @import("base/fatal_error.zig").fatalErrorWithMessage;
pub const fatalErrorWithFormat = @import("base/fatal_error.zig").fatalErrorWithFormat;

pub fn forceAnalysis() void {
    // NOTE: At the time of writing, running forceAnalysis() with all modules included
    // fails with the error "The Writer interface is only defined for BoundedArray(u8, ..."
    // due to the fact that we use BoundedArrays with types other than u8 in the
    // vehicle_controller module. It is a bit silly that BoundedArrays give compile errors
    // when fully analyzed unless the type is u8 but what can you do. Because of this, the
    // vehicle_controller module is currently left out.

    const modules = .{
        library_api,
        memory,
        profiling,
        binary_stream,
        bindings,
        common,
        command_prompt,
        config_options,
        container,
        delegate,
        debug_overlay,
        editor,
        app,
        app_interface,
        state_machine,
        flow_state,
        flow_state_interface,
        host,
        player_controller,
        string,
        debug_draw,
        math,
        messaging,
        meta,
        input,
        imgui,
        implot,
        typeinfo,
        network,
        null_io,

        // We have to do physics modules separately. See comment above.
        physics.physics_engine,
        physics.physics_actor,
        physics.physics_scene,
        physics.physics_shape,
        physics.physics_material,
        physics.physics_transform,
        physics.physics_joint,
        physics.character_controller,
        //physics.vehicle_controller,
        physics.vehicles,

        resources,
        renderer,
        game_object,
        game_session,
        game_state,
        navmesh_runtime,
        components,
        component_factory,
        component_contexts,
        streaming_utils,
        json_helper,
        utils,
        os_utility,
        level_data,
        exposed_properties,
        angelscript,
        animation,
        serializable_blob,
    };

    inline for (modules) |module| {
        std.testing.refAllDecls(module);
    }
}
