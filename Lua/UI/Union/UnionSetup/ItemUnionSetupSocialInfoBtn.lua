--[[
    Author: songzeming
    Function: 联盟设置 修改联盟社交信息Item
]]
local ItemUnionSetupSocialInfoBtn = fgui.extension_class(GButton)
fgui.register_extension('ui://Union/itemUnionReviseSocialBtn', ItemUnionSetupSocialInfoBtn)

function ItemUnionSetupSocialInfoBtn:ctor()
    self:AddListener(self.onClick,
        function()
            self.cb()
        end
    )
end

function ItemUnionSetupSocialInfoBtn:Init(cb, title)
    self.cb = cb
    self._title.text = title
    self:SetLight(false)
end

function ItemUnionSetupSocialInfoBtn:GetLight()
    return self._light.visible
end

function ItemUnionSetupSocialInfoBtn:SetLight(flag)
    self._light.visible = flag
end

return ItemUnionSetupSocialInfoBtn
