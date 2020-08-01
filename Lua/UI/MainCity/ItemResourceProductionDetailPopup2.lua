--author: 	Amu
--time:		2019-11-01 20:09:18

local UpgradeModel = import("Model/UpgradeModel")
local BuffModel = import("Model/BuffModel")

local ItemResourceProductionDetailPopup2 = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemResourceProductionDetailPopup2", ItemResourceProductionDetailPopup2)

function ItemResourceProductionDetailPopup2:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")
    -- self._effect = self:GetChild("effect")
    -- self._effectCirclePic = self._effect:GetChild("circle"):GetChild("circle")
    NodePool.Init(NodePool.KeyType.ResBuildSpeedUp, "Effect", "EffectNode")

    self:InitEvent()
end

function ItemResourceProductionDetailPopup2:InitEvent(  )
    self._iconBuild = self:GetChild("iconBuild")
    self._level = self:GetChild("textLevel")
    self._outPutText = self:GetChild("textYieldTime")
end

function ItemResourceProductionDetailPopup2:SetData(info, type)
    self._info = info
    local buildInfo = Model.Buildings[info.Id]
    local _buildConfigInfo = ConfigMgr.GetItem("configResBuilds", buildInfo.ConfId+buildInfo.Level)
    local addProduce = _buildConfigInfo.produce*(BuffModel.GetResProduce(info.Category)-1)
    self._iconBuild.icon = UITool.GetIcon(UpgradeModel.GetIcon(buildInfo.ConfId, buildInfo.Level))
    self._level.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Level", {number = buildInfo.Level})
    if info.BuffExpireAt > Tool.Time() then
        addProduce = addProduce + info.Produce
        self:PlayEffect(true, info.BuffExpireAt - Tool.Time())
    else
        self:PlayEffect(false)
    end
    local addvalue = math.ceil(math.floor(addProduce*100)/100)
    local addSymbol = addvalue >= 0 and "+" or ""
    self._outPutText.text = ("%s %s [color=#30c756]%s/h[/color]"):format(
        Tool.FormatNumberThousands(math.ceil(_buildConfigInfo.produce)),addSymbol,Tool.FormatNumberThousands(addvalue))
end

function ItemResourceProductionDetailPopup2:GetData()
    return self._info
end

function ItemResourceProductionDetailPopup2:PlayEffect(flag, time)
    if flag then
        -- local color = Color(0.2, 1, 0.09)
        local path = "effects/build/resourcesincrease/prefab/effect_res_increase_g"
        local pathCircle = "effects/build/resourcesincrease/prefab/effect_res_increase_g_quanui"
        if time < 1800 then
            -- color = Color(1, 0.93, 0.09)
            path = "effects/build/resourcesincrease/prefab/effect_res_increase_y"
            pathCircle = "effects/build/resourcesincrease/prefab/effect_res_increase_y_quanui"
        end

        -- self._effect.visible = true
        -- self._effectCirclePic.color = color

        self.resBuildEffect = NodePool.Get(NodePool.KeyType.ResBuildSpeedUp)
        local x = self._iconBuild.x + self._iconBuild.width / 2
        local y = self._iconBuild.y + self._iconBuild.height / 2
        self.resBuildEffect.xy = Vector2(x, y)
        self:AddChild(self.resBuildEffect)
        -- self.resBuildEffect.sortingOrder = CityType.CITY_MAP_SORTINGORDER.PlaneAnimation
        self.resBuildEffect:InitNormal()
        -- self.resBuildEffect:PlayEffectLoop(path, Vector3(40, 40, 40))
        self.resBuildEffect:PlayEffectLoop(path, Vector3(0.5, 0.5, 0.5),0)

        self.resBuildEffectCircle = NodePool.Get(NodePool.KeyType.ResBuildSpeedUp)
        local x = self._iconBuild.x + self._iconBuild.width / 2
        local y = self._iconBuild.y + self._iconBuild.height / 2
        self.resBuildEffectCircle.xy = Vector2(x, y + 12)
        self:AddChildAt(self.resBuildEffectCircle, 1)
        self.resBuildEffectCircle:InitNormal()
        self.resBuildEffectCircle:PlayEffectLoop(pathCircle, Vector3(0.8, 0.8, 0.8),0)
    else
        -- self._effect.visible = false
        if self.resBuildEffect then
            self.resBuildEffect:StopEffect()
            NodePool.Set(NodePool.KeyType.ResBuildSpeedUp, self.resBuildEffect)
            self.resBuildEffect = nil
        end
        if self.resBuildEffectCircle then
            self.resBuildEffectCircle:StopEffect()
            NodePool.Set(NodePool.KeyType.ResBuildSpeedUp, self.resBuildEffectCircle)
            self.resBuildEffectCircle = nil
        end
    end
end

return ItemResourceProductionDetailPopup2