--author: 	Amu
--time:		2019-09-24 17:02:26
local GD = _G.GD

local ItemPropNum = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/itemPropNum", ItemPropNum)

function ItemPropNum:ctor()
    self._icon = self:GetChild("icon")
    self._amount = self:GetChild("amount")
    self._title = self:GetChild("title")
    self._bg = self:GetChild("bg")

    self:InitEvent()
end

function ItemPropNum:InitEvent(  )
end

function ItemPropNum:SetData(itemInfo)
    local url
    local bgUrl
    if itemInfo.Category == REWARD_TYPE.Res then
        local resConfigInfo = ConfigMgr.GetItem("configResourcess", math.ceil(itemInfo.ConfId))
        url = GD.ResAgent.GetIconUrl(math.ceil(itemInfo.ConfId))
        self._title.text =  ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..math.ceil(itemInfo.ConfId))
        bgUrl = GD.ItemAgent.GetItmeQualityByColor(resConfigInfo.color)
    elseif itemInfo.Category == REWARD_TYPE.Item then
        local itemConfigInfo = ConfigMgr.GetItem("configItems", math.ceil(itemInfo.ConfId))
        url = UITool.GetIcon(itemConfigInfo.icon)
        self._title.text = GD.ItemAgent.GetItemNameByConfId(math.ceil(itemInfo.ConfId))
        bgUrl = GD.ItemAgent.GetItmeQualityByColor(itemConfigInfo.color)
    end
    self._amount.text = "+"..math.ceil(itemInfo.Amount)
    local _icon = url
    if not _icon then
        _icon = url
    end
    self._icon.icon = _icon
    self._bg.url = bgUrl
end

return ItemPropNum