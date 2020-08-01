--author: 	Amu
--time:		2020-06-12 17:33:37
local GD = _G.GD
local Turntable = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/Turntable", Turntable)

local ChatModel = import("Model/ChatModel")
local GiftModel = import("Model/GiftModel")
local WelfareModel = import("Model/WelfareModel")

local RewardState = {}
RewardState.LuackDraw = 1
RewardState.GetReward = 2

function Turntable:ctor()
    self:SetShow(false)
    self._btnHelp = self:GetChild("btnHelp")

    self._textDec = self:GetChild("textDec")

    self._textLuckyValue = self:GetChild("textLuckyValue")
    self._btnLuckDraw = self:GetChild("btnLuckDraw")
    self._luckDrawText = self._btnLuckDraw:GetChild("title")
    self._luckDrawBumText = self._btnLuckDraw:GetChild("text")

    self._listView = self:GetChild("liebiao")


    for i=1, 10 do
        self["_item"..i] = self:GetChild("itemProp"..i)
    end

    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")


    self._textDec.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Txt")

    self._luckDrawText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Do")
    self._luckDrawBumText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Times", {number = 0})

    self._textLuckyValue.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Lucky", {number = 0})

    self.giftConfig = ConfigMgr.GetList("configLuckyGifts")
    self.itemConfig = ConfigMgr.GetList("configLuckyDraws")

    for k,v in ipairs(self.itemConfig)do
        --self["_item"..k]:SetData({Category = REWARD_TYPE.Item, ConfId = v.award[1].itemid})
        --self["_item"..k]:SetAmount(v.award[1].amount)
        --self["_item"..k]:SetAmountMid(v.award[1].itemid)
        --self["_item"..k]:SetControl(1)
        
        local icon,color = GD.ItemAgent.GetShowRewardInfo({Category = REWARD_TYPE.Item, ConfId = v.award[1].itemid})
        local mid = GD.ItemAgent.GetItemInnerContent(v.award[1].itemid)
        self["_item"..k]:SetShowData(icon,color,v.award[1].amount,nil,mid)

        self["_item"..k]:GetChild("_textBg").y = self["_item"..k]:GetChild("_textBg").y - 2
        self["_item"..k]:GetChild("_amount").y = self["_item"..k]:GetChild("_amount").y - 2
        self["_item"..k]:GetChild("_textBg").x = self["_item"..k]:GetChild("_textBg").x - 2
        self["_item"..k]:GetChild("_amount").x = self["_item"..k]:GetChild("_amount").x - 2

        local title = GD.ItemAgent.GetItemNameByConfId(v.award[1].itemid)
        local decs = GD.ItemAgent.GetItemDescByConfId(v.award[1].itemid)

        self:AddListener(self["_item"..k].onTouchBegin,function()
            if (self.detailPop and self.detailPop.OnShowUI) then
                self.detailPop:OnShowUI(title, decs, self["_item"..k], false)
            end
        end)

        self:AddListener(self["_item"..k].onTouchEnd, function()
            self.detailPop:OnHidePopup()
        end)

        self:AddListener(self["_item"..k].onRollOut,function()
            self.detailPop:OnHidePopup()
        end)
    end
    self.canLuackDraw = true
    self.RewardState = RewardState.LuackDraw

    self._banner.icon = UITool.GetIcon(GlobalBanner.TurntableActivity)



    --radio
    self._bg = self:GetChild("radioBg")
    self._cg = self:GetChild("radioItem")
    self._title = self._cg:GetChild("title")
    self._bgY = self._bg.y
    self._bgW = self._cg.width

    self:InitEvent()
end

local speed = Global.BroadCastSpeed
function Turntable:Roll(msg)
    self._roll = true
    self._title.text = TextUtil:ReplaceMoreBySpace(msg.Content, "\n", -1)
    local _width = -self._title.displayObject.width
    self._title.x = self._bgW
    self:GtweenOnComplete(self._title:TweenMoveX(_width, (math.abs(_width)+self._bgW)/speed):SetEase(EaseType.Linear),function()
        if self.isShow then
            local radio = ChatModel:GetTurntableRadio()
            self:Roll(radio)
        else
            self._roll = false
        end
    end)
