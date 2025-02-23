local subtitleLogFilePath = "subtitles_log.txt"
local dialogChoicesLogFilePath = "dialog_choices_log.txt"

-- Open the subtitle log file for appending.
local subtitleFile = io.open(subtitleLogFilePath, "a")
if not subtitleFile then
    print("Failed to open subtitle log file!")
end

-- Cached subtitle to avoid duplicate logging.
local cachedSub = "\n"

-- Hook into the subtitle UI system.
Observe("BaseSubtitlesGameController", "SetupLine", function(self, lineWidget, lineSpawnData)
    if lineSpawnData and lineSpawnData.lineData then
        local subtitleText = lineSpawnData.lineData.text or "UNKNOWN_TEXT"
        local speaker = lineSpawnData.lineData.speakerName or "Unknown Speaker"
        -- Only log the subtitle if it's different from the last one.
        if subtitleText ~= cachedSub then
            print(speaker .. ": " .. subtitleText)
            if subtitleFile then
                subtitleFile:write(os.date("%X") .. " - " .. speaker .. ": " .. subtitleText .. "\n")
                subtitleFile:flush()
            end
            cachedSub = subtitleText
        end
    end
end)

-- Cached dialog choice to avoid duplicate logging.
local cachedChoice = "cached"

-- Hook into the dialog choice UI system.
Observe("DialogHubLogicController", "SetData", function(self, value)
    if value and value.choices then 
        -- Open the dialog choices log file (append mode).
        local dialogChoicesFile = io.open(dialogChoicesLogFilePath, "w+")
        if dialogChoicesFile then
            local dialogChoiceTable = value.choices
            for i, choice in ipairs(dialogChoiceTable) do
                local choiceText = choice.localizedName or "UNKNOWN_CHOICE"
                if cachedChoice ~= choiceText then
                    print("Player Choice: " .. choiceText)
                    dialogChoicesFile:write(os.date("%X") .. " - " .. choiceText .. "\n")
                    dialogChoicesFile:flush()
                    cachedChoice = choiceText
                end
            end 
            io.close(dialogChoicesFile)
        else
            print("Failed to open dialog choices log file!")
        end
    end
end)
