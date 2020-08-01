--[[
    Author: songzeming
    Function: 玩家战力跳转弹窗item
]]
local ItemPlayerPowerTurnBox = fgui.extension_class(GComponent)
fgui.register_extension('ui://PlayerDetail/itemPlayerPowerTurnBox', ItemPlayerPowerTurnBox)

import("UI/Common/ItemPropForMail")

function ItemPlayerPowerTurnBox:ctor()
    self:AddListener(self._btnGoto.onClick,
        function()
            self.cb()
        end
    )
end

function ItemPlayerPowerTurnBox:Init(icon, title, cb)
    self.cb = cb
    --self._itemProp:SetIcon(icon)
    self._itemProp:SetShowData(icon)
    self._title.text = title
end

return ItemPlayerPowerTurnBox
