--[[
    Author: songzeming
    Function: 网络请求数据刷新不及时遮罩
]]
local Mask = fgui.extension_class(GComponent)
fgui.register_extension("ui://Loading/Mask", Mask)
local GlobalVars = GlobalVars

local DEFAULT_ALPHA = 0.3 --遮罩透明度默认值
function Mask:ctor()
    self:MakeFullScreen()
    self.sortingOrder = 99
    self.visible = false

    table.insert(GlobalVars.CommonMask, self)
end

-- 如果遮罩存在了五秒钟，则强制关闭遮罩
local function ReTriggerGuide()
    Mask:Check(false)
end

function Mask:Check(flag, ...)
    if flag then
        self:Open(...)
        self:UnSchedule(ReTriggerGuide)
        self:ScheduleOnce(ReTriggerGuide, 5)
    end
    self:UnSchedule(ReTriggerGuide)
    self.visible = flag
end

-- 设置透明度-opacity, 提示内容-tipContent
function Mask:Open(opacity, tipContent)
    self.isOpen = true

    --透明度管理
    if not opacity then
        self._mask.alpha = 0
    else
        if type(opacity) == "number" then
            self._mask.alpha = opacity
        else
            self._mask.alpha = DEFAULT_ALPHA
        end
    end

    --提示内容管理
    if not tipContent then
        self._tip.text = ""
    else
        if type(tipContent) == "boolean" then
            self._tip.text = "请求数据中..."
        else
            self._tip.text = tipContent
        end
    end

    -- TODO 测试阶段遮罩透明度改为0.3，方便查看，后面取消，删除下面即可
    -- self._mask.alpha = DEFAULT_ALPHA
    -- self._tip.text = "遮罩：" .. self.displayObject.cachedTransform.name
end

function Mask:SetTestMask()
    self._mask.alpha = DEFAULT_ALPHA
    self._tip.text = "遮罩：" .. self.displayObject.cachedTransform.name
end

return Mask
