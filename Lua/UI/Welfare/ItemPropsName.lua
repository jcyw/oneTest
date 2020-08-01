--[[
    author:{maxiaolong}
    time:2019-10-24 16:28:48
    function:{活动奖励弹窗列表元素}
]]
local GD = _G.GD
local ItemPropsName = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemPropsName", ItemPropsName)
local WelfareModel = import("Model/WelfareModel")
function ItemPropsName:ctor()
    self._itemIcon = self:GetChild("icon")
    self._itemTitle = self:GetChild("title")
    self._itemNum = self:GetChild("text")
end

function ItemPropsName:SetData(data)
    self._itemIcon.icon = UITool.GetIcon(data[1].icon)
    self._itemNum.text = data[2]
    self._itemTitle.text = GD.ItemAgent.GetItemNameByConfId(data[1].id)
end
return ItemPropsName
