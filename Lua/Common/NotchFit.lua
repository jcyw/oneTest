--     [
--         Author : maxiaolong
--         function: 异形屏适配
--     ]

local NotchFit = {}

--当前运行平台
NotchFit.curtPlayform = nil

--Ipone手动填写下移参数
NotchFit.IponeModelArray = {
    ["iPhone10,3"] = 32.0,
    ["iPhone10,6"] = 32.0,
    ["iPhone11,8"] = 32.0,
    ["iPhone11,2"] = 32.0,
    ["iPhone11,6"] = 32.0
}

function NotchFit:InitFit()
    GRoot.inst:SetPivot(0.5, 1.0)
end

function NotchFit:AutoMaticFit()
    -- FIXME 请重构使用枚举
    -- if true then
    --     return
    -- end
    local playformStr = KSUtil.GetPlayformStr()
    if playformStr == PlayformEnum.IPHONE then
        self.curtPlayform = PlayformEnum.IPONE
        self:IOSAuto()
    elseif playformStr == PlayformEnum.ANDROID then
        self.curtPlayform = PlayformEnum.ANDROID
        self:ANDROIDAuto()
    elseif playformStr == PlayformEnum.UNITYEDITOR then
        self.curtPlayform = PlayformEnum.UNITYEDITOR
        self:UNITYAuto()
    elseif playformStr == PlayformEnum.WINDOWS then
        self.curtPlayform = PlayformEnum.WINDOWS
    else
        self.curtPlayform = PlayformEnum.OTHER
    end
end

function NotchFit:UNITYAuto(pixel)
    return
end

function NotchFit:IOSAuto()
    self:CommonAuto(self.IponeModelArray)
end

function NotchFit:ANDROIDAuto()
    return
end

function NotchFit:CommonAuto(modelList)
    local pixel = 0
    local info = util.ModeInfo()
    for key, value in pairs(modelList) do
        if info == key then
            pixel = value
            break
        end
    end
    if pixel > 0 then
        local notchfitY = GRoot.inst.size.y - pixel
        local aspectY = notchfitY / GRoot.inst.size.y
        local scaleY = GRoot.inst.scale.y * aspectY
        GRoot.inst:SetScale(GRoot.inst.scale.x, scaleY)
    end
end

--获取运行设备平台类型
function NotchFit:GetPlayfrom()
    return self.curtPlayform
end

return NotchFit
