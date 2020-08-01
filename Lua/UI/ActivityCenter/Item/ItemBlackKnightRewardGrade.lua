--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻积分详情Item}
]]
local GD = _G.GD
local ItemBlackKnightRewardGrade = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightRewardGrade", ItemBlackKnightRewardGrade)

---BuildSelectTip   环状操作列表item
function ItemBlackKnightRewardGrade:ctor()
    self._itemProp = self:GetChild("itemProp")
    self:OnRegister()
end
function ItemBlackKnightRewardGrade:OnRegister()
end

function ItemBlackKnightRewardGrade:Init(data, condition, scoreInfo)
    local icon,color,mid = GD.ItemAgent.GetShowRewardInfo(data)
    self._itemProp:SetShowData(icon,color,nil,nil,mid)
    
    local nameStr = ""
    if data.Category == REWARD_TYPE.Res then
        nameStr = StringUtil.GetI18n(I18nType.Commmon, "RESOURE_TYPE_" ..  math.ceil(data.ConfId))
    else
        nameStr = GD.ItemAgent.GetItemNameByConfId(data.ConfId)
    end

    self._textName.text = nameStr
    self._textNum.text = "X"..data.Amount
    self._progressPersonal.max = condition[1]
    self._progressPersonal.value = scoreInfo.PlayerScore
    self._textPersonalNum.text = condition[1]

    self._progressUnion.max = condition[2]
    self._progressUnion.value = scoreInfo.AllianceScore
    self._textUnionNum.text =condition[2]
end

return ItemBlackKnightRewardGrade
