-- author:{Amu}
-- time:2019-06-10 11:00:15
local BuildModel = import("Model/BuildModel")

local ItemMailScout = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailScout", ItemMailScout)


function ItemMailScout:ctor()
    self._titlelab = self:GetChild("textSuccess")
    self._timelab = self:GetChild("textTime")

    self._describe = self:GetChild("textExplain")

    self._icon = self:GetChild("iconMy")
    self._nameLab = self:GetChild("textName")
    self._posLab = self:GetChild("textPlace")

    self._bg = self:GetChild("bg")

    self._resMainItem = self:GetChild("btnDrop-downBox")
    self._resMainItem.visible = false

    self._itemX =  self._resMainItem.x
    self._itemY =  self._resMainItem.y

    self._bgH = self._bg.height

    self._height = self.height

    self.tempList = {}

    self.resItemList = {}
    self.armiesItemList = {}
    self.defenceItemList = {}

    self.assistItemList = {}
    self.rallyItemList = {}
    
    self:InitEvent()
end

function ItemMailScout:InitEvent(  )
    self:AddListener(self._posLab.onClick,function()
        TurnModel.WorldPos(self._pos.x, self._pos.y)
    end)
end

function ItemMailScout:SetData(index, _info)
    self.info = _info
    self.subType = _info.SubCategory
    self.report = JSON.decode(self.info.Report)
    self.level = self.report.SpyerRadarLevel and self.report.SpyerRadarLevel or 0
    self:RefreshData()
    self:InitList()
end

function ItemMailScout:RefreshData()
    if self.subType == MAIL_SUBTYPE.subScoutReport then--侦察
        self._titlelab.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Investigate_Report")
        if self.report.Alliance ~= "" then
            local str = ""
            if self.report.Alliance ~= "" then
                str = str .. "[" .. self.report.Alliance .. "]"
            end
            str = str .. self.report.Name
            self._nameLab.text = str
        else
            self._nameLab.text = self.report.Name
        end
        self._icon:SetAvatar(self.report)
        -- self._posLab.text = string.format( "坐标[color=#ffff99](%d,%d)[/color]", self.report.X, self.report.Y)
        self._posLab.visible = true
        self._pos = {x = self.report.X, y = self.report.Y}
        self._posLab.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_PlayPlace", {x = math.ceil(self.report.X), y = math.ceil(self.report.Y)})
    elseif self.subType == MAIL_SUBTYPE.subBeScoutReport then--被侦察
        self._titlelab.text = ConfigMgr.GetI18n("configI18nCommons", "UI_BeInvestigate")
        if self.report.SpyName ~= "" then
            -- self._nameLab.text = string.format( "[%s]%s", self.report.SpyAlliance, self.report.SpyName)
            local str = ""
            if self.report.SpyAlliance ~= "" then
                str = str .. "[" .. self.report.SpyAlliance .. "]"
            end
            str = str .. self.report.SpyName
            self._nameLab.text = str
        else
            self._nameLab.text = self.report.SpyAlliance
        end
        self._posLab.visible = false
        self._icon:SetAvatar(self.report)
    end
    self._timelab.text = TimeUtil:GetTimesAgo(self.info.CreatedAt)
end

