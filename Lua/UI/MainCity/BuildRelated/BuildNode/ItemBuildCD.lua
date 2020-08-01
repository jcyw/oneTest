--[[
    Author: songzeming
    Function: 建筑 倒计时显示
]]
local ItemBuildCD = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/itemBuildCD", ItemBuildCD)

import("UI/MainCity/BuildRelated/BuildAnim/BuildCenter")
import("UI/MainCity/BuildRelated/BuildAnim/BuildBeastBase")
import("UI/MainCity/BuildRelated/BuildAnim/BuildHospital")
import("UI/MainCity/BuildRelated/BuildAnim/BuildBeastHospital")
import("UI/MainCity/BuildRelated/BuildAnim/BuildUpgradeAnimWall")
import("UI/MainCity/BuildRelated/BuildAnim/BuildUpgradeAnimInner")
import("UI/MainCity/BuildRelated/BuildAnim/BuildUpgradeAnimOuter")
local BuildModel = import("Model/BuildModel")
local TrainModel = import("Model/TrainModel")
local MonsterModel = import("Model/MonsterModel")
local TechModel = import("Model/TechModel")

function ItemBuildCD:ctor()
    self.hammerkey = NodePool.KeyType.HammerBuild
    NodePool.Init(self.hammerkey, "Build", "hammerBuild")
    self:SetCDActive(false)
end

-- 重置倒计时显示
function ItemBuildCD:ResetBuild(ctx, event, isInit)
    self.ctx = ctx
    self.event = event
    self.isInit = isInit
    self.confId = self.ctx.building.ConfId
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    if not event or event.JewelId==0 then
        self:SetCDActive(false)
        ctx:IdleAnim(true)
        return
    end
    ctx:IdleAnim(false)
    local function time_func()
        local ct = event.FinishAt - Tool.Time()
        return ct <= event.Duration and ct or event.Duration
    end
    if time_func() > 0 then
        local isSpecial = event.Duration <= 3
        if isSpecial then
            self._bar.value = 0
            self._bar:TweenValue(100, time_func() - 0.1)
        end
        self:SetCDActive(true)
        self:SetIcon()
        local bar_func = function()
            local t = time_func()
            if not isSpecial then
                self._bar.value = (1 - t / event.Duration) * 100
            end
            self._text.text = Tool.FormatTime(t)
            self:SetTitle(event.Category, t)
        end
        bar_func()
        self.cd_func = function()
            ctx:ShowStatus(event)
            if time_func() >= 0 then
                bar_func()
                return
            end
            self:SetCDActive(false)
        end
        self:Schedule(self.cd_func, 1)
    end
end

-- 设置倒计时是否显示
function ItemBuildCD:SetCDActive(flag)
    if self.ctx then
        self.ctx:ResetHarest()
    end
    if not flag then 
        self:StopBuildAnim()
    end
    self:UpdateState()
    self.visible = flag
    if flag then
        return
    end
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
end

-- 获取倒计时是否显示
function ItemBuildCD:GetCDActive()
    return self.visible
end

