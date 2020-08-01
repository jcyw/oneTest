--[[
    author:{Temmie}
    time:2019-11-1
    function:{城墙Model}
]]
if WallModel then
    return WallModel
end
local WallModel = {}

function WallModel.GetWallData()
    return Model.GetMap(ModelType.Wall)
end

-- 城墙是否满耐久
function WallModel.IsDurableMax()
    local cur = WallModel.GetCurDurable()
    local data = WallModel.GetWallData()
    return cur >= data.MaxDurable
end

-- 获取城墙当前耐久
function WallModel.GetCurDurable()
    local data = WallModel.GetWallData()
    local nowDurable = data.Durable - math.ceil((Tool.Time() - data.RefreshAt) / Global.WallBurningSpeedNormal)
    if not data.IsOnFire then
        nowDurable = data.Durable
    end
    return nowDurable
end

return WallModel