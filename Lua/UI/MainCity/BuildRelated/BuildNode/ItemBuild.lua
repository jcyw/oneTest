--[[
    Author: songzeming
    Function: 建筑
]]
local ItemBuild = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/itemBuild", ItemBuild)

local BuildModel = import("Model/BuildModel")
local TrainModel = import("Model/TrainModel")
local CommonModel = import("Model/CommonModel")
local EventModel = import("Model/EventModel")
local UnionModel = import("Model/UnionModel")
local BuffModel = import("Model/BuffModel")
local TechModel = import("Model/TechModel")
local AnimationArmyQueue = import("Model/Animation/AnimationArmyQueue")
local BuildNest = import("UI/MainCity/BuildRelated/BuildAnim/BuildNest")
local TaskModel = import("Model/TaskModel")
local JumpMap = import("Model/JumpMap")
local JumpMapModel = import("Model/JumpMapModel")
local NoviceModel = import("Model/NoviceModel")
local PlayerDetailModel = import("Model/PlayerDetailModel")
local MissionEventModel = import("Model/MissionEventModel")
local GlobalVars = GlobalVars
import("UI/MainCity/BuildRelated/BuildNode/ItemBuildCD")
import("UI/MainCity/BuildRelated/BuildNode/ItemBuildLevel")
import("UI/MainCity/BuildRelated/BuildNode/ItemBuildName")
import("UI/City/ItemBtnComplete")
import("UI/MainCity/BuildRelated/ItemReadBar")
import("UI/City/MapRelated/ItemAreaLock")
local WelfareModel = import("Model/WelfareModel")
local lowPhoneBuildingMap = {"Building400000", "Building419000", "Building423000", "Building424000", "Building425000", "Building426000", "Building435000", "Building436000", "Building437000"}
function ItemBuild:ctor()
end

function ItemBuild:InitShowData()
    local confId = self.building.ConfId
    local conf = BuildModel.GetConf(confId)
    self.isFirstInit = true
    self.conf = conf
    self._map = CityMapModel.GetCityMap()
    self.isResBuild = conf.category == Global.BuildingTypeRes --资源建筑
    self.isTrainBuild = conf.category == Global.BuildingTypeArmy --训练工厂建筑
    self.isInnerBeast = BuildModel.IsInnerOrBeast(confId) --是否内城建筑或者巨兽建筑
    local zone = BuildModel.GetBuildPosType(confId)
    self.isInnerBeast = BuildModel.IsInnerOrBeast(confId) --是否内城建筑或者巨兽建筑
    self.isInnerBeast = BuildModel.IsInnerOrBeast(confId) --是否内城建筑或者巨兽建筑
    self.isInner = zone == Global.BuildingZoneInnter --是否内城建筑
    self.inOuter = zone == Global.BuildingZoneWild --是否外城建筑
    self._airplainOpenLevel = 0 -- 飞机开放等级
    self._airplainIndex = 0 -- 飞机的索引值
    if confId == Global.BuildingCenter then
        self.isBuildCenter = true --指挥中心
    elseif confId == Global.BuildingWall then
        self.isBuildWall = true --城墙
    elseif confId == Global.BuildingSpecialMall then
        self.isBuildSpecialShop = true --特价商城
    elseif confId == Global.BuildingTankFactory then
        self.isBuildTankFactory = true --坦克工厂
    elseif confId == Global.BuildingHelicopterFactory then
        self.isBuildHelicopterFactory = true --直升机工厂
    elseif confId == Global.BuildingWarFactory then
        self.isBuildWarFactory = true --战车工程
    elseif confId == Global.BuildingVehicleFactory then
        self.isBuildVehicleFactory = true --重型载具工厂
    elseif confId == Global.BuildingBeastBase then
        self.isBuildBeastBase = true --巨兽基地
    elseif confId == Global.BuildingBeastScience then
        self.isBuildBeastScience = true --巨兽科技
    elseif confId == Global.BuildingSecurityFactory then
        self.isBuildSecurityFactory = true --安保工厂
    elseif confId == Global.BuildingHospital then
        self.isBuildHospital = true --战区医院
    elseif confId == Global.BuildingBeastHospital then
        self.isBuildBeastHospital = true --巨兽医院
    elseif confId == Global.BuildingBridge then
        self.isBuildingBridge = true --桥头建筑（在线领奖）
    elseif confId == Global.BuildingResourceHub then
        self.isBuildingResourceHub = true --资源枢纽
    elseif confId == Global.BuildingGodzilla then
        self.isBuildNest = true --巢穴建筑
        self.isGodzillaNest = true --哥斯拉巢穴
    elseif confId == Global.BuildingKingkong then
        self.isBuildNest = true --巢穴建筑
        self.isKingkongNest = true --金刚巢穴
    elseif confId == Global.BuildingCustomerService then
        self.isBuildGm = true --客服中心
    elseif confId == Global.BuildingCasino then
        self.isBuildingCasino = true --军官休息室
    elseif confId == Global.BuildingMilitarySupply then
        self.isBuildingMilitarySupply = true --军需站
    elseif confId == Global.BuildingJointCommand then
        self.isBuildingJointCommand = true --集结指挥部
    elseif confId == Global.BuildingActivityCenter then
        self.isBuildingActivityCenter = true --活动中心
    elseif confId == Global.BuildingTower then
        self.visible = false --喷泉
    elseif confId == Global.BuildingShip then
        self.isBuildingShip = true --轮船
    elseif confId == Global.BuildingRank then
        self.isBuildRank = true --排行榜（战争雕像）
    elseif confId == Global.BuildingEquipMaterialFactory then
        self.isBuildingEquipMaterialFactory = true --装备材料生产
    elseif confId == Global.BuildingScience then
        self.isBuildingScience = true
    elseif confId == Global.BuildingDiamond then
        self.isBuildDiamond = true --钻石基金
    elseif confId == Global.BuildingAirPlane3 then
        self._airplainOpenLevel = Global.FalconQueueUnlock[1]
        self._airplainIndex = 1
    elseif confId == Global.BuildingAirPlane2 then
        self._airplainOpenLevel = Global.FalconQueueUnlock[2]
        self._airplainIndex = 2
    elseif confId == Global.BuildingAirPlane1 then
        self._airplainOpenLevel = Global.FalconQueueUnlock[3]
        self._airplainIndex = 3
    end

    self.isShowLevel = 1 == conf.showlevel --是否显示等级
    self.isShowName = 1 == conf.showname --是否显示名称

    --显示建筑Icon
    local cmpt = BuildModel.GetIconCmptName(confId)
    if (GlobalVars.IsShowEffect()) then
        self._btnIcon = UIMgr:CreateObject(cmpt[1], cmpt[2])
    else
        if lowPhoneBuildingMap[cmpt[2]] then
            cmpt[2] = cmpt[2] .. "L"
            self._btnIcon = UIMgr:CreateObject(cmpt[1], cmpt[2])
        else
            self._btnIcon = UIMgr:CreateObject(cmpt[1], cmpt[2])
        end
    end

    self._btnIcon.sortingOrder = BuildType.SORTINGORDER.BuildIcon
    self._btnIcon.name = "itemBuild" .. self.building.Id
    self:AddChild(self._btnIcon)
    if self.isBuildingResourceHub then
        self._btnIcon.xy = Vector2(160, 0)
    end
    if self.isBuildingShip then
        self._btnIcon.y = self._btnIcon.y - 100
    end

    --点击建筑
    self:AddListener(
        self._btnIcon.onClick,
        function()
            self:BuildClick()
        end
    )
    if self.isBuildDiamond then
        self._btnIconGraph = self._btnIcon:GetChild("_graph")
        self._btnIconTouch = self._btnIcon:GetChild("_touch")
    end

    if self.isBuildHospital or self.isBuildBeastHospital then
        --战区医院和巨兽医院
        self._btnIcon:Init(self.building)
    end
    --训练工厂 训练状态动画
    if self.isTrainBuild then
        self._animTrainStart = self._btnIcon:GetTransition("_animStart")
        self._animTrainEnd = self._btnIcon:GetTransition("_animEnd")
        self._animTrainLoop = self._btnIcon:GetTransition("_animLoop")
        self._animTrainCancel = self._btnIcon:GetTransition("_animCancel")
    end

    --显示等级
    if self.isShowLevel then
        local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildLevel.name]
        self._levelCmpt = UIMgr:CreateObject("Build", "itemBuildLevel")
        parentNode:AddChild(self._levelCmpt)
        self._levelCmpt:Init(self.building)
        self._levelCmpt.visible = self.building.Level > 0
    end
    --显示名称
    if self.isShowName then
        local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildName.name]
        self._nameCmpt = UIMgr:CreateObject("Build", "itemBuildName")
        parentNode:AddChild(self._nameCmpt)
        self._nameCmpt:Init(self.building)
    end

    --初始化点击音效
    if conf.building_click_sound then
        AudioModel.SetSoundName(self._btnIcon, conf.building_click_sound)
    end

    --检查是否解锁
    if self.isGodzillaNest then
        --哥斯拉 AB解锁巢穴
        local ab = ABTest.Kingkong_ABLogic() and 1 or 2
        if Model.Player.Level < Global.Kingkongnestlevel[ab] then
            self:GetLockCmpt()
        end
    elseif self.isKingkongNest then
        --金刚 获得金刚解锁巢穴
        if not Model.Player.isUnlockKingkong then
            self:GetLockCmpt()
            self._levelCmpt.visible = false
        end
    else
        if ABTest.Task_ABLogic() == 2002 and ABTest.GodzilaGuideAB_Logic() == 6002 and confId == Global.BuildingBeastBase then
            if not Model.Player.isUnlockKingkong and Model.Player.Level < 8 then
                self:GetLockCmpt()
            else
                if self._itemLock then
                    self._itemLock:RemoveFromParent()
                    self._itemLock = nil
                end
            end
        else
            if Model.Player.Level < conf.unlock_level then
                self:GetLockCmpt()
            end
        end
    end

    --巢穴是否解锁
    if self.isBuildNest then
        BuildNest.CheckNestUnlock(confId)
    end

    --设置金刚倒计时显示
    if self.isKingkongNest then
        local text1 = self._btnIcon:GetChild("text1")
        local text2 = self._btnIcon:GetChild("text2")
        local box = self._btnIcon:GetChild("box")
        local function king_kong_cd_show(flag)
            text1.visible = flag
            text2.visible = flag
            box.visible = flag
        end
        king_kong_cd_show(false)
        Event.AddListener(
            EventDefines.KingKongBackCD,
            function(data)
                king_kong_cd_show(true)
                self._itemLock.alpha = 0
                text1.text = StringUtil.GetI18n(I18nType.Commmon, "UI_KINGKONG_Coming_Text")
                --data.FinishAt = Tool.Time() + 30 --快速解锁金刚
                self.KingKongComeCb = function()
                    if data.FinishAt < Tool.Time() then
                        king_kong_cd_show(false)
                        self:UnSchedule(self.KingKongComeCb)
                        return
                    end
                    text2.text = Tool.FormatTime(data.FinishAt - Tool.Time())
                end
                self:Schedule(self.KingKongComeCb, 1)
            end
        )
    end

    --是否需要显示zzz
    if _G.Tool.Equal(confId, _G.Global.BuildingScience, _G.Global.BuildingBeastScience) then
        self.isShowZZZ = true
    else
        self.isShowZZZ = false
    end

    --巨兽基地建筑检测
    self:CheckBeastBase(true)

    --是否有点击效果
    self.touchable = conf.click

    self.displayObject.cachedTransform.name = "Build" .. confId

    --初始猎鹰行动
    if self._airplainOpenLevel > 0 then
        -- 飞机飞走后的特殊处理
        self:AddListener(
            self.onClick,
            function()
                if self.triggerCallBack then
                    self.triggerCallBack()
                end
                self:wholeAirClick()
            end
        )
        self:initFalcon()
    end

    self.clickCollectRes = false
