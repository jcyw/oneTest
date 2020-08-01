--[[
    Author: songzeming
    Function: 公用模板 动画
]]
if AnimationModel then
    return AnimationModel
end
AnimationModel = {}

local BuildModel = import("Model/BuildModel")

local RES_SINGLE_TOTAL = 12 --单个建筑最多生成动画个数
local RES_MOVE_SPEED = 1000 --动画移动速度
local RES_DEFAULT_SCALE = 1 --资源生成动画默认大小
local resAnimeObjList = {}
local Rondom = CS.System.Random
local RANDOM_RADIUS = 5 --随机圆的半径

--获取半径为5圈内的一个随机点
local function GetCirclePoint(random)
    local function randomValue(_min, _max)
        return random:NextDouble() * (_max - _min) + _min
    end

    local radin = randomValue(0, 2 * math.pi)
    local x = RANDOM_RADIUS * math.cos(radin)
    local y = RANDOM_RADIUS * math.sin(radin)
    return Vector2(x, y)
end

--收取科技图标
function AnimationModel.TechCollect(node,screenX,screenY,TechId)
    NodePool.Init(NodePool.KeyType.TechCollectAnim, "Common", "TechCollectAnim")
    local obj = NodePool.Get(NodePool.KeyType.TechCollectAnim)
    local posx, posy = MathUtil.ScreenRatio(screenX, screenY)
    obj:GetContext():setIcon(TechId)
    MainCity.ResourceAnimTarget:AddChild(obj)
    obj:SetXY(posx, posy)
    obj:SetScale(0.6, 0.6)
    local globalPos = node:LocalToGlobal(Vector2.zero)
    local startPos = {
        x = posx +20,
        y = posy +20
    }
    globalPos = {
        x = globalPos.x -20,
        y = globalPos.y -20
    }
    obj:TweenScale(Vector2(0.7, 0.7), 0.5):SetEase(EaseType.CubicOut)
    obj:GetContext():GtweenOnComplete(
        obj:TweenMove(startPos, 0.5):SetEase(EaseType.CubicOut),
        function()
            obj:TweenScale(Vector2(0.1, 0.1), 1.0):SetEase(EaseType.CubicOut)
            obj:GetContext():GtweenOnComplete(
                obj:TweenMove(globalPos, 1.0):SetEase(EaseType.CubicOut),
                function()
                    NodePool.Set(NodePool.KeyType.TechCollectAnim, obj)
                end
            )
        end
    )
end

--资源收取
function AnimationModel.ResCollect(node, category)
    NodePool.Init(NodePool.KeyType.ResCollectAnim, "Common", "ResCollectAnim")
    --随机种子
    local random = Rondom(1000)
    --第一次移动的时间
    local firstTime = 0.2
    for i = 1, RES_SINGLE_TOTAL do
        local obj = NodePool.Get(NodePool.KeyType.ResCollectAnim)
        table.insert(resAnimeObjList, obj)
        obj:GetController("Ctr").selectedPage = "c" .. category
        --节点原点
        local globalPos = node:LocalToGlobal(Vector2.zero)
        local posx, posy = MathUtil.ScreenRatio(globalPos.x, globalPos.y)
        --初始位置
        obj:SetXY(posx, posy)
        obj:SetScale(RES_DEFAULT_SCALE, RES_DEFAULT_SCALE)
        --第一次移动节点
        local vector = GetCirclePoint(random)
        local startPos = {
            x = posx + vector.x * 20,
            y = posy + vector.y * 20
        }
        --第二次移动节点
        local goalPos = {
            x = 180 + (CommonType.SORT_RESOURCES[category] - 1) * 130,
            y = 20
        }
        MainCity.ResourceAnimTarget:AddChild(obj)
        local time = MathUtil.GetDistance(globalPos.x - goalPos.x, globalPos.y - goalPos.y) / RES_MOVE_SPEED
        obj:GetContext():GtweenOnComplete(
            obj:TweenMove(startPos, firstTime):SetEase(EaseType.CubicOut),
            function()
                obj:TweenScale(Vector2(0.7, 0.7), time - i * 0.1):SetEase(EaseType.CircIn)
                obj:GetContext():GtweenOnComplete(
                    obj:TweenMove(goalPos, time - i * 0.1):SetEase(EaseType.CircIn),
                    function()
                        NodePool.Set(NodePool.KeyType.ResCollectAnim, obj)
                        obj:GetController("Ctr").selectedPage = "empty"
                        for k, v in ipairs(resAnimeObjList) do
                            if v and v == obj then
                                table.remove(resAnimeObjList, k)
                            end
                        end
                        --顶栏资源图标颤动
                        local icon = MainCity.ResourceAnimTarget:GetChild("_list"):GetChildAt(CommonType.SORT_RESOURCES[category] - 1):GetChild("_icon")
                        AnimationModel.ResIconPunch(icon)
                    end
                )
            end
        )
        obj:TweenScale({x = 1, y = 1}, time):SetEase(EaseType.QuadIn)
    end
