--author: 	Amu
--time:		2019-08-10 11:36:49

local ItemUnionAdministration = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionAdministration", ItemUnionAdministration)

function ItemUnionAdministration:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
end

function ItemUnionAdministration:SetData(info, title, icon)
    self.info = info
    self._icon.icon = icon
    self._title.text = title
end

function ItemUnionAdministration:GetData()
    return self.info
end

function ItemUnionAdministration:CheckPoint()
    local name = self.info.name
    local sub = CuePointModel.SubType.Union.UnionManager
    if name == "Button_Vote" then
        --投票
        CuePointModel:SetSingle(sub.TypeVote, sub.NumberVote, self, sub.PosVote)
    elseif name == "Button_Ceave_Comments" then
        --留言
        CuePointModel:SetSingle(sub.TypeMessage, sub.NumberMessage, self, sub.PosMessage)
    end
end

return ItemUnionAdministration