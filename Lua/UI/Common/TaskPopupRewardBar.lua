--author: 	Amu
--time:		2019-08-15 11:12:54
local GD = _G.GD

local TaskPopupRewardBar = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/taskPopupRewardBar", TaskPopupRewardBar)

function TaskPopupRewardBar:ctor()
    self._title = self:GetChild("title")
    self._textNum = self:GetChild("textNum")

    self._item = self:GetChild("reward")

    self:InitEvent()
end

function TaskPopupRewardBar:InitEvent()
end

function TaskPopupRewardBar:SetData(type, info)
    self.type = type

    local data = {}
    -- local itemInfo
    if self.type == ITEM_TYPE.Item then
        data.Category = REWARD_TYPE.Item
        data.Amount = info.amount
        data.ConfId = info.id
        -- itemInfo = ConfigMgr.GetItem("configItems", data.ConfId).icon
        self._title.text = GD.ItemAgent.GetItemNameByConfId(data.ConfId)
    elseif self.type == ITEM_TYPE.Gift then
        if info.category then
            data.Category = REWARD_TYPE.Res
            data.Amount = info.amount
            data.ConfId = info.category
            -- itemInfo = GD.ResAgent.GetIcon(data.ConfId)--ConfigMgr.GetItem("configResourcess", data.ConfId).img
            self._title.text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_" .. data.ConfId)
            self._textNum.text = data.Amount
        elseif info.confId then
            data.Category = REWARD_TYPE.Item
            data.Amount = info.amount
            data.ConfId = info.confId
            -- itemInfo = ConfigMgr.GetItem("configItems", data.ConfId).icon
            self._title.text = GD.ItemAgent.GetItemNameByConfId(data.ConfId)
            self._textNum.text = string.format("x%d", data.Amount)
        end
    end
    local mid = GD.ItemAgent.GetItemInnerContent(data.ConfId)
    local icon,color = GD.ItemAgent.GetShowRewardInfo(data)
    self._item:SetShowData(icon,color,nil,nil,mid)
end

--新的数据读取方式
function TaskPopupRewardBar:SetParams(itmeData)
    self._title.text = itmeData.titleWithoutCount or itmeData.title
    if itmeData.isRes then
        self._textNum.text = string.format("+%d", itmeData.amount)
    else
        self._textNum.text = string.format("x%d", itmeData.amount)
    end
    --self._item:SetControl(0)
    --self._item:SetIcon(UITool.GetIcon(itmeData.image))
    --self._item:SetQuality(itmeData.color)
    --self._item:SetAmountMid(itmeData.confId)

    local mid = GD.ItemAgent.GetItemInnerContent(itmeData.confId)
    self._item:SetShowData(itmeData.image,itmeData.color,nil,nil,mid)
end

return TaskPopupRewardBar
