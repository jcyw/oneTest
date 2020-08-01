--author: 	Amu
--time:		2019-07-19 16:00:14
local GD = _G.GD
local ItemUnionUnshielding = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionUnshielding", ItemUnionUnshielding)

local CommonModel = import("Model/CommonModel")

ItemUnionUnshielding.tempList = {}

function ItemUnionUnshielding:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    self._btn = self:GetChild("btn")

    self:InitEvent()
end

function ItemUnionUnshielding:InitEvent()
    self:AddListener(self._btn.onClick,function()
        if self.type == 0 then
            Net.AllianceMessage.RequestReleasePlayer(self._info.PlayerId, function()
                 TipUtil.TipById(50228)
                self._panel:DelInfo(self.type, self._info.PlayerId)
            end)
        else
            Net.AllianceMessage.RequestReleaseAlliance(self._info.AllianceId, function()
                 TipUtil.TipById(50229)
                self._panel:DelInfo(self.type, self._info.AllianceId)
            end)
        end
    end)
end

function ItemUnionUnshielding:SetData(type, info, panel)
    self.type = type
    self._info = info
    self._panel = panel

    if self.type == 0 then
        -- CommonModel.SetUserAvatar(self._icon, info.Avatar)
        self._icon:SetAvatar(info)
        if info.AllianceName == "" then
            self._title.text = info.PlayerName
        else
            self._title.text = "["..info.AllianceName.."]"..info.PlayerName
        end
    else
        -- self._icon.icon = UnionModel.GetUnionBadgeIcon(info.Avatar)
        self._icon:SetAvatar({Alliance = info.AllianceName, AllianceAvatar = info.Avatar}, MSG_TYPE.LMsg)
        self._title.text = "("..info.AllianceShort..")"..info.AllianceName
    end
end

return ItemUnionUnshielding