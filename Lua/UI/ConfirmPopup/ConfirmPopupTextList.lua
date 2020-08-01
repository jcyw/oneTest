local ConfirmPopupTextList = UIMgr:NewUI("ConfirmPopupTextList")

local MIN_HEIGHT = 200 --文本框最低高度
local MAX_HEIGHT = 234 --文本框最大高度
local MAX_HEIGHT_C = 680

function ConfirmPopupTextList:OnInit()
    self._btnClose.visible = false
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    MAX_HEIGHT = self._label.height
end

function ConfirmPopupTextList:OnOpen(data)
    self.data = data
    if not data.title then
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    else
        self._title.text = data.title
    end

    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT_C,self._label,self.data.info)

    if self._label.height > MAX_HEIGHT then
        self._bg.height = self._label.height + 100
    elseif self._label.height > MAX_HEIGHT_C then
        self._bg.height = MAX_HEIGHT_C + 100
    end
end

function ConfirmPopupTextList:Close()
    UIMgr:Close("ConfirmPopupTextList")
end

return ConfirmPopupTextList
