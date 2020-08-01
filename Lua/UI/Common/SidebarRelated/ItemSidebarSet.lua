--[[
    Author: songzeming
    Function: 侧边栏设置界面item
]]
local ItemSidebarSet = fgui.extension_class(GComponent)
fgui.register_extension('ui://Common/itemSidebarSet', ItemSidebarSet)

function ItemSidebarSet:ctor()
    self._controller = self:GetController('Controller')

    for i = 1, 3 do
        local node = self:GetChild('check' .. i)
        self:AddListener(node.onClick,
            function()
                self.cb(self._controller.selectedIndex)
            end
        )
    end
end

function ItemSidebarSet:Init(title, index, cb)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, title)
    self._controller.selectedIndex = index
    self.cb = cb
end

return ItemSidebarSet
