--[[
    author:Temmie
    time:2019-8-14
    function:仓库资源描述界面
]]
local GD = _G.GD
local ResourceDescribe = UIMgr:NewUI("ResourceDescribe")

local BuildModel = import("Model/BuildModel")

function ResourceDescribe:OnInit()
    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("ResourceDescribe")
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("ResourceDescribe")
    end)
end

function ResourceDescribe:OnOpen(category)
    self._contentList:RemoveChildrenToPool()
    local normalRes = Model.Resources[category].Amount - Model.Resources[category].SafeAmount
    local protectMax = (Model.ResProtects[category] and Model.ResProtects[category].Amount) or 0
    local protectRes = normalRes > protectMax and protectMax or normalRes
    local dangerRes = normalRes > protectMax and normalRes - protectMax or 0

    -- 安全资源
    local safeItem = self._contentList:AddItemFromPool()
    safeItem:GetChild("_textTitle").color = Color(0.3, 0.65, 0.18)
    safeItem:GetChild("_textContent").text = ConfigMgr.GetI18n("configI18nCommons", "UI_Security_Res_Explain")
    safeItem:GetChild("_textTitle").text = StringUtil.GetI18n(I18nType.Commmon, "UI_Security_Res", {res_amount = GD.ResAgent.SafeAmount(category, true)})

    -- 仓库保护资源
    local protItem = self._contentList:AddItemFromPool()
    protItem:GetChild("_textTitle").color = Color(0.78, 0.68, 0.39)
    protItem:GetChild("_textContent").text = ConfigMgr.GetI18n(I18nType.Commmon, "Ui_Lay_Res_Explain")
    protItem:GetChild("_textTitle").text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Lay_Res", {res_amount = Tool.FormatAmountUnit(protectRes), warehouse_volume = Tool.FormatAmountUnit(protectMax)})

    -- 非安全资源
    local dangerItem = self._contentList:AddItemFromPool()
    dangerItem:GetChild("_textTitle").color = Color(0.86, 0.36, 0.37)
    dangerItem:GetChild("_textContent").text = ConfigMgr.GetI18n(I18nType.Commmon, "UI_Nonsecurity_Res_Explain")
    dangerItem:GetChild("_textTitle").text = StringUtil.GetI18n(I18nType.Commmon, "UI_Nonsecurity_Res", {res_amount = Tool.FormatAmountUnit(dangerRes)})
end

return ResourceDescribe