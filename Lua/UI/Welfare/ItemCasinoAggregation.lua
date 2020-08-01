--[[
    author:{maxiaolong}
    time:2019-12-07 11:37:06
    function:{赌场集结列表}
]]
local GD = _G.GD
local ItemCasinoAggregation = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemCasinoAggregation", ItemCasinoAggregation)
local WelfareModel = import("Model/WelfareModel")
local JumpMap = import("Model/JumpMap")
function ItemCasinoAggregation:ctor()
    self._listView = self:GetChild("liebiao")
    self._textProgress = self:GetChild("textTime")
    self._textProgress.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ONE_TASK_SCHEDULE")
    self._textNum = self:GetChild("textNum")
    self._CT = self:GetController("c1")
    self._btnFree = self:GetChild("btnFree")
    self._btnGray = self:GetChild("btnGray")
    self._btnGreen = self:GetChild("btnGreen")
    self._title = self:GetChild("title")
    self._btnFree:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    self._btnGreen:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Get")
    self._btnGray:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_39")
    self._listView.itemRenderer = function(index, item)
        local data = {}
        -- local id = WelfareModel.DicKeyByIndex(index + 1, self.items, true).id
        -- local amount = WelfareModel.DicKeyByIndex(index + 1, self.items, false)
        local id = self.items[index + 1].confId
        local amount = self.items[index + 1].amount
        local rewardCategory = nil
        if self.items[index + 1].isRes then
            data.Category = REWARD_TYPE.Res
            rewardCategory = Global.RewardTypeRes
        else
            data.Category = REWARD_TYPE.Item
            rewardCategory = Global.RewardTypeItem
        end
        data.ConfId = id
        --item:SetData(data)
        --item:SetControl(1)
        --item:SetAmount(amount)
        --item:SetAmountMid(id)

        local mid = GD.ItemAgent.GetItemInnerContent(id)
        local icon,color = GD.ItemAgent.GetShowRewardInfo(data)
        item:SetShowData(icon,color,amount,nil,mid)

        local reward = {
            Category = rewardCategory,
            ConfId = id,
            Amount = amount
        }

        -- local title = GD.ItemAgent.GetItemNameByConfId(id) .. "X" .. amount
        local title = self.items[index + 1].title
        local desc = self.items[index + 1].desc
        self:AddListener(item.onTouchBegin,
            function()
                self.detailPop:OnShowUI(title, desc, item._icon, false)
            end
        )
        self:AddListener(item.onTouchEnd,
            function()
                self.detailPop:OnHidePopup()
            end
        )
        self:AddListener(item.onRollOut,function()
            self.detailPop:OnHidePopup()
        end)
        table.insert(self.rewards, reward)
    end
    self:AddListener(self._btnFree.onClick,
        function()
            Event.Broadcast(EventDefines.WelareCenterClose)
            if self.info then
                -- if self.type == WelfareModel.TemplateType.BaseType then
                --     --打点剿灭行动前往
                --     JumpMap:JumpSimple(self.info.jump.x)
                -- elseif self.type == WelfareModel.TemplateType.Detect and self.info.alliance and Model.Player.AllianceId == "" then
                --     JumpMap:JumpSimple(811800)
                -- elseif self.type == WelfareModel.TemplateType.HuntingDog then
                -- end
                --如果是侦查任务且是联盟侦查任务且还未加入联盟
                local isUnion=Tool.Equal(self.type,WelfareModel.TemplateType.Detect,WelfareModel.TemplateType.MemorialDay) 
                if isUnion and self.info.alliance and Model.Player.AllianceId == "" then
                    JumpMap:JumpSimple(811800)
                else
                    JumpMap:JumpSimple(self.info.jump.x)
                end
                local strId = tostring(self.info.id)
                Net.UserInfo.RecordLog(
                    4203,
                    strId,
                    function(rsp)
                    end
                )
            end

            local list = PlayerDataModel:GetData(PlayerDataEnum.BREAKPOINT) or {}
            if list[20001] then
                return
            end
            --第一次点到剿灭行动活动怪
            SdkModel.TrackBreakPoint(20001) --打点
            list[20001] = true
            PlayerDataModel:SetData(PlayerDataEnum.BREAKPOINT, list)
        end
    )
    self:AddListener(self._btnGreen.onClick,
        function()
            if self.type == WelfareModel.TemplateType.BaseType then
                Net.Casino.GetCasinoActivityAward(
                    self.info.id,
                    function(rsp)
                        if rsp.OK then
                            self._CT.selectedIndex = 1
                            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_KILL_CASINO_MASS", {num = self.info.kill.para2})
                            UITool.ShowReward(self.rewards)

                            --刷新红点
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.CasionMass.Id, -1)
                        end
                    end
                )
            elseif self.type == WelfareModel.TemplateType.Detect then
                Net.InvestigationActivity.GetInvestigationTaskAward(
                    self.info.id,
                    function(rsp)
                        if rsp.OK then
                            self._CT.selectedIndex = 1
                            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "TASK_ACTIVITY_INVERSTIGATION", {num = self.info.kill.para2})
                            UITool.ShowReward(self.rewards)
                            Event.Broadcast(EventDefines.DetectRefresh)
                            --刷新红点
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.DetectActivity.Id, -1)
                        end
                    end
                )
            elseif self.type == WelfareModel.TemplateType.HuntingDog then
                Net.ActivityTask.GetHuntFoxTaskAward(
                    self.info.id,
                    function(rsp)
                        if rsp.OK then
                            self._CT.selectedIndex = 1
                            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "TASK_ACTIVITY_INVERSTIGATION", {num = self.info.kill.para2})
                            UITool.ShowReward(self.rewards)
                            --刷新UI
                            Event.Broadcast(EventDefines.HuntingUIRefreshUI)
                            --刷新红点
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.HuntFox.Id, -1)
                        end
                    end
                )
            elseif self.type==WelfareModel.TemplateType.MemorialDay then 
                Net.FlagDayDetect.GetAward(
                    self.info.id,
                    function(rsp)
                        if rsp.OK then
                            self._CT.selectedIndex = 1
                            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "TASK_ACTIVITY_INVERSTIGATION", {num = self.info.kill.para2})
                            UITool.ShowReward(self.rewards)
                            Event.Broadcast(EventDefines.MemorialDayRefresh)
                            --刷新红点
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.MemorialDay.Id, -1)
                        end
                    end
                )
            end
        end
    )

    self._btnFree:GetChild("title")
    self:AddListener(self._btnGray.onClick,
        function()
            TipUtil.TipById(50044)
        end
    )
    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function ItemCasinoAggregation:SetData(info, type)
    self.rewards = {}
    self.info = info
    local monsterNum = info.kill.para2
    if not self.info.CurrentProcess then
        info.CurrentProcess = info.kill.para2
    end
    self._textNum.text = info.CurrentProcess .. "/" .. info.kill.para2
    if info.CurrentProcess >= info.kill.para2 and not info.AwardTaken then
        self._CT.selectedIndex = 2
    elseif info.CurrentProcess < info.kill.para2 and not info.AwardTaken then
        self._CT.selectedIndex = 0
    elseif info.CurrentProcess >= info.kill.para2 and info.AwardTaken then
        self._CT.selectedIndex = 1
    end
    self.type = type
    if type == WelfareModel.TemplateType.BaseType then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_KILL_CASINO_MASS", {num = monsterNum})
    elseif type == WelfareModel.TemplateType.Detect then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "TASK_ACTIVITY_INVERSTIGATION", {num = monsterNum})
    elseif type == WelfareModel.TemplateType.HuntingDog then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "UI_KILL_FRONTLINE_OUTPOST", {num = monsterNum})
    elseif type == WelfareModel.TemplateType.MemorialDay then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "TASK_ACTIVITY_INVERSTIGATION2", {num = monsterNum})
    end

    self.items, self.num = WelfareModel.GetResOrItemByGiftId(info.reward)
    self._listView.numItems = self.num
    --是否有联盟任务
    local isUnionType = Tool.Equal(type, WelfareModel.TemplateType.Detect, WelfareModel.TemplateType.MemorialDay)
    if isUnionType and self.info.alliance and Model.Player.AllianceId == "" then
        self._btnFree.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_JOINUNION")
    else
        self._btnFree.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    end
end

return ItemCasinoAggregation