end

--初始猎鹰行动
function ItemBuild:wholeAirClick()
    if (self._btnIcon:GetController("Show").selectedIndex == 1) then
        if (Model.isFalconOpen) then
            if (Model.Player.Level >= self._airplainOpenLevel) then
                UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
            else
                TipUtil.TipById(50354, {num = Global.FalconQueueUnlock[1]})
            end
        else
            TipUtil.TipByContentWithWaring(StringUtil.GetI18n(I18nType.Commmon, "UI_Activity_FALCONType"))
        end
    end
end

--初始猎鹰行动
function ItemBuild:initFalcon()
    self:AddEvent(
        EventDefines.MissionEventRefresh,
        function()
            --print("EventDefines.UIOnMissionInfoEventDefines.UIOnMissionInfo")
            self:FalconAirRefresh()
        end
    )
    -- 猎鹰初始
    self:FalconCD()
    if (self._airplainIndex == 1) then
        self:FalconFuelCD()
        self:AddEvent(
            EventDefines.FalconOpen,
            function()
                self._AirplainFuelCD.visible = Model.isFalconOpen
                if (Model.isFalconOpen == false) then
                    self:AirplainAnim(false)
                end
            end
        )
    end
    self:refreshAirLock()
end

function ItemBuild:refreshAirLock()
    -- 墨轩资源异常检查代码
    if (not self._btnIcon or not self._btnIcon:GetController("Lock")) then
        Log.Error("ItemBuild:refreshAirLock  self.building.ConfId == {0}", self.building.ConfId)
        return
    end

    if (Model.Player.Level >= self._airplainOpenLevel) then
        self._btnIcon:GetController("Lock").selectedIndex = 1
    else
        self._btnIcon:GetController("Lock").selectedIndex = 0
    end
end

--初始猎鹰行动飞机CD
function ItemBuild:FalconCD()
    local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildCD.name]
    local node = UIMgr:CreateObject("Build", "ItemAirplaneCD")
    parentNode:AddChild(node)
    self._airplainCD = node
    self._airplainCD:setIndex(self.building.ConfId)
    self._airplainCD:SetScale(1.5, 1.5)
    self._airplainCD:SetXY(self.x - 155, self.y - 95)
    self._airplainCD.visible = false
    self:FalconAirRefresh()
end

--初始猎鹰行动飞机燃料CD
function ItemBuild:FalconFuelCD()
    local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildCD.name]
    local node1 = UIMgr:CreateObject("Build", "AirplainFuelCD")
    parentNode:AddChild(node1)
    self._AirplainFuelCD = node1
    self._AirplainFuelCD:SetScale(2.0, 2.0)
    self._AirplainFuelCD:SetXY(self.x + 37, self.y + 41)
    self._AirplainFuelCD.visible = Model.isFalconOpen
    self._AirplainFuelCD:setParent(self)
end

--猎鹰行动飞机回飞
function ItemBuild:playAirBackAnm()
    self._btnIcon:GetController("Show").selectedIndex = 0
    self._btnIcon:GetTransition("One"):Play()
    --if (GlobalVars.IsShowEffect()) then
    --    self._btnIcon:GetChild("S_K"):GetTransition("Loop"):Play()
    --    self._btnIcon:GetChild("S_K1"):GetTransition("Loop"):Play()
    --    self._btnIcon:GetChild("Z_K"):GetTransition("Loop"):Play()
    --    self._btnIcon:GetChild("Z_K1"):GetTransition("Loop"):Play()
    --end
end

--初始猎鹰行动飞机刷新
function ItemBuild:FalconAirRefresh()
    local troopList = MissionEventModel.GetFalconMissions()
    --print("FalconAirRefresh troopList " .. table.inspect(troopList))
    --print("FalconAirRefresh HuntHelicopters " .. table.inspect(Model.HuntHelicopters))
    for i, v in pairs(Model.HuntHelicopters) do
        if (v.Id == self._airplainIndex) then
            if (troopList[v.EventId]) then
                --self._btnIcon.visible = false
                self._btnIcon:GetController("Show").selectedIndex = 1
                self._airplainCD.visible = true
                self._airplainCD:RefreshCD(troopList[v.EventId])
            else
                if (self._btnIcon:GetController("Show").selectedIndex == 1) then
                    --self._btnIcon:GetController("Show").selectedIndex = 0
                    --self._btnIcon:GetTransition("One"):Play()
                    self:playAirBackAnm()
                end
                self._airplainCD.visible = false
            end
            break
        end
    end
end

--检查是否解锁
function ItemBuild:CheckUnlock()
    --指挥中心
    for _, v in pairs(Model.Buildings) do
        local conf = BuildModel.GetConf(v.ConfId)
        local buildObj = BuildModel.GetObject(v.Id)
        if ABTest.Task_ABLogic() == 2002 and ABTest.GodzilaGuideAB_Logic() == 6002 and v.ConfId == Global.BuildingBeastBase then
            buildObj._btnIcon:ChangeLockStatus()
        else
            if Model.Player.Level >= conf.unlock_level then
                if buildObj._itemLock then
                    if CommonModel.IsNest(v.ConfId) then
                        --巢穴 无关
                    else
                        buildObj._itemLock:RemoveFromParent()
                        buildObj._itemLock = nil
                    end
                end
            end
        end
    end
end

--巨兽基地建筑检测
function ItemBuild:CheckBeastBase(isInit)
    if self.isBuildBeastBase then
        --巨兽基地
        BuildNest.CheckNestUnlock(Global.BuildingGodzilla)
        BuildNest.CheckNestUnlock(Global.BuildingKingkong)
    elseif self.isBuildNest then
        --巢穴
        if not isInit then
            BuildNest.ShowBeast(self.building.ConfId)
        end
    elseif self.isBuildCenter then
        BuildNest.CheckNestUnlock(Global.BuildingGodzilla)
        BuildNest.CheckNestUnlock(Global.BuildingKingkong)
    end
end

-- 建筑是否显示升级提示
function ItemBuild:ShowUpgradePrompt(flag)
    if not self.isShowLevel then
        return
    end
    self._levelCmpt:SetUpgrade(flag)
end
--是否显示可升级提示
function ItemBuild:CheckShowUpgredeArrow()
    if self._levelCmpt then
        return self._levelCmpt:GetUpgrade()
    else
        return false
    end
end

function ItemBuild:InitBuild(building)
    self.building = building
    self:InitShowData()

    --特价商城
    if self.isBuildSpecialShop then
        self:ResetTrade()
    end

    if self.isBuildGm then
        self:ResetGm()
    end
    if self.isBuildingCasino then
        self:RestCasino()
    end

    if self.isBuildingMilitarySupply then
        self:RestMilitarySupply()
    end

    if self.isBuildingJointCommand then
        if UnionModel:GetNotReadAttackAmount() > 0 then
            self:RestBuildingJointCommand()
        end
    end

    if self.isBuildingActivityCenter then
        self:RestActivityCenter()
    end

    self:IdleAnim(false)
    self:ResetCD(true)
    self:ResetHarest()
    self:AddEvent(
        EventDefines.UIRangeTurntableData,
        function(casinoData)
            if self.isBuildingCasino then
                self:RestCasino()
            end
        end
    )
    self:AddEvent(
        EventDefines.BeautyDateFinish,
        function(casinoData)
            if self.isBuildingCasino then
                self:RestCasino()
            end
        end
    )
    self:AddEvent(
        EventDefines.UIReqMSInfo,
        function()
            if self.isBuildingMilitarySupply then
                self:RestMilitarySupply()
            end
        end
    )
    self:AddEvent(
        TIME_REFRESH_EVENT.Refresh,
        function()
            if not self.isBuildingMilitarySupply then
                return
            end
            
            Net.MilitarySupplies.Info(
                function(msg)
                    Model.InitOtherInfo(ModelType.MSInfos, msg)
                    self:RestMilitarySupply()
                end
            )
        end
    )

    self:AddEvent(
        EventDefines.UICityBuildCenterUpgrade,
        function()
            if self.isBuildingCasino then
                self:RestCasino()
            elseif self.isBuildingActivityCenter then
                self:RestActivityCenter()
            end
            if (self._airplainIndex > 0) then
                self:refreshAirLock()
            end
        end
    )

    self:AddEvent(
        EventDefines.CloseIsNewTag,
        function()
            if self.isBuildingActivityCenter then
                self:RestActivityCenter()
            end
        end
    )

    self:AddEvent(
        EventDefines.HideBuidingCompleteBtn,
        function(isHide)
            -- local node = self:GetBtnComplete()
            if self._btnComplete then
                self._btnComplete:SetVisibleLock(isHide)
            end
        end
    )

    self.isFirstInit = false
end

