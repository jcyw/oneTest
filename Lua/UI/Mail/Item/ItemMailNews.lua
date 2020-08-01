-- author:{Amu}
-- time:2019-05-29 11:00:43

local CommonModel = import('Model/CommonModel')
local ChatModel = import("Model/ChatModel")
local Emojies = import("Utils/Emojies")

local ItemMailNews = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailNews", ItemMailNews)

function ItemMailNews:ctor()
    self._checkBox = self:GetChild("check_box")
    self._redPoint = self:GetChild("redPoint")
    self._iconBg = self:GetChild("iconBg")
    self._icon = self:GetChild("icon")
    self._itemIcon = self:GetChild("itemIcon")
    self._titleText = self:GetChild("title")
    self._subText = self:GetChild("text")
    self._timeText = self:GetChild("textTime")
    self._starlogo = self:GetChild("StarLogo")
    self._giftlogo = self:GetChild("GiftLogo")
    self.iconItemList = {}


    self._ctrPoint = self:GetController("point")
    self._ctrView = self:GetController("c1")
    self._iconCtrView = self:GetController("c2")

    self._subText.emojies = EmojiesMgr:GetEmojies()

    self:InitEvent()
end

function ItemMailNews:InitEvent(  )
    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected
        if _selectd then
            Event.Broadcast(EventDefines.UIMailAdd, self.info.Uuid, self.index)
        else
            Event.Broadcast(EventDefines.UIMailDel, self.info.Uuid, self.index)
        end
    end)
end

