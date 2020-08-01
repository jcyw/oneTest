--[[
    战机的model
]]
local GD = _G.GD
local PlaneModel = {}

local PlaneDir = {} --飞机kv表
local PlaneSortLists = {} --整理后的飞机列表
local CollectPlaneDir = {} --常用飞机字典，id索引
local CollectPlaneList = {} --常用飞机列表
local LuanchPlane = nil --已装备的飞机信息

local Model = _G.Model
local ModelType = _G.ModelType
local Net = _G.Net
local ConfigMgr = _G.ConfigMgr
local EventDefines = _G.EventDefines
local Event = _G.Event
local StringUtil = _G.StringUtil
local I18nType = _G.I18nType
local TurnModel = _G.TurnModel
local TipUtil = _G.TipUtil
local RESBOND = ConfigMgr.GetVar("ResBond")

-------------------------------local function--------------------------------
function PlaneModel.GetPartsConf()
    return ConfigMgr.GetDictionary("configPlaneParts")
end

--获取所有拥有的零件信息
function PlaneModel.GetPartListInfos()
    return Model.GetMap(ModelType.PlanePartList)
end
--获取零件的配置信息通过id
function PlaneModel.GetPartConfByID(id)
    return ConfigMgr.GetItem("configPlaneParts", id)
end

--初始化飞机Dir
local function SetPlaneDir()
    local palneList = Model.GetMap(ModelType.PlaneList)
    for _, planeInfo in pairs(palneList) do
        PlaneDir[planeInfo.Id] = planeInfo
        PlaneDir[planeInfo.Id].config = ConfigMgr.GetItem("configPlanes", planeInfo.Id)
    end
end

--获取所有飞机信息
local function GetPlaneDir()
    if not next(PlaneDir) then
        SetPlaneDir()
    end
    return PlaneDir
end

--初始化启动机信息
local function SetLaunchPlane()
    local planeDir = GetPlaneDir()
    for _, value in pairs(planeDir) do
        if value.IsLaunch then
            LuanchPlane = value
        end
    end
end

--初始化填充CollectPlaneDir
local function SetCollectPlaneDir()
    local planeDir = GetPlaneDir()
    local collectPlaneLists = Model.GetMap(ModelType.CollectPlaneList)
    for _, planeId in pairs(collectPlaneLists) do
        CollectPlaneDir[planeId] = planeDir[planeId]
    end
end

--飞机列表排序
local function PlaneSortList()
    for i = 1, 3, 1 do
        PlaneSortLists[i] = {}
    end
    local planeDir = GetPlaneDir()
    for _, planeInfo in pairs(planeDir) do
        table.insert(PlaneSortLists[planeInfo.config.level], planeInfo)
    end
    for _, lists in pairs(PlaneSortLists) do
        table.sort(
            lists,
            function(a, b)
                return a.Id < b.Id
            end
        )
    end
end

--常用飞机排序
local function CollectPlaneSort()
    CollectPlaneList = {}
    local collectPlane = PlaneModel.GetCollectPlaneDir()
    for _, value in pairs(collectPlane) do
        table.insert(CollectPlaneList, value)
    end
    table.sort(
        CollectPlaneList,
        function(a, b)
            return a.Id < b.Id
        end
    )
end

-------------------------------Global function-------------------------------
function PlaneModel.SetCollectDir()
    SetCollectPlaneDir()
    PlaneSortList()
    CollectPlaneSort()
end

--更改零件信息,走推送,零件的添加和状态变更
function PlaneModel.UpdataPartInfos(UpdataInfos)
    print("======================>>>>",table.inspect(UpdataInfos))
    if not UpdataInfos or #UpdataInfos == 0 then
        return
    end
    PlaneModel.PlanePartKV = {}
    local partInfos = PlaneModel.GetPartListInfos()
    for _, v1 in pairs(UpdataInfos) do
        local isAdd = true
        for k2, v2 in pairs(partInfos) do
            if v1.Uuid == v2.Uuid then
                isAdd = false
                partInfos[k2] = v1
            end
        end
        if isAdd then
            partInfos[v1.Uuid] = v1
        end
    end
end

--删除飞机零件信息
function PlaneModel.DelPartInfos(DelInfos)
    if not DelInfos or #DelInfos == 0 then
        return
    end
    PlaneModel.PlanePartKV = {}
    local partInfos = PlaneModel.GetPartListInfos()
    for _, v1 in pairs(DelInfos) do
        for k2, v2 in pairs(partInfos) do
            if v1 == v2.Uuid then
                partInfos[k2] = nil
            end
        end
    end
