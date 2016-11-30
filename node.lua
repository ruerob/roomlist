gl.setup(1920, 1080)

local json = require "json"
local font = resource.load_font "roboto.ttf"

local Config = (function()
    local roomlist = {}

    util.file_watch("config.json", function(raw)
        print "updated config.json"
        local config = json.decode(raw)

        gl.setup(1920, 1080)

        roomlist = {}

        for idx = 1, #config.roomlist do
            local item = config.roomlist[idx]
            roomlist[#roomlist+1] = {
                index = idx,
                room = item.room,
                day = item.day,
                time = item.time,
                course = item.course,
                tacher = item.teacher
            }
        end
    end)

    return {
        get_roomlist = function() return roomlist end;
    }
end)()

local Time = (function()
    local base
    util.data_mapper{
        ["clock/set"] = function(t)
            base = tonumber(t) - sys.now()
        end
    }
    return {
        get = function()
            if base then
                return base + sys.now()
            end
        end
    }
end)()

function node.render()
    -- print("--- frame", sys.now())
    local roomlist = Config.get_roomlist()
    gl.clear(0, 0, 0, 1)
    font:write(10, 10, "|Raum|Tag|Uhrzeit|Fach|Lehrer", 80, 1,1,1,1)
    local offset=0
    for idx=1, #roomlist do
        font:write(10, 10+offset, "|" + roomlist[idx].room + "|" + roomlist[idx].day + "|" + roomlist[idx].time + "|" + roomlist[idx].course + "|" + roomlist[idx].teacher, 80, 1,1,1,1)
    end
end
