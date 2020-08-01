--[[
    author:{maxiaolong}
    time:2019-12-07 10:55:05
    function:{侦查活动相关}
]]
local DetectActivity = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/DetectActvity", DetectActivity)
local WelfareModel = import("Model/WelfareModel")
local cutData = nil
local personData, unionData = nil
--默认为第一页
local cutIndex = 0
function DetectActivity:ctor()
    self._textSalvation = self:GetChild("textSalvation")
    self._textSalvation.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_INVERSTIGATION_NAME")
    self._textDes = self:GetChild("textDescribe")
    self._textDes.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_INVERSTIGATION_DESC")
    self._textTimer = self:GetChild("textTime")
    self._listView = self:GetChild("liebiao")
    self._textDown = self:GetChild("textDown")
    self._c1 = self:GetController("c1")
    self._cumulativeTag = self:GetChild("cumulativeTag")
    self._unionTag = self:GetChild("unionTag")
    self._unionTagText = self._unionTag:GetChild("title")
    self._cumulativeTagText = self._cumulativeTag:GetChild("title")
    self._unionTagText.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Task")
    self._cumulativeTagText.text = StringUtil.GetI18n(I18nType.Commmon, "PERSONAL_ACTIVITY_INVERSTIGATION")
    self._textDown.text = StringUtil.GetI18n(I18nType.Commmon, "UI_EVERTDAY_RESET")
    self._listView.itemRenderer = function(index, item)
        item:SetData(self.itemData[index + 1], WelfareModel.TemplateType.Detect)
    end

    self:AddEvent(
        EventDefines.DetectRefresh,
        function()
            if self.visible then
                self:RefreshShow(false, self._c1.selectedIndex)
            end
        end
    )

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.InvestigateActivity)
    self:AddListener(self._cumulativeTag.onClick,
        function()
            self:TagChage(0)
        end
    )
    self:AddListener(self._unionTag.onClick,
        function()
            self:TagChage(1)
        end
    )
end

function DetectActivity:TagChage(index)
    self._c1.selectedIndex = index
    self:RefreshList(index)
end

function DetectActivity:OnOpen()
    self:RefreshShow(true, 0)
end

function DetectActivity:RefreshShow(playAnim, c1Page)
    self:SetShow(true)
    self._c1.selectedIndex = c1Page
    Net.InvestigationActivity.GetInvestigationActivityInfo(
        function(msp)
            personData, unionData = WelfareModel.GetDetectConfig(msp)
            self:RefreshList(c1Page)
            if self.cd_func then
                self:UnSchedule(self.cd_func)
            end
            local timeNum = msp.RefreshAt
            local mTimeFunc = function()
                return timeNum - Tool.Time()
            end
            local ctime = mTimeFunc()
            if ctime > 0 then
                local refreshTimeFunc = function(t)
                    self._textTimer.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = Tool.FormatTime(ctime)})
                end
                self.cd_func = function()
                    ctime = mTimeFunc()
                    if ctime >= 0 then
                        refreshTimeFunc(ctime)
                        return
                    else
                        self._textTimer.text = StringUtil.GetI18n(I18nType.Commmon, "UNION_ARMY_OVER_TIME", {time = "0:00:00"})
                    end
                end
                self:Schedule(self.cd_func, 1)
            end
        end
    )
    if playAnim then
        self:PlayAnim()
    end
end

function DetectActivity:SetShow(isShow)
    self.visible = isShow
    if not self.visible then
        self:UnSchedule(self.cd_func)
    end
end

function DetectActivity:PlayAnim()
    for i = 1, self._listView.numChildren do
        local item = self._listView:GetChildAt(i - 1)
        GTween.Kill(item)
        item.x = -item.width
        self:GtweenOnComplete(item:TweenMoveX(item.x, 0.1 * i),function()
            item:TweenMoveX(0, 0.2)
        end)
    end
end

function DetectActivity:RefreshList(index)
    cutIndex = index
    if not personData then
        return
    end
    if cutIndex == 0 then
        cutData = personData
    else
        cutData = unionData
    end
    self.itemData = cutData
    self._listView.numItems = #cutData
end

return DetectActivity
