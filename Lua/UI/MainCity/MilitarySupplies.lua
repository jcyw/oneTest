-- author:  Amu
-- time:    2019-06-20 19:15:34
local GD = _G.GD

local MilitarySupplies = UIMgr:NewUI("MilitarySupplies")

local CHIP_COST = _G.ConfigMgr.GetVar("Res4Equip")

MilitarySupplies.effectList = {}
MilitarySupplies.effectIconList = {}

local BuildModel = import("Model/BuildModel")

function MilitarySupplies:OnInit()
    self._view = self.Controller.contentPane

    self._textFreeSupply = self._view:GetChild("textFreeSupply")
    self._itemNum = self._view:GetChild("itemNum")
    self._freeNum = self._view:GetChild("textFreeNum")
    self._btnHelp = self._view:GetChild("btnHelp")
    self._btnAdd = self._view:GetChild("btnAdd")

    -- self._view:GetChild("bgRing").visible = false
    self._itemNum.visible = false

    self._resList = {}

    self.tagRes = self._view:GetChild("tagResources")
    self.tagRes:InitMS()

    local resList = {RES_TYPE.Wood, RES_TYPE.Food, RES_TYPE.Res4Equip, RES_TYPE.Iron, RES_TYPE.Stone}
    for k, v in ipairs(resList) do
        --local str = "item" .. k
        local itemGroup = self._view:GetChild("itemList")
        local item = itemGroup:GetChildAt(k - 1)
        self._resList[v] = {}
        self._resList[v].item = item
        self._resList[v].ctrView = item:GetController("c1")
        self._resList[v].resNum = item:GetChild("title")
        self._resList[v].icon = item:GetChild("icon")
        -- self._resList[v].goldIcon = item:GetChild("iconGold")
        self._resList[v].btnGold = item:GetChild("btnGold")
        self._resList[v].goldNum = item:GetChild("btnGold"):GetChild("title")
        self._resList[v].freeText = item:GetChild("btnFree")
        self._resList[v].textGray = item:GetChild("btnLock")
        self._resList[v].lock = item:GetChild("groupLock")
        self._resList[v].name = item:GetChild("textName")
        self._resList[v].gold = 0
    end

    for k, v in pairs(self._resList) do
        local a = ConfigMgr.GetItem("configResourcess", k).icon_supply
        v.icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", k).icon_supply)
    end

    self._effectInfoList = {}
    self.isPlay = false
    self:InitEvent()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.MilitarySupplies)
end

function MilitarySupplies:OnOpen(building)
    self._effectInfoList = {}
    self.isPlay = false
    self.centerLevel = BuildModel.GetCenterLevel()
    self.msInfos = Model.GetMap(ModelType.MSInfos)
    self.resInfo = ConfigMgr.GetItem("configMilitarySupplys", 428000 + self.msInfos.Level)
    self:RefreshPanel()
    self:RefreshCPURes()
end

function MilitarySupplies:RefreshCPURes()
    self._cpuIcon.url = GD.ResAgent.GetIconUrl(CHIP_COST)
    self._cpuNum.text = GD.ResAgent.Amount(CHIP_COST, true)
end