-- 设置Icon
function ItemBuildCD:SetIcon()
    local id = 11
    local title = ""
    self._groupDetail.visible = true
    if self.event.Category == EventType.B_BUILD then
        if self.ctx.building.Level == 0 then
            --建造
            id = 12
            self.isInit = false
        else
            --升级
            id = 11
        end
        self._groupDetail.visible = false
        self:PlayBuildUpgradeAnim()
    elseif self.event.Category == EventType.B_DESTROY then
        --拆除
        id = 13
        self._groupDetail.visible = false
        self:PlayBuildUpgradeAnim()
    elseif self.event.Category == EventType.B_TRAIN then
        --训练
        if self.confId == Global.BuildingTankFactory then
            id = 21
        elseif self.confId == Global.BuildingHelicopterFactory then
            id = 23
        elseif self.confId == Global.BuildingWarFactory then
            id = 22
        elseif self.confId == Global.BuildingVehicleFactory then
            id = 24
        elseif self.confId == Global.BuildingSecurityFactory then
            id = 25
        end
        title = TrainModel.GetName(self.event.ConfId) .. " " .. self.event.Amount
    elseif self.event.Category == EventType.B_TECH then
        --科研
        id = 31
        title = TechModel.GetTechName(self.event.TargetId)
    elseif self.event.Category == EventType.B_CURE then
        --医疗
        id = 41
        local amount = 0
        for _, v in pairs(self.event.Armies) do
            amount = amount + v.Amount
        end
        local values = {
            amount = amount
        }
        title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Treating_Army", values)
        self.ctx._btnIcon:StopCureAnim()
    elseif self.event.Category == EventType.B_BEASTTECH then
        --巨兽科研
        id = 32
        title = TechModel.GetTechName(self.event.TargetId)
    elseif self.event.Category == EventType.B_BEASTCURE then
        --巨兽医疗
        id = 42
        local event = Model.GetMap(ModelType.BeastCureEvents)
        for _,v in pairs(event) do
            if MonsterModel.GetBeastModels()[v.BeastId] then
                local c = MonsterModel.GetMonsterRealID(v.BeastId, MonsterModel.GetBeastModels()[v.BeastId].Level)
                title = StringUtil.GetI18n(I18nType.Commmon, "Ui_Treating_Army", {amount = StringUtil.GetI18n(I18nType.Army, c.."_NAME")})
                break
            end
        end
        self.ctx._btnIcon:StopCureAnim()
    elseif self.event.JewelId then
        --装备材料生产
        local typeConfig = EquipModel.GetMaterialByQualityId(self.event.JewelId)
        title = StringUtil.GetI18n(I18nType.Equip, typeConfig.name)
    elseif self.event.EquipId then
        --装备制造
        local typeConfig = EquipModel.GetEquipTypeByEquipQualityID(self.event.EquipId)
        title = StringUtil.GetI18n(I18nType.Equip, typeConfig.name)
    end
    self._btn.icon = UITool.GetIcon(ConfigMgr.GetItem("configQueueIcons", id).icon)
    self._title.text = title
end

--设置Title (仅限升级建造拆除)
function ItemBuildCD:SetTitle(category, time)
    if category == EventType.B_BUILD or category == EventType.B_DESTROY then
        local ctime = time - CommonModel.FreeTime()
        if ctime > 0 and ctime < 15 * 60 then
            self._groupDetail.visible = true
        if ctime < 60 then
                local values = {
                    time = ctime
                }
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rest_Time_Secend", values)
            else
                local values = {
                    time = math.floor(ctime / 60)
                }
                self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Rest_Time_Minute", values)
            end
        else
            self._groupDetail.visible = false
        end
    end
end

function ItemBuildCD:ClearEvent()
    self.event = nil
end

