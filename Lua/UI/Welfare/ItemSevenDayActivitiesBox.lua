local ItemSevenDayActivitiesBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemSevenDayActivitiesBox", ItemSevenDayActivitiesBox)
local ProgressBreakPercent = {10, 30, 50, 68, 88}
local WelfareModel = import("Model/WelfareModel")
local testValue = 0
local effectDic = {}
function ItemSevenDayActivitiesBox:ctor()
    -- self._grips = {}
    self._btnBoxes = {}
    self._texts = {}
    self._points = {}
    for i = 1, 5 do
        self._btnBoxes[i] = self:GetChild("box" .. i)
        -- self._grips[i] = self:GetChild("grip"..i)
        self._points[i] = self:GetChild("point" .. i)
        self._texts[i] = self._btnBoxes[i]:GetChild("title")
        self._btnBoxes[i]:GetController("C1").selectedIndex = 0
        local effect = {front = nil, behind = nil}
        effectDic[i] = effect
        self:AddListener(self._btnBoxes[i].onClick,
            function()
                if not self.hasGet[i] and self.canGet[i] then
                    local rewards = {}
                    local giftId = ConfigMgr.GetItem("configSevenDayPoints", i).gift
                    local items = ConfigMgr.GetItem("configGifts", giftId).items
                    for _, item in ipairs(items) do
                        local reward = {
                            Category = Global.RewardTypeItem,
                            ConfId = item.confId,
                            Amount = item.amount
                        }
                        table.insert(rewards, reward)
                    end

                    WelfareModel.GetSevenDaysTaskBonus(
                        i,
						function(rsp)
                            Event.Broadcast(EventDefines.WelfareRefreshPoint, CuePointModel.SubType.Welfare.RookieGrowth.Id, -1)
                            UITool.ShowReward(rewards)
                            self.hasGet[i] = true
                            self:RefreshBtn()
                            --领取宝箱
                        end
                    )
                else
                    UIMgr:Open("SevenDayActivitiesPopup", {id = i, hasGet = self.hasGet[i]})
                end
            end
        )
    end
    self._progressBar = self:GetChild("progressBar")
    self._progressBar.value = 0
    self._progressBar.max = 100
    local conf = ConfigMgr.GetList("configSevenDayPoints")
    self.confBreakAmount = {}
    self.canGet = {}
    self.hasGet = {}
    for i, v in ipairs(conf) do
        table.insert(self.confBreakAmount, v.taskAmount)
        self._texts[i].text = v.taskAmount
        self.canGet[i] = false
        self.hasGet[i] = false
    end
    self.value = 0
end

function ItemSevenDayActivitiesBox:SetAward(award)
    self.award = award
end

function ItemSevenDayActivitiesBox:SetProgress(value)
    local lastPoint = 0
    local progressValue = 100
    for i, amount in ipairs(self.confBreakAmount) do
        if value < amount then
            progressValue = (value - lastPoint) / (amount - lastPoint)
            local lastPercent = ProgressBreakPercent[i - 1] or 0
            progressValue = progressValue * ProgressBreakPercent[i] + (1 - progressValue) * lastPercent
            break
        end
        self._btnBoxes[i]:GetController("C1").selectedIndex = 0
        lastPoint = amount
    end
    self._progressBar.value = math.floor(progressValue)
    self.value = value
    self:SetState()
end

function ItemSevenDayActivitiesBox:SetState()
    for i, v in ipairs(self.confBreakAmount) do
        if self.value >= v then
            self.canGet[i] = true
        end
    end
    table.sort(
        self.award,
        function(a, b)
            return a.Id < b.Id
        end
    )
    for i, v in ipairs(self.award) do
        self.hasGet[i] = v.Status
    end
    self:RefreshBtn()
end

function ItemSevenDayActivitiesBox:RefreshBtn()
    for i, btn in ipairs(self._btnBoxes) do
		-- local state = self.hasGet[i] and 1 or 0
		
		local pointC1 = self._points[i]:GetController("c1")
        if self.canGet[i] and not self.hasGet[i] then
            --刷新红点
            Event.Broadcast(EventDefines.UIWelfareRookieGrowth)
            self:SetBtnState(btn, 1)
            pointC1.selectedIndex = 1
        elseif self.hasGet[i] then
            self:SetBtnState(btn, 2)
            pointC1.selectedIndex = 1
        else
            self:SetBtnState(btn, 0)
            pointC1.selectedIndex = 0
        end
        self:PlayBoxEffect(btn, i)
    end
end

function ItemSevenDayActivitiesBox:SetBtnState(btn, state)
    btn:GetController("C1").selectedIndex = state
end

function ItemSevenDayActivitiesBox:GetValue()
    return self.value
end

--播放宝箱特效
function ItemSevenDayActivitiesBox:PlayBoxEffect(tempBox, index)
    local controller = tempBox:GetController("C1")
    local effects = effectDic[index]
    if controller.selectedIndex == 1 then
        effects.front, effects.behind = AnimationModel.GiftEffect(tempBox, nil, Vector3(0.6, 0.6, 1), "ItemSevenDayActivitiesBox" .. index, effects.front, effects.behind)
    else
        AnimationModel.DisPoseGiftEffect("ItemSevenDayActivitiesBox" .. index, effects.front, effects.behind)
    end
end

return ItemSevenDayActivitiesBox
