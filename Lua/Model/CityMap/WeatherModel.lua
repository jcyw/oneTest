--[[
    Author: songzeming
    Function: 公用模板 天气
]]
if WeatherModel then
    return WeatherModel
end
WeatherModel = {}

import("UI/Effect/EmptyNode")
import("UI/Effect/RainMask")

local RainNode = nil
local RainMask = nil
local LightNode = nil
local IsRaining = false
local StartTime = 0
local GlobalVars = GlobalVars

--初始化天气特效
function WeatherModel.InitWeather()
    StartTime = Tool.Time()
end

--下雨
local function PlayRainAnim(time)
    if not GlobalVars.IsShowEffect() then
        return
    end
    IsRaining = true
    local _cityPane = CityMapModel.GetCityContext().Controller.contentPane
    local item = UIMgr:CreateObject("Effect", "EmptyNode")
    RainNode = item
    item.sortingOrder = CityType.CITY_MAP_SORTINGORDER.Weather
    item.xy = Vector2(0, 200)
    _cityPane:AddChild(item)
    item:GetContext():GtweenOnComplete(item:TweenFade(1, time),WeatherModel.Clear)
    --加载雨的特效
    DynamicRes.GetBundle("effect_collect", function()
        DynamicRes.GetPrefab("effect_collect", "effect_ui_xiayu", function(prefab)
            local object = GameObject.Instantiate(prefab)
            item:GetGGraph():SetNativeObject(GoWrapper(object))
        end)
    end)
    --阴天蒙版
    local mask = UIMgr:CreateObject("Effect", "RainMask")
    RainMask = mask
    _cityPane:AddChild(mask)
    mask:Show(time)
end
--闪电
local function PlayLight(time)
    if not GlobalVars.IsShowEffect() then
        return
    end
    local item = UIMgr:CreateObject("Effect", "EmptyNode")
    LightNode = item
    item.sortingOrder = CityType.CITY_MAP_SORTINGORDER.Weather
    item.xy = Vector2(GRoot.inst.width - 180, 300)
    CityMapModel.GetCityContext().Controller.contentPane:AddChild(item)
    item:GetContext():GtweenOnComplete(item:TweenFade(1, math.random(1, time - 1)),function()
        --加载闪电特效
        DynamicRes.GetBundle("effect_collect", function()
            DynamicRes.GetPrefab("effect_collect", "lightning", function(prefab)
                local object = GameObject.Instantiate(prefab)
                item:GetGGraph():SetNativeObject(GoWrapper(object))
            end)
        end)
        --屏幕震动
        if GlobalVars.IsInCity then
            CityMapModel.GetCityMiddle():ScreenShock()
        end
    end)
end

--[[
    玩家在线时长超过3分钟将触发雨天检测。玩家进行操作时将会有50%的概率触发雨天。
    1点击提示图标触发收兵、收集资源
    2普通升级建筑时返回基地
    3从大地图返回基地
    4点击触发巨兽动画
    5点击触发大兵敬礼
    雨天持续时间/秒t=固定值K1+ 5*(0,1,2,3中的随机数)
    雨天结束后，再次超过3分钟检测。
    特殊情况：
    1.玩家下线后结束雨天。
    2.玩家切换至大地图时结束雨天。
    需要走配置的：雨天检测（秒）：180。固定值K1：20。概率值（万分比）：5000。
]]
--检测是否播放天气特效
function WeatherModel.CheckWeatherRain()
    if IsRaining then
        return
    end
    if Tool.Time() - StartTime > Global.WeatherRainCheckTime then
        if math.random(0, 1) > Global.WeatherRainOdds / 10000 then
            local t = Global.WeatherRainFixedValue + 5 * math.random(0, 3)
            PlayRainAnim(t)
            if math.random(0, 1) > 0.5 then
                PlayLight(t)
            end
        end
    end
end

--是否显示天气（切换外城不显示）
function WeatherModel.Show(flag)
    if RainNode then
        RainNode.visible = flag
    end
    if RainMask then
        RainMask.visible = flag
    end
    if LightNode then
        LightNode.visible = flag
    end
end

function WeatherModel.Clear()
    if RainNode  then
        RainNode:Dispose()
        RainNode = nil
    end
    if RainMask  then
        RainMask:Dispose()
        RainMask = nil
    end
    if LightNode  then
        LightNode:Dispose()
        LightNode = nil
    end
    IsRaining = false
    StartTime = Tool.Time()
end

return WeatherModel
