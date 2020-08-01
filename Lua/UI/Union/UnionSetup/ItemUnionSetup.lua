--[[
    Author: songzeming
    Function: 联盟设置Item
]]
local ItemUnionSetup = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionSetup", ItemUnionSetup)

function ItemUnionSetup:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._btnArrow = self:GetChild("btnArrow")

    self:AddListener(self.onClick,function()
        self:OnBtnClick()
    end)
end

function ItemUnionSetup:Init(title, img, cb)
    self.cb = cb
    self.isOpen = false
    self._btnArrow.rotation = -90
    self._icon.icon = UITool.GetIcon(img)
    self._title.text = title
end

function ItemUnionSetup:OnBtnClick()
    self.isOpen = not self.isOpen
    self._btnArrow.rotation = self.isOpen and -270 or -90
    self.cb(self.isOpen)
end

return ItemUnionSetup