--建筑建造、升级动画
function ItemBuildCD:PlayBuildUpgradeAnim()
    if self.isPlayBuildUpgradeAnim then
        return
    end
    if(GlobalVars.IsShowEffect())then
        if self.confId == Global.BuildingCenter then
            --指挥中心
            if self.isInit then
                self.ctx._btnIcon:PlayLoopAnim()
            else
                -- self.ctx._btnIcon:PlayStartAnim()
                self.ctx._btnIcon:PlayLoopAnim()
            end
            self:PlayCenterBuildEffect(true)
        elseif self.confId == Global.BuildingWall then
            --围墙
            if self.isInit then
                self.ctx._btnIcon:GetChild("effect"):PlayLoopAnim()
            else
                -- self.ctx._btnIcon:GetChild("effect"):PlayStartAnim()
                self.ctx._btnIcon:GetChild("effect"):PlayLoopAnim()
            end
            self:PlayWallBuildEffect(true)
        else
            --内外城通用
            local posType = BuildModel.GetBuildPosTypeByPos(self.ctx.building.Pos)
            if Tool.Equal(posType, Global.BuildingZoneInnter, Global.BuildingZoneBeast) then
                --城内、巨兽
                self.poolKey = NodePool.KeyType.BuildUpgradeAnimInner
                NodePool.Init(self.poolKey, "Build", "BuildUpgradeAnimInner")
                self.effect = NodePool.Get(self.poolKey)
                self:PlayInnerBuildEffect(true)
            elseif Tool.Equal(posType, Global.BuildingZoneWild) then
                --城外
                self.poolKey = NodePool.KeyType.BuildUpgradeAnimOuter
                NodePool.Init(self.poolKey, "Build", "BuildUpgradeAnimOuter")
                self.effect = NodePool.Get(self.poolKey)
                self:PlayOuterBuildEffect(true)
            elseif Tool.Equal(posType, Global.BuildingZoneNest) then
                --巢穴
                self.poolKey = NodePool.KeyType.BuildUpgradeAnimNest
                NodePool.Init(self.poolKey, "Build", "BuildUpgradeAnimInner")
                self.effect = NodePool.Get(self.poolKey)
                self:PlayInnerBuildEffect(true)
            end

            local _map = CityMapModel.GetCityMap()
            local parentNode = _map[CityType.CITY_MAP_NODE_TYPE.BuildUpgradeAnim.name]
            parentNode:AddChildAt(self.effect, 0)
            self.effect.xy = self.ctx.xy
            if self.isInit then
                self.effect:PlayLoopAnim()
            else
                -- self.effect:PlayStartAnim()
                self.effect:PlayLoopAnim()
            end
        end
    else
        local posType = BuildModel.GetBuildPosTypeByPos(self.ctx.building.Pos)
        self.effect = NodePool.Get(self.hammerkey)
        local _map = CityMapModel.GetCityMap()
        local parentNode = _map[CityType.CITY_MAP_NODE_TYPE.BuildUpgradeAnim.name]
        parentNode:AddChild(self.effect)
        if(self.confId == Global.BuildingCenter)then
            self.effect:SetScale(1.0, 1.0)
            self.effect.xy = self.ctx.xy + Vector2(0,-500)
        elseif self.confId == Global.BuildingWall then
            self.effect:SetScale(0.6, 0.6)
            self.effect.xy = self.ctx.xy + Vector2(-200,-300)
        else
            if Tool.Equal(posType, Global.BuildingZoneInnter, Global.BuildingZoneBeast) then
                self.effect:SetScale(0.6, 0.6)
                self.effect.xy = self.ctx.xy + Vector2(-100,-250)
            elseif Tool.Equal(posType, Global.BuildingZoneWild) then
                self.effect:SetScale(0.5, 0.5)
                self.effect.xy = self.ctx.xy + Vector2(-100,-200)
            elseif Tool.Equal(posType, Global.BuildingZoneNest) then
                self.effect:SetScale(0.6, 0.6)
                self.effect.xy = self.ctx.xy + Vector2(-100,-250)
            else
                self.effect:SetScale(0.6, 0.6)
                self.effect.xy = self.ctx.xy + Vector2(-100,-250)
            end
        end
    end
    self.isPlayBuildUpgradeAnim = true
end
--关闭建筑建造升级动画
function ItemBuildCD:StopBuildUpgradeAnim()
    if not self.isPlayBuildUpgradeAnim then
        return
    end
    self.isPlayBuildUpgradeAnim = false
    if(GlobalVars.IsShowEffect())then
        if self.confId == Global.BuildingCenter then
            if(GlobalVars.IsShowEffect())then
                --指挥中心
                -- self.ctx._btnIcon:PlayEndAnim()
                self.ctx._btnIcon:StopAnim()
            end
            self:PlayCenterBuildEffect(false)
        elseif self.confId == Global.BuildingWall then
            if(GlobalVars.IsShowEffect())then
                --围墙
                -- self.ctx._btnIcon:GetChild("effect"):PlayEndAnim()
                self.ctx._btnIcon:GetChild("effect"):StopAnim()
            end
            self:PlayWallBuildEffect(false)
        else
            --内外城通用
            -- self.effect:PlayEndAnim(function()
            --     NodePool.Set(self.poolKey, self.effect)
            -- end)
            self.effect:StopAnim()
            NodePool.Set(self.poolKey, self.effect)

            local posType = BuildModel.GetBuildPosTypeByPos(self.ctx.building.Pos)
            if Tool.Equal(posType, Global.BuildingZoneWild) then
                self:PlayOuterBuildEffect(false)
            else
                self:PlayInnerBuildEffect(false)
            end
        end
    else
        if(self.effect)then
            --self.effect:StopAnim()
            NodePool.Set(self.hammerkey, self.effect)
        end
    end
end

--关闭特效
function ItemBuildCD:StopBuildAnim()
    self:StopBuildUpgradeAnim()
end

--刷新状态
function ItemBuildCD:UpdateState()
    if Tool.Equal(self.confId, Global.BuildingHospital, Global.BuildingBeastHospital) then
        self.ctx._btnIcon:CheckInjuredArmy()
    end
end

--移动建筑重置节点位置
function ItemBuildCD:ResetPos()
    if self.effect then
        self.effect.xy = self.ctx.xy
    end
