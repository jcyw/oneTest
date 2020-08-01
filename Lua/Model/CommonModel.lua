local CommonModel = {}

local BuffModel = import("Model/BuffModel")

local headCache = {}

--[[
    获取玩家头像
    node =  加载图片或者头像的节点 必传
    avatar = 头像 [可不传 则为自己头像]
    userId = 玩家userId [可不传 则为自己ID]
]]
function CommonModel.SetUserAvatar(node, avatar, userId)
    if not avatar then
        avatar = Model.Player.Avatar
    end

    local defaultAvatar = tonumber(avatar)
    if defaultAvatar then
        --系统默认头像
        local config = ConfigMgr.GetItem("configAvatars", defaultAvatar)
        if config and config.avatar then
            node.icon = UITool.GetIcon(config.avatar)
        end
    else
        --玩家自定义头像 url
        if avatar == "" then
            return
        end

        local id = userId and userId or Model.Account.accountId

        if headCache[avatar] then
            --多个组件同时请求相同头像时缓存组件等待头像获取成功
            table.insert(headCache[avatar], node)
        else
            headCache[avatar] = {}
            table.insert(headCache[avatar], node)

            --预处理
            local needRefresh = true
            local json = Util.GetPlayerData("AvatarChangeTime")
            local data = {}
            if json ~= "" then
                data = JSON.decode(json)
            end
            local headData = StringUtil.Split(avatar, "_")
            if #headData >= 2 then
                --获取头像所属玩家
                if headData[1] ~= id then
                    id = headData[1]
                end
                --是否需要更新头像
                if data[id] and tonumber(data[id]) >= tonumber(headData[2]) then
                    needRefresh = false     
                end
            end

            --获取头像
            CSCoroutine.Start(
                function()
                    coroutine.yield(
                        ResMgr.Instance:DownloadImage(
                            avatar,
                            needRefresh,
                            Model.Account.gate .. "/avatar/avatar?id=" .. id,
                            function(key, newTime, texture)
                                --保存新的头像更新数据
                                data[id] = newTime
                                local newJson = JSON.encode(data)
                                Util.SetPlayerData("AvatarChangeTime", newJson)

                                --将头像设置给等待组件
                                if headCache[key] then
                                    for _, v in pairs(headCache[key]) do
                                        v.texture = texture
                                    end
                                    headCache[key] = nil
                                end
                            end
                        )
                    )
                end
            )
        end
    end
end

--获取建筑免费时间
function CommonModel.FreeTime()
    local time = Global.FreeBuildTime --基础免费时间
    if Model.Player.VipActivated then
        --激活Vip 可增加免费时长
        local conf = ConfigMgr.GetItem("configVips", Model.Player.VipLevel)
        local vipAddTime = 0
        for _, v in pairs(conf.vip_function) do
            if v.vip_right == Global.QuickBuildingTime then
                vipAddTime = v.num
                break
            end
        end
        time = time + vipAddTime
    end
    return time
end

--获取资源建筑对应的 资源类型、资源增产道具Id、资源增产系数
function CommonModel.GetResParameter(confId)
    if confId == Global.BuildingStone then
        --稀土工厂
        return {
            category = Global.ResStone, --稀土
            itemId = GlobalItem.ItemResEarthUp,
             -- 204025, --稀土产量翻倍24小时
            coefficient = Global.ProductivityRiseMineral --稀土增产系数
        }
    end
    if confId == Global.BuildingWood then
        --钢铁厂
        return {
            category = Global.ResWood, --钢铁
            itemId = GlobalItem.ItemResIronUp,
             -- 204024, --钢铁产量翻倍24小时
            coefficient = Global.ProductivityRiseIron --钢铁增产系数
        }
    end
    if confId == Global.BuildingIron then
        --炼制工厂
        return {
            category = Global.ResIron, --石油
            itemId = GlobalItem.ItemResOilUp,
             -- 204023, --石油产量翻倍24小时
            coefficient = Global.ProductivityRiseOil --石油增产系数
        }
    end
    if confId == Global.BuildingFood then
        --食品厂
        return {
            category = Global.ResFood, --粮食
            itemId = GlobalItem.ItemResFoodUp,
             -- 204022, --食品产量翻倍24小时
            coefficient = Global.ProductivityRiseFood --食品增产系数
        }
    end
end

--根据资源产量翻倍道具配置id获取对应资源建筑配置id
function CommonModel.GetBuildingConfIdByResUpItem(confId)
    if confId == GlobalItem.ItemResEarthUp then
        return Global.BuildingStone
    elseif confId == GlobalItem.ItemResIronUp then
        return Global.BuildingWood
    elseif confId == GlobalItem.ItemResOilUp then
        return Global.BuildingIron
    elseif confId == GlobalItem.ItemResFoodUp then
        return Global.BuildingFood
    end
