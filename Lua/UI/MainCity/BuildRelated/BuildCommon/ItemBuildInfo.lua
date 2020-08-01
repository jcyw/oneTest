--[[
    Author: songzeming
    Function: 建筑信息
]]
local ItemBuildInfo = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/ItemBuildInfo", ItemBuildInfo)

function ItemBuildInfo:ctor()
end

function ItemBuildInfo:Init(title, desc)
    self._title.text = title
    self._desc.text = desc
end

function ItemBuildInfo:SetAlpha(alpha)
    self:SetTitleAlpha(alpha)
    self:SetDescAlpha(alpha)
end

function ItemBuildInfo:SetTitleAlpha(alpha)
    self._title.alpha = alpha
end

function ItemBuildInfo:SetDescAlpha(alpha)
    self._desc.alpha = alpha
end

return ItemBuildInfo
