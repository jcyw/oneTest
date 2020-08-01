--author: 	Amu
--time:		2020-07-13 20:55:54

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")
local DressUpModel = import("Model/DressUpModel")

local ItemIndividuationPersonalNewsChatR = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/itemIndividuationPersonalNewsChatR", ItemIndividuationPersonalNewsChatR)

function ItemIndividuationPersonalNewsChatR:ctor()
    self._groupL = self:GetChild("groupL")
    self._groupR = self:GetChild("groupR")


    self._playerInfo = self:GetChild("titleNameR")
    self._msgBox = self:GetChild("title")

    self._head = self:GetChild("btnHeadR")
    self._icon = self._head:GetChild("icon")
    self._caseIcon = self._head:GetChild("caseIcon")

    -- self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemIndividuationPersonalNewsChatR:InitEvent()
end

function ItemIndividuationPersonalNewsChatR:SetData(_info)
    self.info = _info

    self._msgBox:SetData(_info.content)
    self._playerInfo.text = _info.name

    self:RefreshData(_info)
end

function ItemIndividuationPersonalNewsChatR:RefreshData(info)
    if info.avatar == "" then
        self._icon.icon = UITool.GetIcon({"IconCharacter", "avatar_wz"})
    else
        CommonModel.SetUserAvatar(self._icon, info.avatar)
    end

    local iconUrl = ConfigMgr.GetItem("configDressups", info.avatarCase).style
    self._caseIcon.icon = UITool.GetIcon(iconUrl)
end

return ItemIndividuationPersonalNewsChatR