function MilitarySupplies:RefreshPanel()
    self.msInfos = Model.GetMap(ModelType.MSInfos)
    -- self.FreeTimes = self.msInfos.FreeTimes + self.msInfos.Times
    self.FreeTimes = self.msInfos.FreeTimes

    self.TotalTimes = 0

    local index = 0
    for k, v in pairs(self._resList) do
        index = index + 1
        local times = self.msInfos.MSItems[index].TotalTimes
        self.TotalTimes = self.TotalTimes + times
        local amount = 0
        for _, res in pairs(self.resInfo.res) do
            if res.category == k then
                amount = res.amount
                break
            end
        end
        v.resNum.text = math.floor(amount * (1 + times * MILITARY_SUPPLY.ResSupplyIncrease / 100))
        v.name.text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. k)
        if self.centerLevel >= RES_LOCK[k] then
            -- v.lock.visible = false
            v.ctrView.selectedIndex = 0
        else
            -- v.lock.visible = true
            v.ctrView.selectedIndex = 1
        end
        if self.FreeTimes <= 0 then
            -- v.textGray.visible = false
            local gold = MILITARY_SUPPLY.MilitarySupplyFee + MILITARY_SUPPLY.MilitarySupplyFeeStep * self.msInfos.MSItems[index].UsedTimes
            if gold >= MILITARY_SUPPLY.MilitarySupplyFeeMax then
                gold = MILITARY_SUPPLY.MilitarySupplyFeeMax
            end
            v.goldNum.text = gold
            -- v.goldIcon.visible = true
            v.btnGold.visible = true
            v.freeText.visible = false
        else
            -- v.textGray.visible = false
            v.btnGold.visible = false
            -- v.goldIcon.visible = false
            v.freeText.visible = true
        end
    end
    if (self.TotalTimes - MILITARY_SUPPLY.MilitarySupplyLimit) >= 0 and self.FreeTimes <= 0 then
        for k, v in pairs(self._resList) do
            v.btnGold.visible = false
            -- v.goldIcon.visible = false
            v.freeText.visible = false
            v.textGray.visible = true
            -- v.textGray.visible = true
        end
    end
    if self.FreeTimes > 0 then
        self._textFreeSupply.text = UITool.GetTextColor(GlobalColor.Blue, StringUtil.GetI18n(I18nType.Commmon, "UI_Free_Supply"))
        self._freeNum.text = UITool.GetTextColor(GlobalColor.Blue, self.FreeTimes)
    else
        if (MILITARY_SUPPLY.MilitarySupplyLimit - self.TotalTimes) <= 0 then -- 特殊处理
            self._textFreeSupply.text = StringUtil.GetI18n(I18nType.Commmon, "UI_NO_Supply")
            self._freeNum.text = " "
        else
            self._textFreeSupply.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Rest_Supply")
            self._freeNum.text = MILITARY_SUPPLY.MilitarySupplyLimit - self.TotalTimes
        end
    end
end