end

function Turntable:InitEvent(  )
    self:AddListener(self._btnHelp.onClick,function()
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
            info = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_PackageTips")
        }
        UIMgr:Open("ConfirmPopupTextCentered", data)
    end)

    self:AddListener(self._btnGift.onClick, function()
        UIMgr:Open("RechargeGiftPackagePopupGift", function(rewards)
            UITool.ShowReward(rewards)
            GiftModel.SetDailyBonusFlag(false)
            self:RefreshGiftShow("hide")
            -- self:CheckDailyGiftPoint()
            Event.Broadcast(EventDefines.RefreshTurntableredpoint)
        end, Global.LuckDrawFreeGift)
    end)

    self:AddListener(self._btnLuckDraw.onClick,function()
        if self.RewardState == RewardState.LuackDraw then
            if not self.canLuackDraw then
                TipUtil.TipById(50319)
                return
            end
            if self._times and self._times <= 0 then
                TipUtil.TipById(50318)
                return
            end
            Net.ChargeActivity.Lotto(function(msg)
                self:PlayEffect(msg.RewardId)
                self.canLuackDraw = false
                self._times = msg.Times
                self._luckDrawBumText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Times", {number = msg.Times})
                self._textLuckyValue.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Lucky", {number = msg.Luck})
                Event.Broadcast(EventDefines.RefreshTurntableredpoint)
            end)
        elseif self.RewardState == RewardState.GetReward then
            Net.ChargeActivity.GetReward(function(msg)
                self.RewardState = RewardState.LuackDraw
                self._times = msg.Times
                self._luckDrawBumText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Times", {number = msg.Times})
                self._luckDrawText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Do")
                self.canLuackDraw = true

                if msg.Bonus then
                    msg.Rewards[1].Amount = math.ceil(msg.Rewards[1].Amount/2)
                    UITool.ShowReward(msg.Rewards, nil, true)
                else
                    UITool.ShowReward(msg.Rewards)
                end

                if self.effectFrame then
                    self.effectFrame:RemoveFromParent()
                    NodePool.Set(NodePool.KeyType.TurntableFrame, self.effectFrame)
                    self.effectFrame = nil
                end
                
                Event.Broadcast(EventDefines.RefreshTurntableredpoint)
            end)
        end
    end)

    self._listView:SetVirtualAndLoop()
    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        item:SetData(self.giftConfig[index+1], index+1, self._curGiftpackId, self.CanBuy)
    end

    self:AddListener(self._listView.onTouchBegin, function()
        self.scrollDis = Stage.inst:GetTouchPosition(1).x
    end)

    self:AddListener(self._listView.onTouchEnd, function()
        if self.scrollDis then
            local cur = Stage.inst:GetTouchPosition(1).x
            local dis = cur - self.scrollDis
            self.scrollDis = 0
            if dis < -80 and dis > -(Screen.width * 0.3) then
                self._listView.scrollPane:ScrollRight(1, true)
            elseif dis > 80 and dis < (Screen.width * 0.3) then
                self._listView.scrollPane:ScrollLeft(1, true)
            end
        end
    end)

    self:AddListener(self._listView.scrollPane.onScrollEnd,function(context)
        self:RefreshPointListView()
    end)

    local len = #self.giftConfig
    self._listPoint.itemRenderer = function(index, item)
        if not index then 
            return
        end
        local currentPageX = math.fmod(self._listView.scrollPane.currentPageX, len)
        item:SetData(currentPageX, index)
    end

    self:AddListener(self._listPoint.onClickItem,function(context)
        local item = context.data
        self._listView.scrollPane.currentPageX = item:GetIndex()
        self:RefreshPointListView()
    end)

    self:AddEvent(TURNTABLE_EVENT.TimesChange, function(msg)
        self._times = msg.Times
        self._luckDrawBumText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Times", {number = msg.Times})
        Event.Broadcast(EventDefines.RefreshTurntableredpoint)
    end)

    self:AddEvent(EventDefines.PurchaseGiftSuccess, function(id)
        if self._curGiftpackId == id then
            self.CanBuy = false
            self:InitListView()

            local config = GiftModel.GetGiftConfig(id)
            UIMgr:Open("RechargeGiftPackagePopup", config, true)
            Event.Broadcast(EventDefines.RefreshTurntableredpoint)
        end
    end)

    self:AddEvent(TIME_REFRESH_EVENT.Refresh, function()
        -- Event.Broadcast(EventDefines.RefreshTurntableredpoint)
        self:RefreshGiftShow("show")
    end)

    self:AddEvent(EventDefines.ExitWelfareMainEvnet, function()
        self.isShow = false
    end)

    self:AddEvent(TURNTABLE_EVENT.RadioChange, function()
        if not self._roll then
            local radio = ChatModel:GetTurntableRadio()
            if radio then
                self:Roll(radio)
            end
        end
    end)

    self.playFun = function()
        self:Play()
    end
