--[[
    author:Temmie
    time:2020-06-29 10:41:12
    function:装备制造资源不足界面
]]
local EquipGetChip = _G.UIMgr:NewUI("EquipGetChip")
local UIMgr = _G.UIMgr
local ConfigMgr = _G.ConfigMgr
local CHIP_COST = _G.ConfigMgr.GetVar("Res4Equip")

function EquipGetChip:OnInit()
    self:AddListener(self._btnReturn.onClick, function()
        UIMgr:Close("EquipGetChip")
    end)

    self:AddListener(self._btnRes.onClick, function()
        UIMgr:ClosePopAndTopPanel()
        JumpMap:JumpTo({jump = 811100, para = Global.BuildingMilitarySupply})
    end)

    self:AddListener(self._btnDaily.onClick, function()
        UIMgr:ClosePopAndTopPanel()
        UIMgr:Open("TaskMain", true)
    end)
end

function EquipGetChip:OnOpen()
    local resConfig = ConfigMgr.GetItem("configResourcess", CHIP_COST)
    local name = StringUtil.GetI18n(I18nType.Commmon, resConfig.key)
    self._contentText.text = StringUtil.GetI18n(I18nType.Commmon, "Way_Get_Lack_Item", {res_name = name})
end

return EquipGetChip