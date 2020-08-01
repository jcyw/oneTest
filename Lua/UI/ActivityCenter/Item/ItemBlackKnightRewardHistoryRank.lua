--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻历史积分排行}
]]
local GD = _G.GD
local ItemBlackKnightRewardHistoryRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightRewardHistoryRank", ItemBlackKnightRewardHistoryRank)

---BuildSelectTip   环状操作列表item
function ItemBlackKnightRewardHistoryRank:ctor()
    self._controller = self:GetController("c1")
end

function ItemBlackKnightRewardHistoryRank:Init(index, data)
    self._controller.selectedIndex = index < 3 and index or 3
    if data.Category == REWARD_TYPE.Res then
        self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_" .. data.ConfId)
    else
        self._textName.text = GD.ItemAgent.GetItemNameByConfId(data.ConfId)
    end
end

return ItemBlackKnightRewardHistoryRank
