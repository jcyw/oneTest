--[[
    Author: songzeming
    Function: 举报玩家
]]
local PlayerComplaintBox = UIMgr:NewUI("PlayerInfo/PlayerComplaintBox")

import("UI/PlayerDetail/PlayerInfo/ItemPlayerComplaintBox")
local COMPLAINT_TYPE = {
    "Ui_Commander_AccusationCheat", --举报外挂
    "Ui_Commander_AccusationName", --举报名称
    "Ui_Commander_AccusationManifesto", --举报宣言
    "Ui_Commander_AccusationIcon" --举报头像
}

function PlayerComplaintBox:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("Controller")

    self:AddListener(self._btnSure.onClick,
        function()
            self:OnBtnComplaintClick()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnCancel.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            self:Close()
        end
    )

    self._list.scrollPane.touchEffect = false
end

function PlayerComplaintBox:OnOpen(playerId, name)
    self.playerId = playerId
    local textName = UITool.GetTextColor(GlobalColor.Red, name)
    self._name.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_Commander_Accusation") .. ": " .. textName

    self._list.numItems = 4
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local cb_func = function()
            for j = 1, self._list.numChildren do
                self._list:GetChildAt(j - 1):SetChoose(false)
            end
            item:SetChoose(true)
        end
        local title = StringUtil.GetI18n(I18nType.Commmon, COMPLAINT_TYPE[i])
        item:Init(title, cb_func)
    end
end

function PlayerComplaintBox:Close()
    UIMgr:Close("PlayerInfo/PlayerComplaintBox")
end

--点击举报
function PlayerComplaintBox:OnBtnComplaintClick()
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local isCheck = item:GetChoose()
        if isCheck then
            TipUtil.TipById(50129)
            return
        end
    end
    TipUtil.TipById(50042)
end

return PlayerComplaintBox
