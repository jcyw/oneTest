--[[    Author: songzeming,maxiaolong
    Function: 公用模板 跳转到指定界面并做相关操作
]]
if TurnModel then
    return TurnModel
end

TurnModel = {}
TurnModel.WorldMapPos = {}
local BuildModel = import("Model/BuildModel")
local UIType = _G.GD.GameEnum.UIType
local WorldMap = import("UI/WorldMap/WorldMap")
local WelfareModel = import("Model/WelfareModel")
local CheckValidModel = import("Model/Common/CheckValidModel")
local GD = _G.GD
local GlobalVars = GlobalVars

--跳转到指挥中心
function TurnModel.BuildCenter(flag, reset, cb)
    if reset then
        ScrollModel.InitMapData()
    end
    ScrollModel.MoveBuild(Global.BuildingCenter, flag)
    ScrollModel.SetCb(cb)
end

--进入主城操作
function TurnModel.EnterMyCityFunc(cb)
    if not GlobalVars.IsInCity then
        Event.Broadcast(
            EventDefines.UIEnterMyCity,
            function()
                --TODO如果是有触发引导缓存则打断
                if GD.TriggerGuideAgent.CityHaveStashTriggerJudge() then
                    Event.Broadcast(EventDefines.CloseGuide)
                    return
                end
                if cb then
                    cb()
                end
            end
        )
    else
        if cb then
            cb()
        end
    end
end

--[[
    跳转到指定建筑并打开功能列表
    building可不传(对于外城confId相同的建筑必须要传,否则不会跳到指定的建筑)
]]
function TurnModel.BuildFuncDetail(confId, building, isAnime)
    Event.Broadcast(EventDefines.MoveMapEvent, false)
    local cb = function()
        Event.Broadcast(EventDefines.MoveMapEvent, true)
    end
    TurnModel.EnterMyCityFunc(
        function()
            Event.Broadcast(EventDefines.UICityBuildTurn, confId, building, isAnime)
            ScrollModel.SetCb(cb)
        end
    )
end

--跳转到建筑建造位置
function TurnModel.BuildTurnCreatePos(confId)
    TurnModel.EnterMyCityFunc(
        function()
            Event.Broadcast(EventDefines.UICityTurnBuildCreate, nil, confId, true)
        end
    )
end

--跳转到地块解锁区域
function TurnModel.MapLockPiece(pieceId)
    GlobalVars.IsJumpGuide = true
    TurnModel.EnterMyCityFunc(
        function()
            Event.Broadcast(EventDefines.UIMapTurnLockPiece, pieceId)
        end
    )
end

--根据建筑ConfId跳转到地图块并返回地图块
function TurnModel.TurnMapPiece(confId, func, cb, isMove)
    TurnModel.EnterMyCityFunc(
        function()
            -- print("confid--------------:",confId)
            local pos = BuildModel.GetCreatPos(confId)
            if not pos then
                if func then
                    func(nil)
                end
                return
            end
            -- print("pos---------------:",table.inspect(pos))
            local piece = CityMapModel.GetMapPiece(pos)
            if not piece then
                return
            end
            if piece:GetPieceUnlock() then
                if isMove then
                    if confId == Global.BuildingBridge then
                        ScrollModel.Move(piece.x + BuildType.OFFSET_BRIDGE.x, piece.y + BuildType.OFFSET_BRIDGE.y, true)
                    else
                        ScrollModel.Move(piece.x, piece.y, true)
                    end
                else
                    ScrollModel.MoveScale(piece, confId, nil, true)
                end
                ScrollModel.SetCb(cb)
                if func then
                    func(piece)
                end
            else
                TurnModel.MapLockPiece()
            end
        end
    )
end

--跳转特殊建筑
function TurnModel.BuildTurnSpecial(confId)
    TurnModel.EnterMyCityFunc(
        function()
            Event.Broadcast(EventDefines.UICitySpecialBuildTurn, confId)
        end
    )
end

--使用建筑交换道具跳转
function TurnModel.BuildExgPos()
    UIMgr:ClosePopAndTopPanel()
    TurnModel.EnterMyCityFunc(
        function()
            Event.Broadcast(EventDefines.UICityBuildMove, BuildType.MOVE.Item)
        end
    )
end

function TurnModel.OpenWorldMap(val, isRes)
    Event.Broadcast(EventDefines.OpenWorldMap, val.X, val.Y)
    if not GlobalVars.IsInCity then
        TurnModel.WorldMapPos = {X = val.X, Y = val.Y}
        Event.Broadcast(EventDefines.DelayMask, false)
        Event.Broadcast(EventDefines.DelayMask, true)
        WorldMap.Instance():MoveToPoint(val.X, val.Y, false, true, true, isRes)
    else
        WorldMap.AddEventAfterMap(
            function()
                TurnModel.WorldMapPos = {X = val.X, Y = val.Y}
                Event.Broadcast(EventDefines.DelayMask, false)
                Event.Broadcast(EventDefines.DelayMask, true)
                WorldMap.Instance():MoveToPoint(val.X, val.Y, true, true, true, isRes)
            end,
            val.X,
            val.Y
        )
    end
end

function TurnModel.SetWorldTurnPos(isResouce)
    local posNum = 0
    if TurnModel.WorldMapPos ~= nil then
        local x = TurnModel.WorldMapPos.X
        local y = TurnModel.WorldMapPos.Y
        posNum = x * 10000 + y
    end
    if posNum ~= 0 then
        local info = {posNum = posNum, isRes = isResouce}
        Event.Broadcast(EventDefines.JumpTipEvent, nil, -1, UIType.WorldMapUI, info)
    end
end

