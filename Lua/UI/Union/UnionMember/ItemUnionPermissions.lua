--[[
    Author: songzeming
    Function: 联盟成员列表 联盟权限查看Item
]]
local ItemUnionPermissions = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionViewPermissions", ItemUnionPermissions)

local UnionInfoModel = import("Model/Union/UnionInfoModel")

function ItemUnionPermissions:ctor()
    self._title = self:GetChild("title")
    for i = 1, 5 do
        self["check"..i] = self:GetChild("checkR"..i)
    end
end

function ItemUnionPermissions:Init(data)
    self.data = data
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, data.name)
    for i = 1, 5 do
        self["check"..i].selected = false
        self["check"..i].touchable = false
        self["check"..i].grayed = false
    end
    for _, v in pairs(data.members) do
        self["check"..v].selected = not UnionInfoModel.CheckPermissions(self.data.id, v)
    end
end

function ItemUnionPermissions:ShowEdit()
    for i = 1, 5 do
        local isModify = self.data.modify and self.data.modify[i] or false
        self["check"..i].grayed = not isModify
        self["check"..i].touchable = isModify
    end
end

function ItemUnionPermissions:ShowSave()
    for i = 1, 5 do
        self["check"..i].grayed = false
        self["check"..i].touchable = false
    end
end

function ItemUnionPermissions:GetModify()
    if not self.data.modify then
        return
    end
    local data = {}
    for _, v in pairs(self.data.modify) do
        table.insert(data, {
            Permission = self.data.id,
            Position = v,
            Enable = self["check"..v].selected
        })
    end
    return data
end

return ItemUnionPermissions