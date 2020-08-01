--[[
    function:巨兽特性
    author:{tiantian}
    time:2020-07-29 10:00:23
]]
local Itemmonsterskill = fgui.extension_class(GComponent)
fgui.register_extension("ui://Monster/itemmonsterskill", Itemmonsterskill)

function Itemmonsterskill:ctor()
    self.detailPop = _G.UIMgr:CreatePopup("Common", "LongPressPopupLabel")

    self:AddListener(self.onTouchBegin,
    function()
        if not self._info then
            return
        end
        if(self.detailPop and self.detailPop.OnShowUI)then
            self.detailPop:OnShowUI(self._info[1], self._info[2],self._icon, false)
        end
    end
    )
    self:AddListener(self.onTouchEnd,
        function()
            self.detailPop:OnHidePopup()
        end
    )
    self:AddListener(self.onRollOut,function()
        self.detailPop:OnHidePopup()
    end)
end

function Itemmonsterskill:SetData(skillId)
    local skillCfg = _G.ConfigMgr.GetItem("configskills", skillId)
    self._info =
    {
        _G.StringUtil.GetI18n(_G.I18nType.Skills,skillCfg.i18n_name),
        _G.StringUtil.GetI18n(_G.I18nType.Skills,skillCfg.i18n_desc)

    }
    self._icon.icon = _G.UITool.GetIcon(skillCfg.icon)
end

return Itemmonsterskill