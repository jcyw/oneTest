--[[
    Author: songzeming,maxiaolong
    Function: 确认弹窗 单选按钮、多选按钮、无复选框和单选按钮 通用
]]
local ConfirmPopupText = UIMgr:NewUI("ConfirmPopupText")

local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local CTR = {
    Double = "Double",
    Single = "Single",
    Other = "Other"
}
local CLOSE_TYPE = {
    Sure = 1,
    Cancel = 2,
    Close = 3,
    Other = 4
}

local MIN_HEIGHT = 100 --文本框最低高度
local MAX_HEIGHT = 189 --文本框最大高度

function ConfirmPopupText:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Controller")

    self._btnSureGoldText = self._btnSure:GetChild("text")
    self._ctrBtnSure = self._btnSure:GetController("Ctr")
    self:AddListener(self._btnSure.onClick,
        function()
            self:Close(CLOSE_TYPE.Sure)
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            self:Close(CLOSE_TYPE.Close)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close(CLOSE_TYPE.Cancel)
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close(CLOSE_TYPE.Cancel)
        end
    )
    self:AddListener(self._btnOther.onClick,
        function()
            self:Close(CLOSE_TYPE.Other)
        end
    )
    MAX_HEIGHT = self._label.height
end

--[[
    data = {
        content 描述内容
        titleText 标题按钮内容
        sureBtnText 确定按钮内容
        cancelBtnText 取消按钮内容
        otherBtnText 第三按钮内容
        gold 消耗金币数量 [可不传]
        itemNum 消耗道具数量
        goldFixed 消耗金币是否不变化 [可不传]
        event 事件 计算金币消耗刷新显示 [可不传]
        isNoFree 是否免费
        tipType 弹窗类型 TipType中选值 每次上线弹窗提示/满足条件弹窗提示 [可不传]
        onlineType 弹窗类型 TipType中选值 本次在线不在提示 [可不传]
        dayType 弹窗类型 TipType中选值 今日登录不在提示 [可不传]
        buttonType 是否有两个按钮 默认一个 [可不传] 新增 other ，左边为原确定按钮，右边为新增确定按钮
        btnGray 是否置灰确定按钮 [可不传]
        isBuildMove 是否是建筑移动提示
        sureCallback 确认回调 [可不传]
        cancelCallback 取消回调 [可不传] 针对点击返回按钮、点击关闭按钮、点击遮罩关闭
        closeCallback 取消回调 [可不传] 只针对点击返回按扭
        otherCallback Other模式下右侧按钮回调 [不用Other可不传]
        sureBtnIcon 确定按钮图标
        i18nCommonKey 多语言key
        finishTimeText 内容里存在倒计时显示
    }
]]
function ConfirmPopupText:OnOpen(data)
    self.isESCClose = true
    --按钮个数
    if data.buttonType == "double" then
        self._ctr.selectedPage = CTR.Double
    elseif data.buttonType == "other" then
        self._ctr.selectedPage = CTR.Other
    else
        self._ctr.selectedPage = CTR.Single
    end
    --是否显示不再提示
    self._groupCheck.visible = data.onlineType
    self._checkBox.selected = false

    self._btnSure.grayed = data.btnGray
    if data.gold then
        self._ctrBtnSure.selectedPage = "Gold"
        self._btnSureGoldText.text = UITool.UBBTipGoldText(data.gold)
    elseif data.sureBtnIcon then
        self._ctrBtnSure.selectedPage = "Item"
        self._btnSure.icon = data.sureBtnIcon
        if data.itemNum then
            self._btnSureGoldText.text = data.itemNum
        else
            self._btnSureGoldText.text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_Get_More")
        end
    else
        self._ctrBtnSure.selectedPage = "Normal"
    end

    --设置标题文本
    if data.titleText then
        self._title.text = data.titleText
    else
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    end
    --设置确定按钮文本
    if data.sureBtnText then
        self._btnSure.title = data.sureBtnText
    else
        self._btnSure.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    end
    --设置取消按钮文本
    if data.cancelBtnText then
        self._btnCancel.title = data.cancelBtnText
    else
        self._btnCancel.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_NO")
    end
    --设置第三按钮文本
    if data.otherBtnText then
        self._btnOther.title = data.otherBtnText
    else
        self._btnOther.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
    end
    if data.event then
        self:ShowCD()
        return
    end
    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT,self._label,data.content)

    if data.finishTimeText then
        self.timeFunc = function()
            local time = data.finishTimeText - Tool.Time()
            if time > 0 then
                if data.i18nCommonKey then                    
                    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT, self._label, StringUtil.GetI18n(I18nType.Commmon, "Ui_Kondola_Moving_Tips", {time = TimeUtil.SecondToDHMS(time)}))
                else
                    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT, self._label, data.content..TimeUtil.SecondToDHMS(time))
                end
            else
                self:UnSchedule(self.timeFunc)
            end
        end
        self:Schedule(self.timeFunc, 1)
    end
    self._label.scrollPane:ScrollTop()
