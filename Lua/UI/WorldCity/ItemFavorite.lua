--[[
    author:{zhanzhang}
    time:2019-05-29 19:45:56
    function:{收藏夹条目}
]]
local ItemFavorite = fgui.extension_class(GComponent)
fgui.register_extension("ui://WorldCity/ItemFavorite", ItemFavorite)

local FavoriteModel = import("Model/FavoriteModel")
local WorldMap = import("UI/WorldMap/WorldMap")
import("Enum/FavoriteType")
function ItemFavorite:ctor()
    self._checkBox = self:GetChild("check")
    self._textName = self:GetChild("textName")
    self._btnRename = self:GetChild("btnRename")
    self._btnShare = self:GetChild("btnShare")
    self._btnDel = self:GetChild("btnDel")
    self._iconFavorite = self:GetChild("icon")

    self._controller = self:GetController("c1")
    self._iconContoller = self:GetController("c2")

    self:OnRegister()
end

function ItemFavorite:OnRegister()
    self:AddListener(self._btnRename.onClick,
        function()
            self:OnRename()
            UIMgr:Open("AddFavorite", MathUtil.GetPosNum(self.data.X, self.data.Y), "", true, self._textName.text)
        end
    )
    self:AddListener(self._btnShare.onClick,
        function()
            local data = {}
            data.content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_SHARE_MARK")
            data.sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
            data.cancelBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_NO")
            data.sureCallback = function()
                self:OnShare()
            end
            UIMgr:Open("ConfirmPopupText", data)
        end
    )
    self:AddListener(self._btnDel.onClick,
        function()
            local data = {}
            data.content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_DELETE_MARK")
            data.sureBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_YES")
            data.cancelBtnText = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_NO")
            data.sureCallback = function()
                self:OnDel()
            end
            UIMgr:Open("ConfirmPopupText", data)
        end
    )
    -- self:AddListener(self._textName.onFocusOut,
    --     function()
    --         self._textName.text = StringUtil:Utf8LimitOfByte(self._textName.text, 18)
    --         --失去焦点上传数据"
    --         Net.Bookmarks.Edit(
    --             self.data.Id,
    --             self.data.Category,
    --             self._textName.text,
    --             function()
    --
    --             end
    --         )
    --     end
    -- )
    self:AddListener(self._checkBox.onChanged,
        function()
            FavoriteModel.ChangeSelect(self.data.Id, self._checkBox.selected)
            Event.Broadcast(EventDefines.UIOnSelectFavorite)
        end
    )

    self:AddListener(self._textX.onClick,
        function()
            -- WorldMap.Instance():GotoPoint(self.data.X, self.data.Y)
            WorldMap.Instance():MoveToPoint(self.data.X, self.data.Y, false, false)
            UIMgr:Close("Favorites")
        end
    )
    self:AddEvent(
        EventDefines.UIOnEditFavorite,
        function(isCanEdit)
            self:OnEdit(isCanEdit)
        end
    )

    self:AddEvent(
        EventDefines.UIOnSelectAllFavorite,
        function(isSelectAll, mType)
            self:OnSelect(isSelectAll, mType)
        end
    )
end

function ItemFavorite:init(data, isClick)
    self.data = data
    self._textName.text = data.Name
    self._textX.text = "X:" .. data.X .. " " .. "Y:" .. data.Y
    self._checkBox.selected = data.isSelect
    self._textCreateAt.text = TimeUtil:GetTimesAgo(data.CreatedAt)

    if data.Id then
        self.isFavorite = true
        self._iconContoller.selectedIndex = data.Category - 1
        local configInfo = ConfigMgr.GetItem("configMapMarks", data.RecCategory)

        if data.RecCategory == Global.MapTypeMine then
            local iconId = math.floor(data.RecConfId / 1000) % 10 + 1
            self._iconFavorite.icon = UIPackage.GetItemURL(configInfo.icon[1], configInfo.icon[iconId])
        else
            self._iconFavorite.icon = UITool.GetIcon(configInfo.icon)
        end
    else
        --联盟标记
        local configInfo = ConfigMgr.GetItem("configMapMarks", data.Category + 15)
        self.isFavorite = false
        self._iconContoller.selectedIndex = 4
        self._iconFavorite.icon = UITool.GetIcon(configInfo.icon)
    end

    self._btnDel.visible = self.isFavorite
    self._btnRename.visible = self.isFavorite
    self._textHot.text = "NEW"
    local list = PlayerDataModel:GetData(PlayerDataEnum.MapFavorite_New)
    if not isClick then
        return
    end

    if list and list[tostring(data.CreatedAt)] then
        self._iconHot.visible = false
    else
        self._iconHot.visible = true
        if not list then
            list = {}
        end
        list[tostring(data.CreatedAt)] = true
        PlayerDataModel:SetData(PlayerDataEnum.MapFavorite_New, list)
    end
end

function ItemFavorite:OnShare()
    if self.isFavorite then
        GameShareModel.ShareCoordinateToUnion(Global.CoordinateShareAlliance, self.data.Category - 1, 0, self.data.X, self.data.Y)
    else
        GameShareModel.ShareCoordinateToUnion(Global.CoordinateShareAlliance, Global.CoordinateShareAllianceMark, 0, self.data.X, self.data.Y)
    end
end

function ItemFavorite:OnRename()
    -- self._textName:RequestFocus()
end

function ItemFavorite:OnDel()
    local list = {}
    table.insert(list, self.data.Id)
    Net.Bookmarks.Del(
        list,
        function()
            FavoriteModel.DelItem(self.data.Id)
            Event.Broadcast(EventDefines.UIOnRefreshFavorite)
        end
    )
end

function ItemFavorite:OnEdit(isCanEdit)
    self._controller.selectedIndex = isCanEdit and 1 or 0
end

return ItemFavorite
