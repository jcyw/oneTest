--[[
    author:{maxiaolong}
    time:2020-5-27 10:55:05
    function:{猎狐犬行动}
]]
local HuntingDogActivity = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/HuntingDogActivity", HuntingDogActivity)
local WelfareModel = import("Model/WelfareModel")
function HuntingDogActivity:ctor()
    self._textSalvation = self:GetChild("textSalvation")
    self._textSalvation.text = StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FOXHOUND_NAME")
    self._textDes = self:GetChild("textDescribe")
    self._textDes.text = StringUtil.GetI18n(I18nType.Commmon, "UI_KILL_FRONTLINE_DESC")
    self._textTimer = self:GetChild("textTime")
    self._listView = self:GetChild("liebiao")
    self._textDown = self:GetChild("textDown")
    self._textDown.text = StringUtil.GetI18n(I18nType.Commmon, "UI_EVERTDAY_RESET")
    self._listView.itemRenderer = function(index, item)
        local itemData = {
            isReward = false,
            progress = 1
        }
        item:SetData(self.itemData[index + 1], WelfareModel.TemplateType.HuntingDog)
    end
    self:AddEvent(
        EventDefines.HuntingUIRefreshUI,
        function(msg)
            if self.visible then
                self:OnOpen()
            end
        end
    )

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.WelfareFoxHound)
end

function HuntingDogActivity:OnOpen()
    self:SetShow(true)
    Net.ActivityTask.GetHuntFoxInfos(
        function(val)
            local dataList = WelfareModel.GetHuntingDogInfo(val)
            self.itemData = dataList
            self._listView.numItems = #dataList

            if self.cd_func then
                self:UnSchedule(self.cd_func)
            end
            local timeNum = val.RefreshAt
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
    self:PlayAnim()
end

function HuntingDogActivity:SetShow(isShow)
    self.visible = isShow
    if not self.visible then
        self:UnSchedule(self.cd_func)
    end
end

function HuntingDogActivity:PlayAnim()
    for i = 1, self._listView.numChildren do
        local item = self._listView:GetChildAt(i - 1)
        GTween.Kill(item)
        item.x = -item.width
        self:GtweenOnComplete(item:TweenMoveX(item.x, 0.1 * i),function()
            item:TweenMoveX(0, 0.2)
        end)
    end
end

return HuntingDogActivity
