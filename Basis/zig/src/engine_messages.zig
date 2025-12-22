// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

// Hand-converted BasisEngineMessages.h

// Categories.
pub const MESSAGE_CATEGORY_GAME_FLOW: c_uint = 1;
pub const MESSAGE_CATEGORY_AVATAR_TRACKING: c_uint = 2;
pub const MESSAGE_CATEGORY_RENDER_WINDOW_EVENT: c_uint = 3;
pub const MESSAGE_CATEGORY_LEVEL_EDITOR: c_uint = 4;
pub const MESSAGE_CATEGORY_NETWORK_CONNECTION: c_uint = 5;
pub const MESSAGE_CATEGORY_PLAYER_ACTIVITY: c_uint = 6;
pub const MESSAGE_CATEGORY_RAW_INPUT: c_uint = 7;
pub const MESSAGE_CATEGORY_INPUT_EVENTS: c_uint = 8;
pub const MESSAGE_CATEGORY_ASSET_BROWSER: c_uint = 9;

// Engine flow messages (category: MESSAGE_CATEGORY_GAME_FLOW)
pub const MESSAGE_START_LOADING_GAME: c_uint = 100;
pub const MESSAGE_START_UNLOADING_GAME: c_uint = 101;
pub const MESSAGE_END_GAME: c_uint = 102;
pub const MESSAGE_GAME_STARTED: c_uint = 103;
pub const MESSAGE_GAME_ENDED: c_uint = 104;
pub const MESSAGE_RETURN_TO_LOBBY: c_uint = 105;
pub const MESSAGE_BAIL_OUT_TO_SHUTDOWN: c_uint = 106;
pub const MESSAGE_TOGGLE_PAUSE_MENU: c_uint = 107;

// Avatar tracking messages (category: MESSAGE_CATEGORY_AVATAR_TRACKING)
pub const MESSAGE_SET_ACTIVE_AVATAR: c_uint = 108;
pub const MESSAGE_CLEAR_ACTIVE_AVATAR: c_uint = 109;
pub const MESSAGE_LOCAL_AVATAR_TRANSFORM_UPDATED: c_uint = 110;

// Render window event messages (category: MESSAGE_CATEGORY_RENDER_WINDOW_EVENT)
pub const MESSAGE_RENDER_WINDOW_ACTIVATED: c_uint = 111;
pub const MESSAGE_RENDER_WINDOW_DEACTIVATED: c_uint = 112;
pub const MESSAGE_RENDER_WINDOW_RESIZED: c_uint = 113;
pub const MESSAGE_RENDER_WINDOW_CLOSING: c_uint = 114;
pub const MESSAGE_RENDER_WINDOW_CLOSED: c_uint = 115;

