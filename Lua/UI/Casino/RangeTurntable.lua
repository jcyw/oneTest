--[[
    Author: songzeming
    Function: 靶场转盘
]]
local GD = _G.GD
local ChatModel = import("Model/ChatModel")

local RangeTurntable = UIMgr:NewUI("RangeTurntable")

local GlobalVars = GlobalVars
import("UI/Casino/RangeChipPrompt")

function RangeTurntable:OnInit()
    self.isFirstOpen = true
    self.isShooting = false
    local view = self.Controller.contentPane
    self._shootAnim = view:GetTransition("shootAnim")
    self._animShoot = view:GetTransition("animShoot")
    self._animReady = view:GetTransition("animReady")
    local uibg= self._uibg:GetChild("_icon")
    UITool.GetIcon({"falcon", "range_bg_01"},uibg)

    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("RangeTurntable")
    end)
    self:AddListener(self._btnHelp.onClick,function()
        self:OnBtnHelpClick()
    end)
    self:AddListener(self._bgNormal.onClick,function()
        UIMgr:Open("RangeChip", "Normal", self.casinoData)
    end)
    self:AddListener(self._bgHigh.onClick,function()
        UIMgr:Open("RangeChip", "High", self.casinoData)
    end)

    local _shoot = view:GetChild("shoot1")
    self:AddListener(_shoot.onClick,function()
        self:OnLottery()
    end)
    self:AddListener(self._iconCenter.onClick,function()
        self:OnLottery()
    end)
    self:AddListener(self._uibg.onTouchBegin,function(ctx)
        self.touchStartX = ctx.inputEvent.x
        self.touchStartY = ctx.inputEvent.y
    end)
    self:AddListener(self._uibg.onTouchEnd,function(ctx)
        if not self.touchStartX then
            return
        end
        self.touchEndX = ctx.inputEvent.x
        self.touchEndY = ctx.inputEvent.y
        --手指滑动投镖
        if math.abs(self.touchEndX - self.touchStartX) < 100 and math.abs(self.touchEndY - self.touchStartY) > 100 then
            self:OnLottery()
        end
    end)

    self:AddEvent(EventDefines.UIRangeTurntableData, function(casinoData)
        self.casinoData = casinoData
        if casinoData.Free or casinoData.Counts >= GlobalMisc.ShootingReward7 then
            self._prompt:SetPromptVisible(false)
        end
        self:UpdataData()
    end)
    self:AddEvent(EventDefines.RangeFlopClose, function(casinoData)
        self.casinoData = casinoData
        if self.huanEffect then
            NodePool.Set(NodePool.KeyType.RangeTurntableHuanEffect, self.huanEffect)
            self.isLotterying = false
            self.huanEffect = nil
        end
    end)
end

function RangeTurntable:OnOpen(casinoData)
    if self.isFirstOpen then
        self:FixBGImage()
        self.isFirstOpen = false
    end
    self.Controller.contentPane.touchable = true
    self.casinoData = casinoData
    self._prompt:SetPromptVisible(false)

    self._animReady:SetAutoPlay(true, -1, 0)
    self._animShoot:SetAutoPlay(true, -1, 0)
    ChatModel:OpenCasinoRadio()

    Net.Casino.GetCasinoNotice(function(msg)
        --     Event.Broadcast(EventDefines.RadioChatEvent, v)
        -- for _,v in pairs(msg.NoticeList)do
        -- end
        ChatModel:InsertMsgs(msg.NoticeList)
    end)

    --是否指引玩家投镖
    if not PlayerDataModel:GetData(PlayerDataEnum.RANGE_GUIDE_SHOOTING) then
        self._guide.visible = true
    else
        self._guide.visible = false
    end

    --打开界面回收十环特效
    if self.huanEffect then
        NodePool.Set(NodePool.KeyType.RangeTurntableHuanEffect, self.huanEffect)
        self.isLotterying = false
        self.huanEffect = nil
    end

    self.isLotterying = false --是否在抽奖中
    self:UpdataData()
end

