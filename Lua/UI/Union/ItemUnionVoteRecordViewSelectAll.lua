--author: 	Amu
--time:		2019-07-08 11:52:39

local ItemUnionVoteRecordViewSelectAll = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionVoteRecordViewSelectAll", ItemUnionVoteRecordViewSelectAll)

ItemUnionVoteRecordViewSelectAll.tempList = {}

function ItemUnionVoteRecordViewSelectAll:ctor()
    self._checkBox = self:GetChild("checkBox")

    self:InitEvent()
end

function ItemUnionVoteRecordViewSelectAll:InitEvent()
    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected
        if _selectd then
            Event.Broadcast(UNIONVOTERECORDEVENT.AddAll)
        else
            Event.Broadcast(UNIONVOTERECORDEVENT.DelAll)
        end
    end)
end

function ItemUnionVoteRecordViewSelectAll:SetData(index, info, isClick, allSelect)
    self._checkBox.asButton.selected = allSelect
end

return ItemUnionVoteRecordViewSelectAll