function ItemBuild:OnClose()
    if self.harest_func then
        self:UnSchedule(self.harest_func)
    end
    if self.harvest_bar_func then
        self:UnSchedule(self.harvest_bar_func)
    end
    if self._levelCmpt then
        self._levelCmpt.visible = false
    end
    if self._btnCmptCD then
        self._btnCmptCD:SetCDActive(false)
    end
    if self._btnComplete then
        self._btnComplete:PlayAnim(nil, false)
    end
end

function ItemBuild:GetItemBtn()
    if self._btnIcon == nil then
        return nil
    end
    return self._btnIcon
end

-- 获取建筑倒计时是否显示
function ItemBuild:GetCmptCDActive()
    if not self._btnCmptCD then
        return false
    else
        return self._btnCmptCD:GetCDActive()
    end
end

-- 获取建筑倒计时组件
function ItemBuild:GetCmptCD()
    if not self._btnCmptCD then
        local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildCD.name]
        local node = UIMgr:CreateObject("Build", "itemBuildCD")
        if not self.isInnerBeast then
            node:SetScale(0.8, 0.8)
        end
        parentNode:AddChild(node)
        self._btnCmptCD = node
    end
    if self.isBuildCenter then
        --指挥中心
        self._btnCmptCD:SetXY(self.x + 170, self.y - 340)
    elseif self.isBuildWall then
        --城墙
        self._btnCmptCD:SetXY(self.x - 50, self.y - 170)
    elseif self.isGodzillaNest then
        --哥斯拉
        self._btnCmptCD:SetXY(BuildType.OFFSET_BUILD_GODZILLA.x, BuildType.OFFSET_BUILD_GODZILLA.y - 130)
    elseif self.isKingkongNest then
        --金刚
        self._btnCmptCD:SetXY(BuildType.OFFSET_BUILD_KINGKONG.x, BuildType.OFFSET_BUILD_KINGKONG.y - 130)
    elseif self.isInnerBeast then
        --城内建筑或巨兽建筑
        self._btnCmptCD:SetXY(self.x, self.y - 60)
    else
        --城外
        self._btnCmptCD:SetXY(self.x, self.y - 60)
    end
    self._btnCmptCD.y = self._btnCmptCD.y + BuildType.OFFSET_BUILD_CD_Y
    return self._btnCmptCD
end
-- 获取建筑收集组件
function ItemBuild:GetBtnComplete()
    if not self._btnComplete then
        local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildBtnComplete.name]
        local node = UIMgr:CreateObject("Build", "btnComplete")
        parentNode:AddChild(node)
        node:SetContext(self)
        self._btnComplete = node
    end

    if self.building.ConfId == Global.BuildingAirPlane3 then
        --第三个飞机
        self._btnComplete:SetXY(self.x, self.y - 100)
    elseif self.isBuildCenter then
        --指挥中心
        self._btnComplete:SetXY(self.x + 170, self.y - 380)
    elseif self.isBuildWall then
        --城墙
        self._btnComplete:SetXY(self.x - 50, self.y - 280)
    elseif self.isGodzillaNest then
        --哥斯拉
        self._btnComplete:SetXY(BuildType.OFFSET_BUILD_GODZILLA.x, BuildType.OFFSET_BUILD_GODZILLA.y - 400)
    elseif self.isKingkongNest then
        --金刚
        self._btnComplete:SetXY(BuildType.OFFSET_BUILD_KINGKONG.x, BuildType.OFFSET_BUILD_KINGKONG.y - 400)
    elseif self.isBuildingBridge then
        --桥头建筑
        self._btnComplete:SetXY(self.x, self.y - 350)
    elseif self.isBuildingShip then
        --轮船
        self._btnComplete:SetXY(self.x, self.y - 380)
    elseif self.isInnerBeast then
        --城内建筑或巨兽建筑
        self._btnComplete:SetXY(self.x, self.y - 240)
    else
        --城外
        self._btnComplete:SetXY(self.x, self.y - self._btnIcon.height * 0.8)
    end
    return self._btnComplete
end
-- 获取空闲组件
function ItemBuild:GetCmptIdle()
    if not self._btnCmptIdle then
        local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildIdle.name]
        local node = UIMgr:CreateObject("Common", "itemFree")
        parentNode:AddChild(node)
        self._btnCmptIdle = node
    end
    self._btnCmptIdle:SetXY(self.x, self.y - self._btnIcon.height / 2)
    return self._btnCmptIdle
end

-- 获取礼物倒计时组件
function ItemBuild:GetReadBarCD()
    if not self._itemRedadBar then
        local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildCD.name]
        local node = UIMgr:CreateObject("Build", "itemReadBar")
        parentNode:AddChild(node)
        self._itemRedadBar = node
    end
    self._itemRedadBar:SetXY(self.x - 110, self.y - self._btnIcon.height * 0.8 - 50)
    return self._itemRedadBar
end

--获取锁组件
function ItemBuild:GetLockCmpt()
    if not self._itemLock then
        local node = UIMgr:CreateObject("City", "btnMapAreaLock")
        node.touchable = false
        self.parent:AddChild(node)
        self._itemLock = node
    end
    if self.isGodzillaNest then
        self._itemLock:SetXY(BuildType.OFFSET_BUILD_GODZILLA.x - self._itemLock.width / 2, BuildType.OFFSET_BUILD_GODZILLA.y - 240)
    elseif self.isKingkongNest then
        self._itemLock:SetXY(BuildType.OFFSET_BUILD_KINGKONG.x - self._itemLock.width / 2, BuildType.OFFSET_BUILD_KINGKONG.y - 200)
    elseif self.building.ConfId == Global.BuildingBeastBase then
        self._itemLock:SetXY(self.x - self._itemLock.width / 2, self.y - self._btnIcon.height / 2 - self._itemLock.height / 2 + 60)
    else
        self._itemLock:SetXY(self.x - self._itemLock.width / 2, self.y - self._btnIcon.height / 2 - self._itemLock.height / 2)
    end
    return self._itemLock
end

--移动建筑重置节点位置
function ItemBuild:ResetPos()
    if self._btnCmptCD then
        self._btnCmptCD:SetXY(self.x, self.y - 40)
        self._btnCmptCD:ResetPos()
    end
    if self._btnComplete then
        if self.isBuildCenter then
            self._btnComplete:SetXY(self.x, self.y - self._btnIcon.height * 0.2)
        else
            self._btnComplete:SetXY(self.x, self.y - self._btnIcon.height * 0.8)
        end
    end
    if self._btnCmptIdle then
        self._btnCmptIdle:SetXY(self.x, self.y - self._btnIcon.height / 2)
    end
    if self._nameCmpt then
        self._nameCmpt:SetBuildPos()
    end
    if self._levelCmpt then
        self._levelCmpt:SetBuildPos()
    end
end

-- 重置倒计时刷新
function ItemBuild:ResetCD(isInit)
    local event = EventModel.GetEvent(self.building)
    if self.building and self.building.ConfId == Global.BuildingEquipMaterialFactory then
        -- 装备材料生产工厂单独控制气泡
        local info = EquipModel.GetMaterialMakeInfo()
        if #info.OverList > 0 then
            local typeConfig = EquipModel.GetMaterialByQualityId(info.OverList[1])
            self:EquipMaterialMakeAnim(true, typeConfig.icon)
        else
            self:EquipMaterialMakeAnim(false)
        end
        -- 删除正在生产材料icon
        if not event or not event.FinishAt or event.JewelId == 0 then
            if self._middleIcon then
                self._middleIcon.visible = false
            end

            self._btnIcon:GetController("workController").selectedIndex = 0

            if self.materialMakeEffect then
                self.materialMakeEffect:StopEffect()
                NodePool.Set(NodePool.KeyType.EquipMaterialMake, self.materialMakeEffect)
                self.materialMakeEffect = nil
            end
        end
    end

    if not event or not event.FinishAt then
        self:SetNormal()
        self:RefreshBuilder(isInit)
        return
    end
    self:ShowStatus(event, true, isInit)
    self:GetCmptCD():ResetBuild(self, event, isInit)
    self:RefreshBuilder(isInit)
end

--刷新建筑队列
function ItemBuild:RefreshBuilder(isInit)
    if not isInit then
        Event.Broadcast(EventDefines.UIResetBuilder)
    end
end

--重置礼物倒计时刷新
function ItemBuild:ResetGiftCD(t)
    self:GiftAnim()
    self:GetReadBarCD():SetTimerValue(t)
end

-- 资源收集
function ItemBuild:ResetHarest()
    if not self.isResBuild then
        return
    end
    local resBuild = Model.Find(ModelType.ResBuilds, self.building.Id)
    if not resBuild then
        return
    end
    if self.harest_func then
        self:UnSchedule(self.harest_func)
    end
    self:SetResSpeedEffect()
    if self.building.Level == 0 then
        return
    end
    local amount, storage = CommonModel.GetResBuildAmountAndStorage(resBuild)

    local showTime = Global.ResCollectShow
    local waitTime = Global.ResCollectShow
    local stime = 0
    if self.clickCollectRes then
        self.clickCollectRes = false
    else
        stime = Tool.Time() - resBuild.UpdatedAt
        waitTime = showTime - stime
    end
    if (stime >= showTime and amount >= 1) or (self.isFirstInit and (amount / storage) > 0.05) then
        self:HarestAnim(true, resBuild, storage)
    else
        self:HarestAnim(false)
        self.harest_func = function()
            self:HarestAnim(true, resBuild, storage)
        end
        local scheTime = BuildModel.GetResTime(resBuild)
        self:ScheduleOnce(self.harest_func, math.max(waitTime, scheTime))
    end
end

--60秒检测一次
local dt = 2
--特价商城
function ItemBuild:ResetTrade()
    if BuildModel.GetCenterLevel() < ConfigMgr.GetVar("SpecialShopUnlock") then
        return
    end
    local showTime = PlayerDataModel:GetData(PlayerDataEnum.SpecialShowTime)
    if not self.updateSpecialShow then
        self.updateSpecialShow = function()
            local showTime = PlayerDataModel:GetData(PlayerDataEnum.SpecialShowTime)
            if Model.SpecialShopRefreshFreeTimes > 0 then
                if tonumber(showTime) <= Tool.Time() then
                    self:UnSchedule(self.updateSpecialShow)
                    self:TradeAnim(true)
                end
            else
                self:UnSchedule(self.updateSpecialShow)
            end
        end
    end

    if showTime and tonumber(showTime) > Tool.Time() then
        self:TradeAnim(false)
        self:Schedule(self.updateSpecialShow, dt)
    else
        if Model.SpecialShopRefreshFreeTimes > 0 then
            self:TradeAnim(true)
        else
            self:TradeAnim(false)
        end
    end
