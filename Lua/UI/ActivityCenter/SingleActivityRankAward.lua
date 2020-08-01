--[[
    author:{laofu}
    time:2020-06-01 11:12:24
    function:{单人活动阶段排名奖励}
]]
local GD = _G.GD
local SingleActivityRankAward = UIMgr:NewUI("SingleActivityRankAward")
local WelfareModel = import("Model/WelfareModel")

local RANKTYPE = {
    [1] = "Ui_Single_Rank1",
    [2] = "Ui_Single_Rank2",
    [3] = "Ui_Single_Rank3",
    [4] = "Ui_Single_Rank4-10",
    [5] = "Ui_Single_Rank11-30",
    [6] = "Ui_Single_Rank31-50",
    [7] = "Ui_Single_Rank51-100"
}

function SingleActivityRankAward:OnInit()
    local view = self.Controller.contentPane
    self._titleText = view:GetChild("titleName")
    self._awardList = view:GetChild("liebiao")
    self._btnExit = view:GetChild("bgMask")
    self._btnClose = view:GetChild("btnClose")

    self._titleText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_Viewrewards")
    --提示说明
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")

    self:InitEvent()
end

function SingleActivityRankAward:InitEvent()
    self._awardList.itemRenderer = function(index, item)
        local title = item:GetChild("text"):GetChild("textName")
        local list = item:GetChild("liebiao")

        local giftIDs = self.rankAwards[index + 1].rank_award
        local giftID = giftIDs[Model.SingleActivity_Level - 4]
        local itemDatas = WelfareModel.GetResOrItemByGiftId(giftID)
        list.itemRenderer = function(index, item)
            local itemData = itemDatas[index + 1]
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

        title.text = StringUtil.GetI18n(I18nType.Commmon, RANKTYPE[index + 1])
        list.numItems = #itemDatas

        --列表大小
        list:ResizeToFit(list.numItems)
    end

    self:AddListener(self._btnExit.onClick,
        function()
            UIMgr:Close("SingleActivityRankAward")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("SingleActivityRankAward")
        end
    )
end

--道具提示
function SingleActivityRankAward:Label(id, item)
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

--rewards来自排名奖励|configRankAward表
function SingleActivityRankAward:OnOpen(rankAwards)
    self.rankAwards = rankAwards
    self._awardList.numItems = #self.rankAwards
end

function SingleActivityRankAward:OnClose()
end

return SingleActivityRankAward
