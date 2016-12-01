--starting the virtual device
gl.setup(1920, 1080)

local json = require "json"

--setting the font
local font = resource.load_font "RobotoMono-Regular.ttf"
local font_size = 40

--load logo image
local logo = resource.load_image('logo-fsp.png');

--variables for background colors
local table_head_color
local odd_line_color
local even_line_color
local white
local comment_colors = {{r=0.9,g=0.9,b=0.9,a=1}, {r=1,g=0.5,b=0.5,a=1},{r=0.5,g=1,b=0,a=1}}

--returns the rgba values for the color
function get_rgba(color)
    return color.r, color.g, color.b, color.a
end

--returns the lines needed by an item
function get_line_count(item)
    local line_count=0
    if not item.info_only then
        line_count = line_count + 1
    end
    if item.comment ~= '' and item.comment ~= nil then
        line_count = line_count + 1
    end
    return line_count
end

--loading the config
local Config = (function()
    --needed variables
    local roomlist = {}
    local colors = {}
    local col_names = {}
    local timezone
    local header
    local page_duration

    --we watch the config.json file which is created on info-beamer hosting
    util.file_watch("config.json", function(raw)
        print "updated config.json"
        local config = json.decode(raw)
                
        roomlist = {}
        
        --filling the variables
        timezone = config.timezone
        header = config.header
        page_duration = config.page_duration
                
        --filling text colors
        colors[1] = config.background
        colors[2] = config.header_color
        colors[3] = config.tablehead_color
        colors[4] = config.font_color
        colors[5] = config.comment_color
                
        --filling background colors
        table_head_color = resource.create_colored_texture(get_rgba(config.tableheadbackground_color))
        odd_line_color = resource.create_colored_texture(get_rgba(config.odd_lines))
        even_line_color = resource.create_colored_texture(get_rgba(config.even_lines))
        white = resource.create_colored_texture(1,1,1,1);
        
        --filling col names
        col_names[1] = config.room_col
        col_names[2] = config.day_col
        col_names[3] = config.time_col
        col_names[4] = config.course_col
        col_names[5] = config.teacher_col

        local page=1
        local line_count=0
        roomlist[page] = {}
                
        --filling the roomlist
        for idx = 1, #config.roomlist do
            local item = config.roomlist[idx]
            
            line_count = line_count + get_line_count(item)
            
            if(line_count>18) then
                page=page+1;
                line_count=get_line_count(item)
                roomlist[page] = {}
            end
                    
            roomlist[page][#roomlist[page]+1] = {
                index = idx,
                room = item.room,
                day = item.day,
                time = item.time,
                course = item.course,
                teacher = item.teacher,
                info_only = item.info_only,
                comment = item.comment,
                color_schema = item.color_schema
                        
            }
        end
    end)

    --the functions reachable from the outside
    return {
        get_roomlist = function() return roomlist end;
        get_timezone = function() return timezone end;
        get_header = function() return header end;
        get_colors = function() return colors end;
        get_col_names = function() return col_names end;
        get_page_duration = function() return page_duration end;
    }
end)()

--function to write the room line
function write_line(x,y,room,day,time,course,teacher,color)
    offset_step_length=384
    offset_step=0
    font:write(x+(offset_step_length*(offset_step)),y,room,font_size,get_rgba(color))
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,day,font_size,get_rgba(color))
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,time,font_size,get_rgba(color))
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,course,font_size,get_rgba(color))
    offset_step = offset_step + 1
    font:write(x+(offset_step_length*(offset_step)),y,teacher,font_size,get_rgba(color))
end

--function to write the comment line for a room entry
function write_comment_line(y,comment,color)
    local width = font:width(comment,font_size);
    font:write(960-width/2,y,comment,font_size, get_rgba(color))
end

--standard render function used by info-beamer to draw the screen
function node.render()
    
    --get roomlist from config
    local roomlist = Config.get_roomlist()
    local colors = Config.get_colors()
    local cols = Config.get_col_names()
    
    local page=1
    
    if #roomlist > 1 then
        page = math.floor(((os.time()% (Config.get_page_duration() * #roomlist)) / Config.get_page_duration()) + 1)
    end
    
    roomlist = roomlist[page]
    
    --clear the screen
    gl.clear(get_rgba(colors[1]))
    
    logo:draw(624, 150, 1296, 1062, 0.15);
    
    font:write(960-(font:width(Config.get_header(),80)/2),0,Config.get_header(),80,get_rgba(colors[2]))
    
    --write header
    table_head_color:draw(0, 100, WIDTH, 100+font_size, 1)
    write_line(10,100,cols[1],cols[2],cols[3],cols[4],cols[5],colors[3])
    
    --write time in the upper right corner
    time = os.date("!%d.%m.%Y %H:%M", os.time() + Config.get_timezone()*60*60)
    font:write(1900-font:width(time,font_size),0,time,font_size,1,1,1,1)
    
    --set offset for the first line
    local offset=0

    --for each room entry
    for idx=1, #roomlist do
        
        --draw the lines background
        if not roomlist[idx].info_only then
            if (idx%2)==0 then
                odd_line_color:draw(0, 150+offset, WIDTH, 150+offset+font_size, 0.7)
            else
                even_line_color:draw(0, 150+offset, WIDTH, 150+offset+font_size, 0.7)
            end

            --write the line
            write_line(10,150+offset,roomlist[idx].room,roomlist[idx].day,roomlist[idx].time,roomlist[idx].course,roomlist[idx].teacher,colors[4])
            offset=offset+50
        end

        --if there is something written in the comment line for a room line
        if roomlist[idx].comment ~= '' and roomlist[idx].comment ~= nil then

            --setting strarting y of the comment line
            local y = 142+offset
            if roomlist[idx].info_only then
                y=150+offset
            end

            --draw background color of the roomline
            if (idx%2)==0 then
                odd_line_color:draw(0, y, WIDTH, 150+offset+font_size, 0.7)
            else
                even_line_color:draw(0, y, WIDTH, 150+offset+font_size, 0.7)
            end
            --draw comment line
            write_comment_line(150+offset, roomlist[idx].comment, comment_colors[roomlist[idx].color_schema])
            offset = offset+50
        end
    end
    
    --if there is no roomlist show a message
    if #roomlist == 0 then
        --draw background and write line
        odd_line_color:draw(0, 540-font_size/2, WIDTH, 540-font_size/2+font_size, 0.7)
        write_comment_line(540-font_size/2, "Kein Eintrag vorhanden", colors[4])
    end
    
    if #Config.get_roomlist() > 1 then
        --draw page progress
        progress = (os.time()% Config.get_page_duration())/Config.get_page_duration()
        white:draw(0,1060,WIDTH*progress,1080)
        
        --draw page number
        font:write(0,0,"(" .. page .. "/" .. #Config.get_roomlist() .. ")",font_size,1,1,1,1)
    end
    
end
