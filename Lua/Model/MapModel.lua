local MapModel = {}

local reponseAddTile = {}
local MapInfo = {}
local Towns = {}
local MapMiners = {}
local Monsters = {}
local MarchLines = {}
local MapOwners = {}
local AllianceMapTile = {}
--大城区域从属
local Blanks = {}
local ScoutMonster

local Model = import("Model/Model")
local ExpeditionType = import("Enum/ExpeditionType")
local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")
local FavoriteModel = import("Model/FavoriteModel")
local RelationEnum = import("Enum/RelationEnum")
local WorldBuildType = import("Enum/WorldBuildType")
local MissionEventModel = import("Model/MissionEventModel")
local WelfareModel = import("Model/WelfareModel")

local math_floor = math.floor
-- 通过建筑ID获取对应事件
function MapModel.SetMapInfo(posId, data)
    MapInfo[posId] = data
end

function MapModel.ClearPoints(delPoints)
    for _, point in pairs(delPoints) do
        MapInfo[point] = nil
        if AllianceMapTile[point] ~= nil then
            AllianceMapTile[point] = nil
        end
    end
end
function MapModel.DelPoint(posNum)
    MapInfo[posNum] = nil
end
--获取地图对象信息
function MapModel.GetMapRecs()
    return MapInfo
end

function MapModel.RefreshMap(rsp)
    local info = nil
    -- AllianceMapTile = {}
    for i = 1, #rsp.MapMiners do
        MapMiners[rsp.MapMiners[i].MineId] = rsp.MapMiners[i]
    end

    for i = 1, #rsp.MapOwners do
        MapOwners[rsp.MapOwners[i].UserId] = rsp.MapOwners[i]
    end
    if rsp.EmptyIds then
        for _, point in pairs(rsp.EmptyIds) do
            MapInfo[point] = {
                AllianceId = "",
                Category = 3,
                FortressId = 0,
                Id = point,
                Occupied = 0,
                ConfId = 0,
                FortressIdList = "",
                OwnerId = ""
            }
            if AllianceMapTile[point] then
                AllianceMapTile[point] = nil
            end
        end
    end
    reponseAddTile = {}
    for i = 1, #rsp.MapRecs do
        info = rsp.MapRecs[i]
        reponseAddTile[info.Id] = true
        MapInfo[info.Id] = info

        if info.FortressId ~= 0 then
            AllianceMapTile[info.Id] = info
        elseif AllianceMapTile[info.Id] then
            AllianceMapTile[info.Id] = nil
        end
    end

    MapModel.RefreshAllianceLand(AllianceMapTile)
    for i = 1, #rsp.MarchLines do
        MarchLines[rsp.MarchLines[i].Uuid] = rsp.MarchLines[i]
    end
    if #rsp.MarchLines > 0 then
        Event.Broadcast(EventDefines.UIOnRefreshMarchLine, rsp.MarchLines)
    end
end

function MapModel.GetCurrentMap()
    return {MapMiners = MapMiners}
end

function MapModel.GetReponseAddTile()
    return {MapMiners = MapMiners}
end

