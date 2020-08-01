--[[
    Author: songzeming
    Function: 巢穴建筑
]]
local BuildNest = {}

local BuildModel = import("Model/BuildModel")
local TrainModel = import("Model/TrainModel")

local GodzillaNode = nil
local GodzillaObject = nil
local GodzillaInjured = false
local GodzillaLevel = nil
local GodzillaLoading = false
local KingkongNode = nil
local KingkongObject = nil
local KingkongInjured = false
local KingkongLevel = nil
local KingkongLoading = false

--格式化路径
local function GET_PATH(path, index, kind)
    local sub = ""
    if index < 10 then
        sub = "0" .. index
    else
        sub = index
    end
    return path .. "t" .. index .. "/" .. kind .. sub .. "_anim"
end
--播放巨兽动画
local function PlayMonsterAnim(monsterId)
    if monsterId == Global.BeastGodzilla then
        --哥斯拉
        if GodzillaNode then
            local anim = GodzillaObject:GetComponent("SkeletonAnimation")
            anim:ClearState()
            anim.state:SetAnimation(0, GodzillaInjured and "die" or "stand", true)
        end
    elseif monsterId == Global.BeastKingkong then
        --金刚
        if KingkongNode then
            local anim = KingkongObject:GetComponent("SkeletonAnimation")
            anim:ClearState()
            anim.state:SetAnimation(0, KingkongInjured and "die" or "stand", true)
        end
    end
end
--播放巨兽点击动画
local function PlayMonsterClickAnim(monsterId)
    if monsterId == Global.BeastGodzilla then
        --哥斯拉
        if not GodzillaInjured and GodzillaNode then
            local anim = GodzillaObject:GetComponent("SkeletonAnimation")
            anim.state:SetAnimation(0, "show", false)
            anim.state:AddAnimation(0, GodzillaInjured and "die" or "stand", true, 0)
        end
    elseif monsterId == Global.BeastKingkong then
        --金刚
        if not KingkongInjured and KingkongNode then
            local anim = KingkongObject:GetComponent("SkeletonAnimation")
            anim.state:SetAnimation(0, "show", false)
            anim.state:AddAnimation(0, KingkongInjured and "die" or "stand", true, 0)
        end
    end
end
--播放巨兽受伤动画
function BuildNest.PlayMonsterInjuredAnim(monsterId, flag)
    if monsterId == Global.BeastGodzilla then
        --哥斯拉
        GodzillaInjured = flag
    elseif monsterId == Global.BeastKingkong then
        --金刚
        KingkongInjured = flag
    end
    PlayMonsterAnim(monsterId)
end
--加载哥斯拉、金刚动画
local function LoadMonster(confId, levelBeast)
    local isGodzilla = confId == Global.BuildingGodzilla
    local isKingkong = confId == Global.BuildingKingkong
    if isGodzilla then
        --哥斯拉
        if GodzillaLevel == levelBeast or GodzillaLoading then
            return
        end
        GodzillaLoading = true
        GodzillaLevel = levelBeast
        if GodzillaNode then
            GodzillaNode:Dispose()
            GodzillaNode = nil
        end
    elseif isKingkong then
        --金刚
        if KingkongLevel == levelBeast or KingkongLoading then
            return
        end
        KingkongLoading = true
        KingkongLevel = levelBeast
        if KingkongNode then
            KingkongNode:Dispose()
            KingkongNode = nil
        end
    end

    local node = UIMgr:CreateObject("Effect", "EmptyNode")
    node.sortingOrder = CityType.CITY_MAP_SORTINGORDER.Nest
    node:SetTouchable(true)
    CityMapModel.GetCityMap():AddChild(node)

    if isGodzilla then
        --哥斯拉
        node.xy = Vector2(BuildType.OFFSET_BUILD_GODZILLA.x - 100, BuildType.OFFSET_BUILD_GODZILLA.y - 320)
        node.size = Vector2(300, 280)
    elseif isKingkong then
        --金刚
        node.xy = Vector2(BuildType.OFFSET_BUILD_KINGKONG.x - 100, BuildType.OFFSET_BUILD_KINGKONG.y - 300)
        node.size = Vector2(300, 280)
    end

    local scale = 100 * (levelBeast * 0.05 + 1)
    local function play_func(prefab)
        local object = GameObject.Instantiate(prefab)
        object.transform.localScale = Vector3(scale, scale, scale)
        object.transform.localPosition = Vector3(120, -200, 0)
        node:GetGGraph():SetNativeObject(GoWrapper(object))
        local monsterId = Global.BeastGodzilla
        if isGodzilla then
            GodzillaLoading = false
            GodzillaObject = object
            GodzillaNode = node
            monsterId = Global.BeastGodzilla
        else
            KingkongLoading = false
            KingkongObject = object
            KingkongNode = node
            monsterId = Global.BeastKingkong
        end
        node:ClickCallback(
            function()
                local buildObj = BuildModel.FindByConfId(confId)
                local itemBuild = BuildModel.GetObject(buildObj.Id)
                itemBuild:BuildClick()
                PlayMonsterClickAnim(monsterId)
                WeatherModel.CheckWeatherRain()
            end
        )
        PlayMonsterAnim(monsterId)
    end
    local kind_path = isGodzilla and "godzilla/" or "kingkong/"
    local kind = isGodzilla and "gsl_t" or "jg_t"
    if levelBeast == 1 then
        --本地加载
        CSCoroutine.Start(
            function()
                local path = GET_PATH("prefabs/spine/monster/" .. kind_path, levelBeast, kind)
                coroutine.yield(ResMgr.Instance:LoadPrefab(path))
                local prefab = ResMgr.Instance:GetPrefab(path)
                play_func(prefab)
            end
        )
    else
        --动态资源加载
        local name = kind .. Tool.FormateNumberZero(levelBeast) .. "_anim"
        DynamicRes.GetPrefab("monster_spine/" .. kind_path .. "t" .. levelBeast, name, play_func)
    end