function ItemMailNews:SetData(type, index, _info, isClick, allSelect, panel)
    self.info = _info
    self._starlogo.visible = false
    self._giftlogo.visible = false
    self.type = type
    self.subType = _info.SubCategory
    self.index = index
    self._panel = panel
    if type == MAIL_TYPE.Msg then
        if MailModel:GetMsgGroupIsRead(_info.Uuid) then
            self._ctrPoint.selectedIndex = 1
        else
            self._ctrPoint.selectedIndex = 0
        end
        self._iconCtrView.selectedIndex = 1
        self._timeText.text = TimeUtil:GetTimesAgo(_info.LastMsg.SentAt)
        self._iconBg.icon = nil
        if _info.Category == MAIL_SUBTYPE.subPersonalMsg then
            for _,v in pairs(_info.Members)do
                if v.UserId ~= UserModel.data.accountId then
                    -- CommonModel.SetUserAvatar(self._icon, v.Avatar)
                    self._headIcon:SetAvatar(v)
                    self._titleText.text = v.Name
                end
            end
            self:ClearItemIcon()
        elseif _info.Category == MAIL_SUBTYPE.subGroupMsg then
            self._icon.icon = nil
            self:SetGroupHead(self._icon, _info.Members)
            self:SetMsgGroupTitle(_info.Title, #_info.Members)
        elseif _info.Category == MAIL_SUBTYPE.subMailSubTypeAllianceNotify then
            CommonModel.SetUserAvatar(self._icon)
            self._titleText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Union_Mail")
            self:ClearItemIcon()
        end
        -- self._subText.text = _info.LastMsg.Content
        if _info.LastMsg.Content ~= "" then
            local emojiesName = Emojies:GetEmojieNameByIcon(EmojiesMgr:EmojieTo16String(_info.LastMsg.Content))
            if emojiesName then
                self._subText.text = StringUtil.GetI18n(I18nType.Commmon, emojiesName)
            else
                ChatModel:SetMsgTemplateByType(self._subText, MSG_TYPE.Mail, _info.LastMsg)
            end
        else
            ChatModel:SetMsgTemplateByType(self._subText, MSG_TYPE.Mail, _info.LastMsg)
        end
    else
        self._iconCtrView.selectedIndex = 0
        self._icon.icon = nil
        self:ClearItemIcon()
        self._starlogo.visible = _info.IsFavorite
        self._giftlogo.visible = not _info.IsClaimed
        -- self._redPoint.visible = not _info.IsRead
        if not _info.IsRead then
            self._ctrPoint.selectedIndex = 1
        else
            self._ctrPoint.selectedIndex = 0
        end
        self._timeText.text = TimeUtil:GetTimesAgo(_info.CreatedAt)
        self:SetText(_info)
    end
    if isClick then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end

    -- self._checkBox.visible = isClick
    -- self._checkBox.asButton.selected = self.info._select
    self._checkBox.asButton.selected = allSelect
end

function ItemMailNews:SetRead()
    if self.type == MAIL_TYPE.Msg then
        -- MailModel:updateMsgIsReadDatas(self.type, 1, self.info.subject)
        -- Event.Broadcast(EventDefines.UIMailsNumChange, {})
        -- self:ReadMsg(infos.LastMsg.Number)
        Net.Mails.MarkSessionReaded(self.info.Uuid, self.info.LastMsg.Number, function()
            MailModel:updateMsgIsReadDatas(self.info.Uuid, self.info.LastMsg.Number)
            Event.Broadcast(EventDefines.UIMailsNumChange, {})
            self._panel:RefreshData()
        end)
    else
        if not self.info.IsRead then
            Net.Mails.MarkRead(self.info.Category, {self.info.Uuid},function(msg)
                -- self.info.IsRead = true
                MailModel:updateIsReadData(self.info.Category, self.info.Number, 1)
                self._panel:RefreshData()
                Event.Broadcast(EventDefines.UIMailsNumChange, {})
            end)
        end
    end
end

function ItemMailNews:SetMsgGroupTitle(title, num)
    if title == "" then
        self._titleText.text = string.format( "群聊(%d)", num)
    else
        self._titleText.text = title
    end
end

function ItemMailNews:getData(  )
    return self.info
end

--简单的群聊头像设置
function ItemMailNews:SetGroupHead(_icon, members)
    local len = #members > 9 and 9 or #members
    local _w = 0    --多少行
    local _h = 0    --多少列
    if len == 1 then
        _w = 1
    elseif len <= 4 then
        _w = 2
    else
        _w = 3
    end
    local _item_w = _icon.width/_w
    _h = math.ceil(len/_w)

    -- 高度不能铺满时的y偏移
    local _offectY = 0
    if _h < _w then
        _offectY = _item_w/2
    end

    -- 单独出的item的x偏移
    local _offectX = 0
    local _f = math.fmod(len, _w)
    if _f > 0 and _f < _w then
        _offectX = (_w-_f)*_item_w/2
    end

    for i = len, 1, -1 do
        if not self.iconItemList[i] then
            local icon = UIMgr:CreateObject("Common", "iconItem")
            self._itemIcon:AddChild(icon)
            self.iconItemList[i] = icon
        end
        self.iconItemList[i].visible = true
        if i > _w*(_h-1) then
            self.iconItemList[i].x = _offectX + _item_w*math.fmod((i-1), _w)
        else
            self.iconItemList[i].x = _item_w*math.fmod((i-1), _w)
        end
        self.iconItemList[i].y = _icon.height - _item_w*math.modf((i-1)/_w) - _offectY - _item_w
        local conf = ConfigMgr.GetItem("configAvatars", tonumber(members[i].Avatar))
        local icon = self.iconItemList[i]:GetChild("icon")
        icon.icon = UITool.GetIcon(conf.avatar)
        icon.width = _item_w
        icon.height = _item_w
    end
    for i = len + 1, #self.iconItemList, 1 do
        self.iconItemList[i].visible = false
    end
end

function ItemMailNews:ClearItemIcon()
    for _,v in pairs(self.iconItemList)do
        v.visible = false
    end
end

function ItemMailNews:SetText(_info)
    if _info.MailType then
        MailModel:SetMailIcon(self._icon, self._iconBg, math.ceil(_info.MailType))
    end
    self._titleText.text = _info.Subject
    self._subText.text = _info.Preview
end

return ItemMailNews