end

-- 检查建筑队列是否有空闲队列
function CommonModel.CheckFreeBuilder()
    local c = 0
    for _, v in pairs(Model.Builders) do
        if v.IsWorking then
            c = c + 1
        end
    end
    if c == 0 then
        return true
    elseif c == 1 then
        local expire = Model.Builders[BuildType.QUEUE.Charge].ExpireAt
        local islock = expire > 0 and expire - Tool.Time() <= 0
        if islock then
            return false --金币队列未解锁
        else
            return true
        end
    elseif c == 2 then
        return false
    end
end

--[[
    金币使用弹窗提示是否显示弹窗逻辑
    当玩家在立即完成某些事件或对处于队列状态下的建筑立即加速时，玩家拥有金币超过[20,000]且消耗的金币低于阈值，则不弹出任何提示
    阈值 = min（int（玩家拥有的金币 *5%），5000）
]]
function CommonModel.IsShowGoldPrompt(gold, tipType)
    if Tool.Equal(tipType, TipType.TYPE.OnlineSpecialShop, TipType.TYPE.OnlineSupply) then
        --每次上线弹窗提示
        if TipType.NOTREMIND[tipType] then
            --第一次登陆弹窗
            return true
        else
            return false
        end
    else
        if not gold then
            return true
        end
        --满足条件弹窗提示
        if gold > Global.ExpendDiamondThreshold then
            --消耗钻石超过5k钻石弹窗
            return true
        else
            if TipType.NOTREMIND[tipType] then
                --第一次登陆弹窗
                --玩家拥有钻石是否超过2W
                local isMore = Model.Player.Gem > Global.HaveDiamondThreshold
                --消耗值不超过2%
                local isExpend = gold < Model.Player.Gem * (Global.ExpendDiamondRatio / 10000)
                if isMore and isExpend then
                    return false
                else
                    return true
                end
            else
                return false
            end
        end
    end
end

--是否是资源
function CommonModel.IsResByCategory(category)
    return Tool.Equal(category, Global.ResWood, Global.ResStone, Global.ResIron, Global.ResFood)
end

--是否时资源建筑
function CommonModel.IsResBuild(confId)
    return Tool.Equal(confId, Global.BuildingStone, Global.BuildingWood, Global.BuildingIron, Global.BuildingFood)
end

--是否是训练工厂 不包含安保工厂
function CommonModel.IsTrainFactory(confId)
    return Tool.Equal(confId, Global.BuildingTankFactory, Global.BuildingHelicopterFactory, Global.BuildingWarFactory, Global.BuildingVehicleFactory)
end

--是否是训练工厂或者安保工厂
function CommonModel.IsAllTrainFactory(confId)
    return CommonModel.IsTrainFactory(confId) or Tool.Equal(confId, Global.BuildingSecurityFactory)
end

--是否是训练工厂、安保工厂 或者 巢穴(哥斯拉、金刚)
function CommonModel.IsAllTrainFactoryOrNest(confId)
    return CommonModel.IsTrainFactory(confId) or Tool.Equal(confId, Global.BuildingSecurityFactory) or CommonModel.IsNest(confId)
end

--是否是巢穴
function CommonModel.IsNest(confId)
    return Tool.Equal(confId, Global.BuildingGodzilla, Global.BuildingKingkong)
end

--是否是靶场（军官俱乐部）
function CommonModel.IsCasino(confId)
    return Tool.Equal(confId, Global.BuildingCasino)
end

-- 获取资源建筑数量和暂存上限
local maxDuration = 3600 * 10
function CommonModel.GetResBuildAmountAndStorage(resBuild)
    local now = Tool.Time()
    local duration = math.min(now - resBuild.UpdatedAt, maxDuration)
    -- 计算产量/小时
    local incr = math.floor(resBuild.Produce * duration / 3600)
    -- 叠加双倍
    if resBuild.BuffExpireAt > resBuild.UpdatedAt then
        local doubleDuration = math.min(resBuild.BuffExpireAt, now) - resBuild.UpdatedAt
        incr = math.floor(incr + resBuild.Produce * resBuild.BuffRatio * doubleDuration / 3600)
    end
    local maxStorage = math.floor(incr + resBuild.Produce * (maxDuration - duration) / 3600)

    return math.min(resBuild.Storage + incr, maxStorage), maxStorage
end

-- 根据item的显示状况，检查列表里item上的特效是否显示
function CommonModel.CheckListItemEffectVisible(item, list)
    local pos = item:LocalToGlobal(Vector2.zero)
    local localpos = list:GlobalToLocal(pos)
    if localpos.y < -10 or localpos.y > (list.height - item.height) then
        return false
    else
        return true
    end
end

return CommonModel