--跳转到固定等级野怪
function TurnModel.MonstherTurnPos(mostherLevel)
    Net.MapInfos.SearchMonster(
        true,
        mostherLevel,
        function(val)
            -- print("val:" .. table.inspect(val))
            if val then
                TurnModel.OpenWorldMap(val, false)
            end
        end
    )
end

--击杀过最高等级野怪
function TurnModel.MonsterKilledTurnPos()
    Net.MapInfos.SearchMonster(
        true,
        0,
        function(val)
            if val then
                TurnModel.OpenWorldMap(val, false)
            end
        end
    )
end

--跳转资源矿不考虑等级
function TurnModel.MineTurnPos(resouId)
    Net.MapInfos.SearchMine(
        resouId,
        0,
        function(val)
            TurnModel.OpenWorldMap(val, true)
        end
    )
end

--跳转探险
function TurnModel:Explore()
    Net.MapInfos.SearchSecretBase(
        function(val)
            TurnModel.OpenWorldMap(val, true)
        end
    )
end

--跳转到世界地图某坐标
function TurnModel.WorldPos(x, y)
    UIMgr:ClosePopAndTopPanel()
    Event.Broadcast(EventDefines.OpenWorldMap, x, y)
end

--跳转到世界地图
function TurnModel.WorldMap()
    if GlobalVars.IsInCity then
        Event.Broadcast(EventDefines.OpenWorldMap)
    end
end

--调整到世界地图后回调
function TurnModel.WorldMapCallBack(cb)
    if GlobalVars.IsInCity then
        Event.Broadcast(EventDefines.OpenWorldMap, nil, nil, cb)
    else
        if cb then
            cb()
        end
    end
end

--跳转到世界地图搜索
function TurnModel.WorldMapSearch(index)
    Event.Broadcast(EventDefines.UISelectMapSearch, index)
    Event.Broadcast(EventDefines.UIWorldMapSerch)
end

--跳转到加入联盟界面
function TurnModel.UnionView()
    Event.Broadcast(EventDefines.UIAllianceOpen)
end

--跳转到联盟界面
function TurnModel.UnionMain()
    UIMgr:Open("UnionMain/UnionMain")
end

--跳转到联盟成员列表并打开某成员
function TurnModel.UnionMember()
    UIMgr:Open("UnionMember/UnionMember")
end

--跳转到联盟科技&捐献
function TurnModel.UnionTeck()
    UIMgr:OpenHideLastFalse("UnionScienceDonate")
end

--跳转到联盟帮助
function TurnModel.UnionHelp()
    UIMgr:Open("UnionMain/UnionHelp")
end

--接收联盟任务
function TurnModel.UnionTask()
    UIMgr:Open("UnionTask", 1)
end

--联盟协助任务
function TurnModel.UnionTaskHelp()
    UIMgr:Open("UnionTask", 3)
end

--跳转到邮件界面
function TurnModel.Chat()
    UIMgr:Open("Chat")
end

--跳转到指挥官界面
function TurnModel.PlayerDetails(playerId, closeCb)
    UIMgr:Close("PlayerDetails")
    if playerId and playerId ~= Model.Account.accountId then
        Net.UserInfo.GetUserInfo(
            playerId,
            function(msg)
                UIMgr:Open("PlayerDetails", playerId, closeCb)
            end
        )
    else
        UIMgr:Open("PlayerDetails", playerId, closeCb)
    end
end

--跳转到facebook
function TurnModel.Facebook()
    --TODO facebook链接
end

--跳转到充值
function TurnModel.RechargeMain()
    UIMgr:Open("RechargeMain")
end

--背包商店
function TurnModel.GoBackpackStore(storetag, itemtag)
    if not itemtag then
        itemtag = 0
    end
    UIMgr:Open("Backpack", {StoreTag = storetag, SubTag = itemtag})
end

--特价商城 SpecialMall
function TurnModel.GoSpecialMall()
    Event.Broadcast(EventDefines.UICitySpecialBuildTurn, Global.BuildingSpecialMall)
end

--跳转签到
function TurnModel.GoDayActivities(openType, func)
    TurnModel.EnterMyCityFunc(
        function()
            -- WelfareModel.WelfarePageType.DAILY_ATTENDANCE
            UIMgr:Open("WelfareMain", openType)
            Scheduler.ScheduleOnceFast(
                function()
                    Event.Broadcast(EventDefines.GuideDailyShow)
                    if func then
                        func()
                    end
                end,
                0.3
            )
        end
    )
end

function TurnModel:Meeting_Gift()
    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.CUMULATIVE_ATTENDANCE)
end

function TurnModel.GoUnionStore(id)
    if Model.Player.AllianceId == "" then
        TurnModel.UnionView()
    else
        Net.AllianceShop.Info(
            Model.Player.AllianceId,
            function(msg)
                UIMgr:Open("UnionShop", msg, id)
            end
        )
    end
end

--跳转训练建筑训练兵种 args = {ConfId, ArmyId, Amount}
function TurnModel.TrainArmy(building, args)
    UIMgr:Open("BuildRelated/BuildTrain", building, args)
end

--指挥官改名
function TurnModel.PlayerRename()
    UIMgr:Open("Rename", CheckValidModel.From.PlayerRename)
    PlayerDataModel:SetDayNotTip(PlayerDataEnum.PLAYER_RENAME)
    local ui = UIMgr:GetUI("PlayerDetails")
    if ui then
        ui:CheckEditNameCuePoint()
    end
end

--靶场
function TurnModel.Casion()
    if BuildModel.GetUnlockByConfId(Global.BuildingCasino) then
        Net.Casino.GetCasinoInfo(
            function(rsp)
                UIMgr:Close("RangeTurntable")
                UIMgr:Open("RangeTurntable", rsp)
            end
        )
    else
        TipUtil.TipById(50058)
    end
end

return TurnModel
