--[[
    author:{zhanzhang}
    time:2019-11-29 16:10:23
    function:{缩略图城市名}
]]
local ItemResourceBeltMapName = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/itemResourceBeltMapName", ItemResourceBeltMapName)

function ItemResourceBeltMapName:ctor()
    self.textTopName = self:GetChild("textTopName")
    self.iconNationalFag = self:GetChild("iconNationalFag")
end

function ItemResourceBeltMapName:Init(data)
end

return ItemResourceBeltMapName