end

--更改飞机信息,走推送,启动和解锁都会走这里
function PlaneModel.UpdataPlaneInfos(UpdataInfos)
    if not UpdataInfos or not next(UpdataInfos) then
        return
    end
    local planeDir = GetPlaneDir()
    for _, list in pairs(UpdataInfos) do
        for _, v in pairs(list) do
            if planeDir[v.Id] then
                planeDir[v.Id] = v
                planeDir[v.Id].config = ConfigMgr.GetItem("configPlanes", v.Id)
            end
            --更新启动机的信息
            if v.IsLaunch then
                LuanchPlane = PlaneDir[v.Id]
            end
        end
    end
    --排序
    PlaneSortList()
    --刷新页面
    Event.Broadcast(EventDefines.RefreshHangarContent)
    Event.Broadcast(EventDefines.RefreshAirDetailsContent)
end

------------------------------商店net请求------------------------------
--购买零件
function PlaneModel.BuyPlanePart(PartId, callback)
    local Net_func = function(rsp)
        if callback then
            callback(rsp)
        end
    end
    Net.Plane.BuyPlanePart(
        PartId,
        function(rsp)
            Net_func(rsp)
        end
    )
end

-- 出售零件
function PlaneModel.SellPlanePart(Uuids, callback)
    local Net_func = function(rsp)
        if callback then
            callback(rsp)
        end
    end
    Net.Plane.SellPart(
        Uuids,
        function(rsp)
            Net_func(rsp)
        end
    )
end

------------------------------飞机的net请求------------------------------

--解锁一个飞机
function PlaneModel.UnlockPlane(aircraftId, cb)
    Net.Plane.UnlockPlane(
        aircraftId,
        function(rsp)
            if cb then
                cb(rsp.PlaneId)
            end
        end
    )
end

--启动一个飞机
function PlaneModel.NetLuanchPlane(aircraftId, cb)
    Net.Plane.LaunchPlane(
        aircraftId,
        function(rsp)
            local planeInfos = GetPlaneDir()
            LuanchPlane = planeInfos[rsp.PlaneId]
            if cb then
                cb(rsp.PlaneId)
            end
        end
    )
end

--取消启动一个飞机
function PlaneModel.UnlaunchPlane(aircraftId, cb)
    Net.Plane.UnlaunchPlane(
        aircraftId,
        function(rsp)
            LuanchPlane = nil
            if cb then
                cb(rsp.PlaneId)
            end
        end
    )
end

--一键启动一个飞机
function PlaneModel.OneKeyLuanchPlane(aircraftId, cb)
    Net.Plane.OnekeyLaunchPlane(
        aircraftId,
        function(rsp)
            if cb then
                cb(rsp.PlaneId)
            end
        end
    )
end

--添加常用飞机
function PlaneModel.AddCollectPlane(aircraftId, cb)
    Net.Plane.AddCollectPlane(
        aircraftId,
        function(rsp)
            if not CollectPlaneDir[rsp.PlaneId] then
                local planeDir = GetPlaneDir()
                CollectPlaneDir[rsp.PlaneId] = planeDir[rsp.PlaneId]
                CollectPlaneSort()
            end
            if cb then
                cb(rsp.PlaneId)
            end
        end
    )
end

--移除常用飞机
function PlaneModel.DelCollectPlane(aircraftId, cb)
    Net.Plane.DelCollectPlane(
        aircraftId,
        function(rsp)
            if CollectPlaneDir[rsp.PlaneId] then
                CollectPlaneDir[rsp.PlaneId] = nil
                CollectPlaneSort()
            end
            if cb then
                cb(rsp.PlaneId)
            end
        end
    )
end

