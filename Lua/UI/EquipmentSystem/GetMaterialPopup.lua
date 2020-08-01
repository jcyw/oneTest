--[[
    author:Temmie
    time:2020-07-01
    function:分解材料获得提示弹窗
]]
local GetMaterialPopup = _G.UIMgr:NewUI("GetMaterialPopup")
local UIMgr = _G.UIMgr

function GetMaterialPopup:OnInit()
    self:AddListener(self._mask.onClick, function()
        UIMgr:Close("GetMaterialPopup")
    end)

    self:AddListener(self._btnClose.onClick, function()
        UIMgr:Close("GetMaterialPopup")
    end)

    self:AddListener(self._btnSureSingle.onClick, function()
        UIMgr:Close("GetMaterialPopup")
    end)
end

function GetMaterialPopup:OnOpen(datas)
    self.datas = datas
    self:RefreshList()
end

function GetMaterialPopup:RefreshList()
    self._list:RemoveChildrenToPool()
    for _,v in pairs(self.datas) do
        local item = self._list:AddItemFromPool()
        local config = EquipModel.GetMaterialByQualityId(v.ConfId)
        local data = {
            icon = config.icon,
            quality = math.fmod(v.ConfId, 100),
            ctr = 1,
            num = v.Amount
        }
        item:SetData(data)
    end
end

return GetMaterialPopup