function MilitarySupplies:InitEvent()
    self:AddListener(self._view:GetChild("btnReturn").onClick,
        function()
            self:Close()
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            local data = {
                title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                info = StringUtil.GetI18n(I18nType.Commmon, "Supply_Explain")
            }
            UIMgr:Open("ConfirmPopupTextList", data)
        end
    )

    self:AddListener(self._btnAdd.onClick,
        function()
            local itemInfo = GD.ItemAgent.GetItemModelById(MILITARY_SUPPLY.MSItemConfId)
            local _leftTimes = MILITARY_SUPPLY.MilitarySupplyLimit - self.FreeTimes - self.TotalTimes
            if not itemInfo or itemInfo.Amount <= 0 then
                local data = {
                    title = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
                    info = StringUtil.GetI18n(I18nType.Commmon, "Tips_No_Supply_Item")
                }
                UIMgr:Open("ConfirmPopupTextList", data)
                return
            end
            if _leftTimes <= 0 then
                TipUtil.TipById(50111)
                return
            end

            local _amount = itemInfo.Amount
            if _leftTimes < itemInfo.Amount then
                _amount = _leftTimes
            end

            local data = {
                config = ConfigMgr.GetItem("configItems", MILITARY_SUPPLY.MSItemConfId),
                amount = _amount,
                useCallBack = function()
                    self:RefreshPanel()
                end
            }
            UIMgr:Open("ResourceDisplayUse", data)
        end
    )

    for k, v in pairs(self._resList) do
        local icon = v.item:GetChild("icon")
        self:AddListener(icon.onTouchBegin,
            function()
                icon.scale = Vector2(1.2, 1.2)
            end
        )

        self:AddListener(icon.onTouchEnd,
            function()
                icon.scale = Vector2(1, 1)
            end
        )

        self:AddListener(icon.onRollOut,
            function()
                icon.scale = Vector2(1, 1)
            end
        )

        self:AddListener(v.item.onClick,
            function(context)
                if (self.TotalTimes - MILITARY_SUPPLY.MilitarySupplyLimit) >= 0 and self.FreeTimes <= 0 then
                    TipUtil.TipById(50111)
                    return
                end

                if self.centerLevel < RES_LOCK[k] then
                    TipUtil.TipById(50224)
                    return
                end

                self.selectNum = v.resNum.text

                if self.FreeTimes > 0 or not TipType.NOTREMIND.OnlineSupply then
                    self:GetSupply(k, self.FreeTimes > 0)
                    return
                else
                    local itemInfo = GD.ItemAgent.GetItemModelById(MILITARY_SUPPLY.MSItemConfId)
                    if itemInfo and itemInfo.Amount > 0 then
                        local temp = {
                            prop_name = GD.ItemAgent.GetItemNameByConfId(MILITARY_SUPPLY.MSItemConfId)
                        }
                        local data = {
                            content = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_1", temp),
                            tipType = TipType.TYPE.OnlineSupply,
                            gold = tonumber(v.goldNum.text),
                            buttonType = "other",
                            sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_SUPPLY_DIAMOND"),
                            otherBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_USE_SUPPLY_ITEM"),
                            sureCallback = function()
                                if Model.GetPlayer().Gem < tonumber(v.goldNum.text) then
                                    local data = {
                                        content = StringUtil.GetI18n("configI18nCommons", "Diamond_Not_Enough"),
                                        -- sureBtnText = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_2"),
                                        sureCallback = function()
                                            --TODO
                                        end
                                    }
                                    UIMgr:Open("ConfirmPopupText", data)
                                    return
                                else
                                    self:GetSupply(k, false)
                                end
                            end,
                            otherCallback = function()
                                local itemInfo = GD.ItemAgent.GetItemModelById(MILITARY_SUPPLY.MSItemConfId)
                                local _amount = math.min(itemInfo.Amount, MILITARY_SUPPLY.MilitarySupplyLimit - self.FreeTimes - self.TotalTimes)
                                local data = {
                                    config = ConfigMgr.GetItem("configItems", MILITARY_SUPPLY.MSItemConfId),
                                    amount = _amount,
                                    useCallBack = function()
                                        self:RefreshPanel()
                                    end
                                }
                                UIMgr:Open("ResourceDisplayUse", data)
                            end
                        }
                        UIMgr:Open("ConfirmPopupText", data)
                        return
                    end
                end

                if Model.GetPlayer().Gem < tonumber(v.goldNum.text) then
                    local data = {
                        content = StringUtil.GetI18n("configI18nCommons", "Diamond_Not_Enough"),
                        -- sureBtnText = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_2"),
                        sureCallback = function()
                            --TODO
                        end
                    }
                    UIMgr:Open("ConfirmPopupText", data)
                    return
                end

                local data = {
                    content = StringUtil.GetI18n("configI18nCommons", "Supply_Diamond_2"),
                    gold = tonumber(v.goldNum.text),
                    tipType = TipType.TYPE.OnlineSupply,
                    sureCallback = function()
                        self:GetSupply(k, false)
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
            end
        )
    end

    self:AddEvent(
        EventDefines.UIReqMSInfo,
        function()
            self:RefreshPanel()
        end
    )

    self:AddEvent(TIME_REFRESH_EVENT.Refresh,function()
        Net.MilitarySupplies.Info(function(msg)
            Model.InitOtherInfo(ModelType.MSInfos, msg)
            self:RefreshPanel()
        end)
    end )

    self:AddEvent(EventDefines.UIClosingSoon, function()
        self:ClosingSoon();
    end)

    self:AddEvent(EventDefines.UIResourcesAmount, function(rsp)
        if rsp[1].Category == CHIP_COST then
            self._cpuNum.text = Tool.FormatAmountUnit(rsp[1].Amount)
        end
    end)
end

function MilitarySupplies:GetSupply(category, isFree)
    Net.MilitarySupplies.Exchange(category, isFree, function(rsp)
        local info = {
            num = self.selectNum,
            numRatio = rsp.Critical
        }
        -- table.insert(self._effectInfoList, info)

        self:PlayEffect(info, category)
    end)
end

function MilitarySupplies:PlayEffect(info, category)
    -- if self.isPlay then
    --     return
    -- end
    -- if #self._effectInfoList <= 0 then
    --     self._num.visible = false
    --     self._numRatio.visible = false
    --     self.isPlay = false
    --     return
    -- end

    -- self.isPlay = true

    -- local info = table.remove(self._effectInfoList)
    -- self._num.visible = true
    -- self._numRatio.visible = true

    -- self._num.text = "x"..info.num
    -- self._numRatio.text = "x"..info.numRatio
    -- if info.numRatio <= 1 then
    --     self._numRatio.visible = false
    -- end

    -- self._effect:Play(function()
    --     self.isPlay = false
    --     self:PlayEffect()
    -- end)
    local funcb = function()
        if self.effectList[1] then
            NodePool.Set(NodePool.KeyType.MilitaryEffectNum, self.effectList[1])
        end
        table.remove(self.effectList, 1)
    end
    NodePool.Init(NodePool.KeyType.MilitaryEffectNum, "Number", "MilitarySuppliesNum")
    local effect = NodePool.Get(NodePool.KeyType.MilitaryEffectNum)
    effect.xy = Vector2(self._itemNum.x, self._itemNum.y)
    self._view:AddChild(effect)
    --特效的播放时间比动画长 需要等待特效播放完成后放回对象池
    effect:SetData(info,funcb)
    table.insert(self.effectList, effect)
    local anim = effect:GetTransition(info.numRatio >= 2 and "Multiple" or "Single")
    anim:Play()

    local pos = self.tagRes:GetResItemPos(category)
    if category == RES_TYPE.Res4Equip then
        pos = self._cpuIcon:LocalToGlobal(Vector2.zero)
    end
    NodePool.Init(NodePool.KeyType.MilitaryEffectIcon, "MainCity", "MilitarySuppliesIconEffect")
    local effectIcon = NodePool.Get(NodePool.KeyType.MilitaryEffectIcon)
    effectIcon.xy = Vector2(0, 0)
    self._view:AddChild(effectIcon)
    table.insert(self.effectIconList, effectIcon)
    effectIcon:Init(
        pos,
        category,
        function()
            if self.effectIconList[1] then
                NodePool.Set(NodePool.KeyType.MilitaryEffectIcon, self.effectIconList[1])
            end
            table.remove(self.effectIconList, 1)
        end
    )
end

function MilitarySupplies:ClosingSoon()
    -- self._num.visible = false
    -- self._numRatio.visible = false
    -- self.isPlay = false
    for k, v in pairs(self.effectList) do
        v:Clear()
    end
    for _, v in pairs(self.effectList) do
        v:GetTransition("Multiple"):Stop()
        v:GetTransition("Single"):Stop()
        NodePool.Set(NodePool.KeyType.MilitaryEffectNum, v)
    end
    -- NodePool.Remove(NodePool.KeyType.MilitaryEffectNum)
    self.effectList = {}

    for _, v in pairs(self.effectIconList) do
        v:GetTransition("anim"):Stop()
        NodePool.Set(NodePool.KeyType.MilitaryEffectIcon, v)
    end
    -- NodePool.Remove(NodePool.KeyType.MilitaryEffectIcon)
    self.effectIconList = {}
end

function MilitarySupplies:Close()
    UIMgr:Close("MilitarySupplies")
end

function MilitarySupplies:OnClose()
    self:ClosingSoon()
end

return MilitarySupplies