end

function ItemBuild:RestCasino()
    if BuildModel.GetCenterLevel() < BuildModel.GetConf(self.building.ConfId).unlock_level then
        return
    end
    Net.Beauties.GetBeautiesInfo(
        function(msg)
            local CanDate = false
            for _, v in ipairs(msg.Infos) do
                if v.CanDate then
                    CanDate = true
                    break
                end
            end

            if CanDate then
                self:BeautyAnim(true)
            else
                self:BeautyAnim(false)
                Net.Casino.GetCasinoInfo(
                    function(rsp)
                        if rsp.Free then
                            self:RangeAnim(true)
                        else
                            self:RangeAnim(false)
                        end
                    end
                )
            end
        end
    )
end

function ItemBuild:RestMilitarySupply()
    self:MilitarySupplyAnim(Model.GetMap(ModelType.MSInfos).FreeTimes > 0)
end

function ItemBuild:RestBuildingJointCommand()
    self:UnionWarfareAnim(true)
end

function ItemBuild:ResetGm()
    if self.initGm then
        return
    end
    self:AddEvent(
        GM_MSG_EVENT.NewMsgNotRead,
        function(num)
            self:PlayGmMsg(true)
        end
    )

    self:AddEvent(
        GM_MSG_EVENT.MsgIsRead,
        function(num)
            self:PlayGmMsg(false)
        end
    )
end

function ItemBuild:RestActivityCenter()
    if Model.Player.Level >= self.conf.unlock_level then
        ActivityModel.GetNetActivityData(
            function(msg)
                local info = ActivityModel.GetActivityCenterBubble()
                if info then
                    self:ActivityCenterAnim(true, info.Config.circleicon)
                else
                    self:ActivityCenterAnim(false)
                end
            end
        )
    end
end

------------------------------------------------------- 建筑显示状态
-- 检查是否寻求帮助
function ItemBuild:CheckAskHelp(event, isResetCD)
    if not isResetCD then
        return
    end
    if not UnionModel.CheckJoinUnion() then
        return
    end
    if event.AskedHelp then
        return
    end
    self:HelpAnim(true)
end

-- 设置建筑显示状态
function ItemBuild:ShowStatus(event, isResetCD, isInit)
    local ltime = event.FinishAt - Tool.Time()
    local ftime = CommonModel.FreeTime()
    local help_func = function()
        if BuildModel.UnionHelpState(event.Category) then
            self:CheckAskHelp(event, isResetCD)
        end
    end
    local defultHelp_func = function()
        if BuildModel.UnionHelpState(event.Category) then
            self:DefultUnionHelp(event, isResetCD)
        end
    end
    --升级/建造
    if event.Category == EventType.B_BUILD then
        if ltime <= 0 then
            self:SetNormal()
        else
            if ftime >= ltime then
                self:FreeAnim(true)
            else
                defultHelp_func()
            end
        end
        return
    end
    --拆除
    if event.Category == EventType.B_DESTROY then
        if ftime >= ltime then
            self:FreeAnim(true)
        else
            help_func()
        end
        return
    end
    --训练
    if event.Category == EventType.B_TRAIN then
        if ltime <= 0 then
            self:TrainAnim(true)
        else
            help_func()
            self:TrainArmyStartAnim(isInit)
        end
        return
    end
    --科技研究/巨兽科技研究
    if event.Category == EventType.B_TECH or event.Category == EventType.B_BEASTTECH then
        if ltime <= 0 then
            self:TechResearchAnim(true)
        else
            defultHelp_func()
        end
        return
    end
    --治疗/巨兽治疗
    if event.Category == EventType.B_CURE or event.Category == EventType.B_BEASTCURE then
        if ltime > 0 then
            defultHelp_func()
        end
        return
    end
    --装备制造
    if event.Category == EventType.B_EQUIPTRAN then
        if ltime <= 0 then
            local typeConfig = EquipModel.GetEquipTypeByEquipQualityID(event.EquipId)
            if not typeConfig then
                return
            end
            self:EquipMakeAnim(true, typeConfig.icon)
            return
        end
    end
    --装备材料制造
    if event.Category == EventType.B_EQUIPMATERIALMAKE then
        if event.Uuid == "" then
            return
        end
        if not self._middleIcon then
            local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildCD.name]
            local node = UIMgr:CreateObject("Build", "itemMiddleIcon")
            parentNode:AddChild(node)
            node:SetXY(self.x + 10, self.y - 100)
            node:SetScale(0.8, 0.8)
            self._middleIcon = node:GetChild("_icon")
            self._middle = node
        end
        local typeConfig = EquipModel.GetMaterialByQualityId(event.JewelId)
        self._middleIcon.visible = true
        self._middleIcon.url = UITool.GetIcon(typeConfig.icon, self._middleIcon)
        -- local t = self:GetController("workController")
        self._btnIcon:GetController("workController").selectedIndex = 1

        if not self.materialMakeEffect then
            NodePool.Init(NodePool.KeyType.EquipMaterialMake, "Effect", "EffectNode")
            self.materialMakeEffect = NodePool.Get(NodePool.KeyType.EquipMaterialMake)
            self._middle:AddChildAt(self.materialMakeEffect, 0)
            self.materialMakeEffect:SetXY(self._middle.width / 2, self._middle.height / 2)
            self.materialMakeEffect:InitNormal()
            self.materialMakeEffect:PlayDynamicEffectLoop("effect_collect", "Effect_equipment_light_b", Vector3(300, 300, 300),1)
        end
    end
end
-- 设置建筑正常状态
function ItemBuild:SetNormal()
    local guideStage = JumpMapModel:GuideStage()
    if guideStage and JumpMapModel:GetJumpId() == 813300 and JumpMapModel:GetBuildId() == self.building.ConfId then
        Event.Broadcast(EventDefines.CloseGuide)
    end

    if self._btnCmptCD then
        self._btnCmptCD:SetCDActive(false)
    end
    self:IdleAnim(true)
    self:FreeAnim(false)
    self:HelpAnim(false)
end
-- 建筑升级完成
function ItemBuild:UpgradeEnd(level)
    if self._btnCmptCD then
        self._btnCmptCD:ClearEvent()
    end
    self:SetNormal()
    if not level or level <= self.building.Level then
        return
    end

    Event.Broadcast(EventDefines.UIResetBuilder)
    self.building.Level = level or (Model.Player.Level + 1)
    if self.isBuildCenter then
        --指挥中心升级
        Model.Player.Level = self.building.Level
        Event.Broadcast(EventDefines.UICityBuildCenterUpgrade)
        PlayerDetailModel.SetAchievementAward()
        self:CheckUnlock()
        if (GlobalVars.IsShowEffect()) then
            self._btnIcon:Upgrade()
        end
    elseif self.isBuildWall then
        --城墙 是否打开侧边栏
        UnlockModel:UnlockWall(UnlockModel.Wall.Sidebar)
        Event.Broadcast(EventDefines.UICityBuildWallUpgrade)
    elseif self.isResBuild then
        self:ResetHarest()
    end
    self._levelCmpt.visible = self.building.Level > 0
    self._levelCmpt:SetBuildLevel(self.building.Level)
    Model.Create(ModelType.Buildings, self.building.Id, self.building)
    local values = {
        build_name = BuildModel.GetName(self.building.ConfId),
        build_level = self.building.Level
    }
    TipUtil.TipById(50102, values)

    --播放特效
    if self.isBuildCenter then
        self:PlayCityEffect()
    elseif not self.isBuildWall and not self.isBuildNest then
        self:PlayEffect()
    end
    BuildModel.UpgradePrompt()

    --加入帮会提示
    UnionModel.CheckJoinPush(self.building.ConfId, self.building.Level)
    --巨兽基地建筑检测
    self:CheckBeastBase(false)
    --设置本地巨兽巢穴梯级提升弹窗标识
    if self.building.ConfId == Global.BuildingGodzilla then
        BuildModel.CheckGodzillaUpgradingPopup_Now(self.building.Level)
    elseif self.building.ConfId == Global.BuildingKingkong then
        BuildModel.CheckKingkongUpgradingPopup_Now(self.building.Level)
    end
    --战区医院检测
    if self.isBuildHospital then
        self:ResetCD()
    end
    Event.Broadcast(EventDefines.NoviceGuideBuildUpgrade, self.building.ConfId)
end
-- 科技升级完成
function ItemBuild:TechEnd(confId)
    self:SetNormal()
end

function ItemBuild:PlayEffect()
    NodePool.Init(NodePool.KeyType.BuildUpgradeNormalEffect, "Effect", "EffectNode")
    local buildEffect = NodePool.Get(NodePool.KeyType.BuildUpgradeNormalEffect)
    local scale = Vector3(1, 1, 1)
    if self.isInnerBeast then
        buildEffect.xy = Vector2(self.x -229, self.y - 299)
    else
        buildEffect.xy = Vector2(self.x - 220, self.y - 235)
        scale = Vector3(0.5, 0.5, 0.5)
    end
    self.parent:AddChild(buildEffect)
    buildEffect:InitNormal()
    buildEffect:PlayEffectSingle(
        "effects/buildingupgrade/prefab/effect_building_upgrade",
        function()
            NodePool.Set(NodePool.KeyType.BuildUpgradeNormalEffect, buildEffect)
        end,
        scale
    )
end
--主基地升级
function ItemBuild:PlayCityEffect()
    NodePool.Init(NodePool.KeyType.BuldUpgradeCityEffect, "Effect", "EffectNode")
    local buildEffect = NodePool.Get(NodePool.KeyType.BuldUpgradeCityEffect)
    local scale = Vector3(1.64, 1.64, 1.64)
    buildEffect.xy = Vector2(self.x - 256, self.y - 867)
    self.parent:AddChild(buildEffect)
    buildEffect:InitNormal()buildEffect:PlayEffectSingle(
        "effects/buildingupgrade/prefab/effect_building_upgrade_city",
        function()
            NodePool.Set(NodePool.KeyType.BuldUpgradeCityEffect, buildEffect)
        end,
        scale
    )
