--[[
    RoBeats CS Auto Player

    By Spencer#0003

    Literally just pasted my CS script with slight changes xdddd
]]

-- Init

local replicatedStorage = game:GetService("ReplicatedStorage");
local runService = game:GetService("RunService");

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LegoHacks/Utilities/main/UI.lua"))();

-- Main

local getNoteType;
local _game, trackSystem;

do --> Do blocks are sexy.
    local trackSystemModule = require(replicatedStorage.RobeatsGameCore.NoteTrack.NoteTrackSystem);
    local _gameModule = require(replicatedStorage.RobeatsGameCore.RobeatsGame);

    local trackSystemNew = trackSystemModule.new;
    local gameLocalNew = _gameModule.new;

    function _gameModule.new(...)
        _game = gameLocalNew(...); --> Grab the game table.
        return _game;
    end;

    function trackSystemModule.new(...)
        trackSystem = trackSystemNew(...); --> Grab the tracksystem.
        return trackSystem;
    end;

    -- Thanks Cyclops

    local noteResults = require(replicatedStorage.RobeatsGameCore.Enums.NoteResult); -- Auto update note results:)

    local enum_res = {
        missResult = noteResults.Miss;
        okayResult = noteResults.Okay;
        greatResult = noteResults.Great;
        perfectResult = noteResults.Perfect;
    };

    local mapped_e = {
        enum_res.perfectResult;
        enum_res.greatResult;
        enum_res.okayResult;
        enum_res.missPercentage;
    };

    function getNoteType()
        local r = Random.new();
        for i, v in ipairs{library.flags.perfectPercentage, library.flags.greatPercentage, library.flags.okayResult} do
            if (r:NextNumber(0, 100) <= v) then
                return mapped_e[i];
            end;
        end;

        return enum_res.missPercentage;
    end;
end;

local robeatsCS = library:CreateWindow("RoBeats CS");

robeatsCS:AddSlider({
    text = "Perfect";
    flag = "perfectPercentage";
    min = 0;
    max = 100;
    default = 0;
});

robeatsCS:AddSlider({
    text = "Great";
    flag = "greatPercentage";
    min = 0;
    max = 100;
    default = 0;
});

robeatsCS:AddSlider({
    text = "Good";
    flag = "goodPercentage";
    min = 0;
    max = 100;
    default = 0;
});

robeatsCS:AddSlider({
    text = "Okay";
    flag = "okayResult";
    min = 0;
    max = 100;
    default = 0;
});

robeatsCS:AddSlider({
    text = "Miss";
    flag = "missPercentage";
    min = 0;
    max = 100;
    default = 0;
});

robeatsCS:AddToggle({
    text = "Enabled";
    flag = "enabled";
});

runService:BindToRenderStep("RoBeat CS Hackles", 5, function()
    if (library.flags.enabled and _game and trackSystem) then
        local notes = trackSystem.get_notes();
        for i = 1, notes:count() do --> Loop through each note
            local noteType = getNoteType();
            local note = notes:get(i); --> Get the note.
            local noteTrack = note:get_track_index(); --> Get the track index.
            local testResult, testScoreResult = note:test_hit(_game); --> Test note hit result e.g. Marvelous, perfect etc.
            local testRelease, releaseScoreResult = note.test_release(_game); --> Test note hit result e.g. Marvelous, perfect etc.

            local track = trackSystem:get_track(noteTrack); --> Get track.
            if (testResult and testScoreResult == noteType) then
                track.press(); --> Press track (doesn't actually hit note).
                note.on_hit(_game, noteType, i); --> Fire on hit event for current note with chosen result e.g. Marvelous.
                delay(math.random(0.01, 0.5), function()
                    if (note.Type ~= "HeldNote") then
                        track.release(); --> Release the track.
                    end;
                end);
            elseif (testRelease and releaseScoreResult == noteType) then
                if (not note.Type) then
                    note.on_release(_game, noteType, i); --> If note is held, release it.
                    track.release(); --> Release the track.
                end;
            end;
        end;
    end;
end);

library:Init();
