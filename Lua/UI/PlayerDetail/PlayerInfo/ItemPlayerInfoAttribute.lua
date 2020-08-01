--[[
    Author: songzeming
    Function: 玩家信息属性按钮item
]]
local ItemPlayerInfoAttribute = fgui.extension_class(GComponent)
fgui.register_extension("ui://PlayerDetail/itemPlayerInfoAttribute", ItemPlayerInfoAttribute)

function ItemPlayerInfoAttribute:ctor()
    self._ctr = self:GetController("ctr")

    self:AddListener(self.onClick,
        function()
            if not self:GetChoose() then
                self.cb()
            end
        end
    )
end

function ItemPlayerInfoAttribute:Init(title, cb)
    self.cb = cb
    self._title.text = title
    self:SetChoose(false)
end

function ItemPlayerInfoAttribute:SetChoose(flag)
    self._ctr.selectedIndex = flag and 1 or 0
end

function ItemPlayerInfoAttribute:GetChoose()
    return self._ctr.selectedIndex == 1
end

return ItemPlayerInfoAttribute