end

-- 拆除建筑
function ItemBuild:RemoveEnd()
    Event.Broadcast(EventDefines.UIResetBuilder)
    self:FreeAnim(false)
    local piece = self._map:GetMapPiece(self.building.Pos)
    piece.visible = true
    piece:SetPieceBuild(false)
    Model.Delete(ModelType.Buildings, self.building.Id)
    BuildModel.DelObject(self.building.Id)
    if self._btnCmptCD then
        self._btnCmptCD:ClearEvent()
    end
    if self._btnComplete then
        self._btnComplete.visible = false
    end
    self:OnClose()
    self:RemoveFromParent()
    if self then
        self:Dispose()
    end
    local values = {
        building = BuildModel.GetName(self.building.ConfId),
        building_level = self.building.Level
    }
    TipUtil.TipById(30103, values)
end
-- 治疗完成
function ItemBuild:CureEnd(isBeast)
    if isBeast then
        TipUtil.TipById(30009)
    else
        TipUtil.TipById(30008)
    end

    local event = EventModel.GetEvent(self.building)
    if not event then
        self:SetNormal()
    end
end

------------------------------------------------------- 动画效果
-- 训练空闲Zz动画
function ItemBuild:IdleAnim(flag)
    if not (self.isTrainBuild or self.isShowZZZ) then
        return
    end
    local node = self:GetCmptIdle()
    node.visible = flag
    if not flag then
        if self._btnCmptCD then
            local event = EventModel.GetEvent(self.building)
            if event then
                return
            end
            self._btnCmptCD:SetCDActive(false)
        end
    end
end
-- 帮助摆动动画
function ItemBuild:HelpAnim(flag)
    if flag and not UnionModel.CheckJoinUnion() then
        return
    end
    if Tool.EqualBool(self._playHelp, flag) then
        return
    end
    --研究科技、巨兽科技、资源建筑现在也不出现联盟帮助动画，都是默认请求帮助
    if self.isBuildBeastScience or self.isResBuild or self.isBuildingScience then
        return
    end
    self._playHelp = flag
    self:IdleAnim(false)
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.Help, flag)
end
-- 免费进度摆动动画
function ItemBuild:FreeAnim(flag)
    if Tool.EqualBool(self._playFree, flag) then
        return
    end
    self._playFree = flag
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.Free, flag)
    if flag and GlobalVars.IsTriggerStatus then
        Event.Broadcast(EventDefines.BuildItemStateChange, self.building.ConfId)
    end
    if flag then
        JumpMap:JumpTo({jump = 812600, para = self.building, para1 = node})
        self:GuideFinishTo("UpgradeFreeGuide", self.building)
    end
end

-- 部队训练摆动动画
function ItemBuild:TrainAnim(flag)
    if Tool.EqualBool(self._playTrain, flag) then
        return
    end
    self._playTrain = flag
    self:IdleAnim(not flag)
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.Train, flag)
    node:SetTrainImage(self.building.ConfId)
    if flag then
        self:TrainArmyEndAnim(false)
    else
        if self._btnCmptCD then
            self._btnCmptCD:SetCDActive(false)
        end
    end
    self:PlayTrainCollectEffect(flag)
end
-- 资源收集摆动动画
function ItemBuild:HarestAnim(flag, resBuild, total)
    if Tool.EqualBool(self._playHarest, flag) then
        return
    end
    self._playHarest = flag
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.Harest, false)
    local _node = node:GetBtnNode()
    self._barHarvest = _node:GetChild("bar")
    self._ctrHarvest = _node:GetController("Ctr")

    local parameter = CommonModel.GetResParameter(self.building.ConfId)
    node:PlayAnim(BuildType.ANIMATION.Harest, flag)
    node:SetHarestImage(parameter.category)

    if self.harvest_bar_func then
        self:UnSchedule(self.harvest_bar_func)
    end
    if flag then
        self.harvest_bar_func = function()
            if not self._ctrHarvest then
                return
            end
            local amount, total = CommonModel.GetResBuildAmountAndStorage(resBuild)
            self._barHarvest.fillAmount = amount / total
            self._ctrHarvest.selectedIndex = amount < total and 0 or 1
            if amount > total then
                self:UnSchedule(self.harvest_bar_func)
                return
            end
        end
        self.harvest_bar_func()
        self:Schedule(self.harvest_bar_func, 10)
    end
end
-- 特价商场免费摆动动画
function ItemBuild:TradeAnim(flag)
    if Tool.EqualBool(self._playTrade, flag) then
        return
    end
    self._playTrade = flag
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.Special, flag)
end

-- 美女约会摆动动画
function ItemBuild:BeautyAnim(flag)
    if Tool.EqualBool(self._playBeauty, flag) then
        return
    end
    self._playBeauty = flag
    local node = self:GetBtnComplete()
    node:PlayAnim(
        BuildType.ANIMATION.Beauty,
        flag,
        function()
            UIMgr:Open("BeautySystemMain")
        end
    )
end

-- 靶场免费摆动动画
function ItemBuild:RangeAnim(flag)
    if Tool.EqualBool(self._playRange, flag) then
        return
    end
    self._playRange = flag
    local node = self:GetBtnComplete()
    node:PlayAnim(
        BuildType.ANIMATION.Range,
        flag,
        function()
            TurnModel.Casion()
        end
    )
end

--军需站免费摆动动画
function ItemBuild:MilitarySupplyAnim(flag)
    if Tool.EqualBool(self._playMilitarySupply, flag) then
        return
    end
    self._playMilitarySupply = flag
    local node = self:GetBtnComplete()
    node:PlayAnimBySetIcon(
        BuildType.ANIMATION.MilitarySupply,
        flag,
        "MilitarySupply",
        ConfigMgr.GetItem("configItems", MILITARY_SUPPLY.MSItemConfId).icon,
        function()
            UIMgr:Open("MilitarySupplies")
        end
    )
end

--联盟战争摆动动画
function ItemBuild:UnionWarfareAnim(flag)
    if Tool.EqualBool(self._playUnionWarfare, flag) then
        return
    end
    self._playUnionWarfare = flag
    local node = self:GetBtnComplete()
    node:PlayAnim(
        BuildType.ANIMATION.UnionWarfare,
        flag,
        function()
            UIMgr:Open("UnionWarfare")
        end
    )
end

--活动中心摆动动画
function ItemBuild:ActivityCenterAnim(flag, icon)
    local node = self:GetBtnComplete()
    if Tool.EqualBool(self._playActivityCenter, flag) then
        return
    end
    self._playActivityCenter = flag
    node:PlayAnimBySetIcon(
        BuildType.ANIMATION.ActivityCenter,
        flag,
        "ActivityCenter",
        icon,
        function()
            UIMgr:Open("ActivityCenter")
        end
    )
end

--福利中心摆动动画 (建筑：轮船和战争雕像)
function ItemBuild:WelfareAnim(flag, icon, cb)
    local node = self:GetBtnComplete()
    if Tool.EqualBool(self._playWelfare, flag) then
        node:SetIcon("Welfare", icon)
        node:SetCb(cb)
        return
    end
    self._playWelfare = flag
    node:PlayAnim(BuildType.ANIMATION.Welfare, flag, cb)
    node:SetIcon("Welfare", icon)
end

--装备制造完成摆动动画
function ItemBuild:EquipMakeAnim(flag, icon)
    local node = self:GetBtnComplete()
    if self._btnCmptCD then
        self._btnCmptCD:SetCDActive(false)
    end
    node:PlayAnimBySetDynamicIcon(BuildType.ANIMATION.EquipMake, flag, "EquipMake", icon)
end

function ItemBuild:EquipMaterialMakeAnim(flag, icon)
    local node = self:GetBtnComplete()
    node:PlayAnimBySetDynamicIcon(BuildType.ANIMATION.EquipMaterialMake, flag, "EquipMake", icon)
end

-- 资源收集完成动画
function ItemBuild:HarestEndAnim(amount)
    if not amount or amount <= 0 then
        return
    end
    if not self._textHarestAnim then
        local node = UIMgr:CreateObject("Build", "btnBuildText")
        MainCity.ResourceAnimTarget:AddChild(node)
        self._textHarest = node
        self._textHarestAnim = node:GetTransition("aniText")
    end
    self._textHarest.visible = true
    self._textHarest.title = "+" .. Tool.FormatNumberThousands(amount)
    local newPos = MainCity.ResourceAnimTarget:GlobalToLocal(self:LocalToGlobal({x = 0, y = 0}))

    self._textHarest:SetXY(newPos.x, newPos.y + 70)
    self._textHarestAnim:Play(
        function()
            self._textHarest.visible = false
        end
    )
end

--油料动画
function ItemBuild:AirplainAnim(flag)
    local node = self:GetBtnComplete()
    if Tool.EqualBool(self._playAirplain, flag) then
        return
    end
    self._playAirplain = flag
    node:PlayAnimBySetIcon(
        BuildType.ANIMATION.FalconActivity,
        flag,
        "",
        {"icon_activity","ChargeActivity19"},
        function()
            if self.triggerCallBack then
                self.triggerCallBack()
            end
            if Model.Player.Level >= 4 then
                UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
            else
                --TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS4"))
                TipUtil.TipById(50353)
            end
        end
    )
end

--钻石基金动画
function ItemBuild:DiamondAnim(flag)
    if not self.isBuildDiamond then
        return
    end

    self.effectDiamondFlag = flag
    if flag then
        if self.effectDiamond then
            self._btnIconGraph.visible = true
            self._btnIconTouch.visible = true
        else
            -- local prefab = ResMgr.Instance:LoadPrefabSync("effects/effect_diamonds/prefab/effect_diamonds")
            -- local object = GameObject.Instantiate(prefab)
            -- object.transform.localPosition = Vector3(0, 0, 2000)
            -- self._btnIconGraph:SetNativeObject(GoWrapper(object))
            -- self._btnIconGraph.visible = self.effectDiamondFlag
            -- self._btnIconTouch.visible = self.effectDiamondFlag
            self.effectDiamond = true
            DynamicRes.GetBundle(
                "effect_collect",
                function()
                    DynamicRes.GetPrefab(
                        "effect_collect",
                        "effect_diamonds",
                        function(prefab)
                            local object = GameObject.Instantiate(prefab)
                            object.transform.localPosition = Vector3(-1.66, -21.12, 3000)
                            self._btnIconGraph:SetNativeObject(GoWrapper(object))
                            self._btnIconGraph.visible = self.effectDiamondFlag
                            self._btnIconTouch.visible = self.effectDiamondFlag
                        end
                    )
                end
            )
        end
    else
        self._btnIconGraph.visible = false
        self._btnIconTouch.visible = false
    end
