--[[
    author:{zhanzhang}
    time:2019-05-30 16:47:35
    function:{游戏工具类}
]]
if GameUtil then
    return
end
local GoWrapper = CS.FairyGUI.GoWrapper
local GGraph = CS.FairyGUI.GGraph
local GameObject = CS.UnityEngine.GameObject

GameUtil = {}
local CreateCache = {}
function GameUtil.Clone(org)
    local res = {}
    local function Copy(org, res)
        for k, v in pairs(org) do
            if type(v) ~= "table" then
                res[k] = v
            else
                res[k] = {}
                Copy(v, res[k])
            end
        end
    end
    Copy(org, res)
    return res
end
--获得颜色对象(使用255的颜色值)
function GameUtil.Color(val)
    local b = math.floor(val % 1000)
    val = math.floor(val / 1000)
    local g = math.floor(val % 1000)
    val = math.floor(val / 1000)
    local r = math.floor(val % 1000)

    return Color(r / 255, g / 255, b / 255)
end

function GameUtil.GetTableCount()
end

function GameUtil.ShowPlayerName(playerName, alliance)
    local str = ""
    if alliance ~= "" then
        str = "[" .. alliance .. "]"
    end
    str = str .. playerName
    return str
end
--计算行军进度条:加速只影响速度，不影响进度
function GameUtil.CalTimeSilderVal(data)
    local t1 = (data.SpeedChangeAt - data.CreatedAt) / data.Duration
    local newDuration = data.FinishAt - data.SpeedChangeAt
    local t2 = (Tool.Time() - data.SpeedChangeAt) / newDuration
    return t1 + t2
end
--parent需要是image对象,url为预制地址
function GameUtil.CreateEffect(parent, url, callback)
    CSCoroutine.Start(
        function()
            coroutine.yield(ResMgr.Instance:LoadPrefab(url))
            local go = GameObject.Instantiate(ResMgr.Instance:GetPrefab(url))
            if callback then
                callback(go)
            end
            local wrapper = GoWrapper(go)
            parent.asGraph:SetNativeObject(wrapper)
        end
    )
end

function GameUtil.CreateObj(url)
    return GameObject.Instantiate(ResMgr.Instance:LoadPrefabSync(url))
end

function GameUtil.InitObj(parent, url, callback)
    local info = {}
    info.parent = parent
    info.url = url
    info.callback = callback
    if CreateCache[url] then
        table.insert(CreateCache[url], info)
    else
        CreateCache[url] = {}
        table.insert(CreateCache[url], info)
        CSCoroutine.Start(
            function()
                coroutine.yield(ResMgr.Instance:LoadPrefab(url))
                for i = 1, #CreateCache[url] do
                    local temp = CreateCache[url][i]
                    local obj = GameObject.Instantiate(ResMgr.Instance:GetPrefab(temp.url))
                    if temp.callback then
                        temp.callback(temp.parent, temp.url, obj)
                    end
                    table.remove(CreateCache[url], i)
                end
            end
        )
    end
end
--从对象池中创建对象
function GameUtil.GetObjFromPool(index, callback)
    if index <= 0 or not callback then
        Log.Warning("对象池不符合条件，请修改")
    end

    local resConfig = ConfigMgr.GetItem("configResourcePaths", index)
    if ObjectPoolManager.Instance:IsExistPool(resConfig.name) then
        callback()
    else
        if not CreateCache[resConfig.name] then
            CreateCache[resConfig.name] = {}
        end
        local info = {}
        info.resConfig = resConfig
        info.callback = function()
            callback()
        end
        if #CreateCache[resConfig.name] > 0 then
            table.insert(CreateCache[resConfig.name], info)
            return
        else
            table.insert(CreateCache[resConfig.name], info)
            CSCoroutine.Start(
                function()
                    coroutine.yield(ObjectPoolManager.Instance:CreatePool(resConfig.name, 1, resConfig.resPath))
                    local list = CreateCache[resConfig.name]
                    for i = 1, #list do
                        list[i].callback()
                    end
                    CreateCache[resConfig.name] = {}
                end
            )
        end
    end
end

function GameUtil.RecycleObjToPool(index, obj)
    local config = ConfigMgr.GetItem("configResourcePaths", index)
    ObjectPoolManager.Instance:Release(config.name, obj)
end

--开始文本打印效果 text文本对象 interval频率 waitTime等待时长(叠加频率时间超过等待时长就停止) cb回调
function GameUtil.TypingEffectState(text,interval,waitTime,cb)
    if GameUtil.typingfunc then
        Scheduler.UnScheduleFast(GameUtil.typingfunc)
    end
    local typingEffect = TypingEffect(text)
    typingEffect:Start()
    GameUtil.TypingEffectPrint(typingEffect,interval,waitTime,cb)
end
--打印效果频率
function GameUtil.TypingEffectPrint(typingEffect,interval,waitTime,cb)
    local allInterval = 0
    GameUtil.typingfunc = function()
        allInterval = allInterval + interval
        if not typingEffect:Print() or allInterval>=waitTime then
            Scheduler.UnScheduleFast(GameUtil.typingfunc)
            if cb then
                cb(allInterval)
            end
        end
    end
    Scheduler.ScheduleFast(GameUtil.typingfunc,interval)
end

return GameUtil
