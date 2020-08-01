--author: 	Amu
--time:		2020-06-29 19:42:23

local ItemMail_Main = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMail_Main", ItemMail_Main)


function ItemMail_Main:ctor()
    self._Tag = self:GetChild("Tag")

    self.itemList = {}
    self.itemInfo = ConfigMgr.GetList("configMailShows")

    table.sort(self.itemInfo, function(a, b)
        return a.order < b.order
    end)

    for _,v in pairs(self.itemInfo) do
        self.itemList[v.mailtype] = v
        local info = MailModel:GetInfoByType(v.mailtype)
        if info and #info then
            v.notReadAmount = info.notReadAmount
            v.info = info
        end
        if not self.itemList[v.mailtype].btn then
            local item = UIMgr:CreateObject("Mail", "MailMainItem")
            self:AddChild(item)
            self.itemList[v.mailtype].btn = item

            v.btn:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, v.name)
            v.btn:GetChild("icon").icon = UITool.GetIcon(v.icon)
        end

        self:AddListener(self.itemList[v.mailtype].btn.onClick,function()
            local mailtype = self.itemList[v.mailtype].mailtype
            UIMgr:OpenWithPkg(self.itemList[v.mailtype].main, 
                self.itemList[v.mailtype].sub, self.itemList[v.mailtype].info, mailtype, self)
            if not (self.itemList[v.mailtype].sub == "Mail_News" or self.itemList[v.mailtype].sub == "Mail_StarLogo") then
                Net.Mails.MarkReadAndClaim(mailtype, function()
                    MailModel:updateIsReadDatas(mailtype, 1)
                    self:RefreshData()
                    Event.Broadcast(EventDefines.UIMailsNumChange, {})
                end)
            end
        end)

    end

    self:Refresh()
    self:InitEvent()
end

function ItemMail_Main:InitEvent(  )

end

function ItemMail_Main:InitData()
    
end

function ItemMail_Main:Refresh()
    local _height = 0
    for _,v in pairs(self.itemInfo)do
        if v.position == 1 then
            if v.show_con == 1 then     -- 常驻
                v.btn.y = _height
                _height = _height + v.btn.height
            elseif v.show_con == 2 then -- 有邮件才显示
                local info = MailModel:GetInfoByType(v.mailtype)
                if (info and #info.info > 0) or MailModel:GetAmountByType(v.mailtype) > 0 or MailModel:GetNumByType(v.mailtype) > 0 then
                    v.btn.y = _height
                    v.btn.visible = true
                    _height = _height + v.btn.height
                else
                    -- if MailModel:GetNumByType(v.mailtype) > 0 then
                        v.btn.visible = false
                    -- end
                end
            end
        end
    end

    self._Tag.y = _height

    _height = _height + self._Tag.height

    for _,v in pairs(self.itemInfo)do
        if v.position == 2 then
            v.btn.y = _height
            _height = _height + v.btn.height
        end
    end

    self.height = _height
end

function ItemMail_Main:RefreshData( )
    for _,v in pairs(self.itemList) do
        local info = MailModel:GetInfoByType(v.mailtype)
        if info and #info then
            v.notReadAmount = info.notReadAmount or v.notReadAmount
            v.info = info or v.info
        end
        if v.notReadAmount > 0 then
            -- v.btn:GetChild("redPoint").visible = true
            v.btn:GetChild("textRedPointNumber").visible = true
            v.btn:GetChild("textRedPointNumber").text = v.notReadAmount
        else
            -- v.btn:GetChild("redPoint").visible = false
            v.btn:GetChild("textRedPointNumber").visible = false
        end
    end
end

function ItemMail_Main:SetData(info)
    self._name.text = info.AllianceName
    self._union.text = info.PlayerName
    self._giftId = ConfigMgr.GetItem("configArenaRobots", info.Rank).gift
    CommonModel.SetUserAvatar(self._icon, info.Avatarr)
end

return ItemMail_Main