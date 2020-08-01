--author: 	Amu
--time:		2019-08-16 19:35:54

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")

local ItemMailPersonalNewsChatHead = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemMailPersonalNewsChatHead", ItemMailPersonalNewsChatHead)

ItemMailPersonalNewsChatHead.tempList = {}

function ItemMailPersonalNewsChatHead:ctor()
    self._icon = self:GetChild("icon")
    self._caseIcon = self:GetChild("caseIcon")

    self._ctrView = self:GetController("casetype")

    self:InitEvent()
end

function ItemMailPersonalNewsChatHead:InitEvent()
end

function ItemMailPersonalNewsChatHead:SetData(info, type)
    self.info = info
    if type == MSG_TYPE.LMsg and info.Alliance ~= "" then
        self._icon.icon = UnionModel.GetUnionBadgeIcon(info.AllianceAvatar)
    else
        CommonModel.SetUserAvatar(self._icon, self.info.Avatar)

        if info.DressUpUsing then
            local iconUrl = nil
            for _,v in ipairs(info.DressUpUsing) do
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
                self._caseIcon.icon = nil
            end
        else
            print("====================没有装扮==============================")
        end
    end
end

function ItemMailPersonalNewsChatHead:GetData()
    return self.info
end

function ItemMailPersonalNewsChatHead:SetChoose(flag)
end

return ItemMailPersonalNewsChatHead