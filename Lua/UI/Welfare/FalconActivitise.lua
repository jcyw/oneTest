--[[
    author:{黎叔}
    time:2020-05-23 10:55:05
    function:{猎鹰}
]]
local FalconActivitise = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/FalconActivitise", FalconActivitise)

local WorldMap = import("UI/WorldMap/WorldMap")
local MapModel = import("Model/MapModel")

function FalconActivitise:ctor()
    NodePool.Init(NodePool.KeyType.Effect_Radar_sweep, "Effect", "EffectNode")
    NodePool.Init(NodePool.KeyType.Effect_Button_Light, "Effect", "EffectNode")

    self.needEfeectCount = 0
    self._textFalcon.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCON")
    self._btnStartSweep.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_SCAN")
    self._btnGoto.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_SEARCH")

    self._btnRecords.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips2")

    self.buttonEffectList ={}

    self.showTips = function()
        local data = {
            title = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCON"),
            info = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_ACLCONRULE")
        }
        UIMgr:Open("ConfirmPopupTextList", data)
    end

    self.monsterList = {self._btnPoint1, self._btnPoint2, self._btnPoint3, self._btnPoint4, self._btnPoint5, self._btnPoint6}
    self.buttonEffectList ={}
    for i = 1, #self.monsterList do
        self.monsterList[i]:GetController("ctr").selectedIndex = 2
        self:AddListener(self.monsterList[i].onClick,
            function()
                self:gotoWorldMonster(i - 1)
            end
        )
        self.buttonEffectList[i] = NodePool.Get(NodePool.KeyType.Effect_Button_Light)
        self.buttonEffectList[i].visible = false
        self.monsterList[i]:AddChild(self.buttonEffectList[i])
        self.buttonEffectList[i]:SetScale(200, 200)
        self.buttonEffectList[i].xy = Vector2(350, 18)
        self.buttonEffectList[i]:InitNormal()
        self.buttonEffectList[i]:PlayDynamicEffectLoop("effect_ab/effect_button_light","effect_button_light_prefab",nil,1)
    end

    self.maxCount = Global.FuelOil[1]
    self.restoreCD = Global.FuelOil[2]

    self:AddEvent(
        EventDefines.FalconInfoEvent,
        function()
            if self.visible then
                if (self.IsNeedPlayEffect == false) then
                    self:refreshMonsterDisplay()
                end
                self.SecondRefresh()
            end
        end
    )

    self.playSweepEffect = function()
        if (self.needEfeectCount < #Model.EagleHuntInfos.Targets) then
            self.needEfeectCount = self.needEfeectCount + 1
            self.monsterList[self.needEfeectCount].title = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_" .. Model.EagleHuntInfos.Targets[self.needEfeectCount])
            self.monsterList[self.needEfeectCount]:GetController("ctr").selectedIndex = 1
            self.buttonEffectList[self.needEfeectCount].visible = true
            self.buttonEffectList[self.needEfeectCount]:InitNormal()
            self.buttonEffectList[self.needEfeectCount]:PlayDynamicEffectLoop("effect_ab/effect_button_light","effect_button_light_prefab",nil,1)
            self:ScheduleOnceFast(self.playSweepEffect, 0.5)
        else
            self.isDoingSweeepEffect = false
            if GlobalVars.IsTriggerStatus then--扫描结束后回调
                Event.Broadcast(EventDefines.FalconSearchEndCb)
            end
        end
    end

    self:AddListener(self._btnRecords.onClick,
        function()
            UIMgr:Open("FalconActivitisePopup")
        end
    )

    self:AddListener(self._btnHelp.onClick,
        function()
            self.showTips()
        end
    )

    self:AddListener(self._btnStartSweep.onClick,
        function()
            self.IsNeedPlayEffect = true
            -- 连续扫描提示
            if(Model.EagleHuntInfos.Hunted == -1 and #Model.EagleHuntInfos.Targets>0)then
                local data = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS2"),
                    sureCallback = function()
                        Net.EagleHunt.Search(
                                function(rsp)
                                    self:SearchBack(rsp)
                                end
                        )
                    end
                }
                UIMgr:Open("ConfirmPopupText", data)
                return
            end
            
            if self.triggerClick then
                self.triggerClick()
            end
            
            if GlobalVars.IsTriggerStatus and self.triggerClick then
                Net.EagleHunt.Search(
                    true,
                    function(rsp)
                        --print("Net.EagleHunt.Search rsp ======================" .. table.inspect(rsp))
                        self:SearchBack(rsp)
                    end
                )
            else
                Event.Broadcast(EventDefines.ClearTrigger)
                Net.EagleHunt.Search(
                    function(rsp)
                        --print("Net.EagleHunt.Search rsp ======================" .. table.inspect(rsp))
                        self:SearchBack(rsp)
                    end
                )
            end
        end
    )

    self:AddListener(self._btnGoto.onClick,
        function()
            if (GlobalVars.IsInCity == false) then
                UIMgr:Close("WelfareMain")
            else
                Event.Broadcast(EventDefines.OpenWorldMap)
            end
        end
    )

    self.SecondRefresh = function()
        if (Model.isFalconOpen) then
            if (Model.EagleHuntInfos.Fuel > 0) then
                self._btnGoto.visible = false
                self._btnStartSweep.visible = true
                self._textTip.visible = false
            else
                self._btnGoto.visible = true
                self._btnStartSweep.visible = false
                self._textTip.visible = true
                self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS3")
            end

            if (Model.EagleHuntInfos.Fuel >= 3) then
                self._textNextRestore.visible = false
            else
                self._textNextRestore.visible = true
                self._textNextRestore.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIME", {time = TimeUtil.SecondToHMS(Model.EagleHuntInfos.FuelAddAt - Tool.Time())})
            end

            self._textCount.text = Model.EagleHuntInfos.Fuel .. "/" .. self.maxCount

            if (self.EndTime) then
                --self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = Tool.FormatTime(self.EndTime - Tool.Time())})
                self._textDescribe.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCON_DESC")
            end
        end
    end

    self:Schedule(self.SecondRefresh, 1, true)

    local cb = function(prefab)
        self.temptexture = prefab
        self._CloudBox.texture = NTexture(self.temptexture)
        self._BgLoadingtextTip.visible = false
    end

    local progressCb = function(proNum)
        self._BgLoadingtextTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Res_Loading") .. math.floor(proNum * 100) .. "%"
        self._BgLoadingtextTip.visible = true
    end

    if self.temptexture then
        self._BgLoadingtextTip.visible = false
        self._CloudBox.texture = NTexture(self.temptexture)
    else
        self:DynamicLoad("falcon", "bg_welfare_10", cb, progressCb)
    end
