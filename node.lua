gl.setup(1024, 768)

util.resource_loader{
    "font.ttf"
}

function node.render()
    gl.clear(0,0,0,1)
    font:write(250, 300, "Hello world", 64, 1,1,1,1)
end