--[[
    author:{zhanzhang}
    time:2019-11-19 15:07:59
    function:{大地图建筑类型}
]]
if WorldBuildType then
    return WorldBuildType
end

WorldBuildType = {
    --玩家主程
    MainCity = "MainCity", --4格
    --联盟堡垒
    UnionFortress = "UnionFortress", --4格
    --联盟防御塔
    UnionDefenceTower = "UnionDefenceTower", --1格
    --联盟仓库
    UnionStore = "UnionStore", --4格
    --联盟其他建筑
    OtherUnionBuild = "OtherUnionBuild", -- 4格
    --特殊，联盟迁城，只能前往固定坐标
    UnionGoLeader = "UnionGoLeader",

}

return WorldBuildType
