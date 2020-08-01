--[[
    author:{laofu}
    time:2020-06-11 18:01:02
    function:{新城竞赛rank}
]]
local ItemNewWarZoneRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemNewWarZoneRank", ItemNewWarZoneRank)
local GD = _G.GD
local WelfareModel = import("Model/WelfareModel")

function ItemNewWarZoneRank:ctor()
    self._title = self:GetChild("title")
    self._list = self:GetChild("list")

    self._list.itemRenderer = function(index, item)
        local itemData = self.rewardDatas[index + 1]
        local itemCom = item:GetChild("item")
        itemCom:SetAmount(itemData.image, itemData.color, nil, nil, itemData.midStr)

        local title = item:GetChild("title")
        local countText = item:GetChild("count")
        title.text = itemData.title
        countText.text = "x" .. itemData.amount
    end
end

function ItemNewWarZoneRank:SetData(configRankInfo)
    local titleStr = GD.NewWarZoneActivityAgent.GetRankStr(configRankInfo)
    self._title.text = titleStr

    self.rewardDatas = WelfareModel.GetResOrItemByGiftId(configRankInfo.reward)
    self._list.numItems = #self.rewardDatas
    --列表大小
    self._list:ResizeToFit(self._list.numItems)
end

return ItemNewWarZoneRank
