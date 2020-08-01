--[[
    Author: songzeming
    Function: 联盟成员列表 职位排序Item
]]
local ItemMemberSort = fgui.extension_class(GButton)
fgui.register_extension('ui://Union/itemUnionMemberTag', ItemMemberSort)

local UnionModel = import('Model/UnionModel')
import('UI/Union/UnionMember/ItemMember')
local CONTROLLER = {
    Member = 'Member', --联盟成员列表
    Setup = 'Setup', --联盟设置成员上线提醒
    Officer = 'Officer' --盟主任命官员
}

function ItemMemberSort:ctor()
    self._controller = self:GetController('Controller')

    self:AddListener(self._checkBox.onChanged,
        function()
            if not self.tag then
                self:CheckExg()
            end
        end
    )
    self:AddListener(self._bg.onClick,
        function()
            if not self.tag then
                self:OnBtnClick()
            end
        end
    )

    self._btnArrow.touchable = false
    self._list.visible = false
    self.defaultHeight = self.height
end

function ItemMemberSort:SetTag(tag)
    self.tag = tag
end

--联盟官员审批列表初始化(只有盟主能看)
function ItemMemberSort:InitOfficer(cb, icon, name, members)
    self.itemClickCb = cb
    self._icon.icon = icon
    self._name.text = name

    self._controller.selectedPage = CONTROLLER.Officer
    self:ResetData(members)
    self:ResetShow()
    self:OnBtnClick()
end
--联盟官员搜索刷新
function ItemMemberSort:SearchOfficer(cb, members)
    self.itemClickCb = cb
    self:ResetData(members)
    self:ResetShow()
    if next(members) ~= nil then
        self:OnBtnClick()
    end
end

--联盟设置在线提醒
function ItemMemberSort:InitOnlineRemind(index, members, cb)
    self.cb = cb
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R' .. index)
    self._name.text = UnionModel.GetAppellation(index)

    self._controller.selectedPage = CONTROLLER.Setup
    self:ResetData(members)
    self:ResetShow()
end

--联盟成员列表初始化
function ItemMemberSort:InitMember(index, members, isMine, isUpdate)
    self.isMine = isMine
    self:ResetData(members)
    if isUpdate then
        --成员变动刷新数据
        self:SetContentView(self.isOpen)
    else
        --首次进入初始化
        self._controller.selectedPage = CONTROLLER.Member
        self._icon.visible = false
        self._title.text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R' .. index)
        self._name.text = UnionModel.GetAppellation(index)
        self:ResetShow()
        --盟主默认打开
        if index == Global.AlliancePosR5 then
            self:OnBtnClick()
            self._title.text = ""
            self._icon.visible = true
        end
    end
end

--设置联盟成员列表称谓
function ItemMemberSort:SetAppellation(name)
    self._name.text = name
end

--设置选中框是否选中 [联盟设置-成员上线提醒]
function ItemMemberSort:SetCheck(isCheck)
    self._checkBox.selected = isCheck
end
--获取选中框是否选中 [联盟设置-成员上线提醒]
function ItemMemberSort:GetCheck()
    return self._checkBox.selected
end

--重置显示
function ItemMemberSort:ResetShow()
    self.isOpen = false
    self._btnArrow.rotation = -90
    self:SetContentView(false)
end

--重置数据
function ItemMemberSort:ResetData(members)
    self.members = members
    local count = Tool.GetTableLength(members)

    if self.isMine then
        self._member.text = self:GetOnlineNum(members) .. '/' .. count
    else
        self._member.text = count .. '/' .. count
    end

    self._list.numItems = count
    self._list:ResizeToFit(self._list.numChildren)
    self:SetContentView(self.isOpen)

    local obj = SortMember(members)
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local member = obj[i]
        item:Init(
            member,
            self._controller.selectedPage,
            self.isMine,
            function(isCheck)
                self:ItemCheckExg(member, isCheck)
                self:ItemCheckBox(isCheck)
            end
        )
        item:ClickCb(
            function()
                if self.itemClickCb then
                    self.itemClickCb(member)
                end
            end
        )
    end
end

--设置列表是否显示
function ItemMemberSort:SetContentView(flag)
    self._list.visible = flag
    Log.Info("ssssllllyyyy   self._list.sortingOrder: {0}  ,self.sortingOrder: {1}", self._list.sortingOrder,self.sortingOrder)
    if flag then
        self.height = self.defaultHeight + self._list.scrollPane.contentHeight + 2
    else
        self.height = self.defaultHeight
    end
end

--按钮点击
function ItemMemberSort:OnBtnClick()
    self.isOpen = not self.isOpen
    self._btnArrow.rotation = self.isOpen and 90 or -90
    self:SetContentView(self.isOpen)
    if not self.members or next(self.members) == nil then
        return
    end
    if self.cb then
        self.cb()
    end
end

function ItemMemberSort:InitExg(exgArr, cb)
    self.exgArr = exgArr
    self.exgArrCb = cb
end

--列表中单个Item选中状态改变时 刷新变化数组
function ItemMemberSort:ItemCheckExg(member, isCheck)
    local id = member.Id
    if member.OnlineNotice == isCheck then
        if self.exgArr[id] then
            self.exgArr[id] = nil
        end
    else
        self.exgArr[id] = isCheck
    end
    self.exgArrCb(self.exgArr)
end

--列表中单个Item选中状态改变时 刷新选中框
function ItemMemberSort:ItemCheckBox(isCheck)
    if not isCheck then
        self:SetCheck(false)
    else
        for i = 1, self._list.numChildren do
            local item = self._list:GetChildAt(i - 1)
            if not item:GetCheck() then
                self:SetCheck(false)
                return
            end
        end
        self:SetCheck(true)
    end
end

--点击选中框检查列表全选或全不选后 刷新变化数组
function ItemMemberSort:CheckExg()
    local flag = self:GetCheck()
    for k, v in pairs(self.members) do
        local item = self._list:GetChildAt(k - 1)
        item:SetCheck(flag)
        local id = v.Id
        if v.OnlineNotice == flag then
            if self.exgArr[id] then
                self.exgArr[id] = nil
            end
        else
            if flag then
                self.exgArr[id] = true
            else
                self.exgArr[id] = false
            end
        end
    end
    self.exgArrCb(self.exgArr)
end

--检查选中框是否选中 [联盟设置-成员上线提醒]
function ItemMemberSort:CheckSort()
    if not self.members or next(self.members) == nil then
        self:SetCheck(false)
        return
    end
    for _, v in pairs(self.members) do
        if not v.OnlineNotice then
            self:SetCheck(false)
            return
        end
    end
    self:SetCheck(true)
end

--获取在线成员数量
function ItemMemberSort:GetOnlineNum(members)
    if next(members) == nil then
        return 0
    end
    local state = self._controller.selectedPage
    local num = 0
    if state == CONTROLLER.Member or state == CONTROLLER.Officer then
        for _, v in pairs(members) do
            if v.IsOnline then
                num = num + 1
            end
        end
    elseif state == CONTROLLER.Setup then
        for _, v in pairs(members) do
            if v.OnlineNotice then
                num = num + 1
            end
        end
    end
    return num
end

--排序 [是否在线、战斗力]
function SortMember(members)
    table.sort(members, function(a, b)
        if a.IsOnline and b.IsOnline then
            return a.Power > b.Power
        elseif not a.IsOnline and not b.IsOnline then
            return a.Power > b.Power
        else
            return a.IsOnline
        end
    end)
    return members
end

return ItemMemberSort
