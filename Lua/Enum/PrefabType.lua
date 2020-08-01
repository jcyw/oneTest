--[[
    author:{zhanzhang}
    time:2020-03-15 24:40:24
    function:{预制枚举}
]]
if PrefabType then
    return PrefabType
end

PrefabType = {
    WorldMap = {
        fireStar = 100001,
        --	fireStar	游戏初始
        cityFire01 = 200001,
        --		游戏内城相关
        Empty = 300101, --大地图相关_行军动画
        MarchAnim_Scout = 300102,
        --大地图相关_行军动画
        MarchAnim_Mine = 300103, --大地图相关_行军动画
        MarchAnim_Tank = 300104, --大地图相关_行军动画
        MarchAnim_Chario = 300105, --大地图相关_行军动画
        MarchAnim_Plane = 300106,
        --大地图相关_行军动画
        MarchAnim_Truck = 300107,
        --大地图相关_行军动画
        MarchAnim_AISiege = 300108, --大地图相关_行军动画
        MarchAnim_Godzilla = 301101, --大地图相关_行军动画
        MarchAnim_Kingkong = 302101,
        --大地图相关_行军动画
        Map_BorderLine = 400001, --大地图相关_边界线
        MarchLineMat_My = 600001,
        --大地图相关
        MarchLineMat_Ally = 600002, --大地图相关
        MarchLineMat_Neutrality = 600003, --大地图相关
        MarchLineMat_Enemy = 600004, --	大地图相关
        MapBuildProtect_Blue = 800001, --大地图相关
        MapBuildProtect_Yellow = 800002, --大地图相关
        MapBuildProtect_purple = 800003 --大地图相关
    },
    WorldMapEffect = {
        MarchAIAttack = 900101
    }
}

return PrefabType
