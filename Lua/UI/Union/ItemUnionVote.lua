--author: 	Amu
--time:		2019-07-03 17:17:59

local UnionModel = import("Model/UnionModel")
import("UI/Union/UnionMember/ItemMember")
import("UI/Union/UnionMember/ItemMemberSort")

local ItemUnionVote = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionVote", ItemUnionVote)

ItemUnionVote.tempList = {}
ItemUnionVote.itemTextList = {}
ItemUnionVote.memberItem = {}
ItemUnionVote.selectMember = {}

function ItemUnionVote:ctor()

    self._titleInput = self:GetChild("textInput")
    self:AddListener(self._titleInput.onChanged,function()
        self._titleInput.text = string.gsub(self._titleInput.text, "[\t\n\r[%]]+", "")
    end)
    self._contentInput = self:GetChild("textInputContent")

    self.lastContentInput = ""
    self:AddListener(self._contentInput.onChanged,function()
        if  self._contentInput.textHeight > self._contentInput.height  then
            self._contentInput.text = self.lastContentInput
        else
            self.lastContentInput = self._contentInput.text
        end
    end)

    self._textParticipants = self:GetChild("textParticipants")

    self.itemTextList[1] = self:GetChild("itemTextBox1")
    self.itemTextList[2] = self:GetChild("itemTextBox2")

    self.memberItem[ALLIANCEPOS.R5] = {}
    self.memberItem[ALLIANCEPOS.R4] = {}
    self.memberItem[ALLIANCEPOS.R3] = {}
    self.memberItem[ALLIANCEPOS.R2] = {}
    self.memberItem[ALLIANCEPOS.R1] = {}

    self.memberItem[ALLIANCEPOS.R5].btn = self:GetChild("itemR5")
    self.memberItem[ALLIANCEPOS.R4].btn = self:GetChild("itemR4")
    self.memberItem[ALLIANCEPOS.R3].btn = self:GetChild("itemR3")
    self.memberItem[ALLIANCEPOS.R2].btn = self:GetChild("itemR2")
    self.memberItem[ALLIANCEPOS.R1].btn = self:GetChild("itemR1")

    for k,v in ipairs(self.memberItem)do
        v.btn:SetTag(true)
        v.btn:GetChild("_title").text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Class_R"..k)
        v.btn:GetChild("_name").text = UnionModel.GetAppellation(k)
        v.cilck = v.btn:GetChild("touch")
        v.ctrView =  v.btn:GetController("Controller")
        v.checkBox = v.btn:GetChild("_checkBox")
        v.isShow = false
        v.btnY = v.btn.y
        v.items = {}
        v.members = {}
        v.ctrView.selectedIndex = 2
        v.Key = k
    end


    self._btnAdd = self:GetChild("btnAdd")

    self._comboBox1 = self:GetChild("ComboBoxOptionalField").asComboBox
    self._comboBox2 = self:GetChild("ComboBoxTime").asComboBox


    self._checkBox = self:GetChild("checkBox")

    -- self._bgTop = self:GetChild("bgTop")

    self._itemTextListLen = 2
    self._itemTextX = self:GetChild("itemTextBox1").x
    self._itemTextY = self:GetChild("itemTextBox1").y


    self._tagBoxY = self:GetChild("btnAdd").Y

    -- self._bgTopH = self._bgTop.height
    self._h = self.height

    self._addH = 0

    self._comboBox2.items  = {
        StringUtil.GetI18n("configI18nCommons", "UI_TIME_HOUR", {num = 2}), 
        StringUtil.GetI18n("configI18nCommons", "UI_TIME_HOUR", {num = 8}), 
        StringUtil.GetI18n("configI18nCommons", "UI_TIME_HOUR", {num = 24})
    }
    self._comboBox2.values  = {2, 8, 24}

    self.selectMember = {}
    self.memberItemList = {}
    self.members = {}

    self:InitEvent()
    self:RefreshComboBox()
    Event.Broadcast(UNIONVOTEMEMBEREVENT.Add, UserModel.data.accountId)
end

