--[[
    author:{zhanzhang}
    time:2019-11-04 20:37:29
    function:{道具获取途径}
]]
local AccessWay = UIMgr:NewUI("AccessWay")

function AccessWay:OnInit()
    self:AddListener(
        self._btnClose.onClick,
        function()
            self:Close()
        end
    )
    self:AddListener(
        self._mask.onClick,
        function()
            self:Close()
        end
    )
end

function AccessWay:OnOpen(ItemConfId, cb, text, title)
    self.cb = cb
    local config = ConfigMgr.GetItem("configGetmoreItems", ItemConfId)

    self._content:RemoveChildrenToPool()
    for i = 1, config.num do
        local item = self._content:AddItemFromPool()
        item:Init(config, i, self.cb)
    end

    if text then
        self._text.text = text
    else
        self._text.text = StringUtil.GetI18n(I18nType.Commmon, "UI_GETMORE_ITEM")
    end
    if title then
        self._titleName.text = title
    else
        self._titleName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_ForcesUp_HowGet")
    end
end

function AccessWay:Close()
    UIMgr:Close("AccessWay")
end

return AccessWay
