local PATH = (...):gsub("%.init$", "")
local json = require(PATH..".lib.json")

local ldtk = {
    map = require(PATH..".map"),
    tileset = require(PATH..".tileset"),
    tileLayer = require(PATH..".tileLayer")
}

return ldtk
