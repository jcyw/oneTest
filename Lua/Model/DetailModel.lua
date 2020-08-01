local DetailModel = {}

-- 获取实时数量
function DetailModel.GetType(confId)
    local detail = BuildType.DETAIL.List
    for _, v in pairs(detail) do
        for kk, vv in pairs(v.ConfIds) do
            if confId == Global[vv] then
                local reData = {
                    Col = v.Col,
                    Title = v.Title[kk]
                }
                return reData
            end
        end
    end
    return
end

-- 通过配置ID获取配置-升级
function DetailModel.GetUpConf(confId)
    return ConfigMgr.GetItem("configBuildingUpgrades", confId)
end

-- 通过配置ID获取配置-资源
function DetailModel.GetResConf(confId)
    return ConfigMgr.GetItem("configResBuilds", confId)
end

-- 通过配置ID获取配置-指挥中心
function DetailModel.GetCenterConf(confId)
    return ConfigMgr.GetItem("configBases", confId)
end

-- 通过配置ID获取配置-营房(帐篷)
function DetailModel.GetMarchTentConf(confId)
    return ConfigMgr.GetItem("configMarchTents", confId)
end

-- 通过配置ID获取配置-物资仓库
function DetailModel.GetVaultConf(confId)
    return ConfigMgr.GetItem("configVaults", confId)
end

-- 通过配置ID获取配置-战区医院
function DetailModel.GetHospitalConf(confId)
    return ConfigMgr.GetItem("configHospitals", confId)
end

-- 通过配置ID获取配置-城墙
function DetailModel.GetWallConf(confId)
    return ConfigMgr.GetItem("configWalls", confId)
end

-- 通过配置ID获取配置-作战指挥部
function DetailModel.GetDillGroundConf(confId)
    return ConfigMgr.GetItem("configDillGrounds", confId)
end

-- 通过配置ID获取配置-军需站
function DetailModel.GetMilitarySupplyConf(confId)
    return ConfigMgr.GetItem("configMilitarySupplys", confId)
end

-- 通过配置ID获取配置-军需站
function DetailModel.GetRadarConf(confId)
    return ConfigMgr.GetItem("configRadars", confId)
end

-- 通过配置ID获取配置-联合指挥部
function DetailModel.GetJointCommandConf(confId)
    return ConfigMgr.GetItem("configJointCommands", confId)
end

-- 通过配置ID获取配置-物流中转站
function DetailModel.GetTransferStationConf(confId)
    return ConfigMgr.GetItem("configTransferStations", confId)
end

-- 通过配置ID获取配置-联盟大厦
function DetailModel.GetUnionBuildingConf(confId)
    return ConfigMgr.GetItem("configUnionBuildings", confId)
end

-- 通过配置ID获取配置-警戒塔
function DetailModel.GetTowerConf(confId)
    return ConfigMgr.GetItem("configGuardTowers", confId)
end

-- 通过配置ID获取配置-巨兽医院
function DetailModel.GetBeastHospitalConf(confId)
    return ConfigMgr.GetItem("configBeastHospitals", confId)
end

-- 通过配置ID获取配置-装备制造工厂
function DetailModel.GetEquipFactoryConf(confId)
    return ConfigMgr.GetItem("configEquipFactorys", confId)
end

return DetailModel