function RangeTurntable:FixBGImage()
    --调整轮盘大小
    local bgMarker = self.Controller.contentPane:GetChild("bgMarker")
    if GlobalVars.ScreenRatio.x < GlobalVars.ScreenRatio.y and math.floor(GlobalVars.ScreenRatio.x * 100) ~= math.floor(GlobalVars.ScreenRatio.y * 100) then
        bgMarker.width = bgMarker.width/GlobalVars.ScreenRatio.y*GlobalVars.ScreenRatio.x
    else
        bgMarker.height = bgMarker.height/GlobalVars.ScreenRatio.x*GlobalVars.ScreenRatio.y
    end
    --调整Icon大小
    for i = 1, 11 do
        if GlobalVars.ScreenRatio.x < GlobalVars.ScreenRatio.y and math.floor(GlobalVars.ScreenRatio.x * 100) ~= math.floor(GlobalVars.ScreenRatio.y * 100) then
            self["_icon" .. i].width = self["_icon" .. i].width /GlobalVars.ScreenRatio.y * GlobalVars.ScreenRatio.x
            self["_icon" .. i].height = self["_icon" .. i].height /GlobalVars.ScreenRatio.y * GlobalVars.ScreenRatio.x
        else
            self["_icon" .. i].width = self["_icon" .. i].width /GlobalVars.ScreenRatio.x * GlobalVars.ScreenRatio.y
            self["_icon" .. i].height = self["_icon" .. i].height /GlobalVars.ScreenRatio.x * GlobalVars.ScreenRatio.y
        end
    end
end

function RangeTurntable:UpdataData()
    Net.Casino.GetCasinoInfo(
            function(rsp)
                self.casinoData = rsp
                self._textNormal.text = Tool.FormatNumberThousands(self.casinoData.Counts)
                self._textHigh.text = Tool.FormatNumberThousands(self.casinoData.HyperCounts)
            end
        )
    -- self._textNormal.text = Tool.FormatNumberThousands(self.casinoData.Counts)
    -- self._textHigh.text = Tool.FormatNumberThousands(self.casinoData.HyperCounts)

    --刷新奖池
    local poolConf = ConfigMgr.GetItem("configShootingOutRewards", self.casinoData.RewardPoolId)
    for i = 1, 11 do
        local reward = poolConf.rate[i]
        if reward.type == CommonType.RANGE_NORMAL_CARD_TYPE.Resource then
            --资源
            local conf = ConfigMgr.GetItem("configResourcess", reward.id)
            self["_icon" .. i].icon = UITool.GetIcon(conf.img)
        elseif reward.type == CommonType.RANGE_NORMAL_CARD_TYPE.Item then
            --道具
            local conf = ConfigMgr.GetItem("configItems", reward.id)
            self["_icon" .. i].icon = UITool.GetIcon(conf.icon)
        elseif reward.type == CommonType.RANGE_NORMAL_CARD_TYPE.High then
            --高级场入场券
            self["_icon" .. i].icon = "ui://9w9pozg0j6ym1e"
        end
    end

    if self.casinoData.Free then
        self._textSpend.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_27")
    else
        self._textSpend.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_10")
    end

    if next(self.casinoData.HyperGamblingInfo) ~= nil then
        if not self.isShooting then
            self:GoHigh()
        else
            -- self.Controller.contentPane.touchable = false 不需要,用这个就可以
            self:ScheduleOnce(function()
                self:GoHigh()
                -- self.Controller.contentPane.touchable = true
                self.isShooting = false
            end,1)
        end
    else
        self.isShooting = false
    end
end