// Level editor messages (category: MESSAGE_CATEGORY_LEVEL_EDITOR)
pub const MESSAGE_EDITOR_LEVEL_LOADED: c_uint = 116;
pub const MESSAGE_EDITOR_START_UNLOADING_LEVEL: c_uint = 117;
pub const MESSAGE_EDITOR_LEVEL_UNLOADED: c_uint = 118;
pub const MESSAGE_EDITOR_LEVEL_SAVED: c_uint = 119;
pub const MESSAGE_EDITOR_GAME_OBJECT_SELECTION_CHANGED: c_uint = 120;
pub const MESSAGE_EDITOR_GAME_OBJECT_HOVER_CHANGED: c_uint = 121;
pub const MESSAGE_EDITOR_FRAME_SELECTED_GAME_OBJECTS: c_uint = 122;
pub const MESSAGE_EDITOR_CAMERA_SPEED_CHANGED: c_uint = 123;
pub const MESSAGE_EDITOR_DRAWING_FLAGS_CHANGED: c_uint = 124;
pub const MESSAGE_EDITOR_GAME_OBJECT_CREATED: c_uint = 125;
pub const MESSAGE_EDITOR_GAME_OBJECT_DESTROYED: c_uint = 126;
pub const MESSAGE_EDITOR_GAME_OBJECT_RENAMED: c_uint = 127;
pub const MESSAGE_EDITOR_GAME_OBJECT_BOUNDS_UPDATED: c_uint = 128;
pub const MESSAGE_EDITOR_GAME_OBJECT_TRANSFORM_UPDATED: c_uint = 129;
pub const MESSAGE_EDITOR_GAME_OBJECT_HIDDEN: c_uint = 130;
pub const MESSAGE_EDITOR_GAME_OBJECT_UNHIDDEN: c_uint = 131;
pub const MESSAGE_EDITOR_GAME_OBJECT_REORDERED: c_uint = 132;
pub const MESSAGE_EDITOR_GAME_OBJECT_COMPONENT_DATA_UPDATED: c_uint = 133;
pub const MESSAGE_EDITOR_LAYER_CREATED: c_uint = 134;
pub const MESSAGE_EDITOR_LAYER_DESTROYED: c_uint = 135;
pub const MESSAGE_EDITOR_LAYER_REORDERED: c_uint = 136;
pub const MESSAGE_EDITOR_LIGHT_PROBE_DATA_UPDATED: c_uint = 137;
pub const MESSAGE_EDITOR_LIGHT_PROBE_REQUESTS_RERENDER: c_uint = 138;
pub const MESSAGE_EDITOR_QUERY_BACKGROUND_TASKS: c_uint = 139;
pub const MESSAGE_EDITOR_REPORT_BACKGROUND_TASK_RUNNING: c_uint = 140;
pub const MESSAGE_EDITOR_SET_CAMERA_TRANSFORM: c_uint = 141;

// Network connection messages (category: MESSAGE_CATEGORY_NETWORK_CONNECTION)
pub const MESSAGE_SERVER_CONNECTION_GOING_DOWN: c_uint = 142;
pub const MESSAGE_SERVER_CONNECTION_LOST: c_uint = 143;
pub const MESSAGE_LOBBY_SERVER_CONNECTION_GOING_DOWN: c_uint = 144;
pub const MESSAGE_LOBBY_SERVER_CONNECTION_LOST: c_uint = 145;

// Player activity messages (category: MESSAGE_CATEGORY_PLAYER_ACTIVITY)
pub const MESSAGE_PLAYER_JOINED_GAME: c_uint = 146;
pub const MESSAGE_PLAYER_LEFT_GAME: c_uint = 147;
pub const MESSAGE_PLAYER_SAID: c_uint = 148;

// Raw input messages (category: MESSAGE_CATEGORY_RAW_INPUT)
pub const MESSAGE_RAW_INPUT_MOUSE_PRESSED: c_uint = 149;
pub const MESSAGE_RAW_INPUT_MOUSE_RELEASED: c_uint = 150;
pub const MESSAGE_RAW_INPUT_MOUSE_MOVED: c_uint = 151;
pub const MESSAGE_RAW_INPUT_KEY_PRESSED: c_uint = 152;
pub const MESSAGE_RAW_INPUT_KEY_RELEASED: c_uint = 153;
pub const MESSAGE_RAW_INPUT_MOUSE_WHEEL_MOVED: c_uint = 154;

// Input event messages (category: MESSAGE_CATEGORY_INPUT_EVENTS)
pub const MESSAGE_INPUT_EVENT_GAME_INPUT_MODE_CHANGED: c_uint = 155;
pub const MESSAGE_INPUT_EVENT_GAMEPAD_CONNECTED: c_uint = 156;
pub const MESSAGE_INPUT_EVENT_GAMEPAD_DISCONNECTED: c_uint = 157;

// Asset browser message (category: MESSAGE_CATEGORY_ASSET_BROWSER)
pub const MESSAGE_ASSET_BROWSER_GAME_OBJECT_PREVIEWED: c_uint = 158;
pub const MESSAGE_RESET_ASSET_PREVIEW_CAMERA_VIEW: c_uint = 159;
