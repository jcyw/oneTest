--[[
    author:{zhanzhang}
    time:2019-11-25 17:21:10
    function:{外城主界面行军队列}
]]
local ItemWorldQueueList = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/worldQueueList", ItemWorldQueueList)

function ItemWorldQueueList:ctor()
    self._controller = self:GetController("c1")
    self:OnRegister()
end

function ItemWorldQueueList:OnRegister()
    self:AddListener(self._btnMore.onClick,
        function()
            self:OnClickMoreQueue()
        end
    )
    -- self._queueGlist:SetVirtual()
    self._queueGlist.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:init(self.missions[index + 1])
    end
    self.isShowAll = false
end

function ItemWorldQueueList:Init(missions)
    self.missions = missions
    self.nowQueueCount = #self.missions
    self._queueGlist.numItems = self.nowQueueCount
    self:OnRefreshQueueRect()
end

--显示更多进度条
function ItemWorldQueueList:OnClickMoreQueue()
    self.isShowAll = not self.isShowAll
    self:OnRefreshQueueRect()
end

function ItemWorldQueueList:OnRefreshQueueRect()
    --一般情况最多显示两个，点击更多全部显示

    local isShowBtn = self.nowQueueCount > 2
    local showCount = self.nowQueueCount
    if not self.isShowAll then
        showCount = self.nowQueueCount < 2 and self.nowQueueCount or 2
        local str = StringUtil.GetI18n(I18nType.Commmon, "UI_QUEUE_MORE", {amount = self.nowQueueCount - 2})
        self._textMore.text = self.nowQueueCount > 2 and str or ""
    else
        self._textMore.text = ""
    end

    self._queueGlist.height = (59 + 5) * showCount
    self._queueBg.height = (59 + 5) * showCount + 10 + (isShowBtn and 52 or 0)

    self._groupBtnMore.visible = self.nowQueueCount > 2
    self._controller.selectedIndex = self.isShowAll and 1 or 0
end

return ItemWorldQueueList
