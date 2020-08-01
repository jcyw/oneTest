--[[
    author:{zhanzhang}
    time:2019-07-04 21:01:19
    function:{联盟进攻兵力详情Item}
]]
local ItemUnionArmyDetail = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemUnionArmyDetail", ItemUnionArmyDetail)

local TrainModel = import("Model/TrainModel")

function ItemUnionArmyDetail:ctor()
    self._icon = self:GetChild("icon")
    self._iconBg = self:GetChild("bg")
    self._textNum = self:GetChild("textNum")
    self._textLv = self:GetChild("textTroop")
    self._iconTroop = self:GetChild("iconTroop")
    self._sizeControl = self:GetController("sizeControl")

    self:AddListener(self.onClick,
        function()
            if self.callBack then
                self.callBack(self)
            end
        end
    )

    self:AddEvent(
        EventDefines.UIArmiesRefresh,
        function()
            local armies = Model.GetMap("Armies")
            for _, v in pairs(armies) do
                if v.ConfId == self.configId then
                    self:Refresh(v.Amount)                    
                end
            end
        end
    )
end

function ItemUnionArmyDetail:Init(info, parent, cb)
    self.callBack = cb
    self.panel = parent
    self.confId = info.ConfId
    self._icon.url = TrainModel.GetImageAvatar(info.ConfId)
    self._iconBg.url = TrainModel.GetBgAvatar(info.ConfId)
    self._textNum.text = "x"..info.Amount 
    self._sizeControl.selectedPage = "small"
    local armyInfo = ConfigMgr.GetItem("configArmys",info.ConfId)
    self._textLv.text = ArmiesModel.GetLevelText(armyInfo.level)
    if armyInfo.army_type == Global.SecurityArmyType then
        self._iconTroop.visible = false
    else
        self._iconTroop.visible = true
        self._iconTroop.url = TrainModel.GetArmIcon(armyInfo.arm)
    end
end

function ItemUnionArmyDetail:BeastInit(info, parent, cb)
    local confId = info.Level > 0 and (info.Id + info.Level - 1) or info.Id
    local config = ConfigMgr.GetItem("configArmys", confId)
    self.callBack = cb
    self.panel = parent
    self.confId = confId
    self._icon.url = UITool.GetIcon(config.army_port)
    self._iconBg.url = UITool.GetIcon(config.amry_icon_bg)
    self._textLv.text = ArmiesModel.GetLevelText(info.Level)
    self._iconTroop.visible = false
    self._sizeControl.selectedPage = "blood"
    self._barHp.value = (info.Health / config.health) * 100
end

function ItemUnionArmyDetail:Refresh(amount)
    self._textNum.text = amount
    if amount <= 0 and self.panel then
        self.panel:Refresh(self.confId)
    end
end
------------------------------------------
function ItemUnionArmyDetail:InitArmy(info)
    local armyInfo = ConfigMgr.GetItem("configArmys", info.ConfId)

    self._textName.text = ConfigMgr.GetI18n("configI18nArmys", info.ConfId .. "_NAME")
    self._icon.url = TrainModel.GetImageAvatar(info.ConfId)
    self._textNum.text = info.amount
end

return ItemUnionArmyDetail
