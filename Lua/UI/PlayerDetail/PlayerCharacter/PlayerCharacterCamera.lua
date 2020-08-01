--[[
    Author: songzeming
    Function: 玩家形象 拍照/相册
]]
local PlayerCharacterCamera = UIMgr:NewUI("PlayerCharacter/PlayerCharacterCamera")

function PlayerCharacterCamera:OnInit()
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("PlayerCharacter/PlayerCharacterCamera")
        end
    )
    self:AddListener(self._btnPhotograph.onClick,
        function()
            self:OnBtnPhotographClick()
        end
    )
    self:AddListener(self._btnAlbum.onClick,
        function()
            self:OnBtnAlbumClick()
        end
    )
end

function PlayerCharacterCamera:OnOpen(canUseItem, cb)
    self.canUseItem = canUseItem
    self.cb = cb
end

--点击相机
function PlayerCharacterCamera:OnBtnPhotographClick()
    if not Sdk.CanAccessCamera() then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Tips_Jurisdiction_Camerabefore"),
            buttonType = "double",
            sureCallback = function()
                Sdk.RequestOpenCamera()
                UIMgr:Close("PlayerCharacter/PlayerCharacterCamera")
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        Sdk.RequestOpenCamera()
        UIMgr:Close("PlayerCharacter/PlayerCharacterCamera")
    end
end

--点击相册
function PlayerCharacterCamera:OnBtnAlbumClick()
    if not Sdk.CanAccessGallery() then
        local data = {
            content = StringUtil.GetI18n(I18nType.Commmon, "Tips_Jurisdiction_Imagebefore"),
            buttonType= "double",
            sureCallback = function()
                Sdk.RequestOpenGallery()
                UIMgr:Close("PlayerCharacter/PlayerCharacterCamera")
            end
        }
        UIMgr:Open("ConfirmPopupText", data)
    else
        Sdk.RequestOpenGallery()
        UIMgr:Close("PlayerCharacter/PlayerCharacterCamera")
    end
end

return PlayerCharacterCamera
