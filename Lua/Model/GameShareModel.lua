--[[
    author:{zhanzhang}
    time:2019-09-07 11:41:54
    function:{游戏内部分享Model}
]]
local GameShareModel = {}

--分享坐标到世界
function GameShareModel.ShareCoordinateToWorld()
    -- Net.Bookmarks.Share(Global.CoordinateShareWorld, category, confId, x, y, cb)
end
 --

--[[分享坐标到联盟频道
--categroy --0为一般分享--1为野怪
]] 
local _isShare = false
function GameShareModel.ShareCoordinateToUnion(channel, category, confId, posX, posY, cb)
    if Model.UserAllianceInfo.AllianceId == "" then
        TipUtil.TipById(50054)
        return
    end
    if not cb then
        cb = function()
            TipUtil.TipById(50055)
        end
    end
    if _isShare then
        TipUtil.TipById(50294)
        return
    end
    local _fun = function()
        _isShare = false
    end
    Scheduler.ScheduleOnce(_fun, Global.ChatSpeechInterval)
    _isShare = true

    Net.Bookmarks.Share(Global.CoordinateShareAlliance, category, confId, posX, posY, cb)
end

function GameShareModel.ShareCoordinateToPerson()
    -- Net.Bookmarks.Share(Global.CoordinateSharePersonal, category, confId, x, y, cb)
end

return GameShareModel