function MapModel.RefreshAllianceLand(allianceTile)
    local left = {}
    local right = {}
    local up = {}
    local down = {}
    local enemyLeft = {}
    local enemyRight = {}
    local enemyUp = {}
    local enemyDown = {}
    local offset = ConfigMgr.GetItem("ConfigMaps", Model.MapConfId).offset
    local tempPoint
    local currentId
    local otherId
    local emptyIds = {}

    --判断每个块的前后左右
    for _, v in pairs(allianceTile) do
        --当前地块的ID
        currentId = v.Id
        --左边地块Id
        otherId = math_floor(currentId / 10000 - 1)
        if otherId >= offset then
            tempPoint = MapInfo[currentId - 10000]
            if tempPoint and tempPoint.FortressId ~= v.FortressId then
                if Model.Player.AllianceId == v.AllianceId then
                    left[#left + 1] = currentId
                else
                    enemyLeft[#enemyLeft + 1] = currentId
                end
            end
        end
        --右边地块Id
        otherId = math_floor(currentId / 10000 + 1)
        if otherId <= 1200 - offset then
            tempPoint = MapInfo[currentId + 10000]
            if tempPoint and tempPoint.FortressId ~= v.FortressId then
                if Model.Player.AllianceId == v.AllianceId then
                    right[#right + 1] = currentId
                else
                    enemyRight[#enemyRight + 1] = currentId
                end
            end
        end
        --上方地块Id
        otherId = math_floor(currentId % 10000 - 1)
        if otherId >= offset then
            tempPoint = MapInfo[currentId - 1]
            if tempPoint and tempPoint.FortressId ~= v.FortressId then
                if Model.Player.AllianceId == v.AllianceId then
                    up[#up + 1] = currentId
                else
                    enemyUp[#enemyUp + 1] = currentId
                end
            end
        end
        --下方地块Id
        otherId = math_floor(currentId % 10000 + 1)
        if otherId <= 1200 - offset then
            tempPoint = MapInfo[currentId + 1]
            if tempPoint and tempPoint.FortressId ~= v.FortressId then
                if Model.Player.AllianceId == v.AllianceId then
                    down[#down + 1] = currentId
                else
                    enemyDown[#enemyDown + 1] = currentId
                end
            end
        end
    end
    WorldMap.Instance():RefreshAllianceLand(left, right, up, down, enemyLeft, enemyRight, enemyUp, enemyDown)
end

--获取矿点信息
function MapModel.GetMineOwner(Id)
    return MapMiners[Id]
end
--一般不使用，此处用于ABTest 新手引导
function MapModel.SetMarchLine(data)
    MarchLines[data.Uuid] = data
end

function MapModel.GetTargetPos(posNum)
    local area = MapInfo[posNum]

    if not area then
        return posNum
    end
    if area.Category ~= Global.MapTypeBlank and area.Occupied ~= 0 then
        return area.Occupied
    else
        return posNum
    end
end

function MapModel.GetArea(posNum)
    local area = MapInfo[posNum]

    if not area then
        --此处为空地
        -- Log.Error("此处为空地")
        return nil
    end

    if area.Occupied and area.Occupied ~= 0 then
        area = MapInfo[area.Occupied]
    end
    if not area then
        -- Log.Error("MapModel  目标位置的实际坐标未获取")
        return nil
    end

    if area.Category == Global.MapTypeBlank then
        --纯空地
        return area, ExpeditionType.None
    elseif area.Category == Global.MapTypeMine then
        --野矿
        return area, ExpeditionType.Mining
    elseif area.Category == Global.MapTypeMonster then
        --野怪
        return area, ExpeditionType.Pve
    elseif area.Category == Global.MapTypeTown then
        --城市
        return area, ExpeditionType.AttackPlayer
    elseif area.Category == Global.MapTypeAllianceDomain then
        --联盟堡垒
        return area, ExpeditionType.AttackPlayer
    elseif area.Category == Global.MapTypeCamp then
        --扎营
        return area, ExpeditionType.AttackPlayer
    elseif area.Category == Global.SearchPrison then
        return area, ExpeditionType.SearchPrison
    elseif area.Category == Global.MapTypeFort then
        return area, ExpeditionType.AttackPlayer
    elseif area.Category == Global.MapTypeThrone then
        return area, ExpeditionType.AttackPlayer
    else
        return area
    end
end

--获取地图按钮配置
function MapModel.GetMapButtons(posNum)
    local mapId = 0
    local area = MapInfo[posNum]

    if not area or area.Category == 3 then
        mapId = 10000 * Global.MapTypeBlank
    else
        --Log.Error("area == {0}",table.inspect(area))
        if area.Occupied ~= 0 then
            area = MapInfo[area.Occupied]
        end
        --地图元素类型*10000000
        mapId = 10000 * area.Category
        if area.Category == 11 or area.Category == 12 then
            --Log.Error("hasUser111 == ")
            local activityData = ActivityModel.GetRoyalBattleInfo()
            if activityData and activityData.Open then
                --Log.Error("hasUser2222 == ")
                mapId = mapId + MapModel.CheckOwnerType(area)
            else
                --王城战和平时期
                mapId = mapId + 4
            end
        else
            mapId = mapId + MapModel.CheckOwnerType(area)
        end
    end

    local mapInfo = ConfigMgr.GetItem("configMapStatuss", mapId)

    if not mapInfo then
        return {}
    end
    local funs = {}
    local isOk = true
    if mapInfo.funcs then
        for i = 1, #mapInfo.funcs do
            repeat
                local btnIndex = mapInfo.funcs[i]

                --特殊处理环节 ----------------------
                --地块在联盟表紧
                if btnIndex == 15 then
                    if Model.Player.AlliancePos < ALLIANCEPOS.R5 then
                        break
                    end

                    if FavoriteModel.GetUnionSign(posNum) then
                        btnIndex = 40
                    end
                elseif btnIndex == 11 then --返回按钮 如果目标地任务状态还在行军中，则点击地面不显示返回按钮
                    local mission = MissionEventModel.GetMissionByPos(posNum)
                    if not mission or mission.Status == Global.MissionStatusMarch then
                        break
                    end
                end

                --特殊处理-------------------------
                --部队详情

                ----------------------------------
                local btnInfo = ConfigMgr.GetItem("configMapButtons", btnIndex)
                --是否在修建、破损状态
                if btnInfo.construction ~= 0 then
                    if btnInfo.construction == 1 and (area.State ~= Global.MapRecStateBuilding and area.State ~= Global.MapRecStateUnfinished) then -- 修建显示按钮
                        break
                    end
                    if btnInfo.construction == 2 and (area.State == Global.MapRecStateBuilding or area.State == Global.MapRecStateUnfinished or area.State == Global.MapRecStateBroken) then
                        break
                    end
                    if btnInfo.construction == 3 and area.State ~= Global.MapRecStateBroken then -- 破损显示按钮
                        break
                    end
                -- UnionTrritoryModel.GetBuildingStatus(area)
                end
                --我的公会状态
                if btnInfo.mystatus ~= 0 then
                    if btnInfo.mystatus == 1 and Model.Player.AllianceId ~= "" then
                        -- isOk = false
                        break
                    end
                    if btnInfo.mystatus == 2 and Model.Player.AlliancePos == 0 and Model.Player.AlliancePos > 3 then
                        break
                    end
                    if btnInfo.mystatus == 3 and Model.Player.AlliancePos < 4 then
                        break
                    end
                    if btnInfo.mystatus == 4 and Model.Player.AllianceId == "" then
                        -- isOk = false
                        break
                    end
                end
                --对方是否有工会
                if btnInfo.enemystatus ~= 0 then
                    local ownerInfo = MapModel.GetMapOwner(area.OwnerId)
                    if btnInfo.enemystatus == 1 and ownerInfo.Alliance ~= "" then
                        -- isOk = false
                        break
                    end
                    if btnInfo.enemystatus == 2 and ownerInfo.Alliance == "" then
                        -- isOk = false
                        break
                    end
                end
                --王位状态
                if btnInfo.citywar ~= 0 then
                    -- break
                    Log.Info(btnInfo.citywar)
                end

                table.insert(funs, btnIndex)
            until true
        end
    end
    return funs
end

--获取矿点拥有者信息
function MapModel.GetMapOwner(Id)
    return MapOwners[Id]
end

--获取地块上联盟状态多语言
function MapModel.GetAllianceDomainStatus(area)
    -- if area.Category ~= Global.MapTypeAllianceDomain and area.Category ~= Global.MapTypeAllianceStore then
    --     return ""
    -- end

    if area.State == Global.MapRecStateBuilding then
        --修建中
        return "QUEUE_IN_BUILD"
    elseif area.State == Global.MapRecStateUnfinished then
        --未完成
        return "Ui_Alliance_Incomplete"
    elseif area.State == Global.MapRecStateAttacked then
        --被破坏中
        return "Ui_Alliance_Destroy"
    elseif area.State == Global.MapRecStateBroken then
        --破损
        return "Ui_Alliance_Damaged"
    elseif area.State == Global.MapRecStateNormal then
        if area.Category == Global.MapTypeAllianceStore then
            return ""
        end
        if area.OwnerId == "" then
            --未驻防
            return "Ui_Alliance_Bunker_Noarmy"
        else
            --驻防中
            return "Ui_Alliance_Bunker_army"
        end
    end
end

-- 0无归属-- 1自己-- 2盟友-- 3敌方
function MapModel.CheckOwnerType(area)
    --联盟建筑单独处理
    if area.Category >= Global.MapTypeAllianceStore and area.Category < Global.MapTypeFort then
        if Model.Player.AllianceId ~= "" then
            if Model.Player.AllianceId ~= area.AllianceId then
                if area.OwnerId == Model.Account.accountId then
                    return 32
                elseif MapOwners[area.OwnerId] and MapOwners[area.OwnerId].AllianceId == Model.Player.AllianceId then
                    return 31
                else
                    return 3
                end
            elseif Model.Player.AllianceId == area.AllianceId then
                if area.OwnerId == Model.Account.accountId then
                    return 1
                elseif MapOwners[area.OwnerId] and MapOwners[area.OwnerId].AllianceId ~= Model.Player.AllianceId then
                    return 23
                else
                    return 2
                end
            -- elseif area.OwnerId == Model.Account.accountId then
            --     return 1
            -- else
            --     return 2
            end
        else
            return 3
        end
    end
    --普通建筑
    if area.OwnerId == "" then
        return 0
    end
    local info = MapOwners[area.OwnerId]
    if info then
        if info.UserId == Model.Account.accountId then
            -- 王城站地块特殊处理
            if (area.Category == 12 or area.Category == 11) then
                -- 查找是否有增援部队
                local mission = nil
                local posX, posY = MathUtil.GetCoordinate(area.Id)
                local list = Model.GetMap("MissionEvents")
                for k, v in pairs(list) do
                    if v.StopX == posX and v.StopY == posY and v.Category == Global.MissionAssit then
                        mission = v
                        break
                    end
                end
                if mission then
                    return 1
                else
                    return 2
                end
            else
                return 1
            end
        elseif info.AllianceId == Model.Player.AllianceId and info.AllianceId ~= "" then
            -- 查找是否有增援部队
            local mission = nil
            local posX, posY = MathUtil.GetCoordinate(area.Id)
            local list = Model.GetMap("MissionEvents")
            for k, v in pairs(list) do
                if v.StopX == posX and v.StopY == posY and v.Category == Global.MissionAssit then
                    mission = v
                    break
                end
            end
            -- 王城站地块特殊处理
            if (area.Category == 12 or area.Category == 11) then
                if mission then
                    return 1
                else
                    return 2
                end
            else
                if mission then
                    return 21
                else
                    return 2
                end
            end
        else
            return 3
        end
    elseif area.AllianceId == Model.Player.AllianceId then
        return 2
    else
        return 3
    end
end

function MapModel.GetMyTownPos()
    return Model.GetPlayer().X, Model.GetPlayer().Y
end

--返回是否显示Tip 以及Tip位置
function MapModel.GetTownTipPos()
    local myPosX, myPosY = MapModel.GetMyTownPos()
    local nowPosX, nowPosY = WorldMap.Instance():ScreenToLogicPos(Screen.width / 2, Screen.height / 2)

    local diffX = myPosX - nowPosX
    local diffY = myPosY - nowPosY

    local angle = diffX == 0 and (diffY > 0 and 90 or 270) or math.atan(diffY / diffX) / math.pi * 180
    if diffX < 0 then
        angle = angle + 180
    end

    local isShow = false
    if diffX <= 0 then
        if diffY <= 0 then
            isShow = MathUtil.GetDistanceToBase(nowPosX, nowPosY) > 6.4
        else
            isShow = MathUtil.GetDistanceToBase(nowPosX, nowPosY) > 3.2
        end
    else
        if diffY <= 0 then
            isShow = MathUtil.GetDistanceToBase(nowPosX, nowPosY) > 3.2
        else
            isShow = MathUtil.GetDistanceToBase(nowPosX, nowPosY) > 6.4
        end
    end
    local screenPosX1, screenPosY1 = MathUtil.ScreenRatio(WorldMap.Instance():LogicToScreenPos(myPosX, myPosY))
    local screenPosX2, screenPosY2 = MathUtil.ScreenRatio(WorldMap.Instance():LogicToScreenPos(nowPosX, nowPosY))
    return isShow, angle,(screenPosX1 - screenPosX2)/100,(screenPosY1 - screenPosY2)/100
end

--返回是否显示Tip 以及Tip位置
function MapModel.GetTownDistance(posX, posY)
    local lastPosX, lastPosY = MapModel.GetMyTownPos()
    local worldY = posY - lastPosY
    local worldX = posX - lastPosX
    local dis = math.sqrt(worldX * worldX + worldY * worldY)
    return math.floor(dis)
end

--检测行军路线状态
function MapModel.CheckMarchRouteStatus(data)
    if Model.Account.accountId == data.OwnerId then
        return RelationEnum.Oneself
    end

    local userInfo = MapModel.GetMapOwner(data.OwnerId)
    if not userInfo then
        if MissionEventModel.IsMyRallingEvent(data.AllianceBattleId) then
            return RelationEnum.Ally
        end
        Log.Warning("未找到Owner信息")
        return RelationEnum.Enemy
    end

    if Model.Player.AllianceId ~= "" and Model.Player.AllianceId == userInfo.AllianceId then
        return RelationEnum.Ally
    elseif (Model.Player.AllianceId == data.TargetAllianceId and data.TargetAllianceId ~= "") or data.TargetOwnerId == Model.Account.accountId then
        return RelationEnum.Enemy
    else
        return RelationEnum.Neutrality
    end
end

function MapModel.GetResByMineConfId(confId)
    return math.floor((confId / 1000) % 10)
end

--判断自身是否开启防护罩
function MapModel.IsShieldByOneself()
end
--计算挖矿量
function MapModel.CalCollection(posNum)
    local miner = MapModel.GetMineOwner(posNum)
    if not miner then
        return 0
    end
    local getNum = math.floor((Tool.Time() - miner.RefreshedAt) * miner.MineSpeed / 3600) + miner.Mined
    return getNum
end
--检测防护罩状态（进攻或侦查）
function MapModel.CheckProtectStatus(accountId)
    local userInfo = MapModel.GetMapOwner(accountId)
    local nowTime = Tool.Time()
    if userInfo and userInfo.ProtectedAt > nowTime then
        return true
    end
    return false
end
--提示
function MapModel.TipShield(str, cb)
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, str),
        sureCallback = function()
            if cb then
                cb()
            end
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end
--攻击行为检测
--首先检测对方防护罩
--其次检测自己防护罩
function MapModel.AttackCheck(area, cb)
    local I18key = "TIPS_BROKEN_PROTECTION"
    if area.Category == Global.MapTypeTown and MapModel.CheckProtectStatus(area.OwnerId) then
        TipUtil.TipById(50059)
        return false
    end
    if area.Category == Global.MapTypeFort or area.Category == Global.MapTypeThrone then
        I18key = "Ui_WarZone_Fire_Tips"
    end

    if MapModel.CheckProtectStatus(Model.Account.accountId) and not MapModel.IsMyAllianceDomain(area) then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, I18key),
            sureCallback = function()
                if cb then
                    cb()
                end
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    elseif cb then
        cb()
    end
end
--是否为自己的联盟堡垒
function MapModel.IsMyAllianceDomain(area)
    return area.Category == Global.MapTypeAllianceDomain and Model.Player.AllianceId == area.AllianceId
end

function MapModel.CheckIsBlankChunk(pos)
    local chunkInfo = MapModel.GetArea(pos)
    if not chunkInfo or chunkInfo.Category == Global.MapTypeBlank then
        if WorldMap.Instance():IsMapTerrain(pos) then
            return false
        end
        return true
    else
        return false
    end
    return true
end
--计算行军点
function MapModel.GetMarchPoint(data)
    local startX, startY, stopX, stopY
    if not data.StartPointSize or not data.StopPointSize then
        Log.Error("出错了")
    end
    startX = MapModel.CalMarchPoint(data.StartX, data.StartPointSize)
    startY = MapModel.CalMarchPoint(data.StartY, data.StartPointSize)
    stopX = MapModel.CalMarchPoint(data.StopX, data.StopPointSize)
    stopY = MapModel.CalMarchPoint(data.StopY, data.StopPointSize)

    if data.IsReturn then
        return stopX, stopY, startX, startY
    else
        return startX, startY, stopX, stopY
    end
end

function MapModel.CalMarchPoint(point, size)
    if size == 1 then
        return point
    elseif size == 2 then
        return point - 0.5
    elseif size == 3 then
        return point
    else
        -- Log.Error("提示，MapModel.CalMarchPoint计算行军点有错误状态")
        return point
    end
end

function MapModel.CheckBuildPoint(posNum, buildType)
    local checkList = {}
    local posX, posY = MathUtil.GetCoordinate(posNum)

    local chunkInfo = MapModel.GetArea(posNum)
    if posX < mapOffset or posY < mapOffset or posX > 1201 - mapOffset or posY > 1201 - mapOffset then
        return {false, false, false, false}
    end

    if buildType == WorldBuildType.UnionDefenceTower then
        --必须所属领地为联盟领地才可修建
        if chunkInfo and chunkInfo.AllianceId == Model.Player.AllianceId then
            table.insert(checkList, MapModel.CheckIsBlankChunk(posX * 10000 + posY))
        else
            table.insert(checkList, false)
        end
    else
        --传入坐标为中心坐标，需要计算以左下角为基准的点位
        posX = math.floor(posX + 0.5)
        posY = math.floor(posY + 0.5)
        local isBlank
        local isCanFly = false
        local isInBorder = false
        local fortressId
        for i = 0, 1 do
            for j = 0, 1 do
                isBlank = MapModel.CheckIsBlankChunk((posX - i) * 10000 + posY - j)
                isInBorder = not MapModel.IsOutBorder(posX - i, posY - j)
                if buildType == WorldBuildType.MainCity or buildType == WorldBuildType.UnionGoLeader then
                    isCanFly = isBlank and not MapModel.IsInKingCity(posX - i, posY - j) and isInBorder
                    --主城只需要检测是否是空地
                    table.insert(checkList, isCanFly)
                elseif buildType == WorldBuildType.UnionFortress then
                    isCanFly = isBlank and not MapModel.IsInBlackZone(posX, posY) and isInBorder
                    --联盟堡垒必须不在别人联盟领地内
                    if not chunkInfo or chunkInfo.AllianceId == "" or chunkInfo.AllianceId == Model.Player.AllianceId then
                        table.insert(checkList, isCanFly)
                    else
                        table.insert(checkList, false)
                    end
                else
                    --联盟其他建筑必须在同一块联盟领地内
                    local curChunkInfo = MapModel.GetArea((posX - i) * 10000 + posY - j)
                    if not curChunkInfo then
                        table.insert(checkList, false)
                    else
                        if curChunkInfo.AllianceId == Model.Player.AllianceId then
                            if not fortressId then
                                fortressId = curChunkInfo.FortressId
                            end
                            local fortressInfo = MapModel.GetArea(curChunkInfo.FortressId)
                            table.insert(checkList, isBlank and isInBorder and fortressInfo.State == 0 and fortressId == curChunkInfo.FortressId)
                        else
                            table.insert(checkList, false)
                        end
                    end
                end
            end
        end
        local isInBlack = MapModel.IsInBlackZone(posX, posY)
        for i = 0, 1 do
            for j = 0, 1 do
                if isInBlack ~= MapModel.IsInBlackZone(posX - i, posY - j) then
                    return {false, false, false, false}
                end
            end
        end
    end
    return checkList
end

-- 获取穿越黑土地的距离（黑土地范围为（574，574）到（626，626））
function MapModel.GetDistanceCrossBlackZone(startX, startY, endX, endY)
    local crossAX = 0 -- 最终交点A的x
    local crossAY = 0 -- 最终交点A的y
    local crossBX = 0 -- 最终交点B的x
    local crossBY = 0 -- 最终交点B的y
    local minX = startX > endX and endX or startX
    local maxX = startX > endX and startX or endX
    local minY = startY > endY and endY or startY
    local maxY = startY > endY and startY or endY
    -- 路径直线表达式y=a*x+b
    local a, b
    local points = {} -- 路径所在直线与黑土地边缘的交点
    if endX == startX then
        -- a不存在
        if startX >= 574 and startX <= 626 then
            if (minY <= 574 and maxY >= 574) or (maxY >= 626 and minY <= 626) then
                table.insert(points, {x = startX, y = 574})
                table.insert(points, {x = startX, y = 626})
            elseif minY >= 574 and maxY <= 626 then
                table.insert(points, {x = startX, y = minY})
                table.insert(points, {x = startX, y = maxY})
            end
        end
    else
        a = (endY - startY) / (endX - startX)
        b = endY - (a * endX)
        points = MapModel.GetIntersectionPoints(a, b)
    end

    -- 没有交点或只有一个交点（一个交点表示路径和黑土地边角切过）
    if #points < 2 then
        return 0
    end

    -- 找出在路径范围内的交点（不算线段端点）
    if points[1].x > minX and points[1].x < maxX and points[1].y > minY and points[1].y < maxY then
        crossAX = points[1].x
        crossAY = points[1].y
    end
    if points[2].x > minX and points[2].x < maxX and points[2].y > minY and points[2].y < maxY then
        crossBX = points[2].x
        crossBY = points[2].y
    end

    -- 当路径起点或终点在黑土地内（与黑土地边缘重合也算在内）
    if MapModel.IsInBlackZone(startX, startY) then
        if crossAX == 0 then
            crossAX = startX
            crossAY = startY
        elseif crossBX == 0 then
            crossBX = startX
            crossBY = startY
        end
    end
    if MapModel.IsInBlackZone(endX, endY) then
        if crossAX == 0 then
            crossAX = endX
            crossAY = endY
        elseif crossBX == 0 then
            crossBX = endX
            crossBY = endY
        end
    end

    -- 当只有一个最终交点有值，说明是路径线段有一个端点在黑土地边上，另一个端点在黑土地外
    if crossBX == 0 or crossAX == 0 then
        return 0
    end

    local disX = crossBX - crossAX
    local disY = crossBY - crossAY
    return math.sqrt(disX * disX + disY * disY)
end

-- 得到直线与黑土地的交点
function MapModel.GetIntersectionPoints(a, b)
    local points = {}

    local y0 = a * 574 + b
    if y0 >= 574 and y0 <= 626 then
        local point = {}
        point["x"] = 574
        point["y"] = y0
        table.insert(points, point)
    end

    local y1 = a * 626 + b
    if y1 >= 574 and y1 <= 626 then
        local point = {}
        point["x"] = 626
        point["y"] = y1
        table.insert(points, point)
    end

    local x0 = (574 - b) / a
    if x0 > 574 and x0 < 626 then
        local point = {}
        point["x"] = x0
        point["y"] = 574
        table.insert(points, point)
    end

    local x1 = (626 - b) / a
    if x1 > 574 and x1 < 626 then
        local point = {}
        point["x"] = x1
        point["y"] = 626
        table.insert(points, point)
    end

    return points
end

function MapModel.IsInBlackZone(x, y)
    if x >= 574 and x <= 626 and y >= 574 and y <= 626 then
        return true
    else
        return false
    end
end

--判断是否在黑土地不在王城
function MapModel.IsInKingCity(x, y)
    if math.abs(x - 600) <= 5 and math.abs(y - 600) <= 5 then
        return true
    else
        return false
    end
end

--是否越界
function MapModel.IsOutBorder(x, y)
    if x < mapOffset or x > 1200 - mapOffset or y < mapOffset or y > 1200 - mapOffset then
        return true
    end
    return false
end

--获取大地图行军时间估算值
function MapModel.GetMarchTime(startp, endp, speed)
    if speed <= 0 then
        return 0
    end

    local distance = MathUtil.GetDistance(startp.x - endp.x, startp.y - endp.y)
    local blackZoneDistance = MapModel.GetDistanceCrossBlackZone(startp.x, startp.y, endp.x, endp.y)

    local blackZoneTime = 0
    local blackZoneSpeed = speed * Global.BlackGroundSpeed
    if blackZoneSpeed > 0 then
        blackZoneTime = math.floor(Global.MarchSpeedParamK1 * (blackZoneDistance ^ Global.MarchSpeedParamK2) / blackZoneSpeed)
    end

    local normalDis = distance - blackZoneDistance
    return math.floor(Global.MarchSpeedParamK1 * (normalDis ^ Global.MarchSpeedParamK2) / speed) + blackZoneTime
end

----------活动相关数据--------------------------------------------------------------------------------
--刷新侦查野怪
function MapModel.IsCanScoutMonster(posNum, activityId)
    if not Model.MonsterVisitInfo[activityId] then
        return true
    end
    local info = Model.MonsterVisitInfo[activityId]

    if info.DailyTimesFull then
        return false
    else
        for k, v in pairs(info.VisitFullRecs) do
            if v == posNum then
                return false
            end
        end
    end
    return true

    -- int32 ActivityId = 1;
    -- bool DailyTimesFull = 2;
    -- repeated int32 VisitFullRecs = 3;
    -- int64 UpdateTime = 4;
end
--
function MapModel.AddMapInfo(posNum, info)
    MapInfo[posNum] = info
end

function MapModel.CheckIsMyFalcon(posNum)
    if not Model.MonsterVisitInfo or not Model.MonsterVisitInfo[WelfareModel.WelfarePageType.FALCON_ACTIVITY] then
        return false
    end
    local area = MapModel.GetArea(posNum)
    if area and (area.Category ~= Global.MapTypeBlank or area.IsFalcon) then
        return false
    end

    local posX, posY = MathUtil.GetCoordinate(posNum)
    for _, v in pairs(Model.MonsterVisitInfo[WelfareModel.WelfarePageType.FALCON_ACTIVITY].Avaliable or {}) do
        if not v.Banned and v.X == posX and v.Y == posY then
            local chunkInfo = {
                AllianceId = "",
                Category = Global.MapTypeMonster,
                ConfId = v.ConfId,
                DeadTime = 0,
                FortressId = 0,
                FortressIdList = "",
                Id = v.Id,
                Occupied = 0,
                ServerId = Model.Player.Server
            }
            return true, chunkInfo
        end
    end
end

return MapModel
