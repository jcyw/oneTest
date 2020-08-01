--[[
    author:Temmie
    time:2020-06-23
    function:装备材料生产加速弹窗
]]
local EquipPayAccelerationPopup = _G.UIMgr:NewUI("EquipPayAccelerationPopup")
local UIMgr = _G.UIMgr
local EquipModel = _G.EquipModel

function EquipPayAccelerationPopup:OnInit()
    self._textGold = self._btnSureGold:GetChild("text")
    self.time_func = function()
        local time = self.event.FinishAt - Tool.Time()
        self.gold = math.ceil(Global.DiamondPerHours * (time / 3600))--Tool.TimeTurnGold(time)
        if time > 0 then
            self._textGold.text = self.gold
            self._textProgress.text = StringUtil.GetI18n(I18nType.Commmon, "Vip_Activate_Time", {vip_active_time = TimeUtil.SecondToHMS(time)})
            self._progressBar.value = 100 - ((time / self.event.Duration) * 100)
        else
            self:UnSchedule(self.time_func)
            UIMgr:Close("EquipPayAccelerationPopup")
        end
    end

    self:AddListener(self._mask.onClick, function()
        UIMgr:Close("EquipPayAccelerationPopup")
    end)

    self:AddListener(self._btnClose.onClick, function()
        UIMgr:Close("EquipPayAccelerationPopup")
    end)

    self:AddListener(self._btnSureGold.onClick, function()
        if self.gold > Model.Player.Gem then
            UITool.GoldLack()
            return
        end
        if self.isEquip then
            self:EquipSpeed()
            return
        end
        self:MaterialSpeed()
    end)
end
function EquipPayAccelerationPopup:MaterialSpeed()
    _G.Net.Events.Speedup(_G.EventType.B_EQUIPMATERIALMAKE, self.event.Uuid, function(rsp)
        local getId = self.event.JewelId
        if self.cb then
            self.cb()
        end
            
        Net.Equip.CollectJewel(function(rsp)
            Model.JewelMakeInfo = rsp
                
            local buildId = BuildModel.GetObjectByConfid(Global.BuildingEquipMaterialFactory)
            local node = BuildModel.GetObject(buildId)
            if node then
                --刷新建筑倒计时条
                node:ResetCD()
            end

            --播放领取动画
            UIMgr:Open("EffectRewardMask", CommonType.REWARD_TYPE.GetEquipMaterial, getId)
                
            UIMgr:Close("EquipPayAccelerationPopup")            
            end)
        end
    )
end
function EquipPayAccelerationPopup:EquipSpeed()
        EquipModel.EquipSpeed(self.event.Uuid,self.event.EquipId,function ()
            if self.cb then
                self.cb()
            end
            UIMgr:Close("EquipPayAccelerationPopup")
        end)
end
function EquipPayAccelerationPopup:OnOpen(cb,isEquip)
    self.cb = cb
    if isEquip then
        self.isEquip = true
        self.event = EquipModel.GetEquipEvents()
        local typeConfig = EquipModel.GetEquipTypeByEquipQualityID(self.event.EquipId)
        self._icon:SetType(0)
        self._icon:SetIcon(typeConfig.icon)
        self._icon:SetNum("")
        self._icon:SetQuality(EquipModel.QualityID2Quality(self.event.EquipId - 1))
    else
        self.isEquip = false
        self.event = EquipModel.GetMakingMaterial()
        local typeConfig = EquipModel.GetMaterialByQualityId(self.event.JewelId)
        self._icon:SetType(0)
        self._icon:SetIcon(typeConfig.icon)
        self._icon:SetNum("")
        self._icon:SetQuality(EquipModel.QualityID2Quality(self.event.JewelId - 1))
    end
    self:Schedule(self.time_func, 1)
end

return EquipPayAccelerationPopup