--author: 	Amu
--time:		2019-07-19 11:20:22

local ShieldType = {}
ShieldType.Player = 0
ShieldType.Union = 1


local UnionUnshielding = UIMgr:NewUI("UnionUnshielding")

function UnionUnshielding:OnInit()
    -- body
    self._view = self.Controller.contentPane
    self._btnReturn = self._view:GetChild("btnReturn")

    self._listView = self._view:GetChild("liebiao")

    self._tag = self._view:GetChild("textNotShielding")

    self._ctrView = self._view:GetController("c1")

    self.banList = {}

    self:InitEvent()
end

function UnionUnshielding:OnOpen()
    self.showType = ShieldType.Player
    self._ctrView.selectedIndex = ShieldType.Player
    Net.AllianceMessage.RequestBanList(Model.Player.AllianceId, function(msg)
        self.banList[ShieldType.Player] = msg.BanList
        self.banList[ShieldType.Union] = msg.AllianceBanList
        self:RefreshView()
    end)
end

function UnionUnshielding:InitEvent( )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    self:AddListener(self._ctrView.onChanged,function()
        self.showType = self._ctrView.selectedIndex
        self:RefreshView()
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then 
            return
        end
        item:SetData(self.showType, self.banList[self.showType][index+1], self)
    end
    self._listView:SetVirtual()
end

function UnionUnshielding:DelInfo(type, id)
    for k,v in pairs(self.banList[type]) do
        if type == ShieldType.Player then
            if v.PlayerId == id then
                table.remove(self.banList[type], k)
                break
            end
        else
            if v.AllianceId == id then
                table.remove(self.banList[type], k)
                break
            end
        end
    end
    self:RefreshView()
end

function UnionUnshielding:RefreshView()
    if #self.banList[self.showType] <= 0 then
        self._tag.visible = true
        if self.showType == ShieldType.Player then
            self._tag.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_UnBlocking_NoPlayer")
        elseif self.showType == ShieldType.Union then
            self._tag.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_UnBlocking_NoAlliance")
        end
    else
        self._tag.visible = false
    end
    self._listView.numItems = #self.banList[self.showType]
end

function UnionUnshielding:Close( )
    UIMgr:Close("UnionUnshielding")
end

return UnionUnshielding