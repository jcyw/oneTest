--author: 	Amu
--time:		2019-07-08 11:04:16

local ItemUnionVoteRecordView = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionVoteRecordView", ItemUnionVoteRecordView)

ItemUnionVoteRecordView.tempList = {}

ItemUnionVoteRecordView._scheduler = false

function ItemUnionVoteRecordView:ctor()
    self._icon = self:GetChild("icon")

    self._textTitle = self:GetChild("textTitle")
    self._textPlayerName = self:GetChild("textPlayerName")
    self._textParticipantsNum = self:GetChild("textParticipantsNum")
    self._textTime = self:GetChild("textTime")

    self._textOngoing = self:GetChild("textOngoing")

    self._checkBox = self:GetChild("checkBox")

    self._ctrView = self:GetController("c1")

    self._iconX = self._icon.x

    self:InitEvent()
end

function ItemUnionVoteRecordView:InitEvent()
    self:AddListener(self._checkBox.onChanged,function()
        local _selectd = self._checkBox.asButton.selected
        if _selectd then
            Event.Broadcast(UNIONVOTERECORDEVENT.Add, self.info.Uuid, self.index)
        else
            Event.Broadcast(UNIONVOTERECORDEVENT.Del, self.info.Uuid, self.index)
        end
    end)

    local callback
    callback = function()
        if not self._endTime then
            return
        end
        local time = self._endTime - Tool.Time()
        if time <= 0 then
            self:UnSchedule(callback)
            self._scheduler = false
            self._textOngoing.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Over")
            self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Cutoff")
            return
        end
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Deadline", {time = TimeUtil.SecondToHMS(time)})
    end
    self.dt = 0.5
    self.callback = callback
    self:AddEvent(UNIONVOTECOUNTDOWNEVNET.Start, function()
        if not self._scheduler then
            self:Schedule(callback, self.dt)
            self._textOngoing.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Ongoing")
            self._scheduler = true
            callback()
        end
    end)

    self:AddEvent(UNIONVOTECOUNTDOWNEVNET.End, function()
        self:UnSchedule(callback)
        self._scheduler = false
        self._textOngoing.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Over")
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Cutoff")
    end)
end

function ItemUnionVoteRecordView:SetData(index, info, isClick)
    self.index = index
    self.info = info

    self._endTime = info.Start + info.Time
    if self._endTime <= Tool.Time() then
        self._textOngoing.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Over")
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Cutoff")
    else
        self._textOngoing.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Ongoing")
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Vote_Deadline", {time = TimeUtil.SecondToHMS(self._endTime - Tool.Time())})
    end

    self._textTitle.text = info.Title
    self._textPlayerName.text = StringUtil.StringShortly(info.PlayerName,18)
    
    local voteNum = 0
    for _,v in ipairs(info.members)do
        if #v.Votes>0 then
            voteNum = voteNum + 1
        end
    end

    self._textParticipantsNum.text = string.format( "%d/%d",voteNum, #info.members)
    

    self._checkBox.asButton.selected = info._select

    if isClick then
        self._ctrView.selectedIndex = 1
    else
        self._ctrView.selectedIndex = 0
    end

    if not self._scheduler then
        self:Schedule(self.callback, self.dt)
        self._scheduler = true
    end
end

function ItemUnionVoteRecordView:getData(  )
    return self.info
end

return ItemUnionVoteRecordView