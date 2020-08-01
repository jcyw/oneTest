--[[
    Author: songzeming
    Function: 训练界面 兵种详情
]]
local ItemTrainArmyDetail = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/trainTips', ItemTrainArmyDetail)

local TrainModel = import('Model/TrainModel')
local DetailModel = import('Model/DetailModel')
local BuildModel = import('Model/BuildModel')
local BuffModel = import('Model/BuffModel')
local CONTROLLER = {
    Train = 'Train', --训练
    CityDefense = 'CityDefense' --城防
}

function ItemTrainArmyDetail:ctor()
    self._controller = self:GetController('Controller')

    self:AddListener(self._btnDetail.onClick,
        function()
            self:OnBtnArmyDetailClick()
        end
    )
end

function ItemTrainArmyDetail:Init(confId, armyId)
    self.confId = confId
    self.armyId = armyId

    local conf = TrainModel.GetConf(armyId)
    self.isTrap = conf.is_defence

    local curNum = TrainModel.GetArmAmount(armyId)
    if self.isTrap then
        --安保工厂
        local building = BuildModel.FindByConfId(Global.BuildingWall)
        local confWall = DetailModel.GetWallConf(building.ConfId + building.Level)
        local values = {
            have_amount = curNum,
            volume_amount = confWall.defense_limit + BuffModel.GetTrapLimit()
        }
        self._controller.selectedPage = CONTROLLER.CityDefense
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, 'UI_Have_Volume', values)
    else
        --训练工厂
        local values = {
            base_amount = curNum,
            have_amount = TrainModel.GetArmTotal(armyId)
        }
        self._controller.selectedPage = CONTROLLER.Train
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, 'UI_Base_Have', values)
    end
end

--点击兵种详情按钮
function ItemTrainArmyDetail:OnBtnArmyDetailClick()
    if self.isTrap then
        --安保工厂
        UIMgr:Open("TrainRelated/CityDefenseAttribute", self.armyId)
    else
        --训练工厂
        local armIds = {}
        local index = 1
        local arm = TrainModel.GetArm(self.confId)
        for i = 1, arm.amount do
            local confId = arm.base_level + i - 1
            table.insert(armIds, confId)
            if confId == self.armyId then
                index = i
            end
        end
        UIMgr:Open("TroopsDetailsPopup", armIds, index)
    end
end

return ItemTrainArmyDetail
