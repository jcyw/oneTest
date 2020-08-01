--[[
    Author: songzeming
    Function: 主界面UI 左侧付费活动
]]
local MainUIPay = fgui.extension_class(GButton)
fgui.register_extension('ui://Common/btnMainPay', MainUIPay)

function MainUIPay:ctor()
    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )

    self:Init()
end

function MainUIPay:Init()
    self.visible = false
end

function MainUIPay:OnBtnClick()
end

return MainUIPay
