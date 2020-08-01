--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻积分Item}
]]
local ItemBlackKnightHistoryRank = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightHistoryRank", ItemBlackKnightHistoryRank)

---BuildSelectTip   环状操作列表item
function ItemBlackKnightHistoryRank:ctor()
    self._controller = self:GetController("c1")
    self:OnRegister()
end
function ItemBlackKnightHistoryRank:OnRegister()
end

function ItemBlackKnightHistoryRank:Init(index, data, showType)
    self._controller.selectedIndex = index < 3 and index or 3
    self._textNum.text = (index + 1) .. ""
    if showType == 1 then
        -- 个人排行榜
        --{color:#de350b}
        local nameStr = ""
        if data.AllianceName ~= "" then
            nameStr = string.format("(%s)%s", UITool.GetTextColor("#de350b", data.AllianceName), data.UserName)
        else
            nameStr = data.UserName
        end
        self._textName.text = nameStr
        CommonModel.SetUserAvatar(self._icon, data.UserAvatar, data.UserId)
    else
        self._icon.url = UnionModel.GetUnionBadgeIcon(data.AllianceAvatar)
        self._textName.text = data.AllianceName
    end

    -- AllianceAvatar:0
    -- AllianceId:"bnsq0jro6higt602dqv0"
    -- AllianceName:"qwe"
    -- AllianceShortName:"q8u"
    -- Rank:1
    -- UserAvatar:""
    -- UserId:""
    -- UserName:""
    -- Value:94000
end

return ItemBlackKnightHistoryRank

-------------------to do 多语言  时间   UI_TIME_FORM