end

--刷新礼包显示
function Turntable:RefreshGiftShow(type)
    CuePointModel:SetSingle(CuePointModel.Type.Warning, type == "show" and 1 or 0, self._btnGift, CuePointModel.Pos.Warning)
    if type == "show" then-- and not self.giftEffect
        self._btnGift.visible = true
        self.front, self.behind = AnimationModel.GiftEffect(self._btnGift, Vector3(2, 2, 1), nil, 
        "RechargeMainGift", self.front, self.behind, {x = -30, y = -30})
    else
        AnimationModel.DisPoseGiftEffect("RechargeMainGift", self.front, self.behind)
        self._btnGift.visible = false
    end
end

-- --检测提示点
-- function Turntable:CheckDailyGiftPoint()
--     local number = GiftModel.GetDailyBonusFlag() and 1 or 0
--     CuePointModel:Set(CuePointModel.SubType.Gift.DailyGift, number, self._btnGift)
-- end

function Turntable:OnOpen()
    self.isShow = true
    self._rewardId = 0

    local initFun = function(msg)
        self._curGiftpackId = msg.GiftpackId
        self._times = msg.Times
        self.CanBuy = msg.CanBuy
        self._rewardId = msg.RewardId

        GiftModel.SetDailyBonusFlag(msg.CanGetDailyBonus)
        self:RefreshGiftShow(GiftModel.GetDailyBonusFlag() and "show" or "hide")

        -- ChatModel:OpenTurnRadio()
        ChatModel:InsertMsgs(msg.Notifies)

        local radio = ChatModel:GetTurntableRadio()
        if not self._roll and radio then
            self:Roll(radio)
        end

        if self._rewardId ~= 0 and not self.effectFrame and not self._playing then
            self:ShowAwardEffect(self._rewardId)
        end
        self:SetRewardState(self._rewardId ~= 0)

        self._luckDrawBumText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Times", {number = msg.Times})
        self._textLuckyValue.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_LuckyDraw_Lucky", {number = msg.Luck})

        self:InitListView()

        for k,v in ipairs(self.giftConfig)do
            if self._curGiftpackId == v.purchaseid then
                self._listView.scrollPane.currentPageX = k-1
                self:RefreshPointListView()
                break
            end
        end
    end
    
    WelfareModel.GetLotteryInfo(function(msg)
        if msg then
            initFun(msg)
        end
    end)
    self:SetShow(true)
    self:PlayOpenAnimation()
end

function Turntable:SetData(info)
end

function Turntable:SetShow(isShow)
    self.visible = isShow
