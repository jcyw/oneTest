--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻积分详情ItemTag}
]]
local ItemBlackKnightRewardRanklTag = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightRewardRanklTag", ItemBlackKnightRewardRanklTag)

---BuildSelectTip   环状操作列表item
function ItemBlackKnightRewardRanklTag:ctor()
    self._controller = self:GetController("c1")

    self:AddListener(self._btnAllReward.onClick,
        function()
            UIMgr:Open("BlackKnightUnionRank", self.showType)
        end
    )
    -- 1为个人 2为联盟
    self:AddListener(self._btnUnionRank.onClick,
        function()
            Net.Siege.GetHistoryRank(
                2,
                function(data)
                    UIMgr:Open("BlackKnightHistoryRank", 2, data.RankInfos)
                end
            )
        end
    )
    self:AddListener(self._btnPersonRank.onClick,
        function()
            Net.Siege.GetHistoryRank(
                1,
                function(data)
                    UIMgr:Open("BlackKnightHistoryRank", 1, data.RankInfos)
                end
            )
        end
    )
end
--index 序号
--showType 联盟或者个人 2为联盟 1为个人
--isRank 是否为排行榜
function ItemBlackKnightRewardRanklTag:Init(index, data, showtype, isRank)
    self.showType = showtype
    self.isRank = isRank
    self._controller.selectedIndex = isRank and 0 or 1
    self.data = data
    self._content:RemoveChildrenToPool()
    self._textTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_RANK_NUMBER", {num = index})

    local gift = ConfigMgr.GetItem("configGifts", data.reward)

    local count = 0
    --首先判断资源
    local info = {}
    if gift.res then
        -- table.insert(self.rewardList, gift.res)
        for i = 1, #gift.res do
            local item = self._content:AddItemFromPool()
            info.Category = REWARD_TYPE.Res
            info.ConfId = gift.res[i].category
            info.Amount = gift.res[i].amount

            item:Init(info, data.condition)
        end
        count = count + #gift.res
    end
    if gift.items then
        for i = 1, #gift.items do
            info.Category = REWARD_TYPE.Item
            info.ConfId = gift.items[i].confId
            info.Amount = gift.items[i].amount
            local item = self._content:AddItemFromPool()
            item:Init(info, data.condition)
        end
        count = count + #gift.items
    end
    self._content.height = count * 113
    if not isRank then
        self.height = count * 113 + 500
    else
        self.height = self._content.height + 40
    end
end

return ItemBlackKnightRewardRanklTag
