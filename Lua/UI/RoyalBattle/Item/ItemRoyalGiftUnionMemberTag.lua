--[[
    author:{xiaosao}
    time:2020/6/12
    function:{王城战市长发放礼包选择联盟玩家item}
]]
local ItemRoyalGiftUnionMemberTag = fgui.extension_class(GComponent)
fgui.register_extension("ui://RoyalBattle/itemRoyalGiftUnionMemberTag", ItemRoyalGiftUnionMemberTag)
local UnionModel = import('Model/UnionModel')

function ItemRoyalGiftUnionMemberTag:ctor()
    --self._list.visible = false
    self.defaultHeight = self.height
    self._btnArrow.touchable = false
    self._list.visible = false
    self:AddListener(self._bg.onClick,
        function()
            self:OnBtnClick()
        end
    )
    self.isOpen = false
    self._btnArrow.rotation = -90
end

--按钮点击
function ItemRoyalGiftUnionMemberTag:OnBtnClick()
    self.isOpen = not self.isOpen
    self._btnArrow.rotation = self.isOpen and 90 or -90
    self:SetContentView(self.isOpen)
    if not self.members or next(self.members) == nil then
        return
    end
end

--联盟成员列表初始化
function ItemRoyalGiftUnionMemberTag:InitMember(members,index)
    self.members = members
    local count = Tool.GetTableLength(members)
    self._member.text = count
    self._list.numItems = count
    self._list:ResizeToFit(self._list.numChildren)
    self:SetContentView(self.isOpen)
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local member = members[i]
        item:SetData(member)
    end
    --首次进入初始化
    self._icon.visible = false
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_Class_R' .. (Global.AlliancePosR5 + 1 - index))
    self._name.text = UnionModel.GetAppellation((Global.AlliancePosR5 + 1 - index))
    if (Global.AlliancePosR5 + 1 - index) == Global.AlliancePosR5 then
                self._title.text = ""
        self._icon.visible = true
    end
    -- --盟主默认打开
    -- if index == Global.AlliancePosR5 then
    --     self.isOpen = true
    --     self._btnArrow.rotation = 90
    --     self:SetContentView(true)
    --     self._title.text = ""
    --     self._icon.visible = true
    -- end
end
--设置列表是否显示
function ItemRoyalGiftUnionMemberTag:SetContentView(flag)
    self._list.visible = flag
    if flag then
        self.height = self.defaultHeight + self._list.scrollPane.contentHeight + 2
    else
        self.height = self.defaultHeight
    end
end

return ItemRoyalGiftUnionMemberTag
