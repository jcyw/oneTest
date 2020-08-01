--[[
    Author: songzeming
    Function: 主界面UI 左侧在线时长奖励
]]
local MainUIOnline = fgui.extension_class(GButton)
fgui.register_extension('ui://Common/btnMainOnline', MainUIOnline)

function MainUIOnline:ctor()
    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )

    self:Init()
end

function MainUIOnline:Init()
end

function MainUIOnline:OnBtnClick()
end

return MainUIOnline