end

-- 检查巢穴是否解锁
function BuildNest.CheckNestUnlock(confId)
    local b1 = BuildModel.FindByConfId(confId)
    local itemBuild = BuildModel.GetObject(b1.Id)
    if confId == Global.BuildingKingkong then
        if Model.Player.isUnlockKingkong then
            if itemBuild and itemBuild._itemLock then
                itemBuild._itemLock:RemoveFromParent()
                itemBuild._itemLock = nil
            end
        else
            if itemBuild then
                itemBuild:GetLockCmpt()
            end
        end
    end
    if b1.Level > 0 then
        BuildNest.ShowBeast(confId)
        return
    end
    if itemBuild then
        local bConf = ConfigMgr.GetItem("configBuildingUpgrades", b1.ConfId + b1.Level + 1)
        local condition = bConf.condition[1]
        local b2 = BuildModel.FindByConfId(condition.confId)
        itemBuild:GetLockCmpt()
        if b2 and b2.Level >= condition.level then
            if itemBuild._itemLock then
                itemBuild._itemLock:SetStateUnlock()
                itemBuild._itemLock._anim:Play() 
            end
        end
        -- itemBuild._btnIcon:GetChild("touch").alpha = 0.5 --显示框框
    end
end

-- 巢穴解锁成功
function BuildNest.NestUnlock(confId)
    local building = BuildModel.FindByConfId(confId)
    local itemBuild = BuildModel.GetObject(building.Id)
    if itemBuild._itemLock then
        itemBuild._itemLock:RemoveFromParent()
        itemBuild._itemLock = nil
    end

    --屏幕震动
    Event.Broadcast(EventDefines.Mask, true)
    local _middle = CityMapModel.GetCityMiddle()
    local anim = _middle:GetTransition("shake")
    anim:Play(
        function()
            BuildNest.ShowBeast(confId)
            BuildModel.UpgradePrompt()
        end
    )

    NodePool.Init(NodePool.KeyType.NestCloudEffect, "Effect", "EffectNode")
    local effect = NodePool.Get(NodePool.KeyType.NestCloudEffect)
    effect.sortingOrder = 10
    if confId == Global.BuildingGodzilla then
        --哥斯拉
        effect.xy = Vector2(-20, -300)
    else
        --金刚
        effect.xy = Vector2(-20, -160)
        itemBuild._btnIcon:GetChild("text1").visible = false
        itemBuild._btnIcon:GetChild("text2").visible = false
        itemBuild._btnIcon:GetChild("box").visible = false
    end
    itemBuild:AddChild(effect)
    effect:InitNormal()
    effect:PlayEffectSingle(
        "effects/citymap/monstersmoke/prefab/effect_jushou_smoke",
        function()
            NodePool.Set(NodePool.KeyType.NestCloudEffect, effect)
        end,
        Vector3(150, 150, 150)
    )
end

--显示巨兽 哥斯拉、金刚
function BuildNest.ShowBeast(confId)
    if not BuildModel.CheckBuildNestUnlock(confId) then
        Log.Debug("巨兽解锁 confId: {0}", confId)
        return
    end
    local building = BuildModel.FindByConfId(confId)
    local itemBuild = BuildModel.GetObject(building.Id)
    if not itemBuild then
        return
    end
    itemBuild._levelCmpt.visible = true
    itemBuild._levelCmpt:SetBuildLevel(building.Level)

    --获取巨兽等级
    local levelBeast = 1
    local arm = TrainModel.GetArm(confId)
    local baseId = arm.base_level
    for k = 1, arm.amount do
        local armId = baseId + k - 1
        local lv = TrainModel.GetLevelById(armId)
        if building.Level > lv then
            levelBeast = k
        elseif building.Level == lv then
            levelBeast = k
            break
        else
            break
        end
    end
    LoadMonster(confId, levelBeast)
    Event.Broadcast(EventDefines.Mask, false)
end

return BuildNest