--抽奖
function RangeTurntable:OnLottery()
    if self.isLotterying or self.isShooting then
        return
    end
    self.isShooting = true
    self.isLotterying = true
    PlayerDataModel:SetData(PlayerDataEnum.RANGE_GUIDE_SHOOTING, true)
    self._guide.visible = false
    if not self.casinoData.Free and self.casinoData.Counts < GlobalMisc.ShootingReward7 then
        --没有免费次数 且 飞镖靶单次消耗普通幸运币数量不足
        self._prompt:Init(self.casinoData)
        self.isLotterying = false
        return
    end
    --投掷飞镖回收十环特效
    if self.huanEffect then
        NodePool.Set(NodePool.KeyType.RangeTurntableHuanEffect, self.huanEffect)
        self.isLotterying = false
        self.huanEffect = nil
    end
    --发送抽奖信息
    Net.Casino.Gamble(function(rsp)
        self.casinoData.RewardPoolId = rsp.RewardPoolId --刷新奖池
        Net.Casino.GetCasinoInfo(
            function(rsp)
                self.casinoData = rsp
                self._textNormal.text = Tool.FormatNumberThousands(self.casinoData.Counts)
                self._textHigh.text = Tool.FormatNumberThousands(self.casinoData.HyperCounts)
            end
        )
        local shoot_end_func = function()
            -- 播放飞镖中板的特效
            NodePool.Init(NodePool.KeyType.RangeTurntableHitEffect, "Effect", "EffectNode")
            self.hitEffect = NodePool.Get(NodePool.KeyType.RangeTurntableHitEffect)
            self._blank:AddChild(self.hitEffect)
            self.hitEffect:InitNormal()
            self.hitEffect:PlayEffectSingle("effects/casino/prefab/effect_zhuanpan_guang",function()
                    NodePool.Set(NodePool.KeyType.RangeTurntableHitEffect, self.hitEffect)
                    self:UpdataData()
                end,Vector3(2,2,2))
            if rsp.Reward.Category == CommonType.RANGE_NORMAL_CARD_TYPE.Resource then
                --抽中资源
                local conf = ConfigMgr.GetItem("configResourcess", rsp.Reward.ConfId)
                local values = {
                    item_name = StringUtil.GetI18n(I18nType.Commmon, conf.key),
                    item_num = Tool.FormatNumberThousands(rsp.Reward.Amount)
                }
                TipUtil.TipById(50032, values, conf.img)
                self.isLotterying = false
            elseif rsp.Reward.Category == CommonType.RANGE_NORMAL_CARD_TYPE.Item then
                --抽中道具
                local conf = ConfigMgr.GetItem("configItems", rsp.Reward.ConfId)
                local values = {
                    item_name = GD.ItemAgent.GetItemNameByConfId(rsp.Reward.ConfId),
                    item_num = rsp.Reward.Amount
                }
                TipUtil.TipById(50032, values, conf.img)
                self.isLotterying = false
            elseif rsp.Reward.Category == CommonType.RANGE_NORMAL_CARD_TYPE.High then
                --抽中高级场入场券
                --临时逻辑，播放中心红圈特效
                self:ScheduleOnceFast(function()
                    NodePool.Init(NodePool.KeyType.RangeTurntableHuanEffect, "Effect", "EffectNode")
                    self.huanEffect = NodePool.Get(NodePool.KeyType.RangeTurntableHuanEffect)
                    self._blank:AddChild(self.huanEffect)
                    self.huanEffect:InitNormal()
                    self.huanEffect:PlayEffectSingle("effects/casino/prefab/effect_zhuanpan_huan")
                end,0.25)
            end
            self.casinoData.RewardPoolId = rsp.RewardPoolId
            self.casinoData.HyperGamblingInfo = rsp.HyperGamblingInfo
            self.casinoData.Free = false
            --self:UpdataData()
            --self.isLotterying = false
            --引导
            Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 13000, 0)
            self._animShoot:SetAutoPlay(true, -1, 0)
            Event.Broadcast(EventDefines.UIRangeTurntableData, self.casinoData)
        end
        self._shootAnim:Play(shoot_end_func)
        self._animShoot:SetAutoPlay(false, -1, 0) --SetAutoPlay启动的动画，要用SetAutoPlay关闭，不能用stop
    end)
end

--进入高级场
function RangeTurntable:GoHigh()
    UIMgr:Open("RangeFlop/RangeFlop", self.casinoData)
end

--点击帮助按钮
function RangeTurntable:OnBtnHelpClick()
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
        info = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_16")
    }
    UIMgr:Open("ConfirmPopupTextList", data)
end

function RangeTurntable:OnClose()
    ChatModel:CloseCasinoRadio()
end

return RangeTurntable
