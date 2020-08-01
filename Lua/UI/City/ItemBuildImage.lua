--[[
    Author: songzeming
    Function: 建筑图片显示
]]
local ItemBuildImage = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemBuildImage", ItemBuildImage)
local GlobalVars = GlobalVars

function ItemBuildImage:ctor()
    self._icon = self:GetChild("icon")
end

function ItemBuildImage:SetImage(image)
    if GlobalVars.IsRestar then
        return
    end
    if not image then
        self.visible = false
        return
    end
    self.visible = true
    self._icon.icon = image
end

function ItemBuildImage:GetIcon()
    return self._icon
end

return ItemBuildImage
