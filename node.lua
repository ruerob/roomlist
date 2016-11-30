--starting the virtual device
gl.setup(1920, 1080)

local json = require "json"

-- setting the font
local font = resource.load_font "roboto.ttf"
local font_size = 40

--loading the config
local Config = (function()
    --needed variables
    local roomlist = {}
    local timezone

    --we watch the config.json file which is created on info-beamer hosting
    util.file_watch("config.json", function(raw)
        print "updated config.json"
        local config = json.decode(raw)
        
        --filling the variables
        timezone = config.timezone
        roomlist = {}

        --filling the roomlist
        for idx = 1, #config.roomlist do
            local item = config.roomlist[idx]
            roomlist[#roomlist+1] = {
                index = idx,
                room = item.room,
                day = item.day,
                time = item.time,
                course = item.course,
                teacher = item.teacher
            }
        end
    end)

    return {
        get_roomlist = function() return roomlist end;
        get_timezone = function() return timezone end;
    }
end)()

--function to write the line for the room
function write_line(x,y,room,day,time,course,teacher)
    offset_step_length=300
    offset_step=0
    font:write(x+(offset_step_length*(offset_step)),y,room,font_size,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,day,font_size,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,time,font_size,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,course,font_size,1,1,1,1)
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,teacher,font_size,1,1,1,1)
end

--standard render function used by info-beamer to draw the screen
function node.render()
    
    --get roomlist from config
    local roomlist = Config.get_roomlist()
    
    --clear the screen
    gl.clear(0, 0, 0, 1)
    
    --write header
    write_line(0,0,"Raum","Tag","Uhrzeit","Fach","Lehrer")
    
    --write time in the upper right corner
    time = os.date("!%H:%M", os.time() + Config.get_timezone()*60*60)
    font:write(1780,0,time,font_size,1,1,1,1)
    
    --set offset for the first line
    local offset=0
    
    --for each room entry
    for idx=1, #roomlist do
        
        --current time
        local time = os.time() + Config.get_timezone()*60*60
        
        --read out the start time for the room
        local timestamp = {}
        for t in string.gmatch((roomlist[idx].day .. ".") .. roomlist[idx].time, '%d+') do
            timestamp[#timestamp+1] = t
        end
        local start_time = os.time({year=tonumber(timestamp[3]), month=tonumber(timestamp[2]), day=tonumber(timestamp[1]), hour=tonumber(timestamp[4]), min=tonumber(timestamp[5])});
        
        --draw the line if the room start time wasn't 15 minutes ago
        if ( start_time > (time-15*60) ) then
            write_line(0,50+offset,roomlist[idx].room,roomlist[idx].day,roomlist[idx].time,roomlist[idx].course,roomlist[idx].teacher)
            offset=offset+50
        end
    end
    
    --debugging purposes
    font:write(0,1000,"Debug: passed without error",font_size,1,1,1,1)
end
