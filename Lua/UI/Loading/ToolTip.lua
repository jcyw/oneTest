--[[
    Author: songzeming
    Function: 弹窗提示 通用
]]
local ToolTip = UIMgr:NewUI("ToolTip")

local CommonModel = import("Model/CommonModel")

local CONTROLLER = {
    Icon = "Icon", --可改变图标
    Label = "Label", --没有图标
    Warning = "Warning" --感叹号
}
local DELAY_TIME = 1.5 --提示默认显示时间 单位:秒
local isShow = false --是否显示

function ToolTip:OnInit()
    local view = self.Controller.contentPane
    view.width = GRoot.inst.width
    self._controller = view:GetController("Controller")

    self.view = view
    view.touchable = false
    view.x = (GRoot.inst.width - view.width) / 2
    view.sortingOrder = 10

    self:AddEvent(
        EventDefines.UIToolTip,
        function(data)
            if isShow then
                if self.close_func then
                    self:UnSchedule(self.close_func)
                    self.close_func = nil
                end
                self:Close(false)
                UIMgr:Open("ToolTip", data)
            else
                UIMgr:Open("ToolTip", data)
            end
        end
    )
end

--[[
    content = 显示内容
    icon = 图标icon [可不传]
    posy = 显示位置 [可不传]
    delay = 提示显示时间 [可不传]
    showType = 控制器类型 [可不传] Icon/Warning/Label
]]
function ToolTip:OnOpen(data)
    self._controller.selectedPage = data.showType
    self._icon.icon = data.icon
    if data.avatar and data.userId then
        CommonModel.SetUserAvatar(self._icon, data.avatar, data.userId)
    end
    if data.title then
        self._Name.text = data.title
    end
    self._content.text = data.content
    self._content2.text = data.content
    self.view.y = (GRoot.inst.height - self.view.height) / 2 - 100
    if data.posy then
        self.view.y = data.posy
    end
    self:TipAnim(data.delay)
end

function ToolTip:DoOpenAnim(...)
    self:OnOpen(...)
    self.Controller.x = 0
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreRight, self)
end

function ToolTip:Close(anim)
    if anim then
        AnimationLayer.PanelAnim(AnimationType.PanelMoveRight, self, false, function()
            UIMgr:Close("ToolTip")
        end)
    else
        GTween.Kill(self.Controller)
        UIMgr:Close("ToolTip")
    end
end

function ToolTip:OnClose()
    isShow = false
end

function ToolTip:TipAnim(delay)
    if not delay then
        delay = DELAY_TIME
    end
    isShow = true
    self.close_func = function()
        self.close_func = nil
        self:Close(true)
    end
    self:ScheduleOnce(self.close_func, delay)
    
    if self.wait_close_func then
        self:UnScheduleFast(self.wait_close_func)
    end
    self.wait_close_func = function()
        self.wait_close_func = nil
        if isShow then
            UIMgr:Close("ToolTip")
        end
    end
    self:ScheduleOnceFast(self.wait_close_func, delay + 0.5)
end

return ToolTip
