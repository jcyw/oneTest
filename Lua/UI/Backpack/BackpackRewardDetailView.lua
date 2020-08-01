--[[
    author:Temmie
    time:2019-11-13 11:55:12
    function:物品详细界面
]]
local GD = _G.GD
local UIMgr = _G.UIMgr
local BackpackRewardDetailView = UIMgr:NewUI("BackpackRewardDetailView")

local StringUtil = _G.StringUtil
local I18nType = _G.I18nType

function BackpackRewardDetailView:OnInit()
    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("BackpackRewardDetailView")
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("BackpackRewardDetailView")
    end)
end

--[[
    items 列表显示内容。（icon 图标，title 名称，amount 数量，quality 品质框，tip 物品标签显示内容）
]]
function BackpackRewardDetailView:OnOpen(data)
    self._list:RemoveChildrenToPool()
    self._titleName.text = data.isRandom and StringUtil.GetI18n(I18nType.Commmon, "Ui_OpenGet") or StringUtil.GetI18n(I18nType.Commmon, "Ui_Backpack_Getreward")
    for _,v in pairs(data.items) do
        local item = self._list:AddItemFromPool()
        local itemProp = item:GetChild("itemProp1")
        --itemProp:SetIcon(v.icon)
        --itemProp:SetQuality(v.quality)
        --itemProp:SetAmountMid(v.id)
        item:GetChild("title").text = v.title
        item:GetChild("text").text = v.amount

        local mid = GD.ItemAgent.GetItemInnerContent(v.id)
        itemProp:SetShowData(v.icon,v.quality,nil,nil,mid)
    end
end

return BackpackRewardDetailView