end

function FalconActivitise:GetbtnPoint()
    local cutIndex=1
     if next(self.monsterList)  then 
        return self.monsterList[cutIndex+1],cutIndex
     end
end

function FalconActivitise:SearchBack(rsp)
    if rsp.OK then
        if not self._sweepEffect then
            self._sweepEffect = NodePool.Get(NodePool.KeyType.Effect_Radar_sweep)
            self._sweepContainer:AddChild(self._sweepEffect)
            self._sweepEffect:SetScale(200, 200)
            self._sweepEffect.xy = Vector2(12, 158)
            self._sweepEffect:InitNormal()
            self._sweepEffect:PlayEffectLoop("effects/effect_radar_sweep/prefab/effect_radar_sweep",nil,1)
            self:ScheduleOnceFast(
                    function()
                        self._sweepEffect.visible = false
                        --self._sweepEffect:getEagleSweepFadeOut()
                        for i, v in pairs(self.buttonEffectList) do
                            v.visible = false
                        end
                    end,
                    #Model.EagleHuntInfos.Targets * 0.5 + 1.0
            )
        else
            self._sweepEffect.visible = true
            self:ScheduleOnceFast(
                    function()
                        self._sweepEffect.visible = false
                        --self._sweepEffect:getEagleSweepFadeOut()
                        for i, v in pairs(self.buttonEffectList) do
                            v.visible = false
                        end
                    end,
                    #Model.EagleHuntInfos.Targets * 0.5 + 1.0
            )
        end
        self.isDoingSweeepEffect = true
        self.IsNeedPlayEffect = false
        self.needEfeectCount = 0
        for i = 1, #self.monsterList do
            self.monsterList[i]:GetController("ctr").selectedIndex = 2
        end
        self:ScheduleOnceFast(self.playSweepEffect, 0.5)
    end
