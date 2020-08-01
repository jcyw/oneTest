--author: 	Amu
--time:		2020-07-21 16:17:27

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")
local DressUpModel = import("Model/DressUpModel")

local BtnMainHead = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/btnMainHead", BtnMainHead)

BtnMainHead.tempList = {}

function BtnMainHead:ctor()
    self._icon = self:GetChild("icon")
    self._caseIcon = self:GetChild("headBox")

    self._ctrView = self:GetController("casetype")
    self:InitEvent()
end

function BtnMainHead:InitEvent()
end

function BtnMainHead:SetAvatar(info, type, userId)
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

function BtnMainHead:SetDefault()
    self._ctrView.selectedIndex = 0
    self._caseIcon.icon = UITool.GetIcon(DressUpModel.GetDefaultDressUpUrl(DRESSUP_TYPE.Avatar))
end

function BtnMainHead:ForceSetAvater()
    
end

function BtnMainHead:GetData()
    return self.info
end

function BtnMainHead:GetState()
    return self._ctrView.selectedIndex
end

return BtnMainHead