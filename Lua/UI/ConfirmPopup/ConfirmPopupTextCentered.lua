--[[
    author:{maxiaolong}
    time:2019-09-18 15:32:07
    func:{提示说明面板}
]]
local ConfirmPopupTextCentered = UIMgr:NewUI("ConfirmPopupTextCentered")

local MIN_HEIGHT = 200 --文本框最低高度
local MAX_HEIGHT = 249 --文本框最大高度

function ConfirmPopupTextCentered:OnInit()
    local view = self.Controller.contentPane

    self._textTitle = view:GetChild("_title")
    self._CloseBtn = view:GetChild("btnClose")
    local _mask = view:GetChild("bgMask")
    self:AddListener(_mask.onClick,
        function()
            UIMgr:Close("ConfirmPopupTextCentered")
        end
    )
    self:AddListener(self._CloseBtn.onClick,
        function()
            UIMgr:Close("ConfirmPopupTextCentered")
        end
    )
    MAX_HEIGHT = self._label.height
end

function ConfirmPopupTextCentered:OnOpen(data)
    self._textTitle.text = data.title
    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT,self._label,data.info)
end

return ConfirmPopupTextCentered
