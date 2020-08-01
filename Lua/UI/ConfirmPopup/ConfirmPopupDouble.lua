--[[
    Author: songzeming
    Function: 确认弹窗 两个按钮
]]
local ConfirmPopupDouble = UIMgr:NewUI("ConfirmPopupDouble")

local MIN_HEIGHT = 200 --文本框最低高度
local MAX_HEIGHT = 274 --文本框最大高度

function ConfirmPopupDouble:OnInit()
    local view = self.Controller.contentPane
    self.typeController = view:GetController("TypeController")

    self:AddListener(self._btnL.onClick,
        function()
            self:OnBtnLeftClick()
        end
    )
    self:AddListener(self._btnR.onClick,
        function()
            self:OnBtnRightClick()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:OnBtnCloseClick()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:OnBtnCloseClick()
        end
    )
    MAX_HEIGHT = self._label.height
end

--[[
    data = {
        panelType = 弹窗层级类型
        textContent = 内容
        controlType = 窗口样式 double：两个按钮 single：一个按钮 none：没有按钮 不传默认double
        textTitle = 自定义标题 可不传
        textBtnLeft = 左侧按钮文本
        textBtnRight = 右侧按钮文本
        cbBtnLeft = 左侧按钮点击回调 可不传
        cbBtnRight = 右侧按钮点击回调 可不传
        cbBtnClose = 关闭按钮点击回调 可不传
    }
]]
function ConfirmPopupDouble:OnOpen(data)
    self.data = data
    self.cb = nil
    self:UpdataData()
end

function ConfirmPopupDouble:Close(cb)
    self.cb = cb
    UIMgr:Close("ConfirmPopupDouble")
end

function ConfirmPopupDouble:OnClose()
    if self.cb then
        self.cb()
    else
        if self.data.cbBtnClose then
            self.data.cbBtnClose()
        end
    end
end

function ConfirmPopupDouble:UpdataData()
    --设置样式
    if self.data.controlType then
        self.typeController.selectedPage = self.data.controlType
    else
        self.typeController.selectedPage = "double"
    end

    --设置标题
    if self.data.textTitle then
        self._title.text = self.data.textTitle
    else
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    end
    --弹窗内容
    ConfirmPopupTextUtil.SetContent(MIN_HEIGHT,MAX_HEIGHT,self._label,self.data.textContent)
    --按钮标题
    self._btnL.title = self.data.textBtnLeft
    self._btnR.title = self.data.textBtnRight
end

--点击左侧按钮
function ConfirmPopupDouble:OnBtnLeftClick()
    -- if self.data.cbBtnLeft then
    --     self.data.cbBtnLeft()
    -- end
    self:Close(self.data.cbBtnLeft)
end

--点击右侧按钮
function ConfirmPopupDouble:OnBtnRightClick()
    -- if self.data.cbBtnRight then
    --     self.data.cbBtnRight()
    -- end
    self:Close(self.data.cbBtnRight)
end

--点击关闭按钮
function ConfirmPopupDouble:OnBtnCloseClick()
    -- if self.data.cbBtnClose then
    --     self.data.cbBtnClose()
    -- end
    self:Close(self.data.cbBtnClose)
end

return ConfirmPopupDouble