end

function ItemBuild:PlayGmMsg(flag)
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.Gm, flag)
end

-- 播放士兵训练完成动画
function ItemBuild:PlayTrainCollectEffect(flag)
    if flag then
        if not self.trainCollectBoxAnim then
            self.trainCollectBoxAnim = UIMgr:CreateObject("Effect", "EffectTrainBox")
            self.trainCollectBoxAnim.sortingOrder = BuildType.SORTINGORDER.Down
            self.trainCollectBoxAnim.y = 5
            self.trainCollectBoxAnim:GetChild("_massif").icon = UITool.GetIcon({"icon_effect","icon_lot_yellow_01"})
            self:AddChild(self.trainCollectBoxAnim)

            if not self.trainCollectLight then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainComplete, "Effect", "EffectNode")
                self.trainCollectLight = NodePool.Get(NodePool.KeyType.TrainArmyTrainComplete)
                self._btnIcon:AddChild(self.trainCollectLight)
                self.trainCollectLight.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.trainCollectLight:InitNormal()
                self.trainCollectLight:PlayEffectLoop("effects/build/training/prefab/effect_train_army", nil, 0)
            else
                self.trainCollectLight:PlayEffectLoop("effects/build/training/prefab/effect_train_army", nil, 0)
            end
        else
            self.trainCollectBoxAnim.visible = true
            if not self.trainCollectLight then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainComplete, "Effect", "EffectNode")
                self.trainCollectLight = NodePool.Get(NodePool.KeyType.TrainArmyTrainComplete)
                self._btnIcon:AddChild(self.trainCollectLight)
                self.trainCollectLight.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.trainCollectLight:InitNormal()
                self.trainCollectLight:PlayEffectLoop("effects/build/training/prefab/effect_train_army", nil, 0)
            else
                self.trainCollectLight:PlayEffectLoop("effects/build/training/prefab/effect_train_army", nil, 0)
            end
        end
    else
        if self.trainCollectBoxAnim then
            self.trainCollectBoxAnim.visible = false
            if self.trainCollectLight then
                self.trainCollectLight:StopEffect()
            end
        end
    end
    if flag then
        self:GuideFinishTo("TrainFreeGuide", self.building)
    end
end

-- 播放士兵收集完成特效(光效)
function ItemBuild:PlayTrainEndEffect()
    NodePool.Init(NodePool.KeyType.TrainArmyCollectEffect, "Effect", "EffectNode")
    local item = NodePool.Get(NodePool.KeyType.TrainArmyCollectEffect)
    local parentNode = self._map[CityType.CITY_MAP_NODE_TYPE.BuildTrainEffect.name]
    parentNode:AddChild(item)
    item.xy = self.xy
    item:InitNormal()
    item:PlayEffectSingle(
        "effects/build/training/prefab/effect_train_army_t",
        function()
            NodePool.Set(NodePool.KeyType.TrainArmyCollectEffect, item)
        end,
        nil,
        nil,
        0
    )
end
-- 停止训练相关动画
function ItemBuild:StopTrainArmyAnim()
    if not self._animTrainStart then
        return
    end
    if (GlobalVars.IsShowEffect()) then
        self._animTrainStart:Stop()
        self._animTrainLoop:Stop()
        self._animTrainEnd:Stop()
    end
end
-- 训练士兵开始动画
function ItemBuild:TrainArmyStartAnim(isInit)
    if self.isTrainning then
        return
    end
    self.isTrainning = true
    if not self._animTrainStart then
        return
    end
    self:StopTrainArmyAnim()
    if isInit then
        self._animTrainLoop:Play(-1, 0, nil)
    else
        self._animTrainStart:Play(
            function()
                self._animTrainLoop:Play(-1, 0, nil)
            end
        )
    end

    if self.isBuildWarFactory then
        if (GlobalVars.IsShowEffect()) then
            --战车工厂
            self._btnIcon:GetChild("doorL"):GetTransition("open"):Play()
            self._btnIcon:GetChild("doorR"):GetTransition("open"):Play()

            if not self.warFactoryLightEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.warFactoryLightEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChildAt(self.warFactoryLightEffect, 2)
                self.warFactoryLightEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.warFactoryLightEffect:InitNormal()
                self.warFactoryLightEffect:PlayEffectLoop("effects/factory/prefab/zhanche_guang")
            else
                self.warFactoryLightEffect:PlayEffectLoop("effects/factory/prefab/zhanche_guang")
            end

            if not self.warFactorySmokeEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.warFactorySmokeEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChild(self.warFactorySmokeEffect)
                self.warFactorySmokeEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.warFactorySmokeEffect:InitNormal()
                self.warFactorySmokeEffect:PlayEffectLoop("effects/factory/prefab/zhanche_smoke")
            else
                self.warFactorySmokeEffect:PlayEffectLoop("effects/factory/prefab/zhanche_smoke")
            end
        end
    elseif self.isBuildVehicleFactory then
        if (GlobalVars.IsShowEffect()) then
            --重型载具工厂
            self._btnIcon:GetChild("door"):GetTransition("open"):Play()

            if not self.vehicleFactoryEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.vehicleFactoryEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChild(self.vehicleFactoryEffect)
                self.vehicleFactoryEffect.xy = Vector2(self._btnIcon.width / 2 + 26, self._btnIcon.height - 11)
                self.vehicleFactoryEffect:InitNormal()
                self.vehicleFactoryEffect:PlayEffectLoop("effects/factory/prefab/zhongxingche")
            else
                self.vehicleFactoryEffect:PlayEffectLoop("effects/factory/prefab/zhongxingche")
            end
        end
    elseif self.isBuildTankFactory then
        if (GlobalVars.IsShowEffect()) then
            --坦克工厂
            if not self.tankFactoryTwoEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.tankFactoryTwoEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChildAt(self.tankFactoryTwoEffect, 7)
                self.tankFactoryTwoEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.tankFactoryTwoEffect:InitNormal()
                self.tankFactoryTwoEffect:PlayEffectLoop("effects/factory/prefab/tanke_2")
            else
                self.tankFactoryTwoEffect:PlayEffectLoop("effects/factory/prefab/tanke_2")
            end

            if not self.tankFactoryOneEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.tankFactoryOneEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChild(self.tankFactoryOneEffect)
                self.tankFactoryOneEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.tankFactoryOneEffect:InitNormal()
                self.tankFactoryOneEffect:PlayEffectLoop("effects/factory/prefab/tanke_1")
            else
                self.tankFactoryOneEffect:PlayEffectLoop("effects/factory/prefab/tanke_1")
            end
        end
    elseif self.isBuildHelicopterFactory then
        if (GlobalVars.IsShowEffect()) then
            --直升机工厂
            if not self.heliFactoryDownEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.heliFactoryDownEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChildAt(self.heliFactoryDownEffect, 5)
                self.heliFactoryDownEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.heliFactoryDownEffect:InitNormal()
                self.heliFactoryDownEffect:PlayEffectLoop("effects/factory/prefab/zhishengji_down")
            else
                self.heliFactoryDownEffect:PlayEffectLoop("effects/factory/prefab/zhishengji_down")
            end

            if not self.heliFactoryUpEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.heliFactoryUpEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChildAt(self.heliFactoryUpEffect, 8)
                self.heliFactoryUpEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.heliFactoryUpEffect:InitNormal()
                self.heliFactoryUpEffect:PlayEffectLoop("effects/factory/prefab/zhishengji_up")
            else
                self.heliFactoryUpEffect:PlayEffectLoop("effects/factory/prefab/zhishengji_up")
            end

            if not self.heliFactorySmokeEffect then
                NodePool.Init(NodePool.KeyType.TrainArmyTrainAnim, "Effect", "EffectNode")
                self.heliFactorySmokeEffect = NodePool.Get(NodePool.KeyType.TrainArmyTrainAnim)
                self._btnIcon:AddChild(self.heliFactorySmokeEffect)
                self.heliFactorySmokeEffect.xy = Vector2(self._btnIcon.width / 2 + 20, self._btnIcon.height)
                self.heliFactorySmokeEffect:InitNormal()
                self.heliFactorySmokeEffect:PlayEffectLoop("effects/factory/prefab/zhishengji_up_smoke")
            else
                self.heliFactorySmokeEffect:PlayEffectLoop("effects/factory/prefab/zhishengji_up_smoke")
            end
        end
    end
end
-- 训练士兵结束动画
function ItemBuild:TrainArmyEndAnim(isCancel)
    if isCancel then
        if not self._animTrainCancel and not self._animTrainEnd then
            return
        end
    else
        if not self._animTrainEnd then
            return
        end
    end
    self.isTrainning = false
    self:StopTrainArmyAnim()
    if isCancel and self._animTrainCancel then
        self._animTrainCancel:Play()
    else
        self._animTrainEnd:Play()
    end
    if self.isBuildWarFactory then
        if (GlobalVars.IsShowEffect()) then
            --战车工厂
            self._btnIcon:GetChild("doorL"):GetTransition("close"):Play()
            self._btnIcon:GetChild("doorR"):GetTransition("close"):Play()

            if self.warFactoryLightEffect then
                self.warFactoryLightEffect:StopEffect()
            end
            if self.warFactorySmokeEffect then
                self.warFactorySmokeEffect:StopEffect()
            end
        end
    elseif self.isBuildVehicleFactory then
        if (GlobalVars.IsShowEffect()) then
            --重型载具工厂
            self._btnIcon:GetChild("door"):GetTransition("close"):Play()

            if self.vehicleFactoryEffect then
                self.vehicleFactoryEffect:StopEffect()
            end
        end
    elseif self.isBuildTankFactory then
        if (GlobalVars.IsShowEffect()) then
            --坦克工厂
            if self.tankFactoryTwoEffect then
                self.tankFactoryTwoEffect:StopEffect()
            end
            if self.tankFactoryOneEffect then
                self.tankFactoryOneEffect:StopEffect()
            end
        end
    elseif self.isBuildHelicopterFactory then
        if (GlobalVars.IsShowEffect()) then
            --直升机工厂
            if self.heliFactoryDownEffect then
                self.heliFactoryDownEffect:StopEffect()
            end
            if self.heliFactoryUpEffect then
                self.heliFactoryUpEffect:StopEffect()
            end
            if self.heliFactorySmokeEffect then
                self.heliFactorySmokeEffect:StopEffect()
            end
        end
    end
