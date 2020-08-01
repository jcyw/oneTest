--[[
    author:{zhanzhang}
    time:2019-09-26 20:15:55
    function:{预设颜色类型}
]]
if ColorType then
    return ColorType
end

ColorType = {
    --白色代表中立
    White = CS.UnityEngine.Color(1, 1, 1, 1),
    --蓝色代表盟友
    Blue = CS.UnityEngine.Color(98 / 255, 151 / 255, 215 / 255, 1),
    --红色代表敌人
    Red = CS.UnityEngine.Color(210 / 255, 115 / 255, 82 / 255, 1),
    --黄色代表自己
    Yellow = CS.UnityEngine.Color(255 / 255, 229 / 255, 158 / 255, 1)
}

return ColorType
