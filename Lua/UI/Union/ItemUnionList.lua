--[[
    Author: songzeming
    Function: 联盟主界面任务Item
]]
local ItemUnionList = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionMain", ItemUnionList)

local BuildModel = import("Model/BuildModel")
local UnionHelpModel = import("Model/Union/UnionHelpModel")
local UnionModel = import("Model/UnionModel")

function ItemUnionList:ctor()
    self._icon = self:GetChild("icon")
    self._num = self:GetChild("textNum")
    -- self._redPoint = self:GetChild("iconPoint")
    -- self._redPoint.visible = false
    -- self._numGroup = self:GetChild("numGroup")
    self._title = self:GetChild("textName")
    self._btnArrow = self:GetChild("btnArrow")
    self._textTip = self:GetChild("text")

    self:AddListener(self.onClick,
        function()
            if self:Check() then
                return
            end
            self:OnBtnClick()
        end
    )

    self.taskFunc = function()
        if self.conf.name == "Button_Cooperative_Lask" then
            self:CheckUnionTaskStatus()
        end
    end

    self.warfareFunc = function()
        if self.conf.name == "BUTTON_UNIONWAR" then
            self:CheckUnionWarfare()
        end
    end

    --进行联盟协作任务提示刷新
    self:AddEvent(EventDefines.UIAllianceRefeshHelpTask, self.taskFunc)
    self:AddEvent(EventDefines.UIOnFinishUnionTask, self.taskFunc)

    --联盟战争提示刷新
    self:AddEvent(EventDefines.UIAllianceWarefarePonit, self.warfareFunc)

    self:AddEvent(
        EventDefines.UIAllianceTaskPonit,
        function()
            if self.conf.name == "Button_Task" or self.conf.name == "Button_Technology" or self.conf.name == "Button_Cooperative_Lask" then
                self:RefreshRedPoint()
            --self:CheckUnionTaskStatus()
            end
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceBossTaskPonit,
        function()
            if self.conf.name == "Button_Task" or self.conf.name == "Button_Technology" then
                self:RefreshRedPoint()
            end
        end
    )

    self:AddEvent(
        EventDefines.UIUnionScience,
        function()
            if self.conf.name == "Button_Technology" then
                self:RefreshRedPoint()
            end
        end
    )
end

function ItemUnionList:Init(conf)
    self.conf = conf
    self._icon.icon = UITool.GetIcon(conf.icon)
    -- self._numGroup.visible = false
    -- self._redPoint:SetData(false)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, conf.name)
    self:Show()
    self:RefreshRedPoint()
end

function ItemUnionList:GetSub()
    local name = self.conf.name
    if name == "BUTTON_UNIONWAR" then
        --联盟战争
        return CuePointModel.SubType.Union.UnionWarfare
    end
    if name == "Button_Cooperative_Lask" then
        --联盟合作任务
        return CuePointModel.SubType.Union.UnionTeamTask
    end
    if name == "Button_Technology" then
        --联盟科技
        return CuePointModel.SubType.Union.UnionScience
    end
    if name == "Button_Help" then
        --联盟帮助
        return CuePointModel.SubType.Union.UnionHelp
    end
    if name == "Button_Task" then
        --联盟任务
        return CuePointModel.SubType.Union.UnionTask
    end
end

function ItemUnionList:Show()
    local name = self.conf.name
    if name == "Button_Help" then
        self:OnHelpShow()
    elseif name == "Button_Cooperative_Lask" then
        --self:RefreshUnionTaskTip()
        --  此处是联盟协作任务
        self:CheckUnionTaskStatus()
    elseif name == "BUTTON_UNIONWAR" then
        self:CheckUnionWarfare()
    end
end

function ItemUnionList:Check()
    local unlockType = self.conf.open_conditions[1]
    if unlockType == 0 then
        return
    end
    local unlockLv = self.conf.open_conditions[2]
    local values = {
        lv = unlockLv
    }
    if unlockType == 1 then
        if BuildModel.GetCenterLevel() >= unlockLv then
            return
        end
        TipUtil.TipById(50134, values)
        return true
    end
    if unlockType == 2 then
        if Model.Player.Level >= unlockLv then
            return
        end
        TipUtil.TipById(50135, values)
        return true
    end
end

--刷新红点
function ItemUnionList:RefreshRedPoint()
    self._textTip.text = ""
    local name = self.conf.name
    if Tool.Equal(name, "Button_Shop", "Button_Gift") then
        --没有提示点
        return
    end
    local sub = self:GetSub()
    --CuePointModel:SetSingle(sub.Type, sub.Number, self, sub.Pos)
    if name == "Button_Cooperative_Lask" then
        self:RefreshUnionTaskTip()
        --若是没有可领取奖励的礼物则不刷新红点
        local count = UnionModel.CheckFinishTaskCount()
        if count == 0 then
            CuePointModel:SetSingle(sub.Type, 0, self, sub.Pos)
            return
        end
        --联盟合作任务
        local t = sub.Type
        local n = sub.Number
        if n == 0 and sub.TypeWaring and UnionModel.IsCanGetTask() > 0 and UnionModel.GetRemainAcceptTimes() > 0 
                and self.conf.open_conditions[2] and BuildModel.GetCenterLevel() >= self.conf.open_conditions[2] 
                and not UnionModel.CheckIsNotOverJoinTime() then
            t = sub.TypeWaring
            n = sub.NumberWaring
            CuePointModel:SetSingle(t, n, self, sub.Pos)
        end
    elseif name == "Button_Technology" then
        --联盟科技
        if Model.Player.AllianceTechCanContri then
            self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AlliancemainTips6")
        end
        CuePointModel:SetSingle(sub.TypeWaring, sub.NumberWaring, self, sub.Pos)
    else
        CuePointModel:SetSingle(sub.Type, sub.Number, self, sub.Pos)
    end
