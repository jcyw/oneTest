local Favorites = UIMgr:NewUI("Favorites")
local FavoriteType = import("Enum/FavoriteType")
local FavoriteModel = import("Model/FavoriteModel")
local view = nil

function Favorites:OnInit()
    view = self.Controller.contentPane
    self._btnClose = view:GetChild("btnReturn")

    self._textCollectionNumber = view:GetChild("textCollectionNumber")
    self._btnEdit = view:GetChild("btnEdit")
    self._btnGroup = view:GetChild("group")
    -- self._itemSelectAll = view:GetChild("itemSelectAll")
    self._btnCancel = view:GetChild("btnMainBlack")
    self._btnDel = view:GetChild("btnDel")
    self._contentGList = view:GetChild("liebiao")
    self._checkBox = view:GetChild("checkBox")
    --收藏夹全选控制器
    self._controller = view:GetController("c2")
    self._contentGList.itemRenderer = function(index, item)
        item:init(self.infoList[index + 1], self.isClick)
    end
    self._contentGList:SetVirtual()

    self:OnRegister()
end

function Favorites:OnRegister()
    for i = 1, 5 do
        local btnTag = view:GetChild("btnTagSingle" .. i)
        self:AddListener(btnTag.onClick,
            function()
                self.currentType = i
                self.isClick = true
                self:OnSelectType(i)
            end
        )
    end
    self._btnTagAll = view:GetChild("btnTagSingle" .. 1)
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnEdit.onClick,
        function()
            self:SelectSwitch(true)
            Event.Broadcast(EventDefines.UIOnEditFavorite, true)
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            Event.Broadcast(EventDefines.UIOnEditFavorite, false)
            FavoriteModel:ClearSelect()
            self:SelectSwitch(false)
        end
    )
    self:AddListener(self._btnDel.onClick,
        function()
            Net.Bookmarks.Del(
                FavoriteModel.GetDelList(self.currentType),
                function(val)
                    FavoriteModel.DelList(FavoriteModel.GetDelList(self.currentType))
                    self.isClick = false
                    self:OnSelectType(self.currentType)
                end
            )
        end
    )
    --点击全选按钮
    self:AddListener(self._checkBox.onChanged,
        function()
            self:SelelAll(self._checkBox.selected, self.currentType)
        end
    )
    self:AddEvent(
        EventDefines.UIOnRefreshFavorite,
        function()
            self.isClick = false
            self:OnSelectType(self.currentType)
        end
    )
    self:AddEvent(
        EventDefines.UIOnSelectFavorite,
        function()
            self._checkBox.selected = FavoriteModel.IsAllSelect(self.currentType)
        end
    )
    self._btnCancel.visible = true
end

function Favorites:OnOpen()
    Event.Broadcast(EventDefines.UIOnEditFavorite, false)
    self.currentType = FavoriteType.All
    self:SelectSwitch(false)
    FavoriteModel.ClearSelect()
    self.isClick = true
    self:OnSelectType(FavoriteType.All)
    self._btnTagAll.selected = true
    self._controller.selectedIndex = 0
end

function Favorites:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreRight, self)
end
function Favorites:DoCloseAnim()
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreLeft, self, true)
end

function Favorites:Close()
    UIMgr:Close("Favorites")
end

function Favorites:OnSelectType(index)
    self.infoList = FavoriteModel.GetItemByType(index)
    self._contentGList.numItems = #self.infoList
    self._textCollectionNumber.text = FavoriteModel.GetAllCount()
    self.currentType = index
    if self._controller.selectedIndex == 1 then
        self._checkBox.selected = FavoriteModel.IsAllSelect(self.currentType)
    end

    if index == 5 then
        self._controller.selectedIndex = 2
    -- else
    --     self._controller.selectedIndex = self.isOpen and 1 or 0
    end
end

function Favorites:SelelAll(isAll, mType)
    FavoriteModel.SetItem(isAll, mType)
    self:OnSelectType(mType)
end

--选择所有的开关
function Favorites:SelectSwitch(isOpen)
    self.isOpenEdit = isOpen
    self._controller.selectedIndex = isOpen and 1 or 0
end
return Favorites
