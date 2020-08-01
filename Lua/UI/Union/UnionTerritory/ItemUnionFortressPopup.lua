--[[
    author:{zhanzhang}
    time:2019-07-24 16:32:02
    function:{领地解锁条件Item}
]]
local ItemUnionFortressPopup = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionFortressPopup", ItemUnionFortressPopup)

local UnionModel = import("Model/UnionModel")
function ItemUnionFortressPopup:ctor()
    self._icon = self:GetChild("icon")
    self._text = self:GetChild("text")

    self._progressBar = self:GetChild("progressBar")
    self._textProgresBar = self:GetChild("textProgressBar")
end

--0为联盟堡垒数量要求
--1为联盟人数要求
--2为战斗力要求
--3联盟科技总等级
function ItemUnionFortressPopup:Init(content, curValue, maxValue, icon)
    self._text.text = content
    self._icon.url = icon
    self._progressBar.value = curValue
    self._progressBar.max = maxValue
    self._textProgresBar.text = curValue .. "/" .. maxValue
end

return ItemUnionFortressPopup
