--[[    Author: songzeming
    Function: 内城功能列表
]]
local ItemCityFunction = fgui.extension_class(GComponent)
fgui.register_extension("ui://Build/CityComplete", ItemCityFunction)

local BuildModel = import("Model/BuildModel")
local CommonModel = import("Model/CommonModel")
local EventModel = import("Model/EventModel")
local TechModel = import("Model/TechModel")
local GuidePanelModel = import("Model/GuideControllerModel")
local JumpModel = import("Model/JumpMapModel")
local WelfareModel = import("Model/WelfareModel")
local UIType = _G.GD.GameEnum.UIType
import("UI/City/FunctionList/ItemCityFunctionBtn")

function ItemCityFunction:ctor()
    self.sortingOrder = CityType.CITY_MAP_SORTINGORDER.FunctionList
    self:SetFuncVisible(false)

    self._animIn = self:GetTransition("In")
    self._animOut = self:GetTransition("Out")
    self._ctrAnim = self:GetController("CtrAnim")

    for i = 1, 6 do
        self["_btnFunc" .. i] = self:GetChild("btn" .. i)
    end
end

function ItemCityFunction:GetFuncState(building, funcId)
    local event = EventModel.GetEvent(building)
    local c = event and event.Category or nil
    if not c then
        --没有事件
        local funcName = ConfigMgr.GetItem("configBuildingFuncs", funcId).name
        if Tool.Equal(funcName, "BoostTime") then
            local eTime = Model.ResBuilds[building.Id].BuffExpireAt - Tool.Time()
            if eTime > 0 then
                return BuildType.FUNCTIONS.ResUp
            else
                return BuildType.FUNCTIONS.Normal
            end
        elseif Tool.Equal(funcName, "FoodBoostItem", "OilBoostItem", "SteelBoostItem", "MineralBoostItem") then
            --资源建筑 [特殊处理]
            local parameter = CommonModel.GetResParameter(building.ConfId)
            if Model.Items[parameter.itemId] then
                return BuildType.FUNCTIONS.Normal
            else
                --资源道具提升 没有该道具不显示
                return BuildType.FUNCTIONS.Never
            end
        elseif Tool.Equal(funcName, "JoinUnion", "AidAllies", "AidResources", "UnionWar", "UnionHelp", "UnionTechnology") then
            return Model.Player.AllianceId == "" and BuildType.FUNCTIONS.OutUnionNormal or BuildType.FUNCTIONS.UnionNormal
        else
            return BuildType.FUNCTIONS.Normal
        end
    end
    if c == EventType.B_BUILD or c == EventType.B_DESTROY then
        return BuildType.FUNCTIONS.Build
    end
    if c == EventType.B_TRAIN then
        return BuildType.FUNCTIONS.Train
    end
    if c == EventType.B_CURE then
        return BuildType.FUNCTIONS.Cure
    end
    if c == EventType.B_TECH then
        return BuildType.FUNCTIONS.Tech
    end
    if c == EventType.B_BEASTTECH then
        return BuildType.FUNCTIONS.BeastTech
    end
    if c == EventType.B_BEASTCURE then
        return BuildType.FUNCTIONS.BeastCure
    end
    if c == EventType.B_EQUIPTRAN then
        return BuildType.FUNCTIONS.Forge 
    end
end

function ItemCityFunction:CheckCondition(funcId)
    local result = true
    local conditions = ConfigMgr.GetItem("configBuildingFuncs", funcId).condition
    -- print("CheckCondition(funcId) funcId == " .. funcId)
    if conditions then
        for _, v in pairs(conditions) do
            if v.confId == 1 then
                local cid = (math.modf(v.numer / 100)) * 100
                local building = BuildModel.FindByConfId(cid)
                if not building or building.Level < math.fmod(v.numer, 10) then
                    return false
                end
            elseif v.confId == 2 then
                if Model.Player.Level < v.numer then
                    return false
                end
            elseif v.confId == 3 then
                if not Model.Items[v.numer] then
                    return false
                end
            elseif v.confId == 4 then
                if not WelfareModel.IsActivityOpen(v.numer) then
                    return false
                end
            end
        end
    end
    -- print("CheckCondition(funcId) result == " .. result)
    return result
