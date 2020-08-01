--[[
    author:{laofu}
    time:2020-05-20 10:13:15
    function:{第三周活动}
]]
local RememberTheDead = UIMgr:NewUI("RememberTheDead")

function RememberTheDead:OnInit()
    local view = self.Controller.contentPane
    self._bgMask = view:GetChild("bgMask")
    self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE")
    self._text.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_MEMORYFEST_SUBHEAD")
    self.memoryDatas = ConfigMgr.GetList("configMemorys")
    --登录的时候就会获得一个次数信息
    self:RefreshTimes()

    self:InitEvent()
end

function RememberTheDead:InitEvent()
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("RememberTheDead")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("RememberTheDead")
        end
    )

    self._list.itemRenderer = function(index, item)
        local memoryData = self.memoryDatas[index + 1]
        local icon = item:GetChild("_icon")
        local title = item:GetChild("titile")
        local times = item:GetChild("times")
        local btnGoto = item:GetChild("btnExchange")
        local count = 0

        --遍历一下获得的第三周活动信息列表得到次数
        for _, v in pairs(self.TimesInfo or {}) do
            if v.Category == memoryData.id then
                count = v.Times
            end
        end

        icon.url = UITool.GetIcon(memoryData.icon)
        local str = "ACTIVITY_MEMORYFEST_CLAIM_NAME_" .. memoryData.id
        title.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_MEMORYFEST_CLAIM_NAME_" .. memoryData.id)
        times.text = StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_MEMORYFEST_CLAIM_NUM", {num = count})
        btnGoto.title = StringUtil.GetI18n(I18nType.Commmon, "BUTTON_GOTO")

        self:AddListener(btnGoto.onClick,
            function()
                if memoryData.id == 100070101 then
                    --跳转世界地图
                    JumpMap:JumpSimple(810701)
                elseif memoryData.id == 100070102 then
                    --跳转城外资源
                    local build = BuildModel.FindAssetBuildMax()
                    if build.Level ~= 0 then
                        local piece = CityMapModel.GetMapPiece(build.Pos)
                        GlobalVars.IsJumpGuide=true
                        TurnModel.EnterMyCityFunc(
                            function()
                                ScrollModel.MoveScale(piece, build.ConfId, nil, true)
                                GlobalVars.IsJumpGuide=false
                            end
                        )
                    else
                        JumpMap:JumpSimple(810001, Global.BuildingWood)
                    end
                elseif memoryData.id == 100070103 then
                    --跳转军需站页面
                    JumpMap:JumpTo({jump = 811100, para = Global.BuildingMilitarySupply})
                end
                --关闭当前页面
                UIMgr:Close("RememberTheDead")
                --关闭活动页面
                self.closeSaveCharlotte()
                Event.Broadcast(EventDefines.CloseActivityUI)
            end
        )
    end
end

function RememberTheDead:OnOpen(activityId,closeCb)
    self.closeSaveCharlotte = closeCb
    self.activityId = activityId
    self:RefreshTimes()
    self._list.numItems = #self.memoryDatas
end


function RememberTheDead:RefreshTimes()
    if self.activityId==1000701 then
        self.TimesInfo = _G.ActivityModel.GetMemoryTimesInfo()
    end
    if self.activityId==1001301 then
        self.TimesInfo = _G.ActivityModel.GetArmsRaceTimesInfo()
    end
end

function RememberTheDead:OnClose()
    -- UIMgr:Close("RememberTheDead")
end

return RememberTheDead
