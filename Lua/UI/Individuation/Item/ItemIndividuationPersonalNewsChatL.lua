--author: 	Amu
--time:		2020-07-13 20:55:41

local CommonModel = import("Model/CommonModel")
local UnionModel = import("Model/UnionModel")
local DressUpModel = import("Model/DressUpModel")

local ItemIndividuationPersonalNewsChatL = fgui.extension_class(GComponent)
fgui.register_extension("ui://Individuation/itemIndividuationPersonalNewsChatL", ItemIndividuationPersonalNewsChatL)

function ItemIndividuationPersonalNewsChatL:ctor()
    self._groupL = self:GetChild("groupL")
    self._groupR = self:GetChild("groupR")


    self._playerInfo = self:GetChild("titleName")
    self._msgBox = self:GetChild("title")

    self._head = self:GetChild("btnHead")

    self._icon = self._head:GetChild("icon")
    self._caseIcon = self._head:GetChild("caseIcon")
    self._caseIconCtrView = self._head:GetController("casetype")

    self._flagText = self:GetChild("n36")

    self._itemChatBar = self:GetChild("itemChatBar")

    -- self._ctrView = self:GetController("c1")

    self.BubbleIcon = {
        [DRESSUP_BUBBLE_TYPE.Arrow] = self:GetChild("chatBgArrowL"),
        [DRESSUP_BUBBLE_TYPE.Box] = self:GetChild("chatBgBox"),
        [DRESSUP_BUBBLE_TYPE.LeftTop] = self:GetChild("righttop"),
        [DRESSUP_BUBBLE_TYPE.LeftBotton] = self:GetChild("rightbottom"),
    }


    self:InitEvent()
end

function ItemIndividuationPersonalNewsChatL:InitEvent()
end

function ItemIndividuationPersonalNewsChatL:SetData(_info)
    self.info = _info

    self._msgBox:SetData(_info.content)
    self._playerInfo.text = _info.name

    self:RefreshData(_info)
end

function ItemIndividuationPersonalNewsChatL:RefreshData(info)

    if info.dressUpType then
        self._flagText.visible = true
    else
        self._flagText.visible = false
    end

    if info.avatar == "" then
        self._icon.icon = UITool.GetIcon({"IconCharacter", "avatar_wz"})
    else
        CommonModel.SetUserAvatar(self._icon, info.avatar)
    end

    if info.avatarCase then
        local config =  ConfigMgr.GetItem("configDressups", info.avatarCase)
        if config.default ~= 0 then
            self._caseIconCtrView.selectedIndex = 1
        else
            self._caseIconCtrView.selectedIndex = 0
        end
        self._caseIcon.icon = UITool.GetIcon(config.style)
    else
        local config = ConfigMgr.GetItem("configDressups", DressUpModel.usingDressUp[DRESSUP_TYPE.Avatar].DressUpConId)
        if config.default ~= 0 then
            self._caseIconCtrView.selectedIndex = 1
        else
            self._caseIconCtrView.selectedIndex = 0
        end
        self._caseIcon.icon = UITool.GetIcon(config.style)
    end

    if info.bubble then
        for _,v in pairs(self.BubbleIcon)do
            v.visible = false
        end
        local config = DressUpModel.GetDressUpInfoByTypeAndId(info.dressUpType, info.bubble).config
        for _,v in pairs(config.urls)do
            if self.BubbleIcon[v.id] then
                self.BubbleIcon[v.id].visible = true
                self.BubbleIcon[v.id].icon = UITool.GetIcon({v.pkg, v.url})
            end
        end
    end
    


    -- self._head:SetData(info, self.type)
end

return ItemIndividuationPersonalNewsChatL