end

function ItemCityFunction:CheckFunIsOpen(id)    --判断功能是否开启
    if id == 72 then    -- 装扮
        return FunOpenMgr.GetFunIsOpen(FunType.DressUp)
    end
    return true
end

function ItemCityFunction:GetFunctions(building)
    local conf = BuildModel.GetConf(building.ConfId)
    if not conf then
        return
    end
    local funcs = GameUtil.Clone(conf.funcs)
    table.sort(
        funcs,
        function(a, b)
            local aConf = ConfigMgr.GetItem("configBuildingFuncs", a)
            local bConf = ConfigMgr.GetItem("configBuildingFuncs", b)
            return aConf.order < bConf.order
        end
    )
    local showFuncs = {}
    for _, v in ipairs(funcs) do
        local funcConf = ConfigMgr.GetItem("configBuildingFuncs", v)
        if self:CheckFunIsOpen(funcConf.id) then
            for _, state in pairs(funcConf.status) do
                if (state == 0 or state == self:GetFuncState(building, v)) and self:CheckCondition(v) then
                    table.insert(showFuncs, v)
                    break
                end
            end 
        end
    end
    return showFuncs
end

function ItemCityFunction:CityInit(data, callback, completeFunc)
    local isGuide = GuidePanelModel.uiType == UIType.CityCompleteUI and GuidePanelModel.isBeginGuide
    if self.bid == data.building.Id and not completeFunc and not isGuide then
        self:OffAnim()
        return
    end
    self.building = data.building
    self.confId = data.building.ConfId
    self:SetFuncState(data.x, data.y)
    self:OffAnim(true)
    self.bid = data.building.Id

    local funcs = self:GetFunctions(data.building)
    if next(funcs) == nil then
        self.confId = nil
        self.bid = nil
        return
    end

    --检测是否满足条件
    for k, v in pairs(funcs) do
        local c = ConfigMgr.GetItem("configBuildingFuncs", v)
        if c.name == "Buff" then
            --基地增益 指挥中心4级解锁
            if not UnlockModel:UnlockCenter(UnlockModel.Center.Gain) then
                table.remove(funcs, k)
            end
            break
        end
    end

    self._titleBox.title = BuildModel.GetName(data.building.ConfId)
    self._ctrAnim.selectedPage = "Anim" .. #funcs
    self.itemData = {}

    for i = 1, #funcs do
        local _btnItem = self["_btnFunc" .. i]
        local funcData = ConfigMgr.GetItem("configBuildingFuncs", funcs[i])
        local funcTitle = funcData.name
        local maxLevel = BuildModel.GetConf(data.building.ConfId).max_level
        local isShowMax = data.building.Level >= maxLevel and funcTitle == "Upgrade"
        local btnText = StringUtil.GetI18n(I18nType.Commmon, funcData.text_id)
        local btnName = isShowMax and StringUtil.GetI18n(I18nType.Commmon, "Ui_Building_MAX") or btnText
        local icon = UITool.GetIcon(funcData.img)
        --功能列表按钮点击
        local click_func = function()
            if isShowMax then
                --建筑升级已经到达最大值
                TipUtil.TipById(50067)
            else
                self:OffAnim(true)
                callback(funcTitle)
            end
        end
        self.itemData[funcTitle] = _btnItem
        --功能列表按钮初始化显示
        _btnItem:Init(btnName, icon, click_func)
        _btnItem:SetTouchMaskEnable(false)

        --金币加速显示金币消耗数量
        if funcTitle == "BuildingGoldSpeedup" then
            --建筑升级金币加速
            local event = EventModel.GetEvent(data.building)
            if BuildModel.FreeState(event.Category) then
                local function time_func()
                    return event.FinishAt - Tool.Time()
                end
                self.gold_cd_func = function()
                    local goldNum = Tool.TimeTurnGold(time_func(), CommonModel.FreeTime())
                    if goldNum > 0 then
                        _btnItem:SetGoldNumberLabel(goldNum)
                    else
                        self:OffAnim()
                    end
                end
                self:Schedule(self.gold_cd_func, 1)
            end
        elseif Tool.Equal(funcTitle, "TrainGoldSpeedup", "ProduceGoldSpeedup", "CureGoldSpeedup", "BeastCureGold", "ForgeGoldSpeedup") then
            --训练、建造、治疗金币加速
            local event = EventModel.GetEvent(data.building)
            local function time_func()
                return event.FinishAt - Tool.Time()
            end
            self.gold_cd_func = function()
                local goldNum = Tool.TimeTurnGold(time_func())
                if goldNum > 0 then
                    _btnItem:SetGoldNumberLabel(goldNum)
                else
                    self:OffAnim()
                end
            end
            self:Schedule(self.gold_cd_func, 1)
        elseif Tool.Equal(funcTitle, "ResearchGoldSpeedup", "BeastResearchGold") then
            --研究加速
            local ctime = TechModel.GetResearchTime(data.building.ConfId == Global.BuildingBeastScience and Global.BeastTech or Global.NormalTech)
            self.gold_cd_func = function()
                ctime = ctime - 1
                local goldNum = Tool.TimeTurnGold(ctime)
                if goldNum > 0 then
                    _btnItem:SetGoldNumberLabel(goldNum)
                else
                    self:OffAnim()
                end
            end
            self:Schedule(self.gold_cd_func, 1)
        elseif funcTitle == "BoostGold" then
            --产量金币提升
            local parameter = CommonModel.GetResParameter(data.building.ConfId)
            local goldNum = parameter.coefficient * data.building.Level
            _btnItem:SetGoldNumberIcon(goldNum)
        elseif funcTitle == "BoostTime" then
            --提速还剩下
            if self.cd_func then
                self:UnSchedule(self.cd_func)
            end
            local buffTime = Model.ResBuilds[data.building.Id].BuffExpireAt
            local function time_func()
                return buffTime - Tool.Time()
            end
            if time_func() > 0 then
                local function name_func()
                    _btnItem:SetName(StringUtil.GetI18n(I18nType.Commmon, funcData.text_id, {time = ""}), Tool.FormatTime(time_func()))
                end
                name_func()
                self.cd_func = function()
                    if time_func() > 0 then
                        name_func()
                        return
                    end
                        self:SetFuncVisible(false)
                end
                self:Schedule(self.cd_func, 1)
            end
        elseif Tool.Equal(funcTitle, "FoodBoostItem", "OilBoostItem", "SteelBoostItem", "MineralBoostItem") then
            local parameter = CommonModel.GetResParameter(data.building.ConfId)
            _btnItem:SetItemNumber(Model.Items[parameter.itemId].Amount)
        elseif Tool.Equal(funcTitle, "CollectFood", "CollectOil", "CollectSteel", "CollectMineral") then
            --收集食品、收集石油、收集钢铁、收集稀土
            local resBuild = Model.Find(ModelType.ResBuilds, data.building.Id)
            local amount, _ = CommonModel.GetResBuildAmountAndStorage(resBuild)
            _btnItem:SetGrayed(amount < 1)
        end
    end

    self:SetGuideMask()
    self:OnAnim(completeFunc)