end

--顶部资源icon图标震动
function AnimationModel.ResIconPunch(icon)
    MainCity.ResourceAnimTarget.parent:GtweenOnComplete(
        icon:TweenScale(Vector2(1.4, 1.4), 0.1),
        function()
            icon:TweenScale(Vector2(1, 1), 0.1)
        end
    )
end

function AnimationModel:StopResCollectAnima()
    for _, obj in ipairs(resAnimeObjList) do
        if obj then
            NodePool.Set(NodePool.KeyType.ResCollectAnim, obj)
            obj:GetController("Ctr").selectedPage = "empty"
        end
    end
    resAnimeObjList = {}
end

local RES_HARVEST_COUNT = 10
local RES_HARVEST_INTERVAL = 80
--主动技能资源丰收动画
function AnimationModel.ResHarvest()
    NodePool.Init(NodePool.KeyType.ResCollectAnim, "Common", "ResCollectAnim")
    for _, v in pairs(Model.Buildings) do
        local conf = BuildModel.GetConf(v.ConfId)
        if conf.category == Global.BuildingTypeRes then
            local buildObj = BuildModel.GetObject(v.Id)
            for i = 1, RES_HARVEST_COUNT do
                local obj = NodePool.Get(NodePool.KeyType.ResCollectAnim)
                local category = CommonModel.GetResParameter(v.ConfId).category
                obj:GetController("Ctr").selectedPage = "c" .. category
                buildObj._btnIcon:AddChild(obj)
                obj.x = buildObj._btnIcon.width / 2 + math.random(-RES_HARVEST_INTERVAL, RES_HARVEST_INTERVAL)
                obj.y = buildObj._btnIcon.height / 2 + math.random(-RES_HARVEST_INTERVAL, RES_HARVEST_INTERVAL)
                obj:GetContext():GtweenOnComplete(
                    obj:TweenMoveY(obj.y - math.random(50, 100), 0.2):SetEase(EaseType.QuadIn),
                    function()
                        obj:GetContext():GtweenOnComplete(
                            obj:TweenMoveY(obj.y + math.random(80, 120), 0.5):SetEase(EaseType.QuadOut),
                            function()
                                NodePool.Set(NodePool.KeyType.ResCollectAnim, obj)
                            end
                        )
                    end
                )
            end
        end
    end
end
--主动技能资源丰收特效
function AnimationModel:ResHarvestEffect()
    for _, v in pairs(Model.Buildings) do
        local conf = BuildModel.GetConf(v.ConfId)
        if conf.category == Global.BuildingTypeRes then
            local buildObj = BuildModel.GetObject(v.Id)
            local category = CommonModel.GetResParameter(v.ConfId).category
            local poolKey = NodePool.KeyType.ResHarvestEffect .. category
            NodePool.Init(poolKey, "Effect", "EffectNode")
            local effect = NodePool.Get(poolKey)
            buildObj._btnIcon:AddChild(effect)
            --关闭摆动动画
            buildObj:HarestAnim(false)
            effect.xy = Vector2(buildObj._btnIcon.width / 2, buildObj._btnIcon.height / 2 - 50)
            effect:InitNormal()
            local path = "effects/matcheffect/prefab/effect_use_skills_" .. category
            effect:PlayEffectSingle(
                path,
                function()
                    NodePool.Set(poolKey, effect)
                end,
                Vector3(0.8, 0.8, 0.8)
            )
            buildObj:ScheduleOnce(
                function()
                    buildObj:ResetHarest()
                end,
                2
            )
        end
    end
end