function ItemUnionVote:InitEvent()
    self:AddListener(self._btnAdd.onClick,function()
        self:AddItemText()
    end)

    for k,v in ipairs(self.memberItem)do
        self:AddListener(v.cilck.onClick,function()
            if v.isShow then
                v.isShow = false
            else
                v.isShow = true
            end
            self:RefreahMemberItem()
            self._panel:RefreahListView1()  --item变化刷新listview
        end)
        self:AddListener(v.checkBox.onChanged,function()
            if v.checkBox.selected == true then
                for _,member in ipairs(self.members[v.Key])do
                    local isHave = false
                    for _,_select in pairs(self.selectMember)do
                        if _select.PlayerId == member.Id then
                            isHave = true
                            break
                        end
                    end
                    if not isHave then
                        local playInfo = {}
                        playInfo.PlayerId = member.Id
                        table.insert(self.selectMember, playInfo)
                    end
                end
                local allMemberCount = 0
                for k,v in ipairs(self.members) do
                    allMemberCount = allMemberCount + #v
                end
                self._textParticipants.text = StringUtil.GetI18n("configI18nCommons", "Ui_Vote_People")
                .. "(" .. UITool.GetTextColor(GlobalColor.Green, tostring(#self.selectMember)) .."/".. allMemberCount .. ")"
            else
                for _,member in ipairs(self.members[v.Key])do
                    Event.Broadcast(UNIONVOTEMEMBEREVENT.Del, member.Id)
                end
            end
            for _,item in ipairs(self.memberItemList)do
                local Id = item:GetData().Id
                item:SetCheck(false)
                for _,playerInfo in ipairs(self.selectMember)do
                    if playerInfo.PlayerId == Id then
                        item:SetCheck(true)
                    end
                end
            end
        end)
    end

    self:AddEvent(UNIONVOTEMEMBEREVENT.Add,function(Uuid)
        local playInfo = {}
        playInfo.PlayerId = Uuid
        table.insert(self.selectMember, playInfo)
        local allMemberCount = 0
        for k,v in ipairs(self.members) do
            allMemberCount = allMemberCount + #v
        end
        self._textParticipants.text = StringUtil.GetI18n("configI18nCommons", "Ui_Vote_People")
                    .. "(" .. UITool.GetTextColor(GlobalColor.Green, tostring(#self.selectMember)) .."/".. allMemberCount .. ")"
        self:RefreahMemberItem()
    end)

    self:AddEvent(UNIONVOTEMEMBEREVENT.Del,function(Uuid)
        for k,v in pairs(self.selectMember)do
            if v.PlayerId == Uuid then
                table.remove(self.selectMember, k)
                break
            end
        end
        local allMemberCount = 0
        for k,v in ipairs(self.members) do
            allMemberCount = allMemberCount + #v
        end
        self._textParticipants.text = StringUtil.GetI18n("configI18nCommons", "Ui_Vote_People")
        .. "(" .. UITool.GetTextColor(GlobalColor.Green, tostring(#self.selectMember)) .."/".. allMemberCount .. ")"
        self:RefreahMemberItem()
    end)
end

function ItemUnionVote:InitPanel(  )
    self.tempList = {}
    self.selectMember = {}
    Event.Broadcast(UNIONVOTEMEMBEREVENT.Add, UserModel.data.accountId)
    self._itemTextListLen = 2
    self._checkBox.asButton.selected = false
    self._titleInput.text = ""
    self._contentInput.text = ""

    for i=self._itemTextListLen+1,#self.itemTextList do
        self.itemTextList[i].visible = false
    end

    self._comboBox1.selectedIndex = 0
    self._comboBox2.selectedIndex = 0

    for _,v in pairs(self.itemTextList)do
        v:SetText("")
    end
    for _,v in ipairs(self.memberItem)do
        v.isShow = false
        v.checkBox.selected = false
        for _,item in ipairs(v.items)do
            item:SetCheck(false)
        end
    end
    self._addH = 0
    self:RefreshItemText()
    self._panel:RefreahListView1()  --item变化刷新listview
end

function ItemUnionVote:SetData(panel, members)
    self._panel = panel
    -- self:RefreahMember(members)
    self:RefreshItemText()
end

function ItemUnionVote:RefreshComboBox()
    local items = {}
    for i=1,self._itemTextListLen-1 do
        table.insert(items, i)
    end
    self._comboBox1.items  = items
    self._comboBox1.values  = items
end

function ItemUnionVote:AddItemText()
    if self._itemTextListLen>=6 then
        TipUtil.TipById(50230)
        return
    end
    self._itemTextListLen = self._itemTextListLen+1
    self:RefreshItemText()
    self:RefreshComboBox()
    self._panel:RefreahListView1()  --item变化刷新listview
end

function ItemUnionVote:DelItemText(index)
    if self._itemTextListLen<=2 then
        TipUtil.TipById(50231)
        return
    end
    local item = table.remove(self.itemTextList, index)
    item:SetText("")
    table.insert(self.itemTextList, item)
    self._itemTextListLen = self._itemTextListLen-1
    self:RefreshItemText()
    self:RefreshComboBox()
    self._panel:RefreahListView1()  --item变化刷新listview
end

function ItemUnionVote:RefreshItemText()
    for i=1,self._itemTextListLen do
        if not self.itemTextList[i] then
            local temp = UIMgr:CreateObject("Union", "itemUnionVoteTextBox")
            self:AddChild(temp)
            self.itemTextList[i] = temp
        end
        self.itemTextList[i].visible = true
        self.itemTextList[i].x = self._itemTextX
        self.itemTextList[i].y = self._itemTextY + 70*(i-1)
        self.itemTextList[i]:SetData(i, self)
        if self._itemTextListLen <= 2 then
            self.itemTextList[i]:ShowX(false)
        else
            self.itemTextList[i]:ShowX(true)
        end
    end
    for i=self._itemTextListLen+1,#self.itemTextList do
        self.itemTextList[i].visible = false
    end
    self._addH = 70*(self._itemTextListLen-2)

    self._btnAdd.y = self._itemTextY + self._addH + 150
    -- self._bgTop:SetSize(self._bgTop.width, self._bgTopH+self._addH)
    -- self:SetSize(self.width, (self._h+self._addH))
    self:RefreahMemberItem()
end

function ItemUnionVote:RefreahMember(members)
    self.members = members
    for k,v in ipairs(self.memberItem)do
        local onLineNum = 0
        if not self.members[k] then
            self.members[k] = {}
        end
        for _,_v in ipairs(self.members[k])do
            if _v.IsOnline then
                onLineNum = onLineNum + 1
            end
        end
        v.btn:GetChild("_member").text = string.format( "%d/%d", onLineNum, #self.members[k])
    end
end

function ItemUnionVote:RefreahMemberItem(  )
    local _addH = 0
    local itemH = 0
    for k,v in ipairs(self.memberItem)do
        local _next = self.memberItem[k-1]
        if v.isShow then
            local index = 1
            local _h = 0
            for _i,member in ipairs(self.members[k]) do
                if not v.items[index] then
                    local temp = UIMgr:CreateObject("Union", "itemUnionInvitationMember")
                    self:AddChild(temp)
                    v.items[index] = temp
                    table.insert(self.memberItemList, temp)
                end
                v.items[index]:SetData(member, UNION_VOTITEM_TYPE.SelectItem)
                for _,playerInfo in ipairs(self.selectMember)do
                    if playerInfo.PlayerId == member.Id then
                        v.items[index]:SetCheck(true)
                    end
                end
                itemH = v.items[index].height
                local _m = math.modf((_i-1)/2)      --  _m 为多少排  0 1 2 3 ...
                local _f = math.fmod(_i-1,2)        --  _f 0 为第一列  1  未第二列
                v.items[index].visible = true
                v.items[index].y = v.btn.y + v.btn.height + _m*itemH + (_m+1)*11
                v.items[index].x = _f*(v.items[index].width) + _f*20
                index = index + 1
            end
            local num = math.ceil(#self.members[k]/2)
            _h = num*(itemH + 11)
            _addH = _addH + _h

            if _next and v.items[index-1]then
                _next.btn.y = v.items[index-1].y + itemH + 11
            end
            
            for i=index, #v.items do
                v.items[i].visible = false
            end
        else
            for _,item in ipairs(v.items) do
                item.visible = false
            end
            
            if _next then
                _next.btn.y = v.btn.y + v.btn.height + 11
            end
        end
    end
    -- for _,v in ipairs(self.memberItemList)do
    --     local Id = v:GetData().Id
    --     for _,playerInfo in ipairs(self.selectMember)do
    --         if playerInfo.PlayerId == Id then
    --             v:SetCheck(true)
    --         else
    --             v:SetCheck(false)
    --         end
    --     end
    -- end
    for k,members in ipairs(self.members)do
        local isClick = false
        for _,member in ipairs(members)do
            isClick = false
            for _,playerInfo in ipairs(self.selectMember)do
                if playerInfo.PlayerId == member.Id then
                --     isClick = false
                --     break
                -- else
                    isClick = true
                end
            end
            if not isClick then
                break
            end
        end
        self.memberItem[k].checkBox.selected = isClick
    end
    self:SetSize(self.width, (self._h+self._addH+_addH))
end

function ItemUnionVote:GetVote() --返回投票详细内容，数据不符合返回false
    local vote = {}
    if self._titleInput.text == StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_EnterTitle") then
        TipUtil.TipById(50232)
        return false
    elseif self._titleInput.text == "" then
        TipUtil.TipById(50233)
        return false
    else
        vote.Title = self._titleInput.text
    end

    if self._contentInput.text == StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_EnterContent") then
        TipUtil.TipById(50220)
        return false
    elseif self._contentInput.text == "" then
        TipUtil.TipById(50220)
        return false
    else
        vote.Content = self._contentInput.text
    end

    local textList = {}
    for i=1,self._itemTextListLen do
        local text = self.itemTextList[i]:GetText()
        if text == StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_EnterTitle") then
            TipUtil.TipById(50234)
            return false
        elseif text == "" then
            TipUtil.TipById(50234)
            return false
        else
            table.insert(textList, text)
        end
    end
    vote.Options = textList

    for k,v in ipairs(textList) do
        for _k,_v in ipairs(textList)do
            if k ~= _k and v == _v then
                TipUtil.TipById(50236)
                return false
            end
        end
    end

    if not self._comboBox1.value then
        TipUtil.TipById(50237)
        return false
    else
        vote.VoteNum = self._comboBox1.value
    end

    if not self._comboBox2.value then
        TipUtil.TipById(50238)
        return false
    else
        vote.Time = self._comboBox2.value*3600
    end

    if self._checkBox.asButton.selected then
        vote.Visible = 1
    else
        vote.Visible = 0
    end

    return vote
end

function ItemUnionVote:GetMembers(  )
    if #self.selectMember <= 0 then
        TipUtil.TipById(50239)
        return
    else
        return self.selectMember
    end
end

function ItemUnionVote:IsFull()
    
end

return ItemUnionVote
