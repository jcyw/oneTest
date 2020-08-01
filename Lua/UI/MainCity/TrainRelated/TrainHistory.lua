--[[
    Author: songzeming
    Function: 兵种历史背景
]]
local TrainHistory = UIMgr:NewUI("TrainRelated/TrainHistory")

local TrainModel = import("Model/TrainModel")

function TrainHistory:OnInit()
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("TrainRelated/TrainHistory")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("TrainRelated/TrainHistory")
        end
    )
    self:AddListener(self._list.scrollPane.onScrollEnd,
        function()
            self:UpdateData()
        end
    )
    self:AddListener(self._arrowL.onClick,
        function()
            self:OnBtnArrowClick(-1)
        end
    )
    self:AddListener(self._arrowR.onClick,
        function()
            self:OnBtnArrowClick(1)
        end
    )
end

function TrainHistory:OnOpen(armyId, confId)
    self.armyId = armyId
    self.armyIds = {}

    self:UpdateList(confId)
    self:UpdateData()
end

function TrainHistory:UpdateList(confId)
    local arm = TrainModel.GetArm(confId)
    self._list.numItems = arm.amount

    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local armyId = arm.base_level + i - 1
        item.icon = TrainModel.GetImageNormal(armyId)
        if armyId == self.armyId then
            if not self.first then
                self.first = true
                self._list.scrollPane:ScrollRight(i - 1, false)
            else
                self._list.scrollPane:SetCurrentPageX(i - 1)
            end
        end
        table.insert(self.armyIds, armyId)
    end
end

function TrainHistory:UpdateData()
    local armyId = self.armyIds[self._list.scrollPane.currentPageX + 1]
    self._textName.text = TrainModel.GetName(armyId)
    self._textTitle.text = StringUtil.GetI18n(I18nType.Army, armyId .. "_WEAPON")
    self._text.text = StringUtil.GetI18n(I18nType.Army, armyId .. "_STORY")
    local conf = ConfigMgr.GetItem("configArmys", armyId)
    for i = 1, 3 do
        local desc = StringUtil.GetI18n(I18nType.Army, conf["para" .. i .. "_name"])
        local value = conf["para" .. i .. "_num"]
        self["_para" .. i].text = desc .. " : " .. value
    end
    self:ShowArrow()
end

function TrainHistory:OnBtnArrowClick(dir)
    self._list.scrollPane:SetCurrentPageX(self._list.scrollPane.currentPageX + dir, true)
    self:UpdateData()
end

function TrainHistory:ShowArrow()
    self._arrowL.visible = true
    self._arrowR.visible = true
    if self._list.scrollPane.currentPageX == 0 then
        self._arrowL.visible = false
    elseif self._list.scrollPane.currentPageX == self._list.numChildren - 1 then
        self._arrowR.visible = false
    end
end

return TrainHistory
