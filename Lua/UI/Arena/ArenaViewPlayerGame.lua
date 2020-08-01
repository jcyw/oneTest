--author: 	Amu
--time:		2020-06-19 14:49:07


local ArenaViewPlayerGame = UIMgr:NewUI("ArenaViewPlayerGame")

function ArenaViewPlayerGame:OnInit()
    self._view = self.Controller.contentPane

    self._name = self._view:GetChild("titleName")

    self._listView = self._view:GetChild("_contentList")


    for i=1, 6 do
        self["_itemEquip"..i] = self._view:GetChild("itemEquip"..i)
    end

    self:InitEvent()
end

function ArenaViewPlayerGame:InitEvent( )
    self:AddListener(self._mask.onClick,function()
        self:Close()
    end)

    self:AddListener(self._btnClose.onClick,function()
        self:Close()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end

        -- item:SetData(self._info.Armies[index+1])
        local i = index+1 - #self._info.Beasts
        if i > 0 then 

        else

        end

        if index < math.ceil(self._beastsLen/2) then
            local itemIndex = index * 2 + 1
            item:SetData(self._info.Beasts[itemIndex], self._beastsLen >= (itemIndex + 1) and self._info.Beasts[itemIndex + 1], true)
        else
            local itemIndex = (index - math.ceil(self._beastsLen / 2)) * 2 + 1
            item:SetData(self._info.Armies[itemIndex], self._armiesLen >= (itemIndex + 1) and self._info.Armies[itemIndex + 1], false)
        end
    end

end
-- Armies:table: 00000000DE5BE4F0
-- Beasts:table: 00000000DE5BE830
-- Candidate:table: 00000000DE5BE7B0
-- Equips:table: 00000000DE5BDD70
function ArenaViewPlayerGame:OnOpen(info)
    self._info = info

    self._armiesLen = #self._info.Armies
    self._beastsLen = #self._info.Beasts
    self._itemLen = math.ceil(self._armiesLen/2) + math.ceil(self._beastsLen/2)


    self:RefreshPanel()
end

function ArenaViewPlayerGame:RefreshPanel(  )
    if self._info.Candidate then
        self._name.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS10", 
            {player_name = self._info.Candidate.PlayerRankInfo.PlayerName})
    else
        self._name.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ARENA_BATTLE_TIPS10", 
            {player_name = Model.User.Name})
    end
    
    for _,v in ipairs(self._info.Equips)do
        if self["_itemEquip"..v.Pos] then
            self["_itemEquip"..v.Pos]:SetData(v.EquipId, v.Pos)
        end
    end
    self:RefreshListView()
end

function ArenaViewPlayerGame:RefreshListView(  )
    self._listView.numItems = self._itemLen
end


function ArenaViewPlayerGame:Close()
    UIMgr:Close("ArenaViewPlayerGame")
end

function ArenaViewPlayerGame:OnClose()
end


return ArenaViewPlayerGame