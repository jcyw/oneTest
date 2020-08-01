local ItemExpeditionArmy = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/ItemExpeditionArmy", ItemExpeditionArmy)

local ArmiesModel = import("Model/ArmiesModel")
local TrainModel = import("Model/TrainModel")

ExpeditionItemType = {
    number = "number", -- 数字显示
    percent = "percent" -- 百分比显示
}

function ItemExpeditionArmy:ctor()
    self._slide = self:GetChild("slide")
    self._bg = self._slide:GetChild("sliderBg")
    self.barWidth = self._bg.width
    self._slideBar = self._slide:GetChild("bar")
    self._btnReduce = self:GetChild("btnReduce")
    self._btnAdd = self:GetChild("btnAdd")
    self._textInput = self:GetChild("textInput")
    self._inputBox = self:GetChild("bgInputBox")
    local imageGroup = self:GetChild("Group")
    self._icon = self:GetChild("icon")
    self._iconBg = self:GetChild("iconBg")
    self._tipIcon = self:GetChild("iconTroop")
    self._textLv = self:GetChild("_text")
    self._textName = self:GetChild("textName")
    self._level = self:GetChild("n33")
    self._mask = self._slide:GetChild("n5")
    self._grip = self._slide:GetChild("grip")
    self._percentTip = self._slide:GetChild("iconUpperlimit")

    self:AddListener(self._slide.onChanged,
        function()
            self:slideOnChange()
        end
    )
    self:AddListener(self._btnReduce.onClick,
        function()
            if (self.showCount > 0) then
                self.showCount = self.showCount - 1
                self._textInput.text = self:GetShowNum()
            end
            self._slide.value = self.showCount
            ArmiesModel.SetExpeditionArmies(self._id, self.showCount, self.maxCount)
        end
    )
    self:AddListener(self._btnAdd.onClick,
        function()
            local num = ArmiesModel.GetSurplusNum()
            if (num <= 0) then
                return
            end
            local limitNum = num + self.showCount
            if (self.showCount < limitNum and self.showCount < self.maxCount and self.showCount < self.info.Amount) then
                self.showCount = self.showCount + 1
                self._textInput.text = self:GetShowNum()
            end
            self._slide.value = self.showCount
            ArmiesModel.SetExpeditionArmies(self._id, self.showCount, self.maxCount)
        end
    )
    self:AddListener(self._slide.onGripTouchEnd,
        function()
            self._slide.value = self.showCount
        end
    )

    self:AddListener(self._slide.onGripTouchBegin,
        function()
            local num = ArmiesModel.GetSurplusNum()
            local limitNum = num + self.showCount
            if limitNum == 0 then
                self._slide.canDrag = false
            else
                if self._slide.limit then
                    self._slide.limit = limitNum
                end
            end
        end
    )
    self.showCount = 0

    self:AddListener(self._slide.onTouchBegin,
        function()
            local num = ArmiesModel.GetSurplusNum()
            if (num <= 0) then
                self._slide.value = 0
            end
        end
    )

    self:AddListener(self._inputBox.onClick,
        function()
            local screenPos = self._inputBox:LocalToRoot({x = 0, y = 0})
            local max
            if self.type == ExpeditionItemType.number then
                local remain = ArmiesModel.GetSurplusNum() + self.showCount
                max = remain > self.maxCount and self.maxCount or remain
            else
                local remain = ArmiesModel.GetSurplusNum() + self.showCount
                max = remain > self.info.Amount and math.ceil(self.info.Amount / self.maxCount * 100) or math.ceil(remain / self.maxCount * 100)
            end

            self.data.keyboard:Init(max, function(count)
                local realcount
                if self.type == ExpeditionItemType.number then
                    realcount = count
                else
                    realcount = math.ceil(count * 0.01 * self.maxCount)

                    local remain = ArmiesModel.GetSurplusNum() + self.showCount
                    realcount = realcount > remain and remain or realcount
                end

                self.showCount = realcount
                self._textInput.text = self:GetShowNum()
                self._slide.value = self.showCount
                ArmiesModel.SetExpeditionArmies(self._id, self.showCount, self.maxCount)
            end)
            self.data.keyboardCb(self._textInput)
        end
    )
end

--[[
    info 兵种信息，id和数量
    initCount 初始显示数量
    maxCount 最大数量
    type 显示类型，ExpeditionItemType
    keyboard 小键盘
    keyboardCb 开启小键盘回调
]]
function ItemExpeditionArmy:Init(data)
    self.data = data
    self.info = data.info
    self.showCount = data.initCount
    self:RefreshType(data.type, data.maxCount)
    self._icon.icon = UITool.GetIcon(self.info.army_port)
    self._iconBg.icon = UITool.GetIcon(self.info.amry_icon_bg)
    self._textName.text = ConfigMgr.GetI18n("configI18nArmys", self.info.id .. "_NAME")
    if self._slide.limit then
        self._slide.limit = 0
    end
    self._slide.value = self.showCount
    self._id = self.info.id
    self._textLv.text = ArmiesModel.GetLevelText(self.info.level)
    self._tipIcon.url = TrainModel.GetArmIcon(self.info.arm)
    ArmiesModel.SetExpeditionArmies(self.info.id, self.showCount, self.maxCount)
end

function ItemExpeditionArmy:RefreshType(type, maxCount)
    self.maxCount = maxCount and maxCount or self.info.Amount
    self.type = type
    self._slide.max = self.maxCount
    self._textInput.text = self:GetShowNum()

    if self.type == ExpeditionItemType.number then
        self._percentTip.visible = false
    else
        self._percentTip.visible = true

        local percent = self.info.Amount / self.maxCount
        self._percentTip.x = percent > 1 and self._slide.width or percent * self._slide.width
    end
end

function ItemExpeditionArmy:slideOnChange()
    local num = ArmiesModel.GetSurplusNum()
    local limitNum = num + self.showCount
    if limitNum == 0 then
        return
    else
        if (self._slide.value >= limitNum) or (self._slide.value > self.info.Amount) then
            local num = limitNum > self.info.Amount and self.info.Amount or limitNum
            self.showCount = math.floor(num)
            -- self._slide.value = self.showCount
        else
            self.showCount = math.floor(self._slide.value)
        end
    end

    self._textInput.text = self:GetShowNum()
    ArmiesModel.SetExpeditionArmies(self._id, self.showCount, self.maxCount)
end

function ItemExpeditionArmy:GetShowNum()
    return self.type == ExpeditionItemType.number and self.showCount or math.ceil(self.showCount / self.maxCount * 100) .. "%"
end

return ItemExpeditionArmy
