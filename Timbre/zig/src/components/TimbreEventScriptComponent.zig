// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");
const timbre = @import("../timbre.zig");

const GameObjectComponent = basis.component_contexts.GameObjectComponent;

const TimbreEventComponent = timbre.components.TimbreEventComponent;

//const Message = basis.messaging.Message;
//const MessageParametersPtr = basis.messaging.MessageParametersPtr;

const PropagatedAction = basis.network.PropagatedAction;
const PropagatedActionHandle = basis.network.PropagatedActionHandle;
const PropagatedValue = basis.network.PropagatedValue;
const PropagatedValueHandle = basis.network.PropagatedValueHandle;

const ScriptCode = basis.angelscript.ScriptCode;
const StringRefConstIn = basis.angelscript.StringRefConstIn;
const StringRefOut = basis.angelscript.StringRefOut;
const AngelScriptFunctionPtr = basis.angelscript.AngelScriptFunctionPtr;

const engine_messages = basis.engine_messages;

pub const TimbreEventScriptComponent = struct {
    const Self = @This();
    pub const RegistrationName = "timbre.TimbreEventScriptComponent";
    pub const UpdateOrder = 50;

    //----------------------------------------------------

    context: GameObjectComponent,

    eventComponent: ?*TimbreEventComponent = null,

    playAction: PropagatedActionHandle,
    stopAction: PropagatedActionHandle,

    // Exposed properties:
    scriptCode: ScriptCode,

    //----------------------------------------------------

    pub const ExposedPropertyMap = .{
        basis.exposed_properties.ScriptCodeProperty(Self, "scriptCode", ScriptCode.Template.Script, 1, ""),
    };

    pub fn registerAngelScript(reg: basis.angelscript.ComponentRegistration) !void {
        reg.registerComponentType("TimbreEventScriptComponent");

        reg.registerComponentMethod("void playEvent()", &_playEvent);
        reg.registerComponentMethod("void stopEvent()", &_stopEvent);
    }

    //----------------------------------------------------

    pub fn init(context: GameObjectComponent) !Self {
        return Self{
            .context = context,
            .playAction = PropagatedAction.init(
                context,
                "playAction",
                true,
                false,
            ),
            .stopAction = PropagatedAction.init(
                context,
                "stopAction",
                true,
                false,
            ),
            .scriptCode = ScriptCode.init(context.allocator),
        };
    }

    //----------------------------------------------------

    // pub fn create(self: *Self) !void { }

    pub fn onObjectCreated(self: *Self) !void {
        const go = self.context.getGameObject();
        self.eventComponent = go.getComponent(TimbreEventComponent); // This is null on the server.

        self.setupCallbacks();
    }

    pub fn destroy(self: *Self) !void {
        self.tearDownCallbacks();

        self.scriptCode.deinit();
        self.playAction.deinit();
        self.stopAction.deinit();
    }

    pub fn tick(self: *Self, tickDeltaTime: f32) !void {
        self.context.callScriptOnTick(tickDeltaTime);
    }

    pub fn beforeHotReload(self: *Self) !void {
        self.tearDownCallbacks();
    }

    pub fn afterHotReload(self: *Self) !void {
        self.setupCallbacks();
    }

    //----------------------------------------------------

    fn setupCallbacks(self: *Self) void {
        self.playAction.setActionFiredCallback(
            .initMethod(self, Self, onPlayActionFired),
        );

        self.stopAction.setActionFiredCallback(
            .initMethod(self, Self, onStopActionFired),
        );
    }

    fn tearDownCallbacks(self: *Self) void {
        self.playAction.clearActionFiredCallback();
        self.stopAction.clearActionFiredCallback();
    }

    fn onPlayActionFired(self: *Self, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;
        if (self.eventComponent) |ec| {
            ec.play();
        }
    }

    fn onStopActionFired(self: *Self, localChange: bool, valueTime: f64) void {
        _ = valueTime;
        _ = localChange;
        if (self.eventComponent) |ec| {
            ec.stop();
        }
    }

    //----------------------------------------------------

    fn _playEvent(_self: basis.IntPtr) callconv(.c) void {
        const self = basis.angelscript.getComponentSelf(Self, _self);
        self.playAction.fire();
    }

    fn _stopEvent(_self: basis.IntPtr) callconv(.c) void {
        const self = basis.angelscript.getComponentSelf(Self, _self);
        self.stopAction.fire();
    }
};
