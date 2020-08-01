--[[
    Author:muyu
    Function:巨兽界面 巨兽Item
]]
local ItemMonster = fgui.extension_class(GComponent)
fgui.register_extension("ui://Monster/itemMonsterHospitalProp", ItemMonster)

local MonsterModel = import("Model/MonsterModel")
local TrainModel = import("Model/TrainModel")
local BLANK_HALF = 2 --占位

function ItemMonster:ctor()
    self:AddListener(self.onClick,function()
        self.cb()
    end)
end

function ItemMonster:Init(index,monster,cb)
    self._ctr = self:GetController("BloodCtr") 
    self.index = index
    self.monsterbaseId = monster.Id
    self.monsterId = monster.Id +monster.Level-1
    self.cb = cb
    self._icon.icon = TrainModel.GetImageAvatar(self.monsterId)
    self._bg.icon = TrainModel.GetBgAvatar(self.monsterId)

    local monsterConf = ConfigMgr.GetItem("configArmys", self.monsterId)
    self._textTroop.text = ArmiesModel.GetLevelText(monsterConf.level)
    self.typeId = MonsterModel.GetMonsterTypeId(self.monsterId)
    local MonsterType = ConfigMgr.GetItem("configArmyTypes", self.typeId)
    self._title.text = TrainModel.GetArmyI18n(MonsterType.i18n_name)

    --需要配置
    self:GetChild("textHP").text = StringUtil.GetI18n(I18nType.Commmon, "UI_Details_Health")
    local percent = math.floor(MonsterModel.GetBloodPercent((index+1),0))
    self:SetController(percent)
    
end

--设置巨兽血条颜色显示
function ItemMonster:SetController(percent)
    self._ctr.selectedPage = MonsterModel.GetBloodColor(percent)
    self:SetBloodPercent(percent)
end

--设置巨兽血量百分比显示
function ItemMonster:SetBloodPercent(percent)
    self:GetChild("barHp"..MonsterModel.GetBloodColor(percent)).value = percent
end

--设置巨兽被选择状态
function ItemMonster:SetLight(isLight)
    self._light.visible = isLight
end


function ItemMonster:GetIndex()
    return self.index
end

function ItemMonster:GetMonsterId()
    return self.monsterId
end

function ItemMonster:GetBaseMonsterId()
    return self.monsterbaseId
end


return ItemMonster
