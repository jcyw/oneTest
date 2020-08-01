--[[
    Author: songzeming
    Function: 联盟管理 修改联盟徽章Item
]]
local ItemUnionBadge = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionBadge", ItemUnionBadge)

function ItemUnionBadge:ctor()
    self:AddListener(self.onClick,
        function()
            if self.cb then
                self.cb()
            end
        end
    )
end

function ItemUnionBadge:Init(index, conf, cb)
    self.index = index
    self.conf = conf
    self.cb = cb

    if not conf then
        self:SetVisible(false)
    else
        self.icon = UITool.GetIcon(conf.image)
    end
end

function ItemUnionBadge:SetVisible(flag)
    for i = 1, self.numChildren do
        self:GetChildAt(i - 1).visible = flag
    end
end

function ItemUnionBadge:GetIndex()
    return self.index
end

function ItemUnionBadge:GetConf()
    return self.conf
end

return ItemUnionBadge
