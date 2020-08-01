local GMLog = fgui.extension_class(GComponent)
fgui.register_extension("ui://GM/Log", GMLog)

import('UI/GM/GMItemLog')

function GMLog:ctor()
    self._list = self:GetChild("list")
    self._list.itemRenderer = function(index, item)
        item:Init(self.logs[index + 1])
    end
    self._list:SetVirtual()

    local _btnClose = self:GetChild("btnClose")
    _btnClose.title = 'X'
    self:AddListener(_btnClose.onClick,function()
        self.visible = false
        self.logs = nil
        self._list.numItems = 0
    end)
    self.y = -80
    self.visible = false
    self:MakeFullScreen()
end

function GMLog:SetLogs()
    local linkList = FUIUtils.GetConsole()
    if linkList.Length <= 0 then
        return
    end

    local logs = {}
    for i = linkList.Length - 1, 0, -1 do
        table.insert(logs, linkList[i])
    end

    self.logs = logs
    self._list.numItems = #logs
    self._list:EnsureBoundsCorrect()

    self.visible = true
    self._list.scrollPane:ScrollBottom()
end

return GMLog