function PlaneModel.GetResBond()
    local centents = {}
    -- 如果有零件的话就出售
    if #PlaneModel.GetPartListInfos() > 0 then
        local SellParts = {
            icon = {"Icon","Building_445000_small"},
            name  = StringUtil.GetI18n(I18nType.Commmon,"UI_PLANE_GETMORE_SELL"),
            click = function()
                if _G.UIMgr:GetUIOpen("AircraftAccessories") then
                    local AircraftAccessoriesUI =  _G.UIMgr:GetUI("AircraftAccessories")
                    AircraftAccessoriesUI:SwitchPage(AircraftAccessoriesUI.PAGENAME.bag)
                else
                    _G.UIMgr:Open("AircraftAccessories",true)
                end
                _G.UIMgr:Close("AcquisitionPopup")
            end
        }
        table.insert(centents,SellParts)
    end
    -- 打怪掉
    local Getspoils = {
        icon = {"IconFactory","army107002"},
        name  = StringUtil.GetI18n(I18nType.Commmon,"UI_PLANE_GETMORE1"),
        click = function()
            --跳转到世界地图
            TurnModel.WorldMapCallBack(
                function()
                    _G.UIMgr:Open("Lookup")
                    _G.UIMgr:Close("AcquisitionPopup")
                    _G.UIMgr:Close("AircraftAccessories")
                    _G.UIMgr:Close("AircraftDetails")
                    _G.UIMgr:Close("AircraftHangar")
                end
            )
        end
    }
    table.insert(centents,Getspoils)
    -- 道具获取
    local directUseGoods = {
        icon = GD.ResAgent.GetIconInfo(RESBOND),
        name  = StringUtil.GetI18n(I18nType.Commmon,"UI_PLANE_GETMORE3"),
        click = function()
            local itemAmounts,curAmount = GD.ResAgent.GetSourceAmount(RESBOND)
            if curAmount > 0 then
                GD.ResAgent.UseAllSource(itemAmounts,curAmount,RESBOND,ConfigMgr.GetI18n(I18nType.Commmon, "UI_PLANE_ONEKEY_USED"))
            else
                TipUtil.TipById(50357)
            end
        end
    }
    table.insert(centents,directUseGoods)
    _G.UIMgr:Open("AcquisitionPopup",StringUtil.GetI18n(I18nType.Commmon,"Ui_ForcesUp_HowGet"), centents)
end

-------------------------------Get function-------------------------------

--获取单个飞机信息
function PlaneModel.GetPlaneInfoById(Id)
    if not Id then
        return
    end
    local planeInfos = GetPlaneDir()
    if planeInfos[Id] then
        return planeInfos[Id]
    end
    return nil
end

--获取单个零件信息
function PlaneModel.GetPartInfoByUuid(Uuid)
    if not Uuid then
        return
    end
    if PlaneModel.PlanePartKV[Uuid] then
        return PlaneModel.PlanePartKV[Uuid]
    end
    local partInfos = PlaneModel.GetPartListInfos()
    for _, v in pairs(partInfos) do
        if v.Uuid == Uuid then
            PlaneModel.PlanePartKV[v.Uuid] = v
            return v
        end
    end
    return nil
end

--通过itemId判断是否有可用零件
function PlaneModel.GetPartInfoByPartId(PartId)
    local partInfos = PlaneModel.GetPartListInfos()
    for _, v in pairs(partInfos) do
        if v.PartId == PartId and v.IsShow then
            return true
        end
    end
    return false
end

--缺失零件总价
function PlaneModel.PartTotalPrice(planeInfo)
    if not planeInfo then
        return false
    end
    local price = 0
    for _, partId in pairs(planeInfo.config.part_type) do
        if not PlaneModel.GetPartInfoByPartId(partId) then
            price = price + PlaneModel.GetPartConfByID(partId).buy_price
        end
    end
    return price
end

--解锁飞机价格
function PlaneModel.UnlockPlanePrice(planeInfo)
    if not planeInfo then
        return false
    end
    local price = 0
    for _, partId in pairs(planeInfo.config.part_type) do
        price = price + PlaneModel.GetPartConfByID(partId).buy_price
    end
    return price
end

--获得某一等级的飞机信息列表
function PlaneModel.GteLevelPlaneList(level)
    return PlaneSortLists[level]
end

--获取排序过后的飞机列表
function PlaneModel.GetPlaneList()
    return PlaneSortLists
end

--获取已装备飞机信息
function PlaneModel.GetLuanchPlane()
    if not LuanchPlane then
        SetLaunchPlane()
    end
    return LuanchPlane
end

--判断是否是启动飞机
function PlaneModel.IsLuanchPlane(aircraftId)
    if LuanchPlane and aircraftId == LuanchPlane.Id then
        return true
    end
    return false
end

--获取排序过后的常用飞机列表
function PlaneModel.GetCollectPlaneList()
    return CollectPlaneList
end

--获取常用飞机字典
function PlaneModel.GetCollectPlaneDir()
    return CollectPlaneDir
end

--根据id获取常用飞机信息
function PlaneModel.GetCollectPlaneById(planeId)
    if CollectPlaneDir[planeId] then
        return CollectPlaneDir[planeId]
    end
    return nil
end

return PlaneModel
