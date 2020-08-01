--[[
    author:{zhanzhang}
    time:2019-11-30 17:41:25
    function:{联合军进攻积分详情ItemTag}
]]
local ItemBlackKnightRewardGradeTag = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemBlackKnightRewardGradeTag", ItemBlackKnightRewardGradeTag)


---BuildSelectTip   环状操作列表item
function ItemBlackKnightRewardGradeTag:ctor()
end

function ItemBlackKnightRewardGradeTag:Init(index, data, scoreInfo)
    self.data = data
    self._content:RemoveChildrenToPool()
    self._textRewardTitle.text = StringUtil.GetI18n(I18nType.Commmon, "UI_POINTS_REWARD") .. index
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

            item:Init(info, data.condition, scoreInfo)
        end
        count = count + #gift.res
    end
    if gift.items then
        for i = 1, #gift.items do
            -- table.insert(self.rewardList, gift.res)

            info.Category = REWARD_TYPE.Item
            info.ConfId = gift.items[i].confId
            info.Amount = gift.items[i].amount
            local item = self._content:AddItemFromPool()
            item:Init(info, data.condition, scoreInfo)
        end
        count = count + #gift.items
    end
    self._content.height = count * 168
    self.height = count * 168 + 40
end

return ItemBlackKnightRewardGradeTag
