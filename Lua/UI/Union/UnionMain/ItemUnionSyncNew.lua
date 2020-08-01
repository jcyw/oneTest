--author: 	Amu
--time:		2020-03-09 16:01:51

local UnionModel = import("Model/UnionModel")

local ItemUnionSyncNew = fgui.extension_class(GButton)
fgui.register_extension("ui://Union/itemUnionSyncNew", ItemUnionSyncNew)

function ItemUnionSyncNew:ctor()
    self._h = self.height
    self.textH = self._desc.height
end

function ItemUnionSyncNew:SetData(index, data)
    self._index = index
    self._desc.text = UnionModel.GetUnionNotice()
    self._title.text = Tool.FormatTimeSF(Tool.Time())

    self.height = self._h + self._desc.height - self.textH
end

function ItemUnionSyncNew:GetIndex()
    return self._index
end

return ItemUnionSyncNew