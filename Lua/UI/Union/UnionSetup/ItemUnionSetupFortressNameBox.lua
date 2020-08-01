--[[
    联盟管理修改堡垒名称界面列表项
    author:{Temmie}
    time:2019-07-31
]]
local ItemUnionSetupFortressNameBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionReviseClassFortressAppellationItem", ItemUnionSetupFortressNameBox)

function ItemUnionSetupFortressNameBox:ctor()
    self._txtOldName = self:GetChild("textAssistant")
    self._inputName = self:GetChild("textAssistantN")

    self:AddListener(self._inputName.onFocusOut,function()
        if self.cb ~= nil then
            self.cb(self.info.ConfId, self._inputName.text)
        end
    end)
end

function ItemUnionSetupFortressNameBox:Init(info, cb)
    local fortressConfig = ConfigMgr.GetItem("configAllianceFortresss", info.ConfId)
    self._txtOldName.text = info.Name == fortressConfig.building_name and StringUtil.GetI18n(I18nType.Commmon, fortressConfig.building_name) or info.Name
    self._inputName.text = ""
    self.info = info
    self.cb = cb
end

return ItemUnionSetupFortressNameBox
