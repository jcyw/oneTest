--[[
    author:{zhanzhang}
    time:2019-11-29 21:35:27
    function:{黑骑士奖励}
]]
local BlackKnightUnionRank = UIMgr:NewUI("BlackKnightUnionRank")

function BlackKnightUnionRank:OnInit()
    local view = self.Controller.contentPane

    self:OnRegister()
end

function BlackKnightUnionRank:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("BlackKnightUnionRank")
        end
    )
    -- --积分配置显示
    self._gradeContent:SetVirtual()
    self._gradeContent.itemRenderer = function(index, item)
        local reward = self.rewardList[self.rankIndex][index + 1]
        item:Init(index + 1, reward, self.rankIndex, true)
    end

    self.configReward = ConfigMgr.GetList("configKnightRewards")
    self.rewardList = {}
    for i = 1, 3 do
        self.rewardList[i] = {}
    end
    for i = 1, #self.configReward do
        local itemConfig = self.configReward[i]
        table.insert(self.rewardList[itemConfig.type], itemConfig)
    end
end
--index 1是个人 ,2是联盟
function BlackKnightUnionRank:OnOpen(index)
    -- self._textName.text = StringUtil.GetI18n(I18nType.Commmon, showtype == 2 and "UI_UNION_RANK_REWARD" or "UI_PERSONAL_RANK_REWARD")
    self.rankIndex = index + 1
    self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, index == 2 and "UI_UNION_RANK_REWARD" or "UI_PERSONAL_RANK_REWARD")
    self._gradeContent.numItems = #self.rewardList[index + 1]
    self._gradeContent.scrollPane:SetPosY(0)
end

return BlackKnightUnionRank