end

function FalconActivitise:DynamicLoad(url, resName, cb, progressCb)
    local _cb = function(ab)
        if not ab then
            return nil
        end
        local prefab = ab:LoadAsset(resName)
        cb(prefab)
    end

    DynamicRes.GetBundle(url, _cb, progressCb)
end

function FalconActivitise:gotoWorldMonster(index)
    if(self.isDoingSweeepEffect)then
        return
    end
    if (Model.EagleHuntInfos.Targets[index + 1]) then
        if (Model.EagleHuntInfos.NoChance == false and (Model.EagleHuntInfos.Hunted == -1 or Model.EagleHuntInfos.Hunted == index)) then
            --print("FalconActivitise:gotoWorldMonster index ======================" .. index)
            Net.EagleHunt.AimTarget(
                index,
                function(rsp)
                    --print("Net.EagleHunt.AimTarget rsp ======================" .. table.inspect(rsp))
                    if rsp.Fail then
                        return
                    end

                    if (GlobalVars.IsInCity == false) then
                        WorldMap.Instance():MoveToPoint(rsp.X, rsp.Y, false)
                        UIMgr:Close("WelfareMain")
                    else
                        Event.Broadcast(EventDefines.OpenWorldMap, rsp.X, rsp.Y)
                    end
                end
            )
        else
            TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS1"))
        end
    end
end

function FalconActivitise:refreshMonsterDisplay()
    for i = 1, #self.monsterList do
        if (Model.EagleHuntInfos.Targets[i]) then
            self.monsterList[i].title = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_" .. Model.EagleHuntInfos.Targets[i])
            if (Model.EagleHuntInfos.NoChance == false and (Model.EagleHuntInfos.Hunted == i - 1 or Model.EagleHuntInfos.Hunted == -1)) then
                self.monsterList[i]:GetController("ctr").selectedIndex = 1
            else
                self.monsterList[i]:GetController("ctr").selectedIndex = 0
            end
        else
            self.monsterList[i]:GetController("ctr").selectedIndex = 2
        end
    end
end

function FalconActivitise:OnOpen()
    self:SetShow(true)
    for i, v in pairs(self.buttonEffectList) do
        v.visible = false
    end
    if(Model.EagleHuntInfos)then
        self.needEfeectCount = #Model.EagleHuntInfos.Targets
    end
    if(self._sweepEffect)then
        self._sweepEffect.visible = false
    end
    Net.EagleHunt.Info(
        function(val)
            --print("Net.EagleHunt.Info rsp ======================" .. table.inspect(rsp))
            Model.EagleHuntInfos = val.Info
            self.StartTime = val.StartTime
            self.EndTime = val.EndTime
            --self._textDescribe.text = TimeUtil.StampTimeToYMD(Model.EagleHuntInfos.StartTime) .. " - " .. TimeUtil.StampTimeToYMD(Model.EagleHuntInfos.EndTime)
            self:refreshMonsterDisplay()
            self.SecondRefresh()
            --页面内触发
            if not GlobalVars.IsTriggerStatus then
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.OpenUI, 15100, 0)
            end
        end
    )
end

function FalconActivitise:SetShow(isShow)
    self.visible = isShow
end

function FalconActivitise:TriggerOnclick(cb)
        self.triggerClick = cb
end

return FalconActivitise