function ItemMailScout:InitList()
    local index = 1

    local _h = 0

    local isAcc = false --是否是精确值

    if self.report.TargetType == Global.MapTypeTown and self.level >=2 and self.report.ResAmounts ~= JSON.null then      --资源  2
        self._resMainItem.visible = true
        self._resMainItem:SetData(ConfigMgr.GetI18n("configI18nCommons", "Ui_Res"))
        _h = _h + self._resMainItem.height
        for _,v in ipairs(self.report.ResAmounts) do
            if not self.resItemList[index] then
                local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState1")
                self:AddChild(temp)
                self.resItemList[index] = temp
            end
            self.resItemList[index]:SetData(v)
            local num = 0
            for _,res in pairs(self.report.UnCollectResAmounts)do
                if res.Category == v.Category then
                    num = res.Amount
                end
            end
            self.resItemList[index]:SetUnCollectResAmount(num)
            self.resItemList[index].visible = true
            self.resItemList[index].x = self._itemX
            self.resItemList[index].y = self._itemY + _h
            _h = _h + self.resItemList[index].height
            index = index + 1
        end

        for i = index, #self.resItemList do
            self.resItemList[i].visible = false
        end
    else
        self._resMainItem.visible = false
        for k,v in pairs(self.resItemList)do
            v.visible = false
        end
    end

    if self.report.TargetType == Global.MapTypeTown and self.level >=6 and self.report.WallDurable ~= JSON.null then  -- 城墙防御 6
        if not self.wallMainItem then
            local temp = UIMgr:CreateObject("Mail", "MailScoutBox")
            self:AddChild(temp)
            self.wallMainItem = temp
        end
        self.wallMainItem.visible = true
        self.wallMainItem:SetData(ConfigMgr.GetI18n("configI18nCommons", "UI_Defense_Value"), math.ceil(self.report.WallDurable))
        self.wallMainItem.x = self._itemX
        self.wallMainItem.y = self._itemY + _h
        _h = _h + self.wallMainItem.height
    else
        if self.wallMainItem then
            self.wallMainItem.visible = false
        end
    end

    index = 1
    if self.level >=4 then     --防御成员 4   10   18
        if self.level >= 18 then
            isAcc = true
        else
            isAcc = false
        end
        if not self.armiesMainItem then
            local temp = UIMgr:CreateObject("Mail", "MailScoutBox")
            self:AddChild(temp)
            self.armiesMainItem = temp
        end
        self.armiesMainItem.visible = true
        self.armiesMainItem.x = self._itemX
        self.armiesMainItem.y = self._itemY + _h
        _h = _h + self.armiesMainItem.height

        -- local num = 0
        if self.report.Beasts ~= JSON.null then
            for _,v in ipairs(self.report.Beasts) do
                if self.level >= 10 then
                    if not self.armiesItemList[index] then
                        local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState2")
                        self:AddChild(temp)
                        self.armiesItemList[index] = temp
                    end
                    self.armiesItemList[index]:SetData(v, isAcc, true)
                    self.armiesItemList[index].visible = true
                    self.armiesItemList[index].x = self._itemX
                    self.armiesItemList[index].y = self._itemY + _h
                    _h = _h + self.armiesItemList[index].height
                    index = index + 1
                end
                -- num = num + v.Amount
            end
        end

        if self.report.Armies ~= JSON.null then
            for _,v in ipairs(self.report.Armies) do
                if self.level >= 10 then
                    if not self.armiesItemList[index] then
                        local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState2")
                        self:AddChild(temp)
                        self.armiesItemList[index] = temp
                    end
                    self.armiesItemList[index]:SetData(v, isAcc)
                    self.armiesItemList[index].visible = true
                    self.armiesItemList[index].x = self._itemX
                    self.armiesItemList[index].y = self._itemY + _h
                    _h = _h + self.armiesItemList[index].height
                    index = index + 1
                end
                -- num = num + v.Amount
            end
        end

        self.armiesMainItem:SetData(ConfigMgr.GetI18n("configI18nCommons", "Ui_Defense_Members"), math.ceil(self.report.ArmiesAmount), isAcc)

        for i = index, #self.armiesItemList do
            self.armiesItemList[i].visible = false
        end
    else
        if self.armiesMainItem then
            self.armiesMainItem.visible = false
        end
        for k,v in pairs(self.armiesItemList)do
            v.visible = false
        end
    end

    index = 1
    if self.level >=8 then        --援助成员   8   14   16   22
        if self.level >= 22 then
            isAcc = true
        else
            isAcc = false
        end
        if not self.assistMainItem then
            local temp = UIMgr:CreateObject("Mail", "MailScoutBox")
            self:AddChild(temp)
            self.assistMainItem = temp
        end
        self.assistMainItem.visible = true
        self.assistMainItem.x = self._itemX
        self.assistMainItem.y = self._itemY + _h
        _h = _h + self.assistMainItem.height
        
        local num = 0
        if self.report.AssistGroups ~= JSON.null then
            for _,v in ipairs(self.report.AssistGroups) do
                if self.level >= 14 then
                    if not self.assistItemList[index] then
                        local temp = UIMgr:CreateObject("Mail", "itemMailScoutHead")
                        self:AddChild(temp)
                        self.assistItemList[index] = {}
                        self.assistItemList[index].heroItem = temp
                        self.assistItemList[index].arimes = {}
                    end
                    self.assistItemList[index].heroItem.visible = true
                    self.assistItemList[index].heroItem:SetData(v)
                    self.assistItemList[index].heroItem.x = self._itemX
                    self.assistItemList[index].heroItem.y = self._itemY + _h
                    _h = _h + self.assistItemList[index].heroItem.height
                end

                local _index = 1
                if self.level >= 16 and v.Beasts and v.Beasts ~= JSON.null then
                    for _,beast in ipairs(v.Beasts) do
                        if self.level >= 10 then
                            if not self.assistItemList[index].arimes[_index] then
                                local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState2")
                                self:AddChild(temp)
                                self.assistItemList[index].arimes[_index] = temp
                            end
                            self.assistItemList[index].arimes[_index]:SetData(beast, isAcc, true)
                            self.assistItemList[index].arimes[_index].visible = true
                            self.assistItemList[index].arimes[_index].x = self._itemX
                            self.assistItemList[index].arimes[_index].y = self._itemY + _h
                            _h = _h + self.assistItemList[index].arimes[_index].height
                            _index = _index + 1
                        end
                        -- num = num + v.Amount
                    end
                end

                if self.level >= 16 and v.Armies ~= JSON.null then
                    for _,v_v in ipairs(v.Armies) do
                        if not self.assistItemList[index].arimes[_index] then
                            local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState2")
                            self:AddChild(temp)
                            self.assistItemList[index].arimes[_index] = temp
                        end
                        self.assistItemList[index].arimes[_index]:SetData(v_v, isAcc)
                        self.assistItemList[index].arimes[_index].visible = true
                        self.assistItemList[index].arimes[_index].x = self._itemX
                        self.assistItemList[index].arimes[_index].y = self._itemY + _h
                        _h = _h + self.assistItemList[index].arimes[_index].height
                        _index = _index + 1
                        -- num = num + v_v.Amount
                    end
                elseif v.Armies ~= JSON.null then
                    for _,v_v in ipairs(v.Armies) do
                        -- num = num + v_v.Amount
                    end
                    
                end
                if self.assistItemList[index] then
                    for i = _index, #self.assistItemList[index].arimes do
                        self.assistItemList[index].arimes[i].visible = false
                    end
                end
                index = index + 1
            end
        end

        for i = index, #self.assistItemList do
            self.assistItemList[i].heroItem.visible = false
        end

        self.assistMainItem:SetData(ConfigMgr.GetI18n("configI18nCommons", "Ui_Help_Members"), math.ceil(self.report.AssistAmount), isAcc)
    else
        if self.assistMainItem then
            self.assistMainItem.visible = false
        end
        for k,v in pairs(self.assistItemList) do
            v.heroItem.visible = false
            for _,_v in pairs(v.arimes)do
                _v.visible = false
            end
        end
    end

    index = 1
    if self.report.TargetType == Global.MapTypeTown and self.level >=6 then     --防御设施   6  12  20
        if self.level >= 20 then
            isAcc = true
        else
            isAcc = false
        end
        if not self.defenceMainItem then
            local temp = UIMgr:CreateObject("Mail", "MailScoutBox")
            self:AddChild(temp)
            self.defenceMainItem = temp
        end
        self.defenceMainItem.visible = true
        self.defenceMainItem.x = self._itemX
        self.defenceMainItem.y = self._itemY + _h
        _h = _h + self.defenceMainItem.height

        local num = 0

        if self.report.Defence ~= JSON.null then
            if self.level >= 12 then
                for _,v in ipairs(self.report.Defence) do
                    if not self.defenceItemList[index] then
                        local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState4")
                        self:AddChild(temp)
                        self.defenceItemList[index] = temp
                    end
                    self.defenceItemList[index]:SetData(v, isAcc)
                    self.defenceItemList[index].visible = true
                    self.defenceItemList[index].x = self._itemX
                    self.defenceItemList[index].y = self._itemY + _h
                    _h = _h + self.defenceItemList[index].height
                    index = index + 1
                    num = num + v.Amount
                end
            else
                for _,v in ipairs(self.report.Defence) do
                    num = num + v.Amount
                end
            end
    
            for i = index, #self.defenceItemList do
                self.defenceItemList[i].visible = false
            end
        end

        self.defenceMainItem:SetData(ConfigMgr.GetI18n("configI18nCommons", "UI_Army_Weapon"), math.ceil(self.report.DefenceAmount), isAcc)
    else
        if self.defenceMainItem then
            self.defenceMainItem.visible = false
        end
        for k,v in pairs(self.defenceItemList)do
            v.visible = false
        end
    end

    index = 1
    if self.report.TargetType == Global.MapTypeTown and self.level >=21 then        --集结      21   23    25     27     
        if self.level >= 23 then
            isAcc = true
        else
            isAcc = false
        end
        if not self.rallyMainItem then
            local temp = UIMgr:CreateObject("Mail", "MailScoutBox")
            self:AddChild(temp)
            self.rallyMainItem = temp
        end
        self.rallyMainItem.visible = true
        self.rallyMainItem.x = self._itemX
        self.rallyMainItem.y = self._itemY + _h
        _h = _h + self.rallyMainItem.height
        
        local num = 0
        if self.report.RallyGroups ~= JSON.null then
            for _,v in ipairs(self.report.RallyGroups) do
                if self.level >= 25 then
                    if not self.rallyItemList[index] then
                        local temp = UIMgr:CreateObject("Mail", "itemMailScoutHead")
                        self:AddChild(temp)
                        self.rallyItemList[index] = {}
                        self.rallyItemList[index].heroItem = temp
                        self.rallyItemList[index].arimes = {}
                    end
                    self.rallyItemList[index].heroItem.visible = true
                    self.rallyItemList[index].heroItem:SetData(v)
                    self.rallyItemList[index].heroItem.x = self._itemX
                    self.rallyItemList[index].heroItem.y = self._itemY + _h
                    _h = _h + self.rallyItemList[index].heroItem.height
                end
    
                local _index = 1
                if self.level >= 27 and v.Armies ~= JSON.null then
                    for _,v_v in ipairs(v.Armies) do
                        if not self.rallyItemList[index].arimes[_index] then
                            local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState2")
                            self:AddChild(temp)
                            self.rallyItemList[index].arimes[_index] = temp
                        end
                        self.rallyItemList[index].arimes[_index]:SetData(v_v, isAcc)
                        self.rallyItemList[index].arimes[_index].visible = true
                        self.rallyItemList[index].arimes[_index].x = self._itemX
                        self.rallyItemList[index].arimes[_index].y = self._itemY + _h
                        _h = _h + self.rallyItemList[index].arimes[_index].height
                        _index = _index + 1
                        num = num + v_v.Amount
                    end
                elseif v.Armies ~= JSON.null then
                    for _,v_v in ipairs(v.Armies) do
                        num = num + v_v.Amount
                    end
                    
                end
                if self.rallyItemList[index] then
                    for i = _index, #self.rallyItemList[index].arimes do
                        self.rallyItemList[index].arimes[i].visible = false
                    end
                end
                index = index + 1
            end
        end

        for i = index, #self.rallyItemList do
            self.rallyItemList[i].heroItem.visible = false
        end
        self.rallyMainItem:SetData(ConfigMgr.GetI18n("configI18nCommons", "Ui_Aggregation_Members"), math.ceil(self.report.RallyAmount), isAcc)
    else
        if self.rallyMainItem then
            self.rallyMainItem.visible = false
        end
        for k,v in pairs(self.rallyItemList) do
            v.heroItem.visible = false
            for _,_v in pairs(v.arimes)do
                _v.visible = false
            end
        end
    end
    --TODO
    --防御塔    24   
    --科技      28
    --技能      30

    self:SetSize(self.width, self._height+_h - self._resMainItem.height)
    self._bg:SetSize(self._bg.width, self._bgH+_h - self._resMainItem.height)
end

return ItemMailScout