end

-- 领取在线礼物摆动动画
function ItemBuild:GiftAnim(flag)
    if Tool.EqualBool(self._playGift, flag) then
        return
    end
    self._playGift = flag
    local node = self:GetBtnComplete()
    self:GetReadBarCD():SetShow(false)
    node:PlayAnim(BuildType.ANIMATION.Gift, flag)
    --在线礼物特效
    if flag then
        self.giftFrontEffect, self.giftBehindEffect =
            AnimationModel.GiftEffect(node:GetCutBtn(), Vector3(1, 1, 1), Vector3(0.6, 0.6, 1), "ItemBuildGiftBtn", self.giftFrontEffect, self.giftBehindEffect)
    else
        AnimationModel.DisPoseGiftEffect("ItemBuildGiftBtn", self.giftFrontEffect, self.giftBehindEffect)
    end
end

-- 科技研究动画
function ItemBuild:TechResearchAnim(flag)
end

-- 科技研究完成奖励动画
function ItemBuild:ScienceAwardAnim(flag)
    local node = self:GetBtnComplete()
    node:PlayAnim(BuildType.ANIMATION.ScienceAward, flag)
    if flag then
        self:GuideFinishTo("TechFreeGuide", self.building)
    end
end

------------------------------------------------------- 点击建筑
-- 点击建筑按钮
function ItemBuild:BuildClick()
    if self.triggerCallBack then
        self.triggerCallBack()
    end

    if CityType.BUILD_MOVE_TIP then
        if self.conf.movable == BuildType.BUILD_MOVEABLE.No then
            return
        end
        if CityType.BUILD_MOVE_TYPE == BuildType.MOVE.Item then
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Move, self.building.Pos)
        elseif CityType.BUILD_MOVE_TYPE == BuildType.MOVE.Move then
            local waitMoveType = BuildModel.GetBuildPosTypeByPos(CityType.BUILD_MOVE_POS)
            local posType = BuildModel.GetBuildPosTypeByPos(self.building.Pos)
            if waitMoveType == posType then
                self:ClickExchange()
            end
        end
        return
    end

    local node = self:GetBtnComplete()
    if node:GetBubbleVisible() then
        local event = EventModel.GetEvent(self.building)
        local animType = node:GetAnimType()
        if animType == BuildType.ANIMATION.Free then
            Log.Error("Click Free -----------------------1009")
            self:ClickFree(event)
            Event.Broadcast(EventDefines.NextNoviceStep, 1009)
            return
        elseif animType == BuildType.ANIMATION.Train then
            self:ClickTrain(event)
            return
        elseif animType == BuildType.ANIMATION.Harest then
            self:ClickHarest()
            return
        elseif animType == BuildType.ANIMATION.Help then
            self:ClickHelp(event)
            return
        elseif animType == BuildType.ANIMATION.ScienceAward then
            self:ClickScienceAward()
            return
        elseif animType == BuildType.ANIMATION.EquipMake then
            self:ClickEquipMaked()
            return
        elseif animType == BuildType.ANIMATION.EquipMaterialMake then
            self:ClickEquipMaterialMaked()
            return
        end
    end

    if self.isBuildCenter then
        --指挥中心
        ScrollModel.Move(self.x + BuildType.OFFSET_CENTER.x, self.y + BuildType.OFFSET_CENTER.y, true)
    elseif self.isBuildWall then
        --城墙
        ScrollModel.Move(self.x + BuildType.OFFSET_WALL.x, self.y + BuildType.OFFSET_WALL.y, true)
    elseif self.isBuildingBridge then
        --桥头建筑（在线领奖）
        ScrollModel.Move(self.x + BuildType.OFFSET_BRIDGE.x, self.y + BuildType.OFFSET_BRIDGE.y, true)
    elseif self.isGodzillaNest then
        --巢穴 哥斯拉
        ScrollModel.Move(self.x + BuildType.OFFSET_GODZILLA.x, self.y + BuildType.OFFSET_GODZILLA.y, true)
    elseif self.isKingkongNest then
        --巢穴 金刚
        ScrollModel.Move(self.x + BuildType.OFFSET_KINGKONG.x, self.y + BuildType.OFFSET_KINGKONG.y, true)
    elseif self.isBuildingEquipMaterialFactory then
        if BuildModel.GetUnlockByConfId(self.building.ConfId) then
            ScrollModel.Scale(self.building.Pos, true)
        end
    else
        --点击移动到屏幕正中间
        ScrollModel.Move(self.x, self.y, true)
    end

    if not self.conf.funcs then
        Event.Broadcast(EventDefines.UICitySpecialBuildTurn, self.building.ConfId)
    else
        self:ShowBuildFuncList(false)
    end

    --飞机特殊处理 前往活动中心
    if self.building.ConfId == Global.BuildingAirPlane1 or self.building.ConfId == Global.BuildingAirPlane2 or self.building.ConfId == Global.BuildingAirPlane3 then
        if (Model.isFalconOpen) then
            --if Model.Player.Level >= 4 then
            --    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
            --else
            --    --TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS4"))
            --    TipUtil.TipById(50353)
            --end
            if self.building.ConfId == Global.BuildingAirPlane3 then --  飞机特殊处理CD
                if (Model.Player.Level >= Global.FalconQueueUnlock[1]) then
                    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                else
                    TipUtil.TipById(50354, {num = Global.FalconQueueUnlock[1]})
                end
            elseif self.building.ConfId == Global.BuildingAirPlane2 then --  飞机特殊处理CD
                if (Model.Player.Level >= Global.FalconQueueUnlock[2]) then
                    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                else
                    TipUtil.TipById(50354, {num = Global.FalconQueueUnlock[2]})
                end
            elseif self.building.ConfId == Global.BuildingAirPlane1 then --  飞机特殊处理CD
                if (Model.Player.Level >= Global.FalconQueueUnlock[3]) then
                    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                else
                    TipUtil.TipById(50354, {num = Global.FalconQueueUnlock[3]})
                end
            end
        else
            TipUtil.TipByContentWithWaring(StringUtil.GetI18n(I18nType.Commmon, "UI_Activity_FALCONType"))
        end
    end
end
--弹出功能列表
function ItemBuild:ShowBuildFuncList(flag)
    if self._itemLock then
        self:BuildUnlock()
    else
        CityMapModel.GetCityContext():ShowFuncList(self.building, flag)
    end
end
--建筑解锁
function ItemBuild:BuildUnlock()
    if CommonModel.IsNest(self.building.ConfId) then
        if self._itemLock:CheckStateUnlock() then
            --巢穴解锁
            local upgrade_func = function(rsp)
                self.building = rsp.Building
                Model.Create(ModelType.Buildings, self.building.Id, rsp.Building)
                if rsp.Gem then
                    Event.Broadcast(EventDefines.UIGemAmount, rsp.Gem)
                end
                if rsp.ResAmounts then
                    Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
                end
                BuildNest.NestUnlock(self.building.ConfId)
            end
            Net.Buildings.Upgrade(self.building.Id, true, upgrade_func)
        else
            --巢穴未解锁提示
            if self.isGodzillaNest then
                local confId = self.building.ConfId + self.building.Level + 1
                local conf = ConfigMgr.GetItem("configBuildingUpgrades", confId)
                local condition = conf.condition[1]
                local data = {
                    base_name = BuildModel.GetName(condition.confId),
                    base_level = condition.level
                }
                TipUtil.TipById(30602, data)
            else
                TipUtil.TipById(50315)
            end
        end
    elseif CommonModel.IsCasino(self.building.ConfId) then
        --靶场（军官俱乐部）未解锁提示
        local conf = ConfigMgr.GetItem("configBuildings", self.building.ConfId)
        local data = {
            base_name = BuildModel.GetName(Global.BuildingCenter),
            base_level = conf.unlock_level
        }
        TipUtil.TipById(30602, data)
    elseif self.building.ConfId == Global.BuildingBeastBase then
        self._btnIcon:BuildUnLock()
    elseif self.building.ConfId == Global.Buildingplane then
        local data = {
            base_name = BuildModel.GetName(Global.BuildingCenter),
            base_level = Global.PlaneSystemUnlockLevel
        }
        TipUtil.TipById(30602, data)
    end
end

-- 点击免费升级
function ItemBuild:ClickFree(event, callback)
    if not event then
        self:FreeAnim(false)
        return
    end
    Net.Events.SpeedupByFree(
        event.Category,
        event.Uuid,
        function(rsp)
            Model.Delete(ModelType.UpgradeEvents, rsp.EventId)
            self:FreeAnim(false)
            self:SetNormal()
            if event.Category == EventType.B_BUILD then
                self:UpgradeEnd(rsp.BuildingLevel)
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.EndLvUp, self.building.ConfId, {self.building.Level, 2})
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.NoTrigger, self.building.ConfId, self.building.Level)
            elseif event.Category == EventType.B_DESTROY then
                self:RemoveEnd()
            end
            if self.isBuildHospital then
                self:ResetCD()
            end

            if callback then
                callback()
            end
            self:ResetHarest()
            self:SetGuideClick("UpgradeFreeGuide")
        end
    )
end
-- 点击训练收集
function ItemBuild:ClickTrain(event)
    if not event then
        self:TrainAnim(false)
        return
    end
    Net.Armies.Collect(
        event.Uuid,
        function(rsp)
            if CommonModel.IsTrainFactory(self.building.ConfId) then
                local args = {
                    building = self.building,
                    amount = event.Amount,
                    confId = event.ConfId
                }
                AnimationArmyQueue:Push(args)
            end
            if rsp.Army then
                Model.Create(ModelType.Armies, rsp.Army.ConfId, rsp.Army)
                Model.Delete(ModelType.TrainEvents, event.Uuid)
            end
            local values = {
                army_level = TrainModel.GetConf(rsp.Army.ConfId).level,
                army_name = TrainModel.GetName(rsp.Army.ConfId)
            }
            local icon = TrainModel.GetConf(rsp.Army.ConfId).army_model
            TipUtil.TipById(self.isBuildSecurityFactory and 30106 or 30104, values, icon)
            self:TrainAnim(false)
            self:PlayTrainEndEffect()
            WeatherModel.CheckWeatherRain()
            self:SetGuideClick("TrainFreeGuide")
        end
    )