end

function ItemCityFunction:SetGuideMask()
    local isGuideMask = GuidePanelModel:IsGuideState() or GlobalVars.IsTriggerStatus
    if not isGuideMask then
        return
    end
    local jumpType = JumpModel:GetJumpType()
    local str = nil
    if jumpType == _G.GD.GameEnum.JumpType.Upgrade then --升级
        str = "Upgrade"
    elseif jumpType == _G.GD.GameEnum.JumpType.Train then --训练
        local buildId = JumpModel:GetBuildId()
        if buildId == Global.BuildingTankFactory then --坦克
            str = "TrainTank"
        elseif buildId == Global.BuildingWarFactory then --战车
            str = "TrainChariot"
        elseif buildId == Global.BuildingHelicopterFactory then --直升机
            str = "TrainHelicopter"
        elseif buildId == Global.BuildingVehicleFactory then --重载载具
            str = "TrainVehicle"
        elseif buildId == Global.BuildingSecurityFactory then --安保中心
            str = "Produce"
        end
    elseif jumpType == _G.GD.GameEnum.JumpType.Cure then --士兵治疗
        str = "Cure"
    elseif jumpType == _G.GD.GameEnum.JumpType.BeastCure then --巨兽治疗
        str = "BeastCure"
    elseif jumpType == _G.GD.GameEnum.JumpType.Speed then --加速
        str = "Speed"
    elseif jumpType == _G.GD.GameEnum.JumpType.Tech then --研究
        str = "Research"
    elseif jumpType == _G.GD.GameEnum.JumpType.BeastResearch then --巨兽研究
        str = "BeastResearch"
    elseif jumpType == _G.GD.GameEnum.JumpType.Promote then --提速
        str = "Boost"
    elseif jumpType == _G.GD.GameEnum.JumpType.Supply then --补给
        str = "Supply"
    elseif jumpType == _G.GD.GameEnum.JumpType.Make then --制造
        str = "Produce"
    elseif jumpType == _G.GD.GameEnum.JumpType.Drats then --飞镖赌场
        str = "RangeTurntable"
    elseif jumpType == _G.GD.GameEnum.JumpType.Girls then
        str = "BeautySystemMain"
    end
    local _btn = self:GetFuncItem(str)
    if _btn then
        _btn:SetTouchMaskEnable(true)
    end
