--[[
    Author: songzeming
    Function: 触摸提示 按下显示 松开关闭
]]
local LongPressPopupLabel = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/LongPressPopupLabel", LongPressPopupLabel)

function LongPressPopupLabel:ctor()
    self._arrowControl = self:GetController("arrowControl")
    self._arrowPosControl = self:GetController("arrowPosControl")
    self._typeControl = self:GetController("typeControl")
end

function LongPressPopupLabel:InitLabel(title, content)
    self._titleText.text = title
    self._contentText.text = content
    self._arrowControl.selectedPage = "up"
    self._arrowPosControl.selectedPage = "left"
    self._typeControl.selectedIndex = 0
end

function LongPressPopupLabel:InitCenterLabel(title, content)
    self._titleText.text = title
    self._contentCenterText.text = content
    self._arrowControl.selectedPage = "up"
    self._arrowPosControl.selectedPage = "left"
    self._typeControl.selectedIndex = 1
end

--[[
    title 标题
    content 描述
    target tips目标对象
    downward 是否是向下显示 true 向下 false 向上
    isRight 箭头左右显示 true 右 false 左 --现在没有用到了保留
    isCenter 是否是 InitCenterLabel 显示
]]
function LongPressPopupLabel:OnShowUI(title,content,target,downward,isRight,isCenter)
    if isCenter then
        self:InitCenterLabel(title,content)
    else
        self:InitLabel(title,content)
    end
    --上下左右的箭头设置 现在没有显示了 保留接口--
    self:SetArrowController(not downward)
    self:SetArrowPosController(isRight)
    -----------------------------------
    _G.UIMgr:ShowPopup("Common", "LongPressPopupLabel",target, downward)
end

function LongPressPopupLabel:SetArrowPosX(posx)
    self._arrow.x = posx
    self:SetArrowActive(true)
end

function LongPressPopupLabel:SetArrowDownPosX(posx)
    self._arrowDown.x = posx
end

function LongPressPopupLabel:SetArrowActive(flag)
    self._arrow.visible = flag
end

function LongPressPopupLabel:SetPos(posx, posy)
    if posx then
        self.x = posx
    end
    if posy then
        self.y = posy
    end
end

function LongPressPopupLabel:SetArrowController(isDown)
    if isDown then
        self._arrowControl.selectedPage = "down"
    else
        self._arrowControl.selectedPage = "up"
    end
end

function LongPressPopupLabel:SetArrowPosController(isRight)
    if isRight then
        self._arrowPosControl.selectedPage = "right"
    else
        self._arrowPosControl.selectedPage = "left"
    end
end

function LongPressPopupLabel:SetVisible(flag)
    self.visible = flag
end

function LongPressPopupLabel:OnHidePopup()
    _G.UIMgr:HidePopup("Common", "LongPressPopupLabel")
end

return LongPressPopupLabel