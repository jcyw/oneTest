--[[
    author:{maxiaolong}
    time:2020-01-15 17:12:14
    function:{desc}
]]
local ItemRankingAward = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemRankingAward", ItemRankingAward)
local WelfareModel = import("Model/WelfareModel")
function ItemRankingAward:ctor()
    self._title = self:GetChild("text"):GetChild("textName")
    self._list = self:GetChild("liebiao")
    self._list.scrollPane.touchEffect = false
    self._list.itemRenderer = function(index, item)
        local len = 5
        if self.giftNum < (index+1)*5 then
            len = self.giftNum - index*5
        end
        item:SetData(index ,len, self.items)
    end
end
function ItemRankingAward:SetData(info, index, isMax)
    self.items, self.giftNum = WelfareModel.GetResOrItemByGiftId(info.id)
    local len = math.ceil(self.giftNum/5)
    self._list.numItems = len
    self._list:ResizeToFit(self._list.numChildren)
    if not isMax then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "AWARD_TITLE") .. index
    else
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = index})
    end
end

return ItemRankingAward
