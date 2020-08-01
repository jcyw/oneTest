--author: 	Amu
--time:		2020-04-15 10:36:25

local BeautyGirlModel = {}

local objList = {}
local unLockSkill = {}
local unLockCostume = {}

GameCtrView = {}  --游戏状态控制
GameCtrView.Ready    = 0
GameCtrView.Gameing   = 1

BeautyGirlModel.gameState = GameCtrView.Ready
BeautyGirlModel._canClick = false
BeautyGirlModel.Shield = false

function BeautyGirlModel.Init()
    if Model.Player.CreatedAt > 1594867000 then
        BeautyGirlModel.Shield = true
    end

    Event.AddListener(BEAUTY_GIRL_EVENT.UnlockSkill, function(msg)
        if not unLockSkill[msg.Beauty] then
            unLockSkill[msg.Beauty] = {}
        end
        -- if BeautyGirlModel.Shield and msg.Skill == 10005 then
        --     return
        -- end
        table.insert(unLockSkill[msg.Beauty], msg)
    end)

    Event.AddListener(BEAUTY_GIRL_EVENT.UnlockCostume, function(msg)
        -- if not BeautyGirlModel.Shield then
            BeautyGirlModel.AddUnlockCostume(msg.Beauty, msg)
        -- end
    end)
end

function BeautyGirlModel.Load(url, cb)
    -- CSCoroutine.Start(function()
        -- coroutine.yield(ResMgr.Instance:LoadPrefab(url))
        ResMgr.Instance:LoadPrefabSync(url)
        cb()
    -- end)
end

function BeautyGirlModel.DynamicLoad(url, resName, cb, progressCb)
    local _cb = function(ab)
        if not ab then
            return nil
        end
        local prefab = ab:LoadAsset(resName)
        cb(prefab)
    end
    
    DynamicRes.GetBundle(url, _cb, progressCb)
end

function BeautyGirlModel.Create(url)
    local prefab = ResMgr.Instance:GetPrefab(url)
    if prefab then
        local obj = GameObject.Instantiate(prefab)

        -- table.insert(objList, obj)
        
        -- local wrapper = GoWrapper()
        -- wrapper:SetWrapTarget(obj, true)
        return obj
    else
        return nil
    end
end

function BeautyGirlModel.GetUnlockSkill(id)
    if unLockSkill[id] then
        for k,v in ipairs(unLockSkill[id])do
            table.remove(unLockSkill[id], k)
            return v
        end
    end
    return nil
end

function BeautyGirlModel.IsHavaUnlockCostume(id)
    return unLockCostume[id]
end

function BeautyGirlModel.AddUnlockCostume(id, info)
    if not unLockCostume[id] then
        unLockCostume[id] = {}
    end
    table.insert(unLockCostume[id], info)
end

function BeautyGirlModel.UnlockCostume(id)
    if unLockCostume[id] then
        for k,v in ipairs(unLockCostume[id])do
            table.remove(unLockCostume[id], k)
            return v
        end
    end
    return nil
end


return BeautyGirlModel