end

function ItemBuildCD:PlayCenterBuildEffect(isPlay)
    if isPlay and not self.centerBuildEffect then
        NodePool.Init(NodePool.KeyType.CenterBuildingEffect, "Effect", "EffectNode")
        self.centerBuildEffect = NodePool.Get(NodePool.KeyType.CenterBuildingEffect)
        self.ctx:AddChild(self.centerBuildEffect)
        self.centerBuildEffect.xy = Vector2(-80, -106)
        self.centerBuildEffect.sortingOrder = BuildType.SORTINGORDER.BuildingEffect
        self.centerBuildEffect:PlayDynamicEffectLoop("effect_collect", "effect_build_smoke_base")
    elseif not isPlay and self.centerBuildEffect then
        self.centerBuildEffect:StopEffect()
        NodePool.Set(NodePool.KeyType.CenterBuildingEffect, self.centerBuildEffect)
        self.centerBuildEffect = nil
    end
end

function ItemBuildCD:PlayWallBuildEffect(isPlay)
    if isPlay and not self.wallBuildEffect then
        local _map = CityMapModel.GetCityMap()
        local parentNode = _map[CityType.CITY_MAP_NODE_TYPE.BuildUpgradeAnim.name]
        NodePool.Init(NodePool.KeyType.WallBuildingEffect, "Effect", "EffectNode")
        self.wallBuildEffect = NodePool.Get(NodePool.KeyType.WallBuildingEffect)
        parentNode:AddChild(self.wallBuildEffect)
        self.wallBuildEffect.xy = self.ctx.xy - Vector2(258, 437)
        self.wallBuildEffect.sortingOrder = BuildType.SORTINGORDER.BuildingEffect
        self.wallBuildEffect:PlayDynamicEffectLoop("effect_collect", "effect_build_smoke_wall")
    elseif not isPlay and self.wallBuildEffect then
        self.wallBuildEffect:StopEffect()
        NodePool.Set(NodePool.KeyType.WallBuildingEffect, self.wallBuildEffect)
        self.wallBuildEffect = nil
    end
end

function ItemBuildCD:PlayInnerBuildEffect(isPlay)
    if isPlay and not self.innerBuildEffect then
        local _map = CityMapModel.GetCityMap()
        local parentNode = _map[CityType.CITY_MAP_NODE_TYPE.BuildUpgradeAnim.name]
        NodePool.Init(NodePool.KeyType.InnerBuildingEffect, "Effect", "EffectNode")
        self.innerBuildEffect = NodePool.Get(NodePool.KeyType.InnerBuildingEffect)
        parentNode:AddChild(self.innerBuildEffect)
        self.innerBuildEffect.xy = self.ctx.xy - Vector2(89, 92)
        self.innerBuildEffect.sortingOrder = 2000
        self.innerBuildEffect:PlayDynamicEffectLoop("effect_collect", "effect_build_smoke_incity")
    elseif not isPlay and self.innerBuildEffect then
        self.innerBuildEffect:StopEffect()
        NodePool.Set(NodePool.KeyType.InnerBuildingEffect, self.innerBuildEffect)
        self.innerBuildEffect = nil
    end
end

function ItemBuildCD:PlayOuterBuildEffect(isPlay)
    if isPlay and not self.outerBuildEffect then
        local _map = CityMapModel.GetCityMap()
        local parentNode = _map[CityType.CITY_MAP_NODE_TYPE.BuildUpgradeAnim.name]
        NodePool.Init(NodePool.KeyType.OuterBuildingEffect, "Effect", "EffectNode")
        self.outerBuildEffect = NodePool.Get(NodePool.KeyType.OuterBuildingEffect)
        parentNode:AddChild(self.outerBuildEffect)
        self.outerBuildEffect.xy = self.ctx.xy - Vector2(34, 63)
        self.outerBuildEffect.sortingOrder = BuildType.SORTINGORDER.BuildingEffect
        self.outerBuildEffect:PlayDynamicEffectLoop("effect_collect", "effect_build_smoke_outcity")
    elseif not isPlay and self.outerBuildEffect then
        self.outerBuildEffect:StopEffect()
        NodePool.Set(NodePool.KeyType.OuterBuildingEffect, self.outerBuildEffect)
        self.outerBuildEffect = nil
    end
end

return ItemBuildCD