end

function ItemCityFunction:GetCityId()
    return self.bid
end

--获取当前点击功能列表建筑ConfId
function ItemCityFunction:GetConfId()
    return self.confId
end

--取消建筑闪烁动画
function ItemCityFunction:CloseBuildFlickerAnim()
    if self.bid then
        local buildObj = BuildModel.GetObject(self.bid)
        buildObj:SetPlayChooseAnim(false)
    end
    self.bid = nil
end

--设置功能列表是否可见
function ItemCityFunction:SetFuncVisible(flag)
    self.visible = flag

    -- if  IsTriggerStatus then
    --     self.visible=true
    -- end

    if not flag then
        self:CloseBuildFlickerAnim()
        if self.cd_func then
            self:UnSchedule(self.cd_func)
        end
        if self.gold_cd_func then
            self:UnSchedule(self.gold_cd_func)
        end
    end
end
function ItemCityFunction:GetFuncVisible()
    return self.visible
end

--打开功能列表动画
function ItemCityFunction:OnAnim(completeCallBack)
    AudioModel.Play(40005)
    if self.bid then
        local buildObj = BuildModel.GetObject(self.bid)
        buildObj:SetPlayChooseAnim(true)
        buildObj:ShowName(false)
    end
    self:SetFuncVisible(true)
    if completeCallBack then
        self._animIn:Play(
            function()
                completeCallBack()
            end
        )
    else
        self._animIn:Play()
    end
    GuidePanelModel:SetValParams("cityFunctionBId", self.bid)
    if GuidePanelModel:GetBid() ~= self.bid then
        Event.Broadcast(EventDefines.CloseGuide)
    end
end
--关闭功能列表动画
function ItemCityFunction:OffAnim(instant)
    self:CloseBuildFlickerAnim()
    if not self:GetFuncVisible() then
        return
    end
    if instant then
       
        --立即关闭动画
        if self._animOut.playing then
            self._animOut:Stop()
        end
        self:SetFuncVisible(false)
        return
    else
        --缓动关闭动画
        if self._animOut.playing then
            return
        end
   
        self._animOut:Play(
            function()
                self:SetFuncVisible(false)
            end
        )
    end
