-- 批量使用道具
local GD = _G.GD
local ResourceDisplayUse = UIMgr:NewUI("ResourceDisplayUse")

local VIPModel = import("Model/VIPModel")

function ResourceDisplayUse:OnInit()
    local view = self.Controller.contentPane
    self._txtTitle = view:GetChild("titleName")
    self._txtDetail = view:GetChild("text")
    self._txtAmount = view:GetChild("textInputNum")
    self._slider = view:GetChild("slide")
    self._input = view:GetChild("textInput")
    self._btnAdd = view:GetChild("btnAdd")
    self._btnReduce = view:GetChild("btnReduce")
    self._btnUse = view:GetChild("btnUse")
    self.keyboard = UIMgr:CreatePopup("Common", "itemKeyboard")

    self:AddListener(self._slider.onChanged,
        function()
            local value = math.floor(self._slider.value + 0.5)
            self.useCount = value < self.minValue and self.minValue or value
            self._input.text = self.useCount

            if self.valueChangeCallBack then
                self.valueChangeCallBack(self, self.useCount)
            end
            self:RefreshDesc()
        end
    )

    self:AddListener(self._slider.onGripTouchEnd,
        function()
            self._slider.value = self.useCount
        end
    )

    self:AddListener(self._btnAdd.onClick,
        function()
            self.useCount = self.useCount + 1 > self.amount and self.amount or self.useCount + 1
            self._input.text = self.useCount
            self._slider.value = self.useCount

            if self.valueChangeCallBack then
                self.valueChangeCallBack(self, self.useCount)
            end
            self:RefreshDesc()
        end
    )

    self:AddListener(self._btnReduce.onClick,
        function()
            self.useCount = self.useCount - 1 < self.minValue and self.minValue or self.useCount - 1
            self._input.text = self.useCount
            self._slider.value = self.useCount

            if self.valueChangeCallBack then
                self.valueChangeCallBack(self, self.useCount)
            end
            self:RefreshDesc()
        end
    )

    self:AddListener(self._btnUse.onClick,
        function()
            self:UseItem()
        end
    )

    local btnInputBox = view:GetChild("btnInputBox")
    self:AddListener(btnInputBox.onClick,
        function()
            self.keyboard:Init(
                self.data.amount,
                function(num)
                    self.useCount = num < self.minValue and self.minValue or num
                    self._input.text = self.useCount
                    self._slider.value = self.useCount

                    if self.valueChangeCallBack then
                        self.valueChangeCallBack(self, self.useCount)
                    end
                    self:RefreshDesc()
                end
            )
            UIMgr:ShowPopup("Common", "itemKeyboard", self._input)
        end
    )

    -- local btnClose = view:GetChild("btnClose")
    -- self:AddListener(btnClose.onClick,function()
    --     UIMgr:Close("ResourceDisplayUse")
    -- end)

    self:AddListener(self._bgMask.onClick,
        function()
            UIMgr:Close("ResourceDisplayUse")
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("ResourceDisplayUse")
        end
    )
end

--[[
    config 物品配置
    initAmount 初始化数量
    amount 最大数量
    min 最小数量，为空时默认1
    title 标题
    context 描述内容
    valueChangeCallBack 选择数量发生变化时回调，可以为空
    useCallBack 使用后回调，可以为空
]]
function ResourceDisplayUse:OnOpen(data)
    self.minValue = data.min and data.min or 1
    self.vipInfo = data.vipInfo
    self.data = data
    self.config = data.config
    self.id = self.config.id
    self.amount = data.amount
    self.useCount = data.initAmount and data.initAmount or self.minValue
    self.context = data.context
    self.itemCount = self.config.value
    self.itemCountType = self.config.show_num
    self.valueChangeCallBack = data.valueChangeCallBack
    self.useCallBack = data.useCallBack

    if data.title then
        self._txtTitle.text = data.title
        self._txtDetail.text = self.context
    else
        self._txtTitle.text = GD.ItemAgent.GetItemNameByConfId(self.id)
        self._txtDetail.text = StringUtil.GetI18n(I18nType.Commmon, "Use_Broadcast_Tips", {item_name = GD.ItemAgent.GetItemNameByConfId(self.id)})
    end

    self._txtAmount.text = "/" .. data.amount

    self._slider.max = data.amount
    self._slider.value = self.useCount
    self._input.text = self.useCount

    if self.valueChangeCallBack then
        self.valueChangeCallBack(self, self.useCount)
    end

    self._desc.text = ""
    self:RefreshDesc()
end

--vip满级时打开提示框
function ResourceDisplayUse:OpenTipPopup()
    local data = {
        content = StringUtil.GetI18n(I18nType.Commmon, "TIPS_VIP_LEVELMAX_USE"),
        titleText = StringUtil.GetI18n(I18nType.Commmon, "Tips_TITLE"),
        sureCallback = function()
            UIMgr:Close("ResourceDisplayUse")
        end
    }
    UIMgr:Open("ConfirmPopupText", data)
end

function ResourceDisplayUse:UseItem()
    SdkModel.TrackBreakPoint(10070) --打点
    if self.config.type2 == PropType.VIP.Points and VIPModel.GetVipLevel() == 10 then
        self.OpenTipPopup()
        return
    end
    GD.ItemAgent.UseItem(
        self.id,
        self.useCount,
        function()
            if self.useCallBack ~= nil then
                self.useCallBack(self.useCount)
            end
            self:Close()
        end
    )
end

function ResourceDisplayUse:RefreshDesc()
    self:CheckVipDesc()
end

function ResourceDisplayUse:CheckVipDesc()
    if not self.vipInfo then
        return
    end
    if self.vipInfo.VipLevel == 10 then
        return
    end

    local amount = self.useCount

    local name = GD.ItemAgent.GetItemNameByConfId(self.id)
    local beforeLevel = self.vipInfo.VipLevel --当前等级
    local point = self.vipInfo.VipPoints --当前积分

    local conf = ConfigMgr.GetList("configVips")
    local list, beforePoint = VIPModel.GetLevelPropByConf(beforeLevel, conf) --根据当前等级获得左端积分值
    local list, nextPoint = VIPModel.GetLevelPropByConf(beforeLevel + 1, conf) --根据下一等级获得右端积分值
    local num = math.floor(((point - beforePoint) / (nextPoint - beforePoint)) * 100)
    local percent = string.format("%.0f", num)

    local newPoint = point + (self.useCount * self.itemCount) --滑动之后积分
    local newNextLevel
    local newNextPoint
    local newPercent
    if newPoint >= 240000 then
        newNextLevel = 10
        newPercent = 100
    else
        newNextLevel, newNextPoint = VIPModel.GetInfoByPiont(newPoint) --通过新积分获得右端对应等级和积分
        local list, newBeforePoint = VIPModel.GetLevelPropByConf(newNextLevel - 1, conf) --通过右端等级获得左端积分
        local newNum = math.floor(((newPoint - newBeforePoint) / (newNextPoint - newBeforePoint)) * 100)
        newPercent = string.format("%.0f", newNum)
    end
    local text =
        StringUtil.GetI18n(
        I18nType.Commmon,
        "Vip_Point_Tips",
        {prop_name = name, vip_level = beforeLevel, vip_percent = percent .. "%", vip_new_level = newNextLevel - 1, vip_new_percent = newPercent .. "%"}
    )
    self._desc.text = text
end

function ResourceDisplayUse:Close()
    UIMgr:Close("ResourceDisplayUse")
end

return ResourceDisplayUse
