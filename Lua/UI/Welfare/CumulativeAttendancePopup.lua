--[[
    author:{maxiaolong}
    time:2019-10-24 16:14:25
    function:{查看活动奖励弹窗}
]]
local GD = _G.GD
local CumulativeAttendancePopup = UIMgr:NewUI("CumulativeAttendancePopup")
local WelfareModel = import("Model/WelfareModel")

function CumulativeAttendancePopup:OnInit()
    self.view = self.Controller.contentPane
    self._listView = self.view:GetChild("liebiao")
    self._title = self.view:GetChild("titleName")
    self._btnClose = self.view:GetChild("btnClose")
    self._bgMask = self.view:GetChild("bgMask")
    self:AddListener(self._btnClose.onClick,
        function()
            self:OnClosePanel()
        end
    )

    self:AddListener(self._bgMask.onClick,
        function(...)
            self:OnClosePanel()
        end
    )

    self._listView.itemRenderer = function(index, item)
        local info = self.itemDatas[index + 1][1]
        local num = self.itemDatas[index + 1][2]
        local itemName = GD.ItemAgent.GetItemNameByConfId(info.id)
        local mid = GD.ItemAgent.GetItemInnerContent(info.id)
        item:SetAmount(info.icon, info.color, num, itemName, mid)
        local title = itemName .. "X" .. num
        item:SetTouchCb(function()
            self.detailPop:OnShowUI(title, GD.ItemAgent.GetItemDescByConfId(info.id), item._icon, false)
        end)
        --self:SetListener(item.onTouchBegin,
        --    function()
        --        --print("onTouchBegin   " .. info.id)
        --        --print(item)
        --        UIMgr:ShowPopup("Common", "LongPressPopupLabel", item._icon, false)
        --        self.detailPop:InitLabel(title, GD.ItemAgent.GetItemDescByConfId(info.id))
        --        self.detailPop:SetArrowController(true)
        --    end
        --)
        --self:SetListener(item.onTouchEnd,
        --    function()
        --        -- print("onTouchEnd   "..info.id)
        --        UIMgr:HidePopup("Common", "LongPressPopupLabel")
        --    end
        --)
    end
    --self:AddListener(self._listView.onTouchMove,
    --    function()
    --        UIMgr:HidePopup("Common", "LongPressPopupLabel")
    --    end
    --)

    self.detailPop = UIMgr:CreatePopup("Common", "LongPressPopupLabel")
end

function CumulativeAttendancePopup:OnOpen(datas)
    local giftNum, items = WelfareModel:GetGiftInfoById(datas[1], 2)
    self.itemDatas = items
    self._listView.numItems = giftNum

    self.hasGet = datas[2]
    local text = self.hasGet == 0 and "ACTIVITY_REWARD_GETED" or "ACTIVITY_REWARD_GET"
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, text)
end

function CumulativeAttendancePopup:OnClose()
    
end

function CumulativeAttendancePopup:OnClosePanel()
    UIMgr:Close("CumulativeAttendancePopup")
end

return CumulativeAttendancePopup