end

function ItemUnionList:OnBtnClick()
    local name = self.conf.name
    if name == "BUTTON_UNIONWAR" then
        --联盟战争
        UIMgr:OpenHideLastFalse("UnionWarfare")
    elseif name == "Button_Cooperative_Lask" then
        --联盟合作任务
        UIMgr:OpenHideLastFalse("UnionTask")
    elseif name == "Button_Technology" then
        --联盟科技
        UIMgr:OpenHideLastFalse("UnionScienceDonate")
    elseif name == "Button_Shop" then
        --联盟商店
        Net.AllianceShop.Info(
            Model.Player.AllianceId,
            function(msg)
                UIMgr:OpenHideLastFalse("UnionShop", msg)
            end
        )
    elseif name == "Button_Help" then
        --联盟帮助
        UIMgr:OpenHideLastFalse("UnionMain/UnionHelp")
    elseif name == "Button_Gift" then
        --联盟礼物
        UIMgr:OpenHideLastFalse("UnionGift")
    elseif name == "Button_Task" then
        --联盟任务
        Net.AllianceDaily.Info(
            Model.Player.AllianceId,
            function(msg)
                UIMgr:OpenHideLastFalse("UnionTaskActive", msg)
            end
        )
    elseif name == "Button_Task_Boss" then
        --盟主任务
        TipUtil.TipById(50259)
    end
end
--检测联盟任务状态
function ItemUnionList:CheckUnionTaskStatus()
    local count = UnionModel.CheckFinishTaskCount()
    -- self._numGroup.visible = count > 0
    -- self._redPoint:SetData(count > 0, count)
    -- self._num.text = count
    self:RefreshUnionTaskTip()
end

--刷新联盟合作任务提示文本
function ItemUnionList:RefreshUnionTaskTip()
    --UnionModel.GetTaskPrice()--这个等0就是有免费任务
    local unlockLv = self.conf.open_conditions[2]
    --指挥中心十级解锁
    if unlockLv and BuildModel.GetCenterLevel() < unlockLv then
        --解锁等级
        self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AlliancemainTips1")
    elseif UnionModel.CheckIsNotOverJoinTime() then
        --到达冷却时间可以领取协作任务
        self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceDtask_get")
    elseif UnionModel.CheckFinishTaskCount() > 0 then
        --奖励可领取
        self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AlliancemainTips4")
    --elseif UnionModel.IsCanGetTask() > 0 and UnionModel.GetRemainAcceptTimes() > 0 then
    --当可接受任务次数大于0可接受任务大于0且是免费任务时才显示任务可领取
    elseif UnionModel.IsCanGetTask() > 0 and UnionModel.GetTaskPrice() == 0 and UnionModel.GetRemainAcceptTimes() > 0 then
        --任务可领取
        self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AlliancemainTips2")
    else
        if UnionModel.NextFreeAt - Tool.Time() > 0 and UnionModel.GetRemainAcceptTimes() > 0 then
            self.RefreshUnionTaskTimeFunc = function()
                if not self.visible then
                    self:UnSchedule(self.RefreshUnionTaskTimeFunc)
                    return
                end
                local delayRefreshTime = UnionModel.NextFreeAt - Tool.Time()
                if delayRefreshTime < 0 then
                    --倒计时结束的时候刷新一下
                    --self.taskFunc()
                    -- self:UnSchedule(self.RefreshUnionTaskTimeFunc)
                    self:UnSchedule(self.RefreshUnionTaskTimeFunc)
                    return
                end
                self._textTip.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AlliancemainTips3", {time = TimeUtil.SecondToHMS(delayRefreshTime)})
            end
            -- self:Schedule(self.RefreshUnionTaskTimeFunc, 1, true)
            self:Schedule(self.RefreshUnionTaskTimeFunc,1)
        else
            Log.Info("完了啥都没有")
        end
    end
end

--联盟帮助状态显示
function ItemUnionList:OnHelpShow()
    local show_func = function()
        local helpInfo = UnionHelpModel.GetUnionHelpOtherInfo()
        if next(helpInfo) == nil then
            -- self._numGroup.visible = false
            -- self._redPoint:SetData(false)
        else
            -- self._numGroup.visible = true
            -- self._num.text = #helpInfo
            -- self._redPoint:SetData(true, #helpInfo)
        end
    end
    show_func()

    if self.addHelp then
        return
    end
    self.addHelp = true
    self:AddEvent(EventDefines.UIAllianceHelpInfoExg, show_func)
end

--联盟战争
function ItemUnionList:CheckUnionWarfare()
    local count = UnionModel:GetWarfarePointAmount()
    -- self._numGroup.visible = count > 0
    -- self._num.text = count
    -- self._redPoint:SetData(count > 0, count)
end

function ItemUnionList:GetItemName()
    return self.conf.name
end
return ItemUnionList
