if MaskModel then
    return MaskModel
end

MaskModel = {}

local MaskCommon = nil
local MaskGuide = nil
local MaskLayer = nil
local MaskCity = nil
local MaskUpgrade = nil
local DelayClick = nil

function MaskModel.InitMask(ctx)
    MaskModel.Clear()
    MaskCommon = UIMgr:CreateObject("Loading", "Mask")
    MaskGuide = UIMgr:CreateObject("Loading", "Mask")
    MaskLayer = UIMgr:CreateObject("Loading", "Mask")
    MaskCity = UIMgr:CreateObject("Loading", "Mask")
    MaskUpgrade = UIMgr:CreateObject("Loading", "Mask")
    DelayClick = UIMgr:CreateObject("Loading", "Mask")
    MaskCommon.displayObject.cachedTransform.name = "Mask"
    MaskGuide.displayObject.cachedTransform.name = "GuideMask"
    MaskLayer.displayObject.cachedTransform.name = "LayerMask"
    MaskCity.displayObject.cachedTransform.name = "CityMask"
    MaskUpgrade.displayObject.cachedTransform.name = "UpgradeMask"
    DelayClick.displayObject.cachedTransform.name = "DelayClickMask"

    ctx.Controller:AddChild(MaskCommon)
    ctx.Controller:AddChild(MaskGuide)
    GRoot.inst:AddChild(MaskLayer)
    GRoot.inst:AddChild(MaskCity)
    GRoot.inst:AddChild(MaskUpgrade)
    GRoot.inst:AddChild(DelayClick)
    ctx:AddEvent(
        EventDefines.Mask,
        function(flag, ...)
            if MaskCommon == nil then
                return
            end
            if KSUtil.IsEditor() then
                Log.Info("=====>>> Mask: {0}", flag)
            end
            MaskCommon:Check(flag, ...)
        end
    )
    ctx:AddEvent(
        EventDefines.GuideMask,
        function(flag, ...)
            if MaskGuide == nil then
                return
            end
            if KSUtil.IsEditor() then
                Log.Info("=====>>> GuideMask: {0}", flag)
            end
            MaskGuide:Check(flag, ...)
        end
    )
    ctx:AddEvent(
        EventDefines.LayerMask,
        function(flag, ...)
            if MaskLayer == nil then
                return
            end
            if KSUtil.IsEditor() then
                Log.Info("=====>>> LayerMask: {0}", flag)
            end
            MaskLayer:Check(flag, ...)
        end
    )
    ctx:AddEvent(
        EventDefines.CityMask,
        function(flag, ...)
            if MaskCity == nil then
                return
            end
            if KSUtil.IsEditor() then
                Log.Info("=====>>> CityMask: {0}", flag)
            end
            MaskCity:Check(flag, ...)
        end
    )
    ctx:AddEvent(
        EventDefines.UpgradeMask,
        function(flag, ...)
            if MaskUpgrade == nil then
                return
            end
            if KSUtil.IsEditor() then
                Log.Info("=====>>> UpgradeMask: {0}", flag)
            end
            MaskUpgrade:Check(flag, ...)
        end
    )
    ctx:AddEvent(
        EventDefines.DelayMask,
        function(flag, ...)
            if DelayClick == nil then
                return
            end
            if KSUtil.IsEditor() then
                Log.Info("=====>>> DelayMask: {0}", flag)
            end
            DelayClick:Check(flag, ...)
        end
    )
end

function MaskModel.Clear()
    if MaskCommon then
        MaskCommon:Dispose()
        MaskCommon = nil
    end
    if MaskGuide then
        MaskGuide:Dispose()
        MaskGuide = nil
    end
    if MaskLayer then
        MaskLayer:Dispose()
        MaskLayer = nil
    end
    if MaskCity then
        MaskCity:Dispose()
        MaskCity = nil
    end
    if MaskUpgrade then
        MaskUpgrade:Dispose()
        MaskUpgrade = nil
    end
    if DelayClick then
        DelayClick:Dispose()
        DelayClick = nil
    end
end

return MaskModel
