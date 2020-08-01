--[[
    Author: songzeming
    Function: Loading界面特效
]]
local LoadingEffect = {}

local GoWrapper = CS.FairyGUI.GoWrapper

--哥斯拉 Loading 特效
local function PlayGodzillaEffect(node)
    local _graphEyeL = node:GetChild("_graphEyeL")
    local _graphEyeR = node:GetChild("_graphEyeR")
    local _graphSmoke = node:GetChild("_graphSmoke")
    local _bar = node.parent:GetChild("_bar")
    local _barSparking
    if _bar then
        _barSparking = _bar:GetChild("_graphSparking")
    end

    --游戏本身时宽度适配，所以只需要适配高度
    local ratioH = GRoot.inst.height / 1334
    _graphEyeL:SetXY(GRoot.inst.width / 2 - 140 * ratioH, 365 * ratioH)
    _graphEyeR:SetXY(GRoot.inst.width / 2 + 125 * ratioH, 360 * ratioH)
    _graphSmoke:SetXY((GRoot.inst.width - 750) / 2, GRoot.inst.height - 1334)

    local pathEye = "effects/loading/loading_fire/loadingfire_eyes"
    local pathSmoke = "effects/loading/loading_fire/loadingfire"
    local pathBar = "effects/loading/loading_jindu/prefab/effect_loading_jindu"
    CSCoroutine.Start(
        function()
            --眼睛特效
            coroutine.yield(ResMgr.Instance:LoadPrefab(pathEye))
            --左
            local prefabEyeL = ResMgr.Instance:GetPrefab(pathEye)
            local objectEyeL = GameObject.Instantiate(prefabEyeL)
            objectEyeL.transform.localScale = CVector3(-1, 1, 1)
            _graphEyeL:SetNativeObject(GoWrapper(objectEyeL))
            --右
            local prefabEyeR = ResMgr.Instance:GetPrefab(pathEye)
            local objectEyeR = GameObject.Instantiate(prefabEyeR)
            _graphEyeR:SetNativeObject(GoWrapper(objectEyeR))
            --进度
            if _barSparking then
                coroutine.yield(ResMgr.Instance:LoadPrefab(pathBar))
                local prefaBar = ResMgr.Instance:GetPrefab(pathBar)
                local objectBar = GameObject.Instantiate(prefaBar)
                _barSparking:SetNativeObject(GoWrapper(objectBar))
            end
            --烟雾特效
            coroutine.yield(ResMgr.Instance:LoadPrefab(pathSmoke))
            local prefabSmoke = ResMgr.Instance:GetPrefab(pathSmoke)
            local objectSmoke = GameObject.Instantiate(prefabSmoke)
            _graphSmoke:SetNativeObject(GoWrapper(objectSmoke))
        end
    )
end

--加载特效
function LoadingEffect.LoadEffect(node)
    if node == nil then
        return
    end
    local _bg = node.parent:GetChild("_bg")
    if not _bg then
        return
    end

    local bgName = UIPackage.GetItemByURL(_bg.url).name
    -- Log.Info("背景图名称: {0}", bgName)
    if bgName == "bg_loading" then
        --哥斯拉 Loading
        PlayGodzillaEffect(node)
    elseif bgName == "bg_loadingB" then

    end
end

return LoadingEffect
