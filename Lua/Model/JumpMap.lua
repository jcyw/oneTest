--[[
    Function:跳转适配

]]
local JumpMap = {}
local MapData = import("Model/JumpMapModel")
local MainTaskModel = import("Model/TaskModel")
local GD = _G.GD
local map = nil
local GlobalVars = GlobalVars

function JumpMap:Init()
    map = MapData:MapInit()
end

--如果嵌套计时器可能会出现问题，isNoDelay=true
function JumpMap:JumpSimple(params, otherId, isNoDelay, otherParams)
    self:SetMaskTime(params, true)
    if self["Jump" .. params] then
        --防止延时中多次点击
        return
    end
    self["Jump" .. params] = true
    local func = function()
        self["Jump" .. params] = false
        if map[params] then
            MapData:SetJumpId(params)
            map[params](otherId, otherParams)
        else
            Log.Info("No Find Same JumpIndex")
        end
    end

    if isNoDelay then
        func()
    else
        Scheduler.ScheduleOnceFast(
            function()
                func()
            end,
            0.1
        )
    end
end

local maskTime = 0
--切换内外城时会屏蔽操作1秒
function JumpMap:SetMaskTime(jumpParam, isSimple)
    local isStartMask = false
    GlobalVars.IsJumpGuide = true
    local jumpId = 0
    if not isSimple then
        jumpId = jumpParam.jump
    else
        jumpId = jumpParam
    end
    if Tool.Equal(jumpId, 810600, 810700, 810701, 810800) then
        isStartMask = true
        maskTime = 8
    elseif not GlobalVars.IsInCity and not Tool.Equal(jumpId, 810600, 810700, 810701, 810800, 813000) then
        isStartMask = true
        maskTime = 1
    elseif GlobalVars.IsInCity and not Tool.Equal(jumpId, 810600, 810700, 810701, 810800, 813000, 812400, 812600) then
        isStartMask = true
        maskTime = 0.1
    end
    if isStartMask then
        Event.Broadcast(EventDefines.DelayMask, true)
        Scheduler.ScheduleOnceFast(
            function()
                Event.Broadcast(EventDefines.DelayMask, false)
            end,
            maskTime
        )
    end
end

--跳转接口:jumpParams={jump=810700,para=9414},finishParams可不填
function JumpMap:JumpTo(jumpParams, finishParams)
    GlobalVars.IsJumpGuide = true
    ScrollModel.SetScaling(false)
    if self["Jump" .. jumpParams.jump] then
        --防止延时中多次点击
        return
    end
    self["Jump" .. jumpParams.jump] = true
    self:SetMaskTime(jumpParams)
    Scheduler.ScheduleOnceFast(
        function()
            self["Jump" .. jumpParams.jump] = false
            local jumpId = jumpParams.jump
            if GlobalVars.IsInCity and jumpId == 810700 and jumpParams.para == 9400 and not GD.TriggerGuideAgent.IsFinishTrigger(13800) then
                Event.Broadcast(EventDefines.TriggerGuideJudge, _G.GD.GameEnum.TriggerType.MainType.ClickTask, 13800, 0)
                return
            end

            local buildId = jumpParams.para
            local building = jumpParams.para1
            if not finishParams then
                self.finishParams = nil
            else
                MapData:SetFinishParams(finishParams)
                self.finishParams = finishParams
            end
            self:AdapterJump(jumpId, buildId, building)
        end,
        0.1
    )
end

--跳转适配器
function JumpMap:AdapterJump(jumpId, buildId, building)
    local jumpIdStr = tonumber(jumpId)
    local buildIdStr = tonumber(buildId)
    if map[jumpIdStr] ~= nil then
        if buildId == 0 or not buildId then
            buildId = self:JumpNullBuildId(jumpId)
        end
        MapData:SetBuildId(buildId)
        MapData:SetJumpId(jumpId)
        map[jumpIdStr](buildId, building)
    else
        Log.Info("No Find Same JumpIndex")
    end
end

--跳转没有buildId的建筑
function JumpMap:JumpNullBuildId(jumpId)
    local buildId = 0
    if jumpId == 810400 then
        buildId = Global.BuildingHospital
    end
    return buildId
end

--跳转特殊建筑
function JumpMap:JumpSpecialTo(jumpConfig)
    local jumpId = jumpConfig.jump
    local buildId = jumpConfig.para
    map[jumpId](buildId)
end

--------------------------跳转商店页面，后期整合到上方接口
function JumpMap:GoFace(jumpId, ...)
    MapData[jumpId](...)
end

return JumpMap
