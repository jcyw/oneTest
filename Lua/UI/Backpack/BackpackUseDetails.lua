local BackpackUseDetails = UIMgr:NewUI("BackpackUseDetails")

import("UI/Common/ItemCondition")

local maxListHeight = 340

function BackpackUseDetails:OnInit()
    local view = self.Controller.contentPane
    self._ctr = view:GetController("c1")
    self:AddListener(self._btnOk.onClick,function()
        self:OnBtnOkClick()
    end)
    self:AddListener(self._btnOk2.onClick,function()
        self:OnBtnOkClick()
    end)

    self:AddListener(self._btnClose.onClick,function()
        UIMgr:Close("BackpackUseDetails")
    end)
    self:AddListener(self._btnClose2.onClick,function()
        UIMgr:Close("BackpackUseDetails")
    end)

    self:AddListener(self._bgMask.onClick,function()
        UIMgr:Close("BackpackUseDetails")
    end)
end

--[[
    items 列表显示内容。（icon 图标，title 名称，amount 数量，quality 品质框，tip 物品标签显示内容）
    title 标题
    content 内容
    btnOkTitle 确定按钮标题
    cbOk 确定按钮点击回调
    cbNot 资源不足时点击回调
    from 何方神圣
]]
function BackpackUseDetails:OnOpen(data)
    self.data = data
    --设置标题文本
    if data.title then
        self._title.text = data.title
        self._title2.text = data.title
    else
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE')
        self._title2.text = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE')
    end
    self._content.text = data.content
    self._content2.text = data.content
    --设置确定按钮文本
    if data.btnOkTitle then
        self._btnOk.title = data.btnOkTitle
        self._btnOk2.title = data.btnOkTitle
    else
        self._btnOk.title = StringUtil.GetI18n(I18nType.Commmon, 'BUTTON_YES')
        self._btnOk2.title = StringUtil.GetI18n(I18nType.Commmon, 'BUTTON_YES')
    end

    self:UpdateData()
end

function BackpackUseDetails:UpdateData()
    if not self.data.from then
        self._ctr.selectedIndex = 0
        self._list:RemoveChildrenToPool()
        for _, v in pairs(self.data.items) do
            local item = self._list:AddItemFromPool()
            item:GetChild("icon").url = v.icon
            item:GetChild("text").text = v.amount
        end
        self._list:ResizeToFit(#self.data.items)
        if self._list.height > maxListHeight then
            self._list.height = maxListHeight
            self._list.scrollPane.touchEffect = true
        else
            self._list.scrollPane.touchEffect = false
        end
    elseif self.data.from == "MAP_AREA_LOCK" then
        --地图解锁区域
        self._ctr.selectedIndex = 1
        self._listBuild:RemoveChildrenToPool()
        for _, v in ipairs(self.data.items) do
            local item = self._listBuild:AddItemFromPool()
            item:Init(v)
        end
        self._listBuild:EnsureBoundsCorrect()
        self._listBuild.scrollPane.touchEffect = self._listBuild.scrollPane.contentHeight > self._listBuild.height
    end
end

function BackpackUseDetails:OnBtnOkClick()
    local function sure_func()
        if self.data.cbOk then
            self.data.cbOk()
        end
        UIMgr:Close("BackpackUseDetails")
    end
    if not self.data.from then
        --确认并关闭界面
        sure_func()
    elseif self.data.from == "MAP_AREA_LOCK" then
        --地图解锁区域
        local isCondtion = true
        for k, v in ipairs(self.data.items) do
            if not v.IsSatisfy then
                isCondtion = false
                local item = self._listBuild:GetChildAt(k - 1)
                item:PlayAnim()
            end
        end
        if isCondtion then
            sure_func()
        else
            if self.data.cbNot then
                self.data.cbNot()
            end
        end
    end
end

return BackpackUseDetails