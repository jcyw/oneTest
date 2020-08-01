--[[
    author:{laofu}
    time:2020-06-01 11:16:30
    function:{单人活动积分奖励}
]]
local GD = _G.GD
local ItemSingleActivityScoreReward = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemSingleActivityScoreReward", ItemSingleActivityScoreReward)
local WelfareModel = import("Model/WelfareModel")

function ItemSingleActivityScoreReward:ctor()
    self._title = self:GetChild("title")
    self._awardList = self:GetChild("liebiao")

    self._awardList.itemRenderer = function(index, item)
        local itemData = self.itemDatas[index + 1]
        local itemInfo = {
            Category = itemData.isRes and REWARD_TYPE.Res or REWARD_TYPE.Item,
            Amount = itemData.amount,
            ConfId = itemData.confId
        }
        local amount =  itemData.amount > 1 and ("x" .. itemData.amount) or nil
        local mid = GD.ItemAgent.GetItemInnerContent(itemData.confId)
        local icon,color = GD.ItemAgent.GetShowRewardInfo(itemInfo)
        item:SetShowData(icon,itemData.color,amount,nil,mid)
        item:RemoveEventListeners()
        self:Label(itemData.confId, item)
    end

    --提示说明
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

--道具提示
function ItemSingleActivityScoreReward:Label(id, item)
    local title = GD.ItemAgent.GetItemNameByConfId(id)
    local decs = GD.ItemAgent.GetItemDescByConfId(id)
    self:AddListener(item.onTouchBegin,
        function()
            if (self.detailPop and self.detailPop.OnShowUI) then
                self.detailPop:OnShowUI(title, decs, item, false)
            end
        end
    )

    self:AddListener(item.onTouchEnd,
        function()
            self.detailPop:OnHidePopup()
        end
    )

    self:AddListener(item.onRollOut,
        function()
            self.detailPop:OnHidePopup()
        end
    )
end

--data.score积分
--data.giftId礼包id
function ItemSingleActivityScoreReward:InitData(data)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Grade") .. ":" .. data.score
    self.itemDatas = WelfareModel.GetResOrItemByGiftId(data.giftId)
    --列表大小
    self._awardList:ResizeToFit(#self.itemDatas)
    self._awardList.numItems = #self.itemDatas
end

return ItemSingleActivityScoreReward
