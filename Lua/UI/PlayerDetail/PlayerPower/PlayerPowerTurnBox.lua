--[[
    Author: songzeming
    Function: 玩家战力跳转弹窗
]]
local PlayerPowerTurnBox = UIMgr:NewUI("PlayerPower/PlayerPowerTurnBox")

import("UI/PlayerDetail/PlayerPower/ItemPlayerPowerTurnBox")
local JumpMap = import("Model/JumpMap")
local TURN_TRAIN_CONFID = {
    Global.BuildingTankFactory,
    Global.BuildingWarFactory,
    Global.BuildingHelicopterFactory,
    Global.BuildingVehicleFactory
}

function PlayerPowerTurnBox:OnInit()
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
end

function PlayerPowerTurnBox:OnOpen(index, title)
    self._power.text = title
    if index == 2 then
        --部队战斗力
        self._list:RemoveChildrenToPool()
        local ids = {2, 3, 4, 5}
        for k, id in pairs(ids) do
            local item = self._list:AddItemFromPool()
            local confId = TURN_TRAIN_CONFID[k]
            local cb_func = function()
                UIMgr:ClosePopAndTopPanel()
                JumpMap:JumpTo({jump = 810200, para = confId})
            end
            local conf = ConfigMgr.GetItem("configForcesUpgrades", id)
            local icon = conf.image
            local t = StringUtil.GetI18n(I18nType.Commmon, conf.name)
            item:Init(icon, t, cb_func)
        end
    else
        self._list:RemoveChildrenToPool()
        local item = self._list:AddItemFromPool()
        local id = 1
        local cb_func = nil
        if index == 1 then
            --指挥官战斗力
            id = 1
            cb_func = function()
                self:Close()
                UIMgr:Close("PlayerPower/PlayerPowerBox")
                --todo 经验点击指引
            end
        elseif index == 3 then
            --建筑战斗力
            id = 6
            cb_func = function()
                UIMgr:ClosePopAndTopPanel()
                JumpMap:JumpTo({jump = 810101, para = BuildModel.FindAllMinLevel().ConfId})
                --todo 建筑队列点击指引
            end
            local icon = {"IconQueue", "Queue_1"}
            local t = StringUtil.GetI18n(I18nType.Commmon, "Ui_ForcesUp_Building")
            item:Init(icon, t, cb_func)
        elseif index == 4 then
            --装备
            id = 10
            cb_func = function()
                UIMgr:ClosePopAndTopPanel()
                JumpMap:JumpTo({jump = 818000, para = Global.BuildingEquipFactory})
            end
        elseif index == 5 then
            --防御武器战斗力
            id = 7
            cb_func = function()
                UIMgr:ClosePopAndTopPanel()
                JumpMap:JumpTo({jump = 810200, para = Global.BuildingSecurityFactory})
            end
        elseif index == 6 then
            --联盟科技战斗力
            id = 8
            cb_func = function()
                UIMgr:ClosePopAndTopPanel()
                JumpMap:JumpTo({jump = 810300, para = Global.BuildingScience})
            end
        elseif index == 7 then
            --巨兽战斗力
            id = 9
            cb_func = function()
                UIMgr:ClosePopAndTopPanel()
                JumpMap:JumpTo({jump = 810100, para = Global.BuildingBeastBase})
            end
        end
        local conf = ConfigMgr.GetItem("configForcesUpgrades", id)
        local icon = conf.image
        local t = StringUtil.GetI18n(I18nType.Commmon, conf.name)
        item:Init(icon, t, cb_func)
    end
    self._list:EnsureBoundsCorrect()
    self._list.scrollPane.touchEffect = self._list.scrollPane.contentHeight > self._list.height
end

function PlayerPowerTurnBox:Close()
    UIMgr:Close("PlayerPower/PlayerPowerTurnBox")
end

return PlayerPowerTurnBox
