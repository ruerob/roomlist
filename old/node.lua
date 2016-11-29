gl.setup(1920, 1200)

util.resource_loader{
    "roboto.ttf"
}

function node.render()
    gl.clear(0,0,0,1)
    font:write(250, 300, "Hallo Raspberry. :0)", 64, 1,1,1,1)
end