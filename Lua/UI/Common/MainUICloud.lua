--[[
    author:{zhanzhang}
    time:2019-12-16 16:43:04
    function:{云层遮罩}
]]
local MainUICloud = UIMgr:NewUI("MainUICloud")
isClouding = false
local delayTime = 0
local isFinsh = false
local isFirst = false
local isLoadMapFinish = false
local GlobalVars = GlobalVars

function MainUICloud:OnInit()
    local view = self.Controller.contentPane
    self._animCloudOut = view:GetTransition("cloudAnimOut")
    self._animCloudIn = view:GetTransition("cloudAnimIn")
    self.CloseFunc = function()
        KSUtil.ResourcesUnloadUnusedAssets()
        KSUtil.MonoGc()
        self._animCloudOut:Play(
            function()
                if self.afterAnimCb then
                    self.afterAnimCb()
                end
                if (GlobalVars.IsHadChangeMap) then
                    GlobalVars.IsHadChangeMap = false
                    Log.Warning("UIMgr:Close    MainUICloud")
                    UIMgr:Close("MainUICloud")
                end
                --处理搜索引导点击
            end
        )
    end
    self:OnRegister()
end

function MainUICloud:OnRegister()
    self:AddEvent(
        EventDefines.UIMapLoadingFinish,
        function()
            if not isLoadMapFinish then
                isLoadMapFinish = true
                --第一次加载如果比云层关闭慢，立即打开云层
                if isFirst then
                    self:UnScheduleFast(self.CloseFunc)
                    self.CloseFunc()
                end
            end
        end
    )
    -- self:AddEvent(
    --     EventDefines.LoadMapUIFinish,
    --     function()
    --         if isFirst and _G.isLoadMapUI then
    --             self:UnScheduleFast(self.CloseFunc)
    --             self.CloseFunc()
    --         end
    --     end
    -- )
end

function MainUICloud:OnOpen(beforeAnimCb, afterAnimCb, isLogin)
    isClouding = true
    self.afterAnimCb = afterAnimCb
    self._animCloudIn:Play(beforeAnimCb)
    if isLoadMapFinish then
        delayTime = 0.7
    else
        isFirst = false
        delayTime = 5
        self:ScheduleOnceFast(
            function()
                --云层第一次关闭时
                if isLoadMapFinish then
                    isLoadMapFinish = true
                    self.CloseFunc()
                else
                    isFirst = true
                end
            end,
            0.7
        )
    end
    self:ScheduleOnceFast(self.CloseFunc, delayTime)
end

function MainUICloud:OnClose()
    Event.Broadcast(EventDefines.UICloudOutFinish)
    isClouding = false
end

return MainUICloud
