--[[
    author:{zhanzhang}
    time:2019-11-18 17:54:28
    function:{探索监狱选项}
]]
local PrisonExplorationPopup = UIMgr:NewUI("PrisonExplorationPopup")

function PrisonExplorationPopup:OnInit()
    local view = self.Controller.contentPane
    self._btnClose = view:GetChild("btnClose")
    self._bgMask = view:GetChild("bgMask")
    self._controller = view:GetController("Controller")
    self._btnList = {}
    self._btnController = {}
    for i = 1, 4 do
        self._btnList[i] = view:GetChild("btnTime" .. i)
        self._btnController[i] = self._btnList[i]:GetController("Ctr")
    end
    self.RefreshFunc = function()
        self:OnRefreshTime()
    end
    self:OnRegister()
end

function PrisonExplorationPopup:OnRegister()
    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("PrisonExplorationPopup")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("PrisonExplorationPopup")
        end
    )
    for i = 1, 4 do
        self._btnList[i].title = TimeUtil.ShowNeedTime(Global.SecretBaseExploreTime[i])
        self:AddListener(self._btnList[i].onClick,
            function()
                local delayTime = self.data.DeadTime - Tool.Time()
                if Global.SecretBaseExploreTime[i] > delayTime then
                    TipUtil.TipById(50196)
                    return
                end

                UIMgr:Close("PrisonExplorationPopup")

                local data = {
                    openType = ExpeditionType.SearchPrison,
                    posNum = self.posNum,
                    searchType = i - 1
                }
                UIMgr:Open("Expedition", data)
            end
        )
    end
end

function PrisonExplorationPopup:OnOpen(chunkInfo)
    self.posNum = chunkInfo.Id
    self.data = chunkInfo
    self:Schedule(self.RefreshFunc, 1)
end
function PrisonExplorationPopup:OnRefreshTime()
    self._textTrainTime.text = StringUtil.GetI18n(I18nType.Commmon, "UI_SECRECT_BASE_DISAPPEAR", {time = TimeUtil.SecondToDHMS(self.data.DeadTime - Tool.Time())})
    self:CheckEnoughtTime()
end

function PrisonExplorationPopup:OnClose()
    self:UnSchedule(self.RefreshFunc)
end
--检测时间是否足够
function PrisonExplorationPopup:CheckEnoughtTime()
    local delayTime = self.data.DeadTime - Tool.Time()
    for i = 1, 4 do
        self._btnController[i].selectedIndex = delayTime > Global.SecretBaseExploreTime[i] and 0 or 3
    end
end

return PrisonExplorationPopup
