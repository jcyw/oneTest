--[[
    author:{laofu}
    time:2020-04-14 09:56:09
    function:{美女在线奖励}
]]
local GD = _G.GD
local BeautyOnlineRewards = UIMgr:NewUI("BeautyOnlineRewards")

--奖励列表对象
--技能列表对象

function BeautyOnlineRewards:OnInit()
    --显示页面
    self.girlsID = 1
    local view = self.Controller.contentPane
    self.maxFavor = GD.BeautyAgent.GetMaxFavor(self.girlsID)

    local uibg = self._uibg:GetChild("_icon")
    UITool.GetIcon({"falcon", "bg_beauty_01"}, uibg)
    --元件
    self._titleName = view:GetChild("textName")
    self._titleSkill = view:GetChild("textSkill")
    --美女立绘的占位，和美女的名字
    self._belleLoader = view:GetChild("hero")
    self._girlName = view:GetChild("titleHreoName")
    --好感度进度条
    self._pbTitle = view:GetChild("text")
    self._progressEffect = view:GetChild("progressEffect")
    --两个列表，一个奖励列表，一个技能列表
    self._awardList = view:GetChild("liebiao")
    self._skillList = view:GetChild("liebiaoSkill")
    self._dialogGroup = view:GetChild("dialogGroup")
    --设置元件内容
    self._awardList.scrollItemToViewOnClick = false
    self._skillList.scrollItemToViewOnClick = false
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "GirlOnlineReward_Title")
    self._titleSkill.text = StringUtil.GetI18n(I18nType.Commmon, "Button_Commander_Skill")
    self._girlName.text = StringUtil.GetI18n(I18nType.Commmon, "GirlOnlineReward_Name")
    self._belleLoader.url = GD.BeautyAgent.GetBeautyIconForIndex(self.girlsID)
    self._skillTab = GD.BeautyAgent.GetSkillTable(self.girlsID)
    self._skillTabList = GD.BeautyAgent.GetSkillTable(self.girlsID)
    self._progressBar.max = self.maxFavor
    self.proArrow0 = view:GetChild("progressArrow0")

    --奖励ID列表
    self._awardTab = GD.BeautyAgent.GetAwardTable()
    --在线时间列表
    self._timesTab = GD.BeautyAgent.GetTimeTable()

    --按钮事件
    self:AddListener(
        self._btnReturn.onClick,
        function()
            UIMgr:Close("BeautyOnlineRewards")
        end
    )
    --订阅事件
    self:AddEvent(
        EventDefines.BeautyOnlineRefresh,
        function()
            self:RefreshShow()
        end
    )
    --根据美女的号码得到技能列表
    self._skillList.itemRenderer = function(index, gObject)
        local skillID = self._skillTab[index + 1]
        gObject:SetData(skillID)
    end
    --设置列表渲染
    self._awardList.itemRenderer = function(index, gObject)
        --奖励列表的渲染内容
        local itemData = self.rewardItemIndexInfo[index + 1]
        --奖励列表需要得到（id,道具信息，是否已经领取，列表的最大个数）
        --道具信息包括（后台信息，文本1，文本2）
        --后台信息包括（领取到第几个，下个领取时间，当前是否有可领取的）
        gObject:SetData(itemData.id, itemData.itmeInfo, itemData.isReceived, self._awardList.numChildren, false)
    end
end

function BeautyOnlineRewards:DoOpenAnim(...)
    self:OnOpen(...)
    AnimationLayer.PanelAnim(AnimationType.PanelMovePreRight, self)
end

function BeautyOnlineRewards:OnOpen()
    --刷新列表显示
    self:RefreshShow()
    --设置进度条下标位置
    self.favorTab = {}
    local offset = self._progressBar.width / self.maxFavor
    local proArrowx = self.proArrow0.x
    self.proArrow0:GetChild("title").text = 0
    for i = 1, 7, 1 do
        local _proArrow = self.Controller.contentPane:GetChild("progressArrow" .. i)
        _proArrow:GetChild("title").text = self._skillTabList[i].favor
        _proArrow.x = proArrowx + (offset * self._skillTabList[i].favor)
        table.insert(self.favorTab, self._skillTabList[i].favor)
    end
    --设置对话框显示时间
    self._dialogGroup.visible = true
    local rondom = math.random(3)
    self._textSpeak.text = StringUtil.GetI18n(I18nType.Commmon, "GirlOnlineReward_Dialogue" .. rondom)
    self._belleLoader.url = GD.BeautyAgent.GetBeautyIconForIndex(self.girlsID)
    self:ScheduleOnce(
        function()
            self._dialogGroup.visible = false
        end,
        5
    )
