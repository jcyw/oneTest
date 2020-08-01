--author: 	Amu
--time:		2020-07-21 16:17:27

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")
local DressUpModel = import("Model/DressUpModel")

local ItemHeadPhotoLarge = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemHeadPhotoLarge", ItemHeadPhotoLarge)

ItemHeadPhotoLarge.tempList = {}

function ItemHeadPhotoLarge:ctor()
    self._icon = self:GetChild("icon")
    self._caseIcon = self:GetChild("caseIcon")

    self._ctrView = self:GetController("casetype")
    self._lightCtrView = self:GetController("light")
    self._lightCtrView.selectedIndex = 0
    self:InitEvent()
end

function ItemHeadPhotoLarge:InitEvent()
end

function ItemHeadPhotoLarge:SetAvatar(info, type, userId)
    self.info = info
    if not info then
        self._icon.icon = UITool.GetIcon(Global.AvatarDefaultBackground)
        self:SetDefault()
    elseif type == MSG_TYPE.LMsg and info.Alliance ~= "" then
        self._icon.icon = UnionModel.GetUnionBadgeIcon(info.AllianceAvatar)
        self:SetDefault()
    elseif type == "custom" then
        self._icon.icon = UITool.GetIcon(info)
        self:SetDefault()
    else
        local avatar = self.info.Avatar and self.info.Avatar or self.info.UserAvatar
        CommonModel.SetUserAvatar(self._icon, avatar, userId)

        if info.DressUpUsing and info.DressUpUsing ~= JSON.null then
            local iconUrl = nil
            for _,v in pairs(info.DressUpUsing) do
                if v.DressType == DRESSUP_TYPE.Avatar then
                    local config = ConfigMgr.GetItem("configDressups", v.DressUpConId)
                    iconUrl = config.style
                    if config.default == 0 then
                        self._ctrView.selectedIndex = 0
                    else
                        self._ctrView.selectedIndex = 1
                    end
                    break
                end
            end
            if iconUrl then
                self._caseIcon.icon = UITool.GetIcon(iconUrl)
            else
                -- self._caseIcon.icon = nil
                self:SetDefault()
            end
        else
            -- Log.Error("====================没有装扮==============================")
        end
    end
end

function ItemHeadPhotoLarge:SetDefault()
    self._ctrView.selectedIndex = 0
    self._caseIcon.icon = UITool.GetIcon(DressUpModel.GetDefaultDressUpUrl(DRESSUP_TYPE.Avatar))
end

function ItemHeadPhotoLarge:ForceSetAvater()
    
end

function ItemHeadPhotoLarge:GetData()
    return self.info
end

function ItemHeadPhotoLarge:SetChoose(flag)
    if flag then
        self._lightCtrView.selectedIndex = 1
    else
        self._lightCtrView.selectedIndex = 0
    end
end

return ItemHeadPhotoLarge