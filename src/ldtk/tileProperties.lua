local tileProperties = {}

tileProperties.flipBits = {
    [0] = "noFlip",
    [1] = "flipX",
    [2] = "flipY",
    [3] = "flipXY"
}

for i, v in pairs(tileProperties.flipBits) do
    tileProperties.flipBits[v] = i
end

return tileProperties
