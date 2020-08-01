--[[
    Author: songzeming
    Function: 联盟帮助Item
]]
local ItemUnionHelp = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionHelp", ItemUnionHelp)

local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local TechModel = import("Model/TechModel")

function ItemUnionHelp:ctor()
    self:AddListener(self._btnHelp.onClick,
        function()
            self:OnBtnHelpClick()
        end
    )
end

function ItemUnionHelp:Init(data, cb)
    self.data = data
    self.cb = cb
    -- CommonModel.SetUserAvatar(self._icon, data.Avatar, data.Id)
    self._icon:SetAvatar(data, nil, data.Id)
    self._name.text = data.Name
    if data.Category == Global.EventTypeBuilding then
        local values = {
            level = data.Level,
            build_name = BuildModel.GetName(data.ConfId)
        }
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Alliance_HelpMe_Build", values)
    elseif Tool.Equal(data.Category, Global.EventTypeTech, Global.EventTypeBeastTech) then
        local values = {
            level = data.Level,
            tech_name = TechModel.GetTechName(data.ConfId)
        }
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Alliance_HelpMe_Othera", values)
    elseif data.Category == Global.EventTypeCure then
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Alliance_HelpMe_Cure")
    elseif data.Category == Global.EventTypeBeastCure then
        local values = {
            beast_name = ConfigMgr.GetI18n(I18nType.Army, data.ConfId .. '_NAME')
        }
        self._desc.text = StringUtil.GetI18n(I18nType.Commmon, "Alliance_HelpMe_Beast_Cure", values)
    end
    local values = {
        now_number = data.Helped,
        max_number = data.HelpLimit
    }
    self._member.text = StringUtil.GetI18n(I18nType.Commmon, "Alliance_Help_schedule", values)
    self._slide.value = data.Helped / data.HelpLimit * 100
    self._btnHelp.visible = Model.Account.accountId ~= data.UserId
end

function ItemUnionHelp:OnBtnHelpClick()
    Net.AllianceHelp.Single(
        Model.Player.AllianceId,
        self.data.Uuid,
        function()
            Event.Broadcast(EventDefines.UIAllianceHelped, self.data.Uuid)
            self.cb()
        end
    )
end

return ItemUnionHelp
