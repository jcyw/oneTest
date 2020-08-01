--[[
    author:{maxiaolong}
    time:2020-01-16 20:46:31
    function:{desc}
]]
local StageRankItem = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/StageRankItem", StageRankItem)
function StageRankItem:ctor()
    self._list = self:GetChild("List")
    self._title = self:GetChild("Title")
    self._list.itemRenderer = function(index, item)
        local data = self.rankData[index + 1]
        item:SetData(data, self.rankCatgroal)
    end
end

function StageRankItem:SetData(rankData, rankCatgroal, rankIndex)
    self.rankCatgroal = rankCatgroal
    if self.rankCatgroal == 1 then
        self._title:GetController("c1").selectedIndex = 0
        self._title:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "TITTLE_STAGE_RANK", {num = rankIndex})
        self.rankData = rankData[rankIndex].Members
    elseif self.rankCatgroal == 2 then
        self._title:GetController("c1").selectedIndex = 1
        self._title:GetChild("textName").text = StringUtil.GetI18n(I18nType.Commmon, "HISTORY_STRONGEST_COMMANDER")
        self._title:GetChild("textTiem").text= Tool.FormatTimeAll(rankData[rankIndex].RankTime) 
        self.rankData = rankData[rankIndex].Members
    end
    self._list.numItems = #self.rankData
    self._list:ResizeToFit(self._list.numChildren)
end

return StageRankItem
