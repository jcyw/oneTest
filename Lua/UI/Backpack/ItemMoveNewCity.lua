--[[
    author:{zhanzhang}
    time:2020-05-18 15:11:08
    function:{迁城条目}
]]
local DressUpModel = import("Model/DressUpModel")
local ItemMoveNewCity = fgui.extension_class(GButton)
fgui.register_extension("ui://Backpack/itemMoveNewCity", ItemMoveNewCity)

local Event = _G.Event
local EventDefines = _G.EventDefines
local Model = _G.Model

function ItemMoveNewCity:ctor()
    self._controller = self:GetController("c1")
    self:InitEvent()
end

function ItemMoveNewCity:InitEvent()
    self:AddListener(self.onClick,
        function()
            if self.isCurrent then
                TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "TIPS_TRANSFER_SAME_ZONE", {server = self.serverName}))
                return
            end
            -- local function CheckRename()

            local function ConfirmChangeServer()
                local tempFunc = {
                    content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_TRANSFER_ZONE_AGAIN"),
                    sureCallback = function()
                        Net.Items.UseRookieFlyCity(
                            self.serverName,
                            function(rsp)
                                Model.Player.Server = rsp.NewServer
                                Model.Player.X = rsp.X
                                Model.Player.Y = rsp.Y
                                Model.MapConfId = rsp.MapConfId
                                _G.mapOffset = ConfigMgr.GetItem("ConfigMaps", rsp.MapConfId).offset
                                Auth.WorldData.sceneId = rsp.NewServer
                                UIMgr:ClosePopAndTopPanel()
                                Event.Broadcast(EventDefines.OpenWorldMap)
                                Event.Broadcast(EventDefines.CustomEventRefresh,
                                    function()
                                        Event.Broadcast(EventDefines.UIMainAllianceIconRefresh)
                                    end
                                )
                                Event.Broadcast(EventDefines.RefreshWorldMapBorder)
                            end
                        )
                    end
                }
                UIMgr:Open("ConfirmPopupText", tempFunc)
            end
            local data = {
                titleText = StringUtil.GetI18n(I18nType.Commmon, "UI_TRANSFER_ZONE_TITLE"),
                content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_TRANSFER_ZONE"),
                contentDown = StringUtil.GetI18n(I18nType.Commmon, "ALERT_TRANSFER_ZONE_LEFTTIME"),
                sureCallback = ConfirmChangeServer,
                UpdateTimeAt = Model.Player.RookieExpireAt
            }

            Net.UserInfo.FindSameName(
                self.serverName,
                function(rsp)
                    print(rsp)
                    if rsp.Result then
                        data.content = StringUtil.GetI18n(I18nType.Commmon, "ALERT_TRANSFER_NAME_NOPASS")
                    end
                    UIMgr:Open("ConfirmPopupVital", data)
                end
            )
        end
    )
end

function ItemMoveNewCity:SetData(serverName)
    self.serverName = serverName
    self.isCurrent = (Model.Player.Server == serverName)
    self._controller.selectedIndex = self.isCurrent and 0 or 1
    self._cityName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_COORDINATE_CITY_TEXT") .. serverName

    if self.isCurrent then
        self._playerName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander") .. Model.Player.Name
        -- CommonModel.SetUserAvatar(self._itemHead:GetChild("icon"), Model.Player.Avatar)
        self._itemHead:SetAvatar({Avatar = Model.User.Avatar, DressUpUsing = DressUpModel.usingDressUp})
    -- self._itemHead:GetChild("icon").url = UITool.GetIcon(data.icon, self._icon)
    end
end

return ItemMoveNewCity
