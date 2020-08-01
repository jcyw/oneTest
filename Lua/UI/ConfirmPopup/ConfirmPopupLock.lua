--[[
    author:Temmie
    time:2020-03-30 16:49:21
    function:兵种、科技说明弹窗
]]
local ConfirmPopupLock = UIMgr:NewUI("ConfirmPopupLock")
local originSize = 128

function ConfirmPopupLock:OnInit()
    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("ConfirmPopupLock")
    end)

    self:AddListener(self._mask.onClick,function()
        UIMgr:Close("ConfirmPopupLock")
    end)
end

function ConfirmPopupLock:OnOpen(icon, title, content, hasCircleBox, size)
    self._icon.icon = icon
    self._title.text = title
    self._content.text = content
    self._box.visible = hasCircleBox == true
    if size then
        self._icon.width = size
        self._icon.height = size
    else
        self._icon.width = originSize
        self._icon.height = originSize
    end
end

return ConfirmPopupLock