end
-- 点击资源收集
function ItemBuild:ClickHarest()
    local resCategory = CommonModel.GetResParameter(self.building.ConfId).category
    if resCategory == RES_TYPE.Food then
        AudioModel.Play(50010)
    elseif resCategory == RES_TYPE.Wood then
        AudioModel.Play(50011)
    elseif resCategory == RES_TYPE.Iron then
        AudioModel.Play(50013)
    elseif resCategory == RES_TYPE.Stone then
        AudioModel.Play(50012)
    end
    Net.ResBuilds.Collect(
        self.building.Id,
        function(rsp)
            for _, v in pairs(rsp.CollectAmounts) do
                local buildObj = BuildModel.GetObject(v.BuildingId)
                buildObj:HarestAnim(false)
                buildObj.clickCollectRes = true
                AnimationModel.ResCollect(buildObj, resCategory)
                --收集动画
                --AnimationModel.NewResCollect(buildObj, resCategory)
                buildObj:HarestEndAnim(v.Amount)
                buildObj:ResetHarest()
                --数字浮动
            end
            Event.Broadcast(EventDefines.UIResourcesAmount, rsp.ResAmounts)
            WeatherModel.CheckWeatherRain()
        end
    )
end
-- 点击请求帮助
function ItemBuild:ClickHelp(event)
    Net.AllianceHelp.AskHelp(
        event.Category,
        event.Uuid,
        function()
            TipUtil.TipById(30001)
            if event.Category == EventType.B_CURE then
                for _, v in pairs(Model.Buildings) do
                    if v.ConfId == Global.BuildingHospital then
                        BuildModel.GetObject(v.Id):HelpAnim(false)
                    end
                end
            else
                self:HelpAnim(false)
            end
            event.AskedHelp = true
        end
    )
end

--升级默认请求帮助
function ItemBuild:DefultUnionHelp(event, isResetCD)
    if not isResetCD then
        return
    end
    if not UnionModel.CheckJoinUnion() or event.AskedHelp then
        return
    end
    Net.AllianceHelp.AskHelp(
        event.Category,
        event.Uuid,
        function()
            TipUtil.TipById(30001)
            event.AskedHelp = true
        end
    )
end

--点击领取科技研究完成奖励
function ItemBuild:ClickScienceAward()
    TechModel.TryGetScienceAward(self.isBuildBeastScience and Global.BeastTech or Global.NormalTech)
    BuildModel.GetObject(self.building.Id):ScienceAwardAnim(false)
    self:SetGuideClick("TechFreeGuide")
end

--点击领取装备
function ItemBuild:ClickEquipMaked()
    local event = EquipModel.GetEquipEvents()
    if event then
        Net.Equip.TakeExchangeEquip(
            event.Uuid,
            function(rsp)
                EquipModel.RemoveEquipEvent(rsp.EventId)
                self:EquipMakeAnim(false)
                UIMgr:Open("EquipDetail", rsp.EquipUuid, true)
            end
        )
    end
end

--点击领取装备材料
function ItemBuild:ClickEquipMaterialMaked()
    local info = EquipModel.GetMaterialMakeInfo()
    local getId
    if #info.OverList > 0 then
        getId = info.OverList[1]
    end

    Net.Equip.CollectJewel(
        function(rsp)
            Model.JewelMakeInfo = rsp
            self:EquipMaterialMakeAnim(false)

            if getId then
                --播放领取动画
                UIMgr:Open("EffectRewardMask", CommonType.REWARD_TYPE.GetEquipMaterial, getId, self.MateriakCall)
                self.MateriakCall = nil
            end
        end
    )
end

--设置点击收取材料后的回调
function ItemBuild:SetClickMateriakCall(cb)
    self.MateriakCall = cb
end

-- 点击交换建筑位置
function ItemBuild:ClickExchange()
    local oldpos = CityType.BUILD_MOVE_POS
    local goalpos = self.building.Pos
    if oldpos == self.building.Pos then
        TipUtil.TipById(50104)
        return
    end
    local move_func = function()
        Net.Buildings.Move(
            oldpos,
            goalpos,
            function()
                CityType.BUILD_MOVE_POS = nil
                --移动原来位置的建筑
                local building = BuildModel.FindByPos(oldpos)
                building.Pos = goalpos
                local node = BuildModel.GetObject(building.Id)
                if not node then
                    return
                end
                local oldPosX = node.x
                local oldPosY = node.y
                node.x = self.x
                node.y = self.y
                node:UpdateBuilding(building)
                node:ResetPos()

                --移动被交换位置的建筑(即当前建筑)
                self.x = oldPosX
                self.y = oldPosY
                self:ResetPos()
                Model.Update(ModelType.Buildings, self.building.Id, {Pos = oldpos})

                --重置地图按钮
                Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Reset)
            end
        )
    end
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_MOVE_BUILDING"),
        sureCallback = move_func
    }
    UIMgr:Open("ConfirmPopupText", data)
end

-- 是否显示名称
function ItemBuild:ShowName(flag)
    if not self.isShowName then
        return
    end
    
    self._nameCmpt:SetBuildVisible(flag)
end

-- 播放、关闭选中动画
function ItemBuild:SetPlayChooseAnim(flag)
    if self.isChoose then
        --关闭动画
        for i = 1, self._btnIcon.numChildren do
            local item = self._btnIcon:GetChildAt(i - 1)
            if item.asImage then
                GTween.Kill(item)
                item.color = Color.white
            end
        end
        return
    end

    if flag then
        --播放动画
        local function choose_func(gray)
            local startValue = gray and Color.white or Color.gray
            local endValue = gray and Color.gray or Color.white
            local imageChildIndex = 1
            for i = 1, self._btnIcon.numChildren do
                local item = self._btnIcon:GetChildAt(i - 1)
                if item.asImage then
                    imageChildIndex = i
                    self:GtweenOnComplete(
                        GTween.To(startValue, endValue, 0.6):SetTarget(item, TweenPropType.Color),
                        function()
                            if i == imageChildIndex then
                                choose_func(not gray)
                            end
                        end
                    )
                end
            end
        end
        choose_func(true)
    else
        --关闭动画
        for i = 1, self._btnIcon.numChildren do
            local item = self._btnIcon:GetChildAt(i - 1)
            if item.asImage then
                GTween.Kill(item)
                item.color = Color.white
            end
        end
    end
end

-- 资源建筑提速特效
function ItemBuild:SetResSpeedEffect(flag)
    local event = EventModel.GetEvent(self.building)
    if event then
        --升级中建造中拆除中不显示提速
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
        return
    end
    local resBuild = Model.Find(ModelType.ResBuilds, self.building.Id)
    local effectTime = resBuild.BuffExpireAt - Tool.Time()
    if effectTime > 0 then
        --提速中
        local path = "effects/build/resourcesincrease/prefab/effect_res_increase_g"
        local pathCircle = "effects/build/resourcesincrease/prefab/effect_res_increase_g_quan"
        if effectTime < 1800 then
            path = "effects/build/resourcesincrease/prefab/effect_res_increase_y"
            pathCircle = "effects/build/resourcesincrease/prefab/effect_res_increase_y_quan"
        end

        NodePool.Init(NodePool.KeyType.ResBuildSpeedUp, "Effect", "EffectNode")
        if not self.resBuildEffect then
            self.resBuildEffect = NodePool.Get(NodePool.KeyType.ResBuildSpeedUp)
            self.resBuildEffect.xy = Vector2(0, -65)
            self:AddChild(self.resBuildEffect)
            self.resBuildEffect.sortingOrder = CityType.CITY_MAP_SORTINGORDER.PlaneAnimation
            self.resBuildEffect:InitNormal()
            -- self.resBuildEffect:PlayEffectLoop(path, Vector3(90, 90, 90))
            self.resBuildEffect:PlayEffectLoop(path, nil, 0)
        end

        if not self.resBuildEffectCircle then
            self.resBuildEffectCircle = NodePool.Get(NodePool.KeyType.ResBuildSpeedUp)
            self.resBuildEffectCircle.xy = Vector2(0, -57)
            self:AddChild(self.resBuildEffectCircle)
            self.resBuildEffectCircle.sortingOrder = 1
            self.resBuildEffectCircle:InitNormal()
            self.resBuildEffectCircle:PlayEffectLoop(pathCircle, Vector3(1.2, 1.2, 1.2), 0)
        end
    else
        --未提速
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

-- 刷新建筑数据
function ItemBuild:UpdateBuilding(building)
    self.building = building
end

function ItemBuild:GetBuilding()
    return self.building
end

function ItemBuild:TriggerOnclick(callback)
    self.triggerCallBack = callback
end

function ItemBuild:GuideFinishTo(GuideType, Building)
    local guideStage = not JumpMapModel:GuideStage() and UIMgr:GetShowPanelCount() == 0
    if not GlobalVars.IsTriggerStatus and Model.Player.Level < 6 and guideStage and not GlobalVars.IsNoviceGuideStatus then
        local isOk = false
        isOk = TaskModel.GetGuideFreeStageByKey(GuideType)
        if not isOk then
            local completeBtn = self:GetBtnComplete():GetCutBtn()
            JumpMapModel:SetBuildId(Building)
            JumpMap:JumpSimple(813300, Building, nil, completeBtn)
        end
    end
end
function ItemBuild:SetCutChooseAnim(flag)
    self.isChoose = flag
end

--设置免费或者领取状态
function ItemBuild:SetGuideClick(GuideFinishType)
    if Model.Player.Level < 6 then
        local guideStage = JumpMapModel:GuideStage() and JumpMapModel:GetJumpId() == 813300
        --关闭引导
        Event.Broadcast(EventDefines.CloseGuide)
        if not TaskModel.GetGuideFreeStageByKey(GuideFinishType) and guideStage then
            TaskModel.SetGuideFreeData(GuideFinishType)
        end
    end
end

return ItemBuild
