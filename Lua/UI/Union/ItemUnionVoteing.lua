--author: 	Amu
--time:		2019-07-09 17:08:03

local ItemUnionVoteing = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionVoteing", ItemUnionVoteing)

ItemUnionVoteing.tempList = {}

function ItemUnionVoteing:ctor()
    self._title = self:GetChild("title")
    self._checkBox = self:GetChild("checkBox")

    self:InitEvent()
end

function ItemUnionVoteing:InitEvent()
   --[[
    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected
        if _selectd then
            Event.Broadcast(UNIONVOTE.Add, self.info)
        else
            Event.Broadcast(UNIONVOTE.Del, self.info)
        end
    end)]]
    self._checkBox.touchable = false;
    self:AddListener(self.onClick,
        function()
            local _selectd = self._checkBox.asButton.selected;
            if _selectd then
                Event.Broadcast(UNIONVOTE.Del, self.info)
            else
                Event.Broadcast(UNIONVOTE.Add, self.info)
            end
            self._checkBox.asButton.selected = not _selectd
        end
    )
end

function ItemUnionVoteing:SetData(info, isVote, votes)
    self._isVote = isVote
    self.info = info
    self.votes = votes

    self._title.text = info
    self._checkBox.selected = false

    for _,v in pairs(votes)do
        if v == info then
            self._checkBox.selected = true
        end
    end
    if #self.votes > 0 then
        self.enabled = false
    else
        self.enabled = true
    end
end

return ItemUnionVoteing