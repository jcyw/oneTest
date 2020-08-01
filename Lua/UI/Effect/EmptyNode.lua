--[[
    Author: songzeming
    Function: 巨兽模型动画
]]
local EmptyNode = fgui.extension_class(GComponent)
fgui.register_extension("ui://Effect/EmptyNode", EmptyNode)

function EmptyNode:ctor()
    self:ResetData()

    self:AddListener(self.onClick,
        function()
            if self.cb then
                self.cb()
            end
        end
    )
    self:AddListener(self.onTouchMove,
        function(context)
            if not self.rotationTouch then
                return
            end
            if not self.lastTouchMoveX then
                self.lastTouchMoveX = context.inputEvent.x
                return
            end
            local mvx = context.inputEvent.x - self.lastTouchMoveX
            mvx = mvx > self.rotationOffset and self.rotationOffset or (mvx < -self.rotationOffset and -self.rotationOffset or mvx)
            self._graph.rotationY = self._graph.rotationY - mvx
            self.lastTouchMoveX = context.inputEvent.x
        end
    )
end

--重置参数
function EmptyNode:ResetData()
    --[[
        是否穿透空白区域 opaque
        If true, mouse/touch events cannot pass through the empty area of the component. Default is true.
        如果为真，鼠标/触摸事件不能通过组件的空白区域。默认是正确的。
    ]]
    self.opaque = false
    self.width = 0
    self.height = 0
    self.xy = Vector2.zero
    self.pivot = Vector2.zero
    self.pivotAsAnchor = false
    self._touch.visible = false
    self._icon.visible = false

    -- self.z = 1000
    self._touch.icon = "" --TODO 关闭框框

    self.rotationOffset = 10 --滑动偏移量
    self.rotationTouch = false --是否可以滑动
end

--点击回调
function EmptyNode:ClickCallback(cb)
    self.cb = cb
end

--设置是否滑动、滑动偏移量
function EmptyNode:SetTouchable(flag)
    self._touch.visible = flag
end

--获取GGraph
function EmptyNode:GetGGraph()
    return self._graph
end

--设置Icon显示
function EmptyNode:SetIcon(icon, width, height)
    self._icon.visible = true
    if not width then
        width = GRoot.inst.width
    end
    if not height then
        height = GRoot.inst.height
    end
    self._icon.width = width
    self._icon.height = height
    self._icon.icon = icon
end

function EmptyNode:GetIcon()
    return self._icon
end

function EmptyNode:GetContext()
    return self
end

return EmptyNode
