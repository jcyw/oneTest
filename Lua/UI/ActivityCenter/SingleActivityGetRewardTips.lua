--[[
    author:{laofu}
    time:2020-06-01 11:19:58
    function:{单人活动积分达到奖励条件后弹窗}
]]
local GD = _G.GD
local SingleActivityGetRewardTips = UIMgr:NewUI("SingleActivityGetRewardTips")

function SingleActivityGetRewardTips:OnInit()
    local view = self.Controller.contentPane
    self._title = view:GetChild("scoreText")
    self._bar = view:GetChild("progressBar")
    self._barText = view:GetChild("barText")
    self._btnGoto = view:GetChild("btnGoto")
    self._btntouch = view:GetChild("touch")
    self._progressArrow = view:GetChild("progressArrow")
    self._arrowText = self._progressArrow:GetChild("title")

    self:AddListener(
        self._btnGoto.onClick,
        function()
            --跳转活动页面
            UIMgr:Close("SingleActivityGetRewardTips")
            UIMgr:Open("SingleActivity")
        end
    )

    self:AddListener(
        self._btntouch.onClick,
        function()
            UIMgr:Close("SingleActivityGetRewardTips")
        end
    )

    self:AddListener(
        self._btntouch.onTouchBegin,
        function()
            UIMgr:Close("SingleActivityGetRewardTips")
        end
    )
end

function SingleActivityGetRewardTips:OnOpen()
    GD.SingleActivityAgent.GetSingleActivityInfo(
        function()
            --设置文本内容
            self._bar.max = Model.SingleActivity_StageAward[3].score
            local beforStage = Model.SingleActivity_Stage - 1 >= 0 and Model.SingleActivity_Stage - 1 or 0
            local beforscore = Model.SingleActivity_StageAward[beforStage] and Model.SingleActivity_StageAward[beforStage].score or 0
            self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_EjectTips") .. beforscore
            self._barText.text = beforscore .. "/" .. Model.SingleActivity_StageAward[3].score
            self._bar.value = beforscore

            --设置下标位置
            local view = self.Controller.contentPane
            self._progressArrow.y = self._bar.y + self._bar.height
            self._progressArrow.x = view:GetChild("box" .. Model.SingleActivity_Stage).x
            self._arrowText.text = Model.SingleActivity_StageAward[Model.SingleActivity_Stage] and Model.SingleActivity_StageAward[Model.SingleActivity_Stage].score or 0

            --设置宝箱状态
            if beforStage >= 1 then
                for i = 1, beforStage, 1 do
                    local box = view:GetChild("box" .. i)
                    local boxController = box:GetController("C1")
                    boxController.selectedIndex = 2
                end
            end
        end
    )
    --设置bar上的图标位置
    self.func = function()
        self:GtweenOnComplete(
            self._bar:TweenValue(Model.SingleActivity_Score, 1),
            function()
                if Model.SingleActivity_Stage >= 1 then
                    self._title.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Single_EjectTips") .. Model.SingleActivity_Score
                    self._barText.text = Model.SingleActivity_Score .. "/" .. Model.SingleActivity_StageAward[3].score
                    local box = self.Controller.contentPane:GetChild("box" .. Model.SingleActivity_Stage)
                    local boxController = box:GetController("C1")
                    boxController.selectedIndex = 1
                    self.front, self.behind = AnimationModel.GiftEffect(box, nil, nil, "SingleActivityGetRewardTips", self.front, self.behind)
                end
            end
        )
    end

    self:ScheduleOnce(self.func, 1)
    self:ScheduleOnce(
        function()
            UIMgr:Close("SingleActivityGetRewardTips")
        end,
        5
    )
end

function SingleActivityGetRewardTips:OnClose()
    GlobalVars.IsOpenSingleScoreTips = false
    AnimationModel.DisPoseGiftEffect("SingleActivityGetRewardTips", self.front, self.behind)
end

return SingleActivityGetRewardTips
