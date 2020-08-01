--author: 	Amu
--time:		2020-07-21 16:16:38

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")
local DressUpModel = import("Model/DressUpModel")

local ItemHeadPhotoSmall = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemHeadPhotoSmall", ItemHeadPhotoSmall)

ItemHeadPhotoSmall.tempList = {}

function ItemHeadPhotoSmall:ctor()
    self._icon = self:GetChild("icon")
    self._caseIcon = self:GetChild("caseIcon")

    self._ctrView = self:GetController("casetype")
    self._lightCtrView = self:GetController("light")

    self:InitEvent()
end

function ItemHeadPhotoSmall:InitEvent()
end

function ItemHeadPhotoSmall:SetAvatar(info, type, userId)
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
        CommonModel.SetUserAvatar(self._icon, self.info.Avatar, userId)

        if info.DressUpUsing then
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
            print("====================没有装扮==============================")
        end
    end
end

function ItemHeadPhotoSmall:SetDefault()
    self._ctrView.selectedIndex = 0
    self._caseIcon.icon = UITool.GetIcon(DressUpModel.GetDefaultDressUpUrl(DRESSUP_TYPE.Avatar))
end

function ItemHeadPhotoSmall:GetData()
    return self.info
end

function ItemHeadPhotoSmall:SetChoose(flag)
    if flag then
        self._lightCtrView.selectedIndex = 1
    else
        self._lightCtrView.selectedIndex = 0
    end
end

return ItemHeadPhotoSmall