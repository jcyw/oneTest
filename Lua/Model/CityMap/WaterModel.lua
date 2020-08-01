--[[
    Author: songzeming
    Function: 河流特效
]]
local WaterModel = {}

import("UI/Effect/EmptyNode")

local WaterNode = nil
local MatchNode = nil
local SpringNode = nil
local isLoadedMatch = false
local isLoadedSpring = false

local GlobalVars = GlobalVars

--检测是否已经显示水坝和喷泉特效
function WaterModel.CheckShow()
    if not isLoadedMatch then
        WaterModel.ShowMatch() 
    end
    if not isLoadedSpring then
        WaterModel.ShowSpring()
    end
end

--河流
function WaterModel.ShowWater()
    local _node = UIMgr:CreateObject("Effect", "EmptyNode")
    WaterNode = _node
    _node.z = 2500
    CityMapModel.GetCityMap()._water:AddChild(_node)
    local path = "effects/citymap/easywater/example/water_simple1"
    local prefabObj = ResMgr.Instance:LoadPrefabSync(path)
    local prefab = ResMgr.Instance:GetPrefab(path)
    local object = GameObject.Instantiate(prefab)
    _node:GetGGraph():SetNativeObject(GoWrapper(object))
    local waters = object:GetComponentsInChildren(typeof(CS.UnityEngine.Transform))
    for i = 0, waters.Length - 1 do
        waters[i].gameObject.layer = CS.UnityEngine.LayerMask.NameToLayer("Water")
        
    end
    object.transform.localScale = Vector3(1, 1, 1)
end
--水坝
function WaterModel.ShowMatch()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    Log.Info("加载水坝特效")
    local _node = UIMgr:CreateObject("Effect", "EmptyNode")
    MatchNode = _node
    _node.z = 2450
    CityMapModel.GetCityMap():AddChild(_node)
    --动态资源加载
    DynamicRes.GetBundle("effect_collect", function()
        DynamicRes.GetPrefab("effect_collect", "effect_shuiba_water", function(prefab)
            if isLoadedMatch then
                return
            end
            isLoadedMatch = true

            Log.Info("加载水坝成功")
            local object = GameObject.Instantiate(prefab)
            _node:GetGGraph():SetNativeObject(GoWrapper(object))
        end)
    end)
end

--喷泉
function WaterModel.ShowSpring()
    if not GlobalVars.IsShowEffect() then
        --低端机不显示
        return
    end
    Log.Info("加载喷泉特效")
    local _node = UIMgr:CreateObject("Effect", "EmptyNode")
    SpringNode = _node
    _node.sortingOrder = CityType.CITY_MAP_SORTINGORDER.Tree
    _node.xy = Vector2(620, 2372)
    CityMapModel.GetCityMap():AddChild(_node)
    --动态资源加载
    DynamicRes.GetBundle("effect_collect", function()
        DynamicRes.GetPrefab("effect_collect", "effect_penquan", function(prefab)
            if isLoadedSpring then
                return
            end
            isLoadedSpring = true
        
            Log.Info("加载喷泉成功")
            local object = GameObject.Instantiate(prefab)
            object.transform.localPosition = Vector3(0, 0, 3000)
            _node:GetGGraph():SetNativeObject(GoWrapper(object))
        end)
    end)
end

function WaterModel.Clear()
    if WaterNode then
        WaterNode:Dispose()
        WaterNode = nil
    end
    if MatchNode then
        MatchNode:Dispose()
        MatchNode = nil
    end
    if SpringNode then
        SpringNode:Dispose()
        SpringNode = nil
    end
end

return WaterModel
