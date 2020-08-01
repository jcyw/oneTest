--[[
    Author: songzeming
    Function: 训练界面 兵种列表Item
]]
local ItemTrainArmy = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemTrainArmy", ItemTrainArmy)

local TrainModel = import("Model/TrainModel")
local BLANK_HALF = 2 --占位

local ICONSTATE = {
    unlock = "unlock",
    lock = "lock"
}
local ICONPOSI = {
    [3] = "flight&security",
    [5] = "flight&security",
    [1]= "tank&trunk",
    [2]= "tank&trunk",
    [4]= "tank&trunk",
}

function ItemTrainArmy:ctor()
    self._iconNode = self:GetChild("icon")
    self._icon = self._iconNode:GetChild("_icon")
    self._iconState = self._iconNode:GetController("state")
    self._iconposition = self._iconNode:GetController("position")
    self._controller = self:GetController("button")
    self:AddListener(self.onClick,function()
        self.cb()
    end)
end

function ItemTrainArmy:Init(index, armyId, flag, cb)
    self.index = index
    self.armyId = nil
    self.visible = flag
    self.touchable = flag
    if not flag then
        return
    end
    self.armyId = armyId
    self.cb = cb

    local isLock = not TrainModel.GetArmUnlock(armyId)
    self._icon.icon = TrainModel.GetImageNormal(armyId)
    self._iconState.selectedPage = isLock and ICONSTATE.lock or ICONSTATE.unlock
    self._lock.visible = isLock
    self._light3.visible = not isLock
    self:SetIconAlpha(isLock and 0.4 or 1)
    local armyConf = ConfigMgr.GetItem("configArmys", armyId)
    self._iconposition.selectedPage = ICONPOSI[armyConf.army_type]
    self._t.text = ArmiesModel.GetLevelText(armyConf.level)
    if armyConf.is_defence then
        self._btnArmyType.visible = false
    else
        self._btnArmyType.visible = true
        local armyTypeConf = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        self._btnArmyType.icon = UITool.GetIcon(armyTypeConf.icon)
    end
    self:SetLight(false)
end

function ItemTrainArmy:SetLight(isLight)
    local index = self._btnArmyType.visible and 1 or 2
    self._controller.selectedIndex = isLight and index or 0
    --self._mask.visible = not isLight
    --self._lock.grayed = not isLight
end

function ItemTrainArmy:GetLock()
    return self._lock.visible
end

function ItemTrainArmy:GetIndex()
    return self.index
end

function ItemTrainArmy:GetArmyId()
    return self.armyId
end

function ItemTrainArmy:SetIconAlpha(alpha)
    self._icon.alpha = alpha
end

function ItemTrainArmy:SetMaskAlpha(alpha)
    --self._mask.alpha = alpha
end

return ItemTrainArmy