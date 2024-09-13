local function bytesToIntLE(bytes)
    return bytes[1] +(bytes[2] *256) +(bytes[3] *256^2) +(bytes[4] *256^3)
end

local string_byte = string.byte
local file_Open = file.Open
local function OGGParse(sndPath)
    local file = file_Open("sound/" .. sndPath, "rb", "GAME")
    if !file then
        -- print("Error: Could not open file " .. sndPath)
        return nil
    end

    local size = file:Size()
    local t = {}
    for i = 1, size do
        t[i] = file:ReadByte()
    end
    file:Close()

    local length = -1
    local rate = -1
    -- for i = size -1 -8 -2 -4, 1, -1 do
    for i = size -15, 1, -1 do
        if t[i] == string_byte("O") && t[i +1] == string_byte("g") && t[i +2] == string_byte("g") && t[i +3] == string_byte("S") then
            local granule_bytes = {t[i +6], t[i +7], t[i +8], t[i +9], t[i +10], t[i +11], t[i +12], t[i +13]}
            length = granule_bytes[1] +granule_bytes[2] *256 +granule_bytes[3] *256^2 +granule_bytes[4] *256^3
            -- print("Granule Position (length): " .. length)
            break
        end
    end

    for i = 1,size -14 do
        if t[i] == string_byte("v") && t[i +1] == string_byte("o") && t[i +2] == string_byte("r") && t[i +3] == string_byte("b") && t[i +4] == string_byte("i") && t[i +5] == string_byte("s") then
            rate = bytesToIntLE({t[i +11], t[i +12], t[i +13], t[i +14]})
            -- print("Sample Rate: " .. rate)
            break
        end
    end

    if length > 0 && rate > 0 then
        return length /rate
    end

    -- print("Error: Could not determine OGG file duration.")
    return nil
end

local string_EndsWith = string.EndsWith
local string_lower = string.lower
local oldSoundDuration = SoundDuration
function SoundDuration(sndPath)
    if string_EndsWith(string_lower(sndPath), ".ogg") then
        return OGGParse(sndPath)
    end
    return oldSoundDuration(sndPath)
end