// ----------------------------------------------------
// Copyright (c) 2018-2026 Madrigal Ltd.
// This file is part of the Basis SDK, and is subject to the
// terms and conditions of the Basis SDK License Agreement.
// https://www.madrigalgames.com
// ----------------------------------------------------

// Auto-delay inserted between consecutive dialogue lines. Used by both
// mission real-time dialogue (cpp side) and the conversation system.
//
// Keep these in sync with Nemo/include/nemo/NemoDialogueTiming.h.

pub const AutoDelaySameSpeaker: f32 = 0.3;
pub const AutoDelaySpeakerChange: f32 = 0.6;

// Auto-delay inserted between a player choice selection and the first
// dialogue line that follows. Conversation-only.
pub const AutoDelayAfterChoice: f32 = 0.4;