end

function ConfirmPopupText:DoOpenAnim(data)
    self.data = data
    if data.tipType then
        if not CommonModel.IsShowGoldPrompt(data.gold, data.tipType) then
            --满足金币大于一定数量 取消弹窗提示
            UIMgr:Close("ConfirmPopupText")
            self:CheckGold()
            return
        end
    end

    self:OnOpen(data)
    AnimationLayer.PanelScaleOpenAnim(self)
end

function ConfirmPopupText:Close(closeType)
    self.isESCClose = false
    self.closeType = closeType
    AnimationLayer.PanelScaleCloseAnim(self, function()
        UIMgr:Close("ConfirmPopupText")
        -- 正常关闭回调里可能存在再次打开该界面的逻辑，所以将非返回按钮的回调调用放在关闭该界面后
        if not self.isESCClose then
            self:CloseCb(self.closeType)
            self:CheckNoTip(self.closeType)
        end
    end)
end

function ConfirmPopupText:CloseCb(closeType)
    if closeType == CLOSE_TYPE.Sure then
        self:CheckGold()
        return
    end
    if closeType == CLOSE_TYPE.Cancel then
        if self.data.cancelCallback then
            self.data.cancelCallback()
        end
        return
    end
    if closeType == CLOSE_TYPE.Close then
        if self.data.cancelCallback then
            self.data.cancelCallback()
        end
        if self.data.closeCallback then
            self.data.closeCallback()
        end
        return
    end
    if closeType == CLOSE_TYPE.Other then
        if self.data.otherCallback then
            self.data.otherCallback()
        end
        if self.data.closeCallback then
            self.data.closeCallback()
        end
        return
    end
end

function ConfirmPopupText:OnClose()
    if self.event_func then
        self:UnSchedule(self.event_func)
    end
    if self.isESCClose then
        self:CloseCb(CLOSE_TYPE.Cancel)
        self:CheckNoTip(CLOSE_TYPE.Cancel)
    end
end

function ConfirmPopupText:CheckGold()
    if self.data.gold and self.data.gold > Model.Player.Gem then
        if self.data.isBuildMove then
            UIMgr:Close("BuildMoveTip")
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
        end
        UITool.GoldLack()
    else
        if self.data.sureCallback then
            self.data.sureCallback()
        end
    end
end

-- 有事件倒计时的提示
function ConfirmPopupText:ShowCD()
    local text_func = function(goldNum)
        self._btnSureGoldText.text = UITool.UBBTipGoldText(goldNum)
        local desc = StringUtil.GetI18n(I18nType.Commmon, self.data.content)
        ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT,self._label,desc)
    end
    text_func(self.data.gold)

    local freeTime = 0
    if not self.data.isNoFree and BuildModel.FreeState(self.data.event.Category) then
        freeTime = CommonModel.FreeTime()
    end
    local function time_func()
        return self.data.event.FinishAt - Tool.Time()
    end
    self.event_func = function()
        local t = time_func()
        print(t)
        if self.data.goldFixed then
            if t > 0 then
                return
            end
        else
            local needGold = Tool.TimeTurnGold(t, freeTime)
            if t > 0 then
                text_func(needGold)
                return
            end
        end
        self:Close(CLOSE_TYPE.Cancel)
    end
    self:Schedule(self.event_func, 1)
end

--检测不再提示
function ConfirmPopupText:CheckNoTip(closeType)
    if closeType == CLOSE_TYPE.Sure then
        if self.data.tipType then
            TipType.NOTREMIND[self.data.tipType] = nil
        end
    end
    if not self._checkBox.selected then
        return
    end
    --设置本次在线不再提示
    if self.data.onlineType then
        TipType.NOTREMIND[self.data.onlineType] = nil
    end
    if self.data.dayType then
        PlayerDataModel:SetDayNotTip(self.data.dayType)
    end
end

return ConfirmPopupText
