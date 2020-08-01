--[[
    author:{maxiaolong}
    time:2019-09-23 13:51:29
    function:{在线奖励页面}
]]
local GD = _G.GD
local MainOnlineCheckInAward = UIMgr:NewUI("MainOnlineCheckInAward")

local UnionModel = import("Model/UnionModel")

function MainOnlineCheckInAward:OnInit()
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._liebiao = self._liebiao:GetChild("_liebiao")
    self._liebiao.scrollPane.touchEffect = false
    self:AddListener(self._bgMask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
    function()
        self:Close()
    end
)
    self._view:GetChild("titleName").icon = UITool.GetIcon(StringUtil.GetI18n(I18nType.WordArt, "1003"))
    self.GetBonusFunc = function()
        Net.OnlineBonus.GetBonus(
            function(params)
                --播放领奖动画
                UIMgr:Open("EffectRewardMask", CommonType.REWARD_TYPE.OnlineReward)
                --加入帮会提示
                UnionModel.CheckJoinPush(nil, nil, true)
                Model.NextBonusTime = params.NextBonusTime
                Model.OnlineBonusTime = Model.OnlineBonusTime + 1
                Event.Broadcast(EventDefines.UIGiftFinishing, params.NextBonusTime)
                self:SetTimeText()
                self:RefreshListView()
            end
        )
    end
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.OnlineAward)
    self:AddEvent(
        EventDefines.OnlineBonusInfoRefresh,
        function(rsp)
            Model.InitOtherInfo(ModelType.OnlineBonusList, rsp.OnlineBonusList)
            Model.NextBonusTime = rsp.NextBonusTime
            Model.OnlineBonusTime = rsp.OnlineBonusTime
            self:RefreshListView()
        end
    )
end

function MainOnlineCheckInAward:OnOpen(params)
    self.params =params
    self:UnSchedule(self.timeFunc)
    self.bounsCount = #self.params
    self.tfunc = function()
        if self.bounsCount>Model.OnlineBonusTime then
            return Model.NextBonusTime - Tool.Time()
        else
            local resetTime = Tool.Time() - Tool.Time()%86400 + 86400
            return resetTime - Tool.Time()
        end
    end
    if self.tfunc() < 0 then
        self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_REWARD_CLAIM_TEXT")
    else
        self:SetTimeText()
    end
    if not params then
        return
    end
    self:RefreshListView()
end

function MainOnlineCheckInAward:RefreshListView()
    local curIndex = Model.OnlineBonusTime + 1
    Model.InitOtherInfo(ModelType.CutOnlineBouns, self.params[curIndex])
    if self.effectFrame then
        NodePool.Set(NodePool.KeyType.OnlineItemEffect,self.effectFrame)
    end
    self._liebiao.itemRenderer = function(index, item)
        if not index then
            return
        end
        index = index + 1
        local conf = ConfigMgr.GetItem("configItems", self.params[index].ConfId)
        local mid = GD.ItemAgent.GetItemInnerContent(self.params[index].ConfId)
        item:SetAmount(conf.icon,conf.color,self.params[index].Amount,nil,mid)
        --  因低端机特效全屏蔽，临时添加选择框（对有特效时的效果无影响）
        item:SetChoose(index == curIndex and self.tfunc() <= 0 )
        if index == curIndex and self.tfunc() <= 0 then
            self:SetBonusEffect(item)
        end
        --item.grayed = i < curIndex
        item:SetMask(index < curIndex)
        item:SetPickTypeMidde(index < curIndex)
        item:ClickCB((index == curIndex and self.tfunc() <= 0) and self.GetBonusFunc or nil)
        item:SetData({GD.ItemAgent.GetItemNameByConfId(self.params[index].ConfId), GD.ItemAgent.GetItemDescByConfId(self.params[index].ConfId)})
    end
    self._liebiao:SetVirtual()
    self._liebiao.numItems = #self.params
    -- self._liebiao:RemoveChildrenToPool()
    -- for i = 1, #self.params do
    --     local item = self._liebiao:AddItemFromPool()
    --     local conf = ConfigMgr.GetItem("configItems", self.params[i].ConfId)
    --     local mid = GD.ItemAgent.GetItemInnerContent(self.params[i].ConfId)
    --     item:SetAmount(conf.icon,conf.color,self.params[i].Amount,nil,mid)
    --     --item:SetChoose(i == curIndex and self.tfunc() <= 0 )
    --     if i == curIndex and self.tfunc() <= 0 then
    --         self:SetBonusEffect(item)
    --     end
    --     --item.grayed = i < curIndex
    --     item:SetMask(i < curIndex)
    --     item:SetPickTypeMidde(i < curIndex)
    --     item:ClickCB((i == curIndex and self.tfunc() <= 0) and self.GetBonusFunc or nil)
    --     item:SetData({GD.ItemAgent.GetItemNameByConfId(self.params[i].ConfId), GD.ItemAgent.GetItemDescByConfId(self.params[i].ConfId)})
    -- end
end


function MainOnlineCheckInAward:SetBonusEffect(item)
    NodePool.Init(NodePool.KeyType.OnlineItemEffect, "Effect", "EffectNode")
    self.effectFrame = NodePool.Get(NodePool.KeyType.OnlineItemEffect)
    self.effectFrame.y = item.height / 2 - 20
    self.effectFrame.x = item.width / 2 + 3
    item:AddChild(self.effectFrame)
    self.effectFrame:InitNormal()
    self.effectFrame:PlayDynamicEffectLoop("effect_collect","effect_draw_frame", Vector3(130, 130, 130))
end

function MainOnlineCheckInAward:SetTimeText()
    local ctime = self.tfunc()
    if ctime > 0 then
        local barFunc = function(t)
            if self.bounsCount>Model.OnlineBonusTime then
                self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Time_Later_Recive", {time = TimeUtil.SecondToDHMS(t)})
            else
                self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_REWARD_RESET_TEXT", {time = TimeUtil.SecondToDHMS(t)})
            end
        end
        barFunc(ctime)
        self.timeFunc = function()
            ctime = self.tfunc()
            if ctime >= 0 then
                barFunc(ctime)
                return
            else
                --barFunc(0)
                self._timeText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_REWARD_CLAIM_TEXT")
                self:RefreshListView()
            end
        end
        self:Schedule(self.timeFunc, 1)
    else
        self:UnSchedule(self.timeFunc)
    end
end

function MainOnlineCheckInAward:Close()
    UIMgr:Close("MainOnlineCheckInAward")
end

function MainOnlineCheckInAward:OnClose()
    self:UnSchedule(self.timeFunc)
    CommonType.DAILY_REWARD_CLICK = true
    NodePool.Set(NodePool.KeyType.OnlineItemEffect,self.effectFrame)
end

return MainOnlineCheckInAward
