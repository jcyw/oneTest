--[[
    Author: songzeming
    Function: 主界面UI 城堡增益
]]
local MainUIGain = fgui.extension_class(GButton)
fgui.register_extension('ui://Common/btnMainGain', MainUIGain)

function MainUIGain:ctor()
    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )

    self:Init()
end

function MainUIGain:Init()
    self.visible = false
end

function MainUIGain:OnBtnClick()
end

return MainUIGain
