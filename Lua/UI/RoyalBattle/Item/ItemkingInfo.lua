--[[
    author:{tiantian}
    time:2020/6/10
    function:{市长信息}
]]
local ItemkingInfo = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/ItemkingInfo", ItemkingInfo)

function ItemkingInfo:ctor()
    UITool.GetIcon({"falcon", "banner_wz01"}, self._bg)
    self:InitEvent()
    self:RefreshUI()
end
function ItemkingInfo:InitEvent()
    self:AddListener(
        self._icon.onClick,
        function()
            local status, _ = _G.RoyalModel.GetRoyalStatus()
            if self.warInfo and status == _G.RoyalModel.RoyalStatusType.Amani then
                local kingConfig = ConfigMgr.GetItem("configWarZoneOfficers", 101)
                RoyalModel.GetKingInfo(function()UIMgr:Open("OfficerPopUpBox",kingConfig,true)end)
            end
        end
    )
    self:AddEvent(
        EventDefines.KingInfoChange,
        function()
            self:RefreshUI()
        end
    )
end
function ItemkingInfo:RefreshUI()
    --战区司令
    local kingeStr = _G.RoyalModel.GetOfficialTitleStr(_G.RoyalModel.OfficialTitleType.Throne_OfficialPost_King)
    self._position.text = string.format("%s", kingeStr)

    self.warInfo = _G.RoyalModel.warInfo
    local status, _ = _G.RoyalModel.GetRoyalStatus()
    if not self.warInfo or status ~= _G.RoyalModel.RoyalStatusType.Amani  then
        -- self._icon.icon = UITool.GetIcon(Global.AvatarDefaultBackground)
        self._icon:SetAvatar(nil)
        self._name.text = _G.StringUtil.GetI18n(_G.I18nType.Commmon, "Ui_Free_Position")
    else
        local info = self.warInfo.KingInfo
        -- CommonModel.SetUserAvatar(self._icon, info.Avatar, info.PlayerId)
        self._icon:SetAvatar(info, nil, info.PlayerId)
        local allianceeText = string.len(info.AllianceShortName)>0 and string.format("[%s]", info.AllianceShortName) or ""
        self._name.text = allianceeText .. info.Name
    end
end
