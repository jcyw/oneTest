--[[
    Author: songzeming
    Function: 内城地图 滑动
]]
if ScrollModel then
    return ScrollModel
end
ScrollModel = {}

ScrollModel.MoveDir = false

local BuildModel = import("Model/BuildModel")

local isInit = false
local Middle = nil
local isShowLog = false

function ScrollModel.Init(middle)
    Middle = middle
    isInit = true
end

function ScrollModel.InitMapData()
    Middle:InitMapData()
end

--[[
    移动到指定位置(不缩放)
    pos：移动位置
    flag：是否播放移动动画
]]
function ScrollModel.Move(x, y, flag)
    if isShowLog then
         Log.Info("----------- >>> Move")
    end
    Middle:MoveMap(x, y, flag)
end

--[[
    缩放
    flag：是否缩放
    buildPos：建筑位置
]]
function ScrollModel.Scale(buildPos, anim)
    if isShowLog then
         Log.Info("----------- >>> Scale buildPos:{0}, anim:{1}", buildPos, anim)
    end
    if not isInit then
        return
    end
    if buildPos then
        Middle:OnMapScale(buildPos, anim)
    else
        Middle:OnCancelScale(anim)
    end
end

--[[
    移动到指定位置且缩放
    piece：地块或建筑
    confId：是否是指挥中心
    scale：缩放大小
]]
function ScrollModel.MoveScale(piece, confId, scale, isAnime)
    if isShowLog then
         Log.Info("----------- >>> MoveScale")
    end
    if not scale then
        scale = Global.BaseGuideVisualAngle
    end
    Middle:MoveScaleMap(piece, scale, confId, isAnime)
end

--[[
    移动到建筑
    confId：建筑ConfId
    flag：是否播放移动动画
]]
function ScrollModel.MoveBuild(confId, flag)
    if isShowLog then
         Log.Info("----------- >>> MoveBuild")
    end
    local build = BuildModel.FindByConfId(confId)
    local item = BuildModel.GetObject(build.Id)
    if confId == Global.BuildingCenter then
        --指挥中心
        ScrollModel.Move(item.x + BuildType.OFFSET_CENTER.x, item.y + BuildType.OFFSET_CENTER.y, flag)
    elseif confId == Global.BuildingWall then
        --城墙
        ScrollModel.Move(item.x + BuildType.OFFSET_WALL.x, item.y + BuildType.OFFSET_WALL.y, flag)
    elseif confId == Global.BuildingBridge then
        --桥头建筑（在线领奖）
        ScrollModel.Move(item.x + BuildType.OFFSET_BRIDGE.x, item.y + BuildType.OFFSET_BRIDGE.y, flag)
    elseif confId == Global.BuildingGodzilla then
        --巢穴 哥斯拉
        ScrollModel.Move(item.x + BuildType.OFFSET_GODZILLA.x, item.y + BuildType.OFFSET_GODZILLA.y, flag)
    elseif confId == Global.BuildingKingkong then
        --巢穴 金刚
        ScrollModel.Move(item.x + BuildType.OFFSET_KINGKONG.x, item.y + BuildType.OFFSET_KINGKONG.y, flag)
    else
        ScrollModel.Move(item.x, item.y, flag)
    end
end

--建筑创建和建筑升级左右移动 dir -1向左 1向右
function ScrollModel.LRMove(dir, flag)
    if isShowLog then
         Log.Info("建筑创建和建筑升级左右移动 dir:{0},  flag:{1}", dir, flag)
    end
    local ratio = -6
    if dir == -1 then
        --创建跳转升级
        ScrollModel.MoveDir = true
        Middle.scrollPane:ScrollLeft(ratio, flag)
    elseif dir == 1 then
        --升级回到创建
        ScrollModel.MoveDir = false
        Middle.scrollPane:ScrollRight(ratio, flag)
    end
end

--是否在缩放中
function ScrollModel.GetScaling()
    if Middle then
        return Middle:GetScaling()
    else
        return false
    end
end

function ScrollModel.SetScaling(flag)
    if isShowLog then
         Log.Info("----------- >>> SetScaling flag: {0}", flag)
    end
    Middle:SetScaling(flag)
end

function ScrollModel.GetMoving()
    return Middle:GetMoving()
end

--是否放弃关闭界面缩放
function ScrollModel.GiveUpCloseScale()
    if isShowLog then
         Log.Info("----------- >>> GiveUpCloseScale")
    end
    Middle:GiveUpCloseScale()
end

function ScrollModel.SetWhetherMoveScale(flag)
    if isShowLog then
         Log.Info("----------- >>> SetWhetherMoveScale flag: {0}", flag)
    end
    if Middle then
        Middle:SetWhetherMoveScale(flag)
    end
end
function ScrollModel.GetWhetherMoveScale()
    return Middle:GetWhetherMoveScale()
end
function ScrollModel.GetLastScalePiece()
    return Middle:GetLastScalePiece()
end

function ScrollModel.ForceStop()
    if isShowLog then
         Log.Info("----------- >>> ForceStop")
    end
    Middle:ForceStop()
end

function ScrollModel.SetLastScale(pos)
    if isShowLog then
        Log.Info("----------- >>> SetLastScale pos: {0}", pos)
    end
    Middle:SetLastScale(pos)
end

function ScrollModel.CenterMoveScale()
    if isShowLog then
        Log.Info("----------- >>> CenterMoveScale")
    end
    Middle:CenterMoveScale()
end

--移动完成或者缩放完成cb
function ScrollModel.SetCb(cb)
    if isShowLog then
        Log.Info("----------- >>> SetCb")
    end
    if cb then
        Middle:SetCb(cb)
    end
end

function ScrollModel.RefreshMap()
    Middle:RefreshMap()
end

return ScrollModel