end
--设置抽奖按钮状态
function Turntable:SetRewardState(hasReward)
    self.canLuackDraw = not hasReward
    self.RewardState = hasReward and RewardState.GetReward or RewardState.LuackDraw
    self._luckDrawText.text = StringUtil.GetI18n(I18nType.Commmon, hasReward and "Ui_Get" or "Ui_LuckyDraw_Do")
end

function Turntable:InitListView(  )
    self._listView.numItems = #self.giftConfig
end

function Turntable:RefreshPointListView()
    -- self._listPoint.numItems = self._listView.scrollPane.contentWidth/self._listView.scrollPane.viewWidth
    self._listPoint.numItems = #self.giftConfig
end

local PlayState = {}
PlayState.UniformSpeed = 1
PlayState.SpeedUp = 2
PlayState.SlowDown = 3
local slowDownIndex = 5
local curPlayIndex = 0
local tragetInex
local curCircle = 0
local maxCircle = 2
local curPlayState = PlayState.UniformSpeed
local speed = 0
local Acc = 0.02
local Acc2 = 0.05
local startSpeend = 0.2

local awardLen = 10


function Turntable:PlayEffect(RewardId)
    for k,v in ipairs(self.itemConfig)do
        if v.id == RewardId then
            tragetInex = k
            break
        end
    end

    maxCircle = 0

    if tragetInex >= slowDownIndex then
        maxCircle = 2
    else
        maxCircle = 3
    end

    curPlayIndex = 1
    curCircle = 0
    curPlayState = PlayState.UniformSpeed
    speed = startSpeend
    
    self:Play()
end

