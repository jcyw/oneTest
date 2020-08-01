import("Enum/FavoriteType")
local StringUtil = import("Utils/StringUtil")
local AddFavorite = UIMgr:NewUI("AddFavorite")
--收藏夹类型
local mType = 0
local posX = 0
local posY = 0

function AddFavorite:OnInit()
    local view = self.Controller.contentPane
    self._mask = view:GetChild("bgMask")
    self._textRename = view:GetChild("textRename")
    self._btnRename = view:GetChild("bgRename")
    self._textCoordinate = view:GetChild("textCoordinateNum")
    self._iconBuild = view:GetChild("iconBuild")
    self._btnSign = view:GetChild("btnSign")
    self._btnFriend = view:GetChild("btnFriend")
    self._btnEnemy = view:GetChild("btnEnemy")
    self._btnCollection = view:GetChild("btnCollection")
    self._controller = view:GetController("c1")
    self:OnRegister()
end

function AddFavorite:OnRegister()
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("AddFavorite")
        end
    )

    self:AddListener(self._btnRename.onClick,
        function()
            self._textRename:RequestFocus()
        end
    )

    self:AddListener(self._btnSign.onClick,
        function()
            mType = FavoriteType.Mark
        end
    )
    self:AddListener(self._btnFriend.onClick,
        function()
            mType = FavoriteType.Friend
        end
    )
    self:AddListener(self._btnEnemy.onClick,
        function()
            mType = FavoriteType.Enemy
        end
    )
    self:AddListener(self._btnCollection.onClick,
        function()
            self:ConfirmFavorite()
        end
    )
    self:AddListener(self._textRename.onFocusOut,
        function()
            --if #self._textRename.text > 18 then
            --    self._textRename.text = StringUtil.Utf8LimitOfByte(self._textRename.text, 18)
            --end
            self._textRename.text = Util.GetStringByLimit(self._textRename.text, 18)
            self._textRename.text = StringUtil.RemoveSpaceAndNextLine(self._textRename.text)
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("AddFavorite")
        end
    )
    self:AddListener(self._btnShare.onClick,
        function()
            local posX, posY = MathUtil.GetCoordinate(self.posNum)
            GameShareModel.ShareCoordinateToUnion(Global.CoordinateShareAlliance, Global.CoordinateShareNormal, 0, posX, posY)
        end
    )
end

function AddFavorite:OnOpen(posNum, fortressInfo, isEdit, nameStr)
    -- AllianceId:"bndtrqlpi1iej7tjm480"
    -- Category:3
    -- ConfId:0
    -- FortressId:70025
    -- FortressIdList:""
    -- Id:80025
    -- Occupied:0
    -- OwnerId:""
    -- ServerId:"{scene}.Game:"
    -- State:0
    -- Value:0
    self.area = MapModel.GetArea(posNum)
    self.posNum = posNum

    self.isEdit = isEdit
    local str = ""
    if not self.area or self.area.Category == Global.MapTypeBlank then
        str = StringUtil.GetI18n(I18nType.Commmon, "MAPTYPE_TEXT_3")
    elseif self.area.Category == Global.MapTypeTown or self.area.Category == Global.MapTypeCamp then
        str = MapModel.GetMapOwner(self.area.OwnerId).Name
    elseif self.area.Category == Global.MapTypeMine then
        str = StringUtil.GetI18n(I18nType.Commmon, "MAP_RESOURCETYPE_" .. math.floor(self.area.ConfId / 1000), {level = math.floor(self.area.ConfId % 100)})
    elseif self.area.Category == Global.MapTypeAllianceDomain then
        str = StringUtil.GetI18n(I18nType.Commmon, fortressInfo.Building.Name)
    elseif self.area.Category == Global.MapTypeSecretBase then
        str = StringUtil.GetI18n(I18nType.Commmon, "MAPTYPE_TEXT_13")
    elseif self.area.Category == Global.MapTypeThrone then --王城
        str = StringUtil.GetI18n(I18nType.Commmon, "Throne_Status_Title")
    elseif self.area.Category == Global.MapTypeFort then --炮台
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_WarZone_Missile_Base")
    elseif self.area.Category == Global.MapTypeAllianceStore then --联盟仓库
        str = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse")
    end

    mType = FavoriteType.Mark
    self._controller.selectedIndex = 0
    self._textRename.text = isEdit and nameStr or str
    -- body
    posX, posY = MathUtil.GetCoordinate(posNum)
    self._textCoordinate.text = StringUtil.GetCoordinataWithLetter(posX, posY)
end

function AddFavorite:ConfirmFavorite()
    if self._textRename.text == "" then
        self._textRename.text = "未命名" --todo国际化
    elseif #self._textRename.text < 3 then
        TipUtil.TipById(50258)
        return
    end
    if self.isEdit then
        Net.Bookmarks.Edit(
            self.posNum,
            mType,
            self._textRename.text,
            function()
                TipUtil.TipById(50372)
            end
        )
    else
        Net.Bookmarks.Add(mType, self._textRename.text, posX, posY,function()
            TipUtil.TipById(50191)
        end)
    end
    UIMgr:Close("AddFavorite")
end

return AddFavorite