end

local SpeedCompletes = {
    Speed = {
        [3] = false,
        [4] = true,
        [5] = false,
        [6] = true,
        [20] = false,
        [21] = true,
        [23] = false,
        [24] = true,
        [26] = false,
        [27] = true,
        [35] = false,
        [36] = true,
        [55] = false,
        [56] = true,
        [57] = false,
        [58] = true
    },
    Boost = {
        [8] = true,
        [9] = true,
        [10] = true,
        [11] = true,
        [12] = false
    }
}

--当前属性按钮id ,List=属性表
function ItemCityFunction:GetCutBtnId(list)
    local funcData = self:GetFunctions(self.building)
    local tempSpeed = {}
    local funcConfigData = {}
    local cutBtnStr = ""
    for i = 1, #funcData do
        local completeData = ConfigMgr.GetItem("configBuildingFuncs", funcData[i])
        table.insert(funcConfigData, completeData)
        local tempId = tonumber(completeData.id)
        if list[tempId] ~= nil then
            table.insert(tempSpeed, completeData.id)
        end
    end
    local cutSpeedId = 0
    --优先使用道具
    for i = 1, #tempSpeed do
        if list[tempSpeed[i]] == true then
            cutSpeedId = tempSpeed[i]
            break
        end
    end
    if cutSpeedId == 0 then
        cutSpeedId = tempSpeed[1]
    end

    for k, v in pairs(funcConfigData) do
        if v.id == cutSpeedId then
            cutBtnStr = v.name
            break
        end
    end
    return cutBtnStr
end

function ItemCityFunction:GetFuncItem(str)
    local cutButName = ""
    if str == "Speed" then
        cutButName = self:GetCutBtnId(SpeedCompletes.Speed)
    elseif str == "Boost" then
        cutButName = self:GetCutBtnId(SpeedCompletes.Boost)
    else
        cutButName = str
    end
    if not self.itemData[cutButName] then
        return nil
    end
    return self.itemData[cutButName], cutButName
end

--设置功能列表位置
function ItemCityFunction:SetFuncState(x, y)
    self._titleBox.y  = 0
    if self.confId == Global.BuildingCenter then
        --指挥中心
        self.xy = Vector2(x + 170, y - 370)
        self._arc.y = 460
        self._titleBox.y = -90
    elseif self.confId == Global.BuildingWall then
        --城墙
        self.xy = Vector2(x - 50, y - 100)
        self._arc.y = 360
    elseif self.confId == Global.BuildingShip then
        --轮船
        self.xy = Vector2(x, y - 150)
        self._arc.y = 380
    elseif self.confId == Global.BuildingGodzilla then
        --巢穴 哥斯拉
        self.xy = Vector2(BuildType.OFFSET_BUILD_GODZILLA.x, BuildType.OFFSET_BUILD_GODZILLA.y - 280)
        self._arc.y = 500
    elseif self.confId == Global.BuildingKingkong then
        --巢穴 金刚
        self.xy = Vector2(BuildType.OFFSET_BUILD_KINGKONG.x, BuildType.OFFSET_BUILD_KINGKONG.y - 280)
        self._arc.y = 520
    elseif BuildModel.IsInnerOrBeast(self.confId) then
        --城内建筑或巨兽建筑
        self.xy = Vector2(x, y - 20)
        self._arc.y = 380
        self._titleBox.y = 20
    else
        --城外
        self.xy = Vector2(x, y + 50)
        self._arc.y = 280
    end
    if self.building then
        local buildObj = BuildModel.GetObject(self.building.Id)
        if buildObj:GetCmptCDActive() then
            self._arc.y = self._arc.y + BuildType.OFFSET_BUILD_FUNC_Y
        end
    end
end

return ItemCityFunction
