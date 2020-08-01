--[[
    Author: songzeming
    Function: 玩家战力弹窗item
]]
local ItemPlayerPowerBox = fgui.extension_class(GComponent)
fgui.register_extension('ui://PlayerDetail/itemPlayerPowerBox', ItemPlayerPowerBox)

function ItemPlayerPowerBox:ctor()
    self:AddListener(self._btnFind.onClick,
        function()
            self.cb()
        end
    )
end

function ItemPlayerPowerBox:Init(title, power, cb)
    self.cb = cb
    self._title.text = title
    self._power.text = power
end

return ItemPlayerPowerBox