end

function BeautyOnlineRewards:OnClose()
end

--刷新页面显示（包括刷新奖励列表、好感度、第几号美女、美女技能列表）
function BeautyOnlineRewards:RefreshShow()
    self.rewardItemOnlineInfo = {}
    local girlsInfo = {}
    Net.Beauties.OnlineBonusInfo(
        function(rsp)
            --获得列表信息
            self.rewardItemOnlineInfo = {
                category = rsp.Index + 1,
                finishAt = rsp.AvaliableAt,
                status = 0
            }
            if rsp.AvaliableAt > Tool.Time() then
                self.rewardItemOnlineInfo.status = 0
            else
                self.rewardItemOnlineInfo.status = 1
            end
            girlsInfo = rsp.BeautyInfo
            --好感度刷新
            if self._progressBar.value < girlsInfo.Exp then
                self:PlayProgressEffect(girlsInfo.Exp)
            else
                self._progressBar.value = girlsInfo.Exp
            end
            self._progressValue.text = string.format("%d/%d", girlsInfo.Exp, self._progressBar.max)
            local tempNum = 0
            for k, v in pairs(self.favorTab) do
                if girlsInfo.Exp > v then
                    tempNum = k
                end
            end
            self._pbTitle.text = StringUtil.GetI18n(I18nType.Commmon, "GirlOnlineReward_Favordesc", {number = self.favorTab[tempNum + 1]})
            --排序和刷新列表
            self:AwardTabelSort()
            self._awardList.numItems = #self._awardTab
            self._skillList.numItems = #self._skillTab
        end
    )
end

--奖励列表的排序
function BeautyOnlineRewards:AwardTabelSort()
    self.rewardItemIndexInfo = {}
    for i = 1, #self._awardTab, 1 do
        --设置奖励列表的数据(id，itemInfo,isreceived)
        local text1ID = "GodzillaOnlineReward" .. tostring(i + 1)
        local text2ID = "GodzillaOnlineReward" .. tostring(i + 7)
        local rewardStr1 = StringUtil.GetI18n(I18nType.Commmon, text1ID)
        local rewardStr2 = StringUtil.GetI18n(I18nType.Commmon, text2ID)

        local data = {
            id = self._awardTab[i],
            itmeInfo = {nil, rewardStr1, rewardStr2},
            isReceived = false
        }
        if i < self.rewardItemOnlineInfo.category then
            data.isReceived = true
        elseif i == self.rewardItemOnlineInfo.category then
            data.itmeInfo = {self.rewardItemOnlineInfo, rewardStr1, rewardStr2}
        end
        table.insert(self.rewardItemIndexInfo, data)
    end
    --排序
    table.sort(
        self.rewardItemIndexInfo,
        function(a, b)
            local flag
            if a.isReceived and not b.isReceived then
                return false
            end
            if not a.isReceived and b.isReceived then
                return true
            end
            flag = a.id < b.id
            return flag
        end
    )
end

--进度条特效
function BeautyOnlineRewards:PlayProgressEffect(value)
    local globalPos = self._progressBar:GetChild("effect"):LocalToGlobal(Vector2.zero)
    local endPos = self.Controller.contentPane:GlobalToLocal(globalPos)
    local data = {
        startPos = self._progressEffect.xy,
        endPos = endPos,
        startNode = self.Controller.contentPane,
        endNode = self._progressBar:GetChild("effect"),
        progressBar = self._progressBar,
        progressValue = value
    }
    AnimationModel.ProgressBarEffect(data)
end

return BeautyOnlineRewards
