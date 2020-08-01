--[[
    Author: songzeming
    Function:
]]
local ItemBuildPromptImage = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/ItemBuildPromptImage", ItemBuildPromptImage)

local CommonModel = import("Model/CommonModel")
local TrainModel = import("Model/TrainModel")
local TechModel = import("Model/TechModel")

function ItemBuildPromptImage:ctor()
    self:AddListener(self.onClick,function()
        self:OnBtnClick()
    end)
end

--军队建筑
function ItemBuildPromptImage:InitArmy(confId, id)
    self._box.visible = false
    self.confId = confId
    self.itemId = id
    self._icon.icon = TrainModel.GetImageNormal(id)
end

--科研中心
function ItemBuildPromptImage:InitScience(confId, id)
    self.confId = confId
    self.itemId = id
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configTechDisplays", id).icon)
    self._box.visible = true
end

--巨兽研究院
function ItemBuildPromptImage:InitMonsterScience(confId, id)
    self.confId = confId
    self.itemId = id
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configBeastTechDisplays", id).icon)
    self._box.visible = true
end

function ItemBuildPromptImage:OnBtnClick()
    if CommonModel.IsAllTrainFactoryOrNest(self.confId) then
        --军队建筑
        local armyConf = TrainModel.GetConf(self.itemId)
        local armyType = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        local isNest = CommonModel.IsNest(self.confId)
        local size = isNest and 190 or nil
        UIMgr:Open("ConfirmPopupLock", self._icon.icon, TrainModel.GetArmyI18n(armyType.i18n_name), TrainModel.GetArmyI18n(armyType.i18n_desc), false, size)
    elseif self.confId == Global.BuildingScience then
        --科研中心
        UIMgr:Open("ConfirmPopupLock", self._icon.icon, TechModel.GetTechName(self.itemId), TechModel.GetTechDesc(self.itemId),true)
    elseif self.confId == Global.BuildingBeastScience then
        --巨兽研究院
        UIMgr:Open("ConfirmPopupLock", self._icon.icon, TechModel.GetTechName(self.itemId), TechModel.GetTechDesc(self.itemId), true)
    end
end

return ItemBuildPromptImage
