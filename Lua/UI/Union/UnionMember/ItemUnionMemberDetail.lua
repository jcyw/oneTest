--[[
    Author: songzeming
    Function: 联盟成员列表 成员详情界面按钮item
]]
local ItemUnionMemberDetail = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemMemberDeatail", ItemUnionMemberDetail)

function ItemUnionMemberDetail:ctor()
    self:AddListener(self.onClick,function()
        if self.cb then
            self.cb()
        end
    end)
end

function ItemUnionMemberDetail:Init(icon, title, cb)
    self.cb = cb

    self:SetVisible(true)
    self.title = title
    self.icon = icon
end

function ItemUnionMemberDetail:SetVisible(flag)
    self.visible = flag
end

return ItemUnionMemberDetail