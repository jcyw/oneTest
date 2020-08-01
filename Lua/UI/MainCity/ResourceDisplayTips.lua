local ResourceDisplayTips = UIMgr:NewUI("ResourceDisplayTips")

function ResourceDisplayTips:OnInit()
    self:AddListener(self._btnUse.onClick,function()
        if self.callback then
            self.callback()
        end
        UIMgr:Close("ResourceDisplayTips")
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("ResourceDisplayTips")
    end)

    self:AddListener(self._btnMask.onClick,function()
        UIMgr:Close("ResourceDisplayTips")
    end)
end

--[[
    data = {
        title 标题
        content 内容
        btnText 按钮内容
        amount 数量
        icon 图标
    }
]]
function ResourceDisplayTips:OnOpen(data)
    self.callback = data.sureCallback
    self._content.text = data.content
    self._textNum.text = StringUtil.GetI18n(I18nType.Commmon, "Use_All_Res_Get")
    self._icon.url = data.icon
    self._amount.text = data.amount
    self._titleName.text = data.title and data.title or StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")

    if data.btnText then
        self._btnUse.text = data.btnText
    else
        self._btnUse.text = ConfigMgr.GetI18n(I18nType.Commmon, "BUTTON_USE_ITEM")
    end
end

return ResourceDisplayTips