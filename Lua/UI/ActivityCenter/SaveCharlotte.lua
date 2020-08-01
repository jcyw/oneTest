--[[
    author:{maxiaolong}
    time:2020-01-16 09:55:08
    function:{活动公用面板}
]]
local GD = _G.GD
local SaveCharlotte = UIMgr:NewUI("SaveCharlotte")
local ActivityModel = import("Model/ActivityModel")
local WelfareModel = import("Model/WelfareModel")
function SaveCharlotte:OnInit()
    self._view = self.Controller.contentPane
    self._viewCom = self._view:GetChild("list"):GetChildAt(0)
    self._getBtn = self._view:GetChild("btnGet")
    self._btnReturn = self._view:GetChild("btnReturn")
    self._textTagName = self._viewCom:GetChild("textTagName")
    self._activtyBg = self._viewCom:GetChild("textActivity")
    self._time = self._view:GetChild("textTime")
    self._textName = self._view:GetChild("textName")
    self._textDes = self._view:GetChild("textDescribe")
    self._textSalvation = self._view:GetChild("textSalvation")
    self._text = self._viewCom:GetChild("text")
    self:AddListener(
        self._getBtn.onClick,
        function()
            --跳转页面
            if self.config.jumpPage then
                UIMgr:Open(
                    self.config.jumpPage.page,
                    self.config.jumpPage.activityId,
                    function()
                        UIMgr:Close("SaveCharlotte")
                    end
                )
                if not self.config.jumpPage.hascb then
                    Event.Broadcast(EventDefines.CloseActivityUI)
                    UIMgr:Close("SaveCharlotte")
                end
            end
        end
    )
    self._list = self._viewCom:GetChild("liebiao")
    self._list.itemRenderer = function(index, item)
        local itemData = self.items[index + 1]
        local title = GD.ItemAgent.GetItemNameByConfId(itemData.id)
        item:SetAmount(itemData.icon, itemData.color, nil, title)
    end
    self:AddListener(
        self._btnReturn.onClick,
        function()
            UIMgr:Close("SaveCharlotte")
        end
    )

    --设置Banner
    --self._banner.icon = UITool.GetIcon(GlobalBanner.BlackKnight)
end

function SaveCharlotte:OnOpen(info)
    self.confId = info.Id
    local items = ActivityModel.GetActivityAward(info.Id)
    self.items = items
    self._list.numItems = #items
    self:EndTimeRender(info.EndAt)
    self.config = info.Config
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, self.config.activity_name)
    self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_REWARD")
    self._activtyBg.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_BACKGROUND")
    self._getBtn:GetChild("title").text = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")
    self._textDes.text = StringUtil.GetI18n(I18nType.Commmon, self.config.activity_desc)
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, self.config.activity_bg)
    self._textSalvation.text = StringUtil.GetI18n(I18nType.Commmon, self.config.activity_name)
    self._banner.icon = UITool.GetIcon(self.config.banner)
end

function SaveCharlotte:EndTimeRender(endTime)
    local mTimeFunc = function()
        return endTime - Tool.Time()
    end
    local time = mTimeFunc()
    self.callbackTime = function()
        if mTimeFunc() > 0 then
            self._time.text =
                StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = TimeUtil.SecondToDHMS(time)})
        end
        if time <= 0 then
            self:UnSchedule(self.callbackTime)
            UIMgr:Close("SaveCharlotte")
            --Event.Broadcast(EventDefines.RefreshActivityUI)
            return
        end
        time = mTimeFunc()
    end
    self:Schedule(self.callbackTime, 1)
end

function SaveCharlotte:OnClose()
    self:UnSchedule(self.callbackTime)
    if UIMgr:GetUIOpen("RememberTheDead") then
        UIMgr:Close("RememberTheDead")
    end
end
return SaveCharlotte
