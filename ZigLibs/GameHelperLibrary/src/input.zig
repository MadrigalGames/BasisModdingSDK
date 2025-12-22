// ----------------------------------------------------
// Copyright (c) 2018-2025 Madrigal Ltd.
// This file is part of the Basis modding SDK, and is subject to the
// terms and conditions of the Basis modding SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

const std = @import("std");
const basis = @import("basis");

const AppContext = basis.app.AppContext;

const InputType = basis.input.InputType;

const GamepadButton = basis.input.GamepadButton;
const InputSource = basis.input.InputSource;
const KeyCode = basis.input.KeyCode;
const InputMappingFlags = basis.input.InputMappingFlags;
const MouseButtonID = basis.input.MouseButtonID;

pub const InputContextID = enum(u8) {
    CinematicControls = basis.input.FirstInputContextID + 100,
};

pub const InputID = enum(u16) {
    // Cinematic controls.
    SkipCinematic = basis.input.FirstGameInputID + 1000,
    CinematicDummyInput,
};

pub fn addInputs(context: *AppContext) void {
    // Cinematic controls.
    context.addInput(InputID.SkipCinematic, InputType.Action);
    context.addInput(InputID.CinematicDummyInput, InputType.Action);
}

pub fn setInputMappings(appContext: *AppContext) void {
    // Cinematic controls.
    appContext.mapKeyboardInput(InputID.SkipCinematic, KeyCode.KEY_ESCAPE, InputContextID.CinematicControls);
    appContext.mapGamepadButtonInput(InputID.SkipCinematic, GamepadButton.B, InputContextID.CinematicControls);

    // When the CinematicControls ctxt is pushed, it is supposed to prevent the InputID.TogglePauseGame event from firing. This happens naturally
    // with the KB since the Escape key now maps to InputID.SkipCinematic instead, but the skipping is done with Button B on the gamepad, so instead
    // we map GamepadButton.Start to a dummy input which does nothing, except sits there and prevents InputID.TogglePauseGame from being fired.
    appContext.mapGamepadButtonInput(InputID.CinematicDummyInput, GamepadButton.Start, InputContextID.CinematicControls);
}

pub const PressedHeldInputHelper = struct {
    const Self = @This();

    const State = enum { NoInput, InputPressed, InputPressedPastThreshold };

    pub const Output = enum { None, Pressed, Held };

    //----------------------------------------------------

    // This determines how long the input has to be pressed to be considered "held".
    heldTimeThreshold: f32 = 1.0,

    //_inputDown: bool = false,
    _state: State = .NoInput,
    _timeSinceInputDown: f32 = basis.math.LargestNumber,

    //----------------------------------------------------

    pub fn tick(self: *Self, inputDown: bool, tickDeltaTime: f32) Output {
        if (self._state == .NoInput and inputDown) {
            self._timeSinceInputDown = 0.0;
            self._state = .InputPressed;
            //basis.print("PHIH: Input now down.\n");
        } else if (self._state == .InputPressed) {
            if (inputDown) {
                self._timeSinceInputDown += tickDeltaTime;
                //basis.printf("PHIH: Time: {d:.2}\n", .{self._timeSinceInputDown});

                if (self._timeSinceInputDown >= self.heldTimeThreshold) {
                    self._state = .InputPressedPastThreshold;
                    //basis.print("PHIH: Held\n");
                    return .Held;
                }
            } else {
                const pastThreshold = self._timeSinceInputDown >= self.heldTimeThreshold;
                self.reset();

                if (pastThreshold) {
                    //basis.print("PHIH: Held\n");
                    return .Held;
                } else {
                    //basis.print("PHIH: Pressed\n");
                    return .Pressed;
                }
            }
        } else if (self._state == .InputPressedPastThreshold and !inputDown) {
            self.reset();
        }

        return .None;
    }

    pub fn reset(self: *Self) void {
        self._state = .NoInput;
        self._timeSinceInputDown = basis.math.LargestNumber;
    }
};
