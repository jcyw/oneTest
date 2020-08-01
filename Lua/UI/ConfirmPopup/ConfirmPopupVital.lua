--[[
    author:{zhanzhang}
    time:2020-05-18 10:56:20
    function:{重要确认框}
]]
local ConfirmPopupVital = UIMgr:NewUI("ConfirmPopupVital")

function ConfirmPopupVital:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("Controller")
    self:AddListener(self._btnSure.onClick,
        function()
            if self.data.sureCallback then
                self.data.sureCallback()
            end
            UIMgr:Close("ConfirmPopupVital")
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            if self.data.cancelCallback then
                self.data.cancelCallback()
            end
            UIMgr:Close("ConfirmPopupVital")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            if self.data.cancelCallback then
                self.data.cancelCallback()
            end
            UIMgr:Close("ConfirmPopupVital")
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            if self.data.cancelCallback then
                self.data.cancelCallback()
            end
            UIMgr:Close("ConfirmPopupVital")
        end
    )
end

--[[
    data = {
        content 描述内容
        contentDown 下方描述内容
        titleText 标题按钮内容
        sureBtnText 确定按钮内容
        cancelBtnText 取消按钮内容
    }
]]
function ConfirmPopupVital:OnOpen(data)
    --设置标题文本

    self._titleName.text = data.titleText and data.titleText or StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    --设置确定按钮文本
    self._btnSure.title = data.sureBtnText and data.sureBtnText or StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")

    --设置取消按钮文本
    self._btnCancel.title = data.cancelBtnText and data.cancelBtnText or StringUtil.GetI18n(I18nType.Commmon, "BUTTON_NO")
    self._content.text = data.content

    if data.UpdateTimeAt > 0 then
        -- self:Schedule
        self.refreshTime = function()
            local preStr = string.gsub(TimeUtil.SecondToDHMS(Model.Player.RookieExpireAt - Tool.Time()), "(%%)", "%%%%") -- 防止配置中出现单个%导致报错
            local str = string.gsub(data.contentDown, "{time}", preStr)
            -- {time = TimeUtil.SecondToHMS(Model.Player.RookieExpireAt - Tool.Time())
            self._contentDown.text = str
        end
        self:Schedule(self.refreshTime, 1, true)
    else
        self._contentDown.text = data.contentDown and data.contentDown or ""
    end
end

function ConfirmPopupVital:DoOpenAnim(data)
    self.data = data
    self:OnOpen(data)
    AnimationLayer.PanelScaleOpenAnim(self)
end

function ConfirmPopupVital:OnClose()
    self.UnSchedule(self.refreshTime)
end

return ConfirmPopupVital
