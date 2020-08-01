local UpgradeModel = {}

--获取建筑图片
function UpgradeModel.GetIcon(confId, level)
    level = level > 0 and level or 1
    local build = ConfigMgr.GetItem("configBuildingUpgrades", confId + level)
    if build then
        return build.building_model
    end
    return UpgradeModel.GetBaseIcon(confId)
end

--获取建筑基础图片
function UpgradeModel.GetBaseIcon(confId)
    local build = ConfigMgr.GetItem("configBuildings", confId)
    if build then
        return build.building_model
    end
end

function UpgradeModel.GetSmallIcon(confId, level)
    level = level > 0 and level or 1
    local build = ConfigMgr.GetItem("configBuildings", confId)
    if build then
        return build.building_icon_small
    end
end

return UpgradeModel