function Turntable:Play()
    if curPlayIndex > awardLen then
        curCircle = curCircle + 1
        curPlayIndex = 1
        if curPlayState == PlayState.UniformSpeed then
            curPlayState = curPlayState + 1
        end
    end
    local item = self["_item"..curPlayIndex]

    self._playing = true

    NodePool.Init(NodePool.KeyType.TurntableCirCle, "Effect", "EffectNode")
    local effectCircle = NodePool.Get(NodePool.KeyType.TurntableCirCle)
    effectCircle.y = item._icon.height / 2
    effectCircle.x = item._icon.width / 2
    item:AddChild(effectCircle)
    effectCircle:InitNormal()


    -- effectCircle:PlayEffectSingle("effects/lottery_circle/prefab/effect_lottery_circle", function()
    effectCircle:PlayDynamicEffectSingle("effect_collect","effect_lottery_circle", function()
        if effectCircle then
            effectCircle:RemoveFromParent()
            NodePool.Set(NodePool.KeyType.TurntableCirCle, effectCircle)
        end
    end, Vector3(120, 120, 120))

    if curPlayState == PlayState.SpeedUp and curCircle == 3
        and tragetInex == math.fmod(curPlayIndex + slowDownIndex, awardLen) then
        speed = startSpeend
        curPlayState = curPlayState + 1
    end

    if curPlayState == PlayState.UniformSpeed then
        speed = startSpeend
    elseif curPlayState == PlayState.SpeedUp then
        speed = speed - curPlayIndex*Acc
    elseif curPlayState == PlayState.SlowDown then
        speed = speed + curPlayIndex*Acc2
        if speed >= startSpeend*2 then
            speed = startSpeend
        end
    end

    -- print("==========================curCircle:"        ..curCircle..
    --                                 "  maxCircle:"      ..maxCircle..
    --                                 "  curPlayState:"   ..curPlayState..
    --                                 "  tragetInex:"     ..tragetInex..
    --                                 "  curPlayIndex:"   ..curPlayIndex..
    --                                 "  speed:"          ..speed)

    if curCircle == maxCircle+1 and tragetInex == curPlayIndex then
        NodePool.Init(NodePool.KeyType.TurntableFrame, "Effect", "EffectNode")
        self.effectFrame = NodePool.Get(NodePool.KeyType.TurntableFrame)
        self.effectFrame.y = item._icon.height / 2 + 6
        self.effectFrame.x = item._icon.width / 2 + 4
        item:AddChild(self.effectFrame)
        self.effectFrame:InitNormal()

        NodePool.Init(NodePool.KeyType.TurntableGet, "Effect", "EffectNode")
        local effectGet = NodePool.Get(NodePool.KeyType.TurntableGet)
        effectGet.y = item._icon.height / 2
        effectGet.x = item._icon.width / 2
        item:AddChild(effectGet)
        effectGet:InitNormal()

        effectGet:PlayDynamicEffectSingle("effect_collect","effect_draw_get", function()
            if effectGet then
                effectGet:RemoveFromParent()
                NodePool.Set(NodePool.KeyType.TurntableGet, effectGet)
            end
        end, Vector3(120, 120, 120))

        self.effectFrame:PlayDynamicEffectLoop("effect_collect","effect_draw_frame", Vector3(130, 130, 130))

        self.RewardState = RewardState.GetReward
        self._playing = false
        self._luckDrawText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    else
        curPlayIndex = curPlayIndex + 1
        self:ScheduleOnceFast(self.playFun, speed)
    end
end

function Turntable:ShowAwardEffect(RewardId)
    self.canLuackDraw = false
    self.RewardState = RewardState.GetReward
    self._luckDrawText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")

    if not self.effectFrame then
        local item
        for k,v in ipairs(self.itemConfig)do
            if v.id == RewardId then
                item = self["_item"..k]
                break
            end
        end

        NodePool.Init(NodePool.KeyType.TurntableFrame, "Effect", "EffectNode")
        self.effectFrame = NodePool.Get(NodePool.KeyType.TurntableFrame)
        self.effectFrame.y = item._icon.height / 2 + 6
        self.effectFrame.x = item._icon.width / 2 + 4
        item:AddChild(self.effectFrame)
        self.effectFrame:InitNormal()

        self.effectFrame:PlayDynamicEffectLoop("effect_collect","effect_draw_frame", Vector3(130, 130, 130))
    end
end

function Turntable:PlayOpenAnimation()
    self:PlayListInit()
    self._btnLuckDraw.visible = false
    self._textLuckyValue.visible = false
    for i = 1, 10 do
        local item = self["_item"..i]
        AnimationLayer.UIAlphaAndScale(self,item,i,Vector2(1.3, 1.3),0.07, function(rewardId)
            if not self.effectFrame and self._rewardId ~= 0 and self._rewardId == rewardId and not self._playing then
                self:ShowAwardEffect(rewardId)
            end
        end, self.itemConfig[i].id)
        if i>=10 then
            self._btnLuckDraw.visible = true
            AnimationLayer.UIAlphaAndScale(self,self._btnLuckDraw,i+1,Vector2(1.3, 1.3),0.07,function()
                self._textLuckyValue.visible = true
                self:PlayListView()
            end)
        end
    end
end
function Turntable:PlayListInit()
    self._listView.touchable = false
    for i=1,self._listView.numChildren do
        local item = self._listView:GetChildAt(i - 1)
        item._listView.visible = false
    end
end
function Turntable:PlayListView()
    for i=1,self._listView.numChildren do
        local list = self._listView:GetChildAt(i - 1)
        list._listView.visible = true
        for i=1,list._listView.numItems do
            local item = list._listView:GetChildAt(i - 1)
            item.visible = true
            list._listView.scrollPane:ScrollTop()
            list._listView.touchable = false
            AnimationLayer.UIHorizontalMove(self,item,i,0.2,AnimationType.UILeftToRight,0,function()
                if i == list._listView.numChildren then
                    list._listView.touchable = true
                    self._listView.touchable = true
                end
            end)
        end
    end
end

function Turntable:OnClose()
    self:UnScheduleFast(self.playFun)
    self._playing = false
    if self.effectFrame then
        self.effectFrame:RemoveFromParent()
        NodePool.Set(NodePool.KeyType.TurntableFrame, self.effectFrame)
        self.effectFrame = nil
    end
end

return Turntable