--战斗力升级特效
local PE_MOVE_TIME = 1.2
function AnimationModel.PlayerPowerEffect(powerNode, parentNode)
    NodePool.Init(NodePool.KeyType.PlayerPowerLightEffect, "Effect", "EffectNode")
    local _light = NodePool.Get(NodePool.KeyType.PlayerPowerLightEffect)
    _light.xy = Vector2(powerNode.x + powerNode.width / 3, powerNode.y + powerNode.height / 2)
    parentNode:AddChild(_light)
    _light:InitNormal()
    _light:PlayEffectSingle("effects/player/playerexppower/prefab/force")
    local goalPos = Vector2(375, 120)
    _light:GetContext():GtweenOnComplete(
        _light:TweenMove(goalPos, PE_MOVE_TIME):SetEase(EaseType.QuadIn),
        function()
            NodePool.Set(NodePool.KeyType.PlayerPowerLightEffect, _light)
        end
    )
end
--经验升级特效
function AnimationModel.PlayerExpEffect(expNode, parentNode)
    NodePool.Init(NodePool.KeyType.PlayerExpLightEffect, "Effect", "EffectNode")
    local _light = NodePool.Get(NodePool.KeyType.PlayerExpLightEffect)
    _light.xy = Vector2(expNode.x + expNode.width / 3, expNode.y + expNode.height / 2)
    parentNode:AddChild(_light)
    _light:InitNormal()
    _light:PlayEffectSingle("effects/player/playerexppower/prefab/exp")
    local goalPos = Vector2(100, 120)
    _light:GetContext():GtweenOnComplete(
        _light:TweenMove(goalPos, PE_MOVE_TIME):SetEase(EaseType.QuadIn),
        function()
            NodePool.Set(NodePool.KeyType.PlayerExpLightEffect, _light)
        end
    )
end

--礼包宝箱特效
function AnimationModel.GiftEffect(item, scalebehind, scalefront, poolKey, frontItem, behindItem, pos)
    AnimationModel.DisPoseGiftEffect(poolKey, frontItem, behindItem)
    local frontNode = item:GetChild("front")
    local behindNode = item:GetChild("behind")
    local key = NodePool.KeyType.GiftBoxEffect .. poolKey
    NodePool.Init(key, "Effect", "EffectNode")
    local front = NodePool.Get(key)
    local behind = NodePool.Get(key)
    frontNode:AddChild(front)
    behindNode:AddChild(behind)
    front:InitNormal()
    front:PlayEffectLoop("effects/recharge/purchasegift/prefab/effect_purchase_star", scalefront)
    behind:InitNormal()
    behind:PlayEffectLoop("effects/recharge/purchasegift/prefab/effect_purchase_gift", scalebehind)
    if pos then
        front.x = pos.x
        front.y = pos.y
        behind.x = pos.x
        behind.y = pos.y
    end
    return front, behind
end

--移除礼包特效
function AnimationModel.DisPoseGiftEffect(poolKey, front, behind)
    if front and behind then
        local key = NodePool.KeyType.GiftBoxEffect .. poolKey
        NodePool.Set(key, front)
        NodePool.Set(key, behind)
    end
end

--主界面推荐任务领奖动画
function AnimationModel.MainTaskFinishAnim(rewardId)
    -- 主界面推荐任务完成领取资源动画
    local giftConf = ConfigMgr.GetItem("configGifts", rewardId)
    local rewards = {}
    if giftConf.res then
        for _, v in ipairs(giftConf.res) do
            local reward = {
                Category = Global.RewardTypeRes,
                ConfId = v.category,
                Amount = v.amount
            }
            table.insert(rewards, reward)
        end
    end
    for _, v in pairs(rewards) do
        if v.ConfId == 1 then
            v.weight = 2
        elseif v.ConfId == 2 then
            v.weight = 5
        elseif v.ConfId == 3 then
            v.weight = 4
        elseif v.ConfId == 4 then
            v.weight = 3
        elseif v.ConfId == 5 then
            v.weight = 6
        else
            v.weight = 1
        end
    end
    table.sort(
        rewards,
        function(a, b)
            return a.weight < b.weight
        end
    )
    NodePool.Init(NodePool.KeyType.NewReceiveAwardAnim, "Common", "ItemImg")
    NodePool.Init(NodePool.KeyType.NewReceiveAwardRes, "Common", "ItemRewardImg")
    AnimationModel.MainUITaskAnim(rewards)
end
--主界面任务动画
function AnimationModel.MainUITaskAnim(rewardsInfo)
    local centerPosX = MainCity.GetRewardCenterPoint.x
    local centerPosY = MainCity.GetRewardCenterPoint.y
    local space = 30 --间隔
    local itemWidth = 90 --UI的宽度
    local mainUIPanle = UIMgr:GetUI("MainUIPanel")
    --计算起始位置
    local num1, num2 = math.modf(#rewardsInfo / 2)
    local startPosY
    if (num2 == 0) then
        --偶数
        startPosY = centerPosX - ((2 * num1 - 1) * (space / 2) + (itemWidth * num1 - itemWidth / 2))
    else
        --奇数
        startPosY = centerPosX - (num1 * itemWidth + num1 * space)
    end
    for i = 1, #rewardsInfo, 1 do
        local item = NodePool.Get(NodePool.KeyType.NewReceiveAwardAnim)
        mainUIPanle.Controller.contentPane:AddChild(item)
        item.xy = Vector2((i - 1) * space + (item.width) * (i - 1) + startPosY, centerPosY)
        local conf = ConfigMgr.GetItem("configResourcess", rewardsInfo[i].ConfId)
        item.icon = _G.UITool.GetIcon(conf.icon_reward)
        item.title = rewardsInfo[i].Amount
        local num = rewardsInfo[i].ConfId == 6 and 1 or 6
        item:GetTransition("anim"):Play(
            function()
                NodePool.Set(NodePool.KeyType.NewReceiveAwardAnim, item)
            end
        )
        local target = mainUIPanle.Controller.contentPane:GetChild("pos" .. rewardsInfo[i].weight)
        local goalPos = target.xy
        if goalPos then
            AnimationModel.FlayResIcon(item, num, conf.icon_reward, nil, goalPos, mainUIPanle)
        end
    end
end

--飞向资源条
function AnimationModel.FlayResIcon(node, num, icon, category, goalPos, mainUIPanle)
    for i = 1, num, 1 do
        local item = NodePool.Get(NodePool.KeyType.NewReceiveAwardRes)
        item:GetChild("icon").icon = _G.UITool.GetIcon(icon)
        item.xy = node.xy
        item.visible = false
        mainUIPanle.Controller.contentPane:AddChild(item)
        item:GetContext():GtweenOnComplete(
            item:TweenFade(1, 0.5 + i * 0.15):SetEase(EaseType.Linear),
            function()
                item.visible = true
                item:GetContext():GtweenOnComplete(
                    item:TweenMove(goalPos, 1):SetEase(EaseType.Custom),
                    function()
                        NodePool.Set(NodePool.KeyType.NewReceiveAwardRes, item)
                    end
                )
            end
        )
    end
end

--[[
    @desc:进度条特效
    data={
        startPos = 特效初始位置
        endPos = 第一次运动后的位置
        startNode = 初始挂载节点
        endNode = 第二次挂载的节点
        progressBar = 进度条本身
        progressValue = 值
        first_cb = 第一段运动回调
        second_cb = 第二段运动回调
        end_cb = 结束运动后回调
    }
    --前6个必传
]]
function AnimationModel.ProgressBarEffect(data)
    local _node = UIMgr:CreateObject("Effect", "EmptyNode")
    _node.xy = data.startPos
    data.startNode:AddChild(_node)
    --动态资源加载
    DynamicRes.GetBundle(
        "effect_collect",
        function()
            DynamicRes.GetPrefab(
                "effect_collect",
                "effect_jindutiao_trail",
                function(prefab)
                    local object = GameObject.Instantiate(prefab)
                    _node:GetGGraph():SetNativeObject(GoWrapper(object))
                    local particle = object:GetComponent("ParticleSystem")
                    particle:Play()
                    --特效生成时的回调
                    if data.first_cb then
                        data.first_cb()
                    end
                    _node:GetContext():GtweenOnComplete(
                        _node:TweenMove(data.endPos, 1),
                        function()
                            data.startNode:RemoveChild(_node)
                            data.endNode:AddChild(_node)
                            _node.xy = Vector2.zero
                            --第一段位移结束后回调
                            if data.second_cb then
                                data.second_cb()
                            end
                            --第二段位移
                            _node:GetContext():GtweenOnComplete(
                                data.progressBar:TweenValue(data.progressValue, 0.5),
                                function()
                                    --所有运动结束后回调
                                    if data.end_cb then
                                        data.end_cb()
                                    end
                                    _node:Dispose()
                                end
                            )
                        end
                    )
                end
            )
        end
    )
end

return AnimationModel
