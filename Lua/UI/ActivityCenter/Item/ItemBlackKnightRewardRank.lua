--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻积分详情ItemTag}
]]
local GD = _G.GD
local ItemBlackKnightRewardRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightRewardRank", ItemBlackKnightRewardRank)

---BuildSelectTip   环状操作列表item
function ItemBlackKnightRewardRank:ctor()
    self._itemProp = self:GetChild("itemProp")
end

function ItemBlackKnightRewardRank:Init(data, condition)
    local icon,color,mid = GD.ItemAgent.GetShowRewardInfo(data)
    self._itemProp:SetShowData(icon,color,nil,nil,mid)

    local nameStr = ""
    if data.Category == REWARD_TYPE.Res then
        nameStr = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_" .. data.ConfId)
    else
        nameStr = GD.ItemAgent.GetItemNameByConfId(data.ConfId)
    end
    self._textName.text = nameStr
    self._textNum.text = "X" .. data.Amount
end

return ItemBlackKnightRewardRank
