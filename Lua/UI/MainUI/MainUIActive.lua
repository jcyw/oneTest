--[[
    Author: songzeming
    Function: 主界面UI 右侧活动栏
]]
local MainUIActive = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/mainActivitys", MainUIActive)

function MainUIActive:ctor()
    self:AddListener(self._btnRecharge.onClick,
        function()
        end
    )
    self:AddListener(self._btnStored.onClick,
        function()
        end
    )
    self:AddListener(self._btnActivity.onClick,
        function()
        end
    )

    self:Init()
end

function MainUIActive:Init()
    self.visible = false
end

return MainUIActive
