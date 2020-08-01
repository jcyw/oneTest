--[[
    Author: songzeming
    Function: 信息条 详情指挥中心列表Item
]]
local ItemDetailCenterList = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/itemDetailCenterList', ItemDetailCenterList)

local DETAIL_TYPE = {
    Resource = 1,
    Item = 2,
}

function ItemDetailCenterList:ctor()
    self:AddListener(self._btnGo.onClick,function()
        self:OnBtnGoClick()
    end)
end

function ItemDetailCenterList:Init(index, data)
    self.index = index
    self.data = data

    local single = index % 2 == 1
    -- self._barBgLight.visible = single
    -- self._barBgDark.visible = not single
    self._barBgLight.visible = false
    self._barBgDark.visible = true

    if data.type == DETAIL_TYPE.Resource then
        --资源 (木材=钢铁 / 石头=稀土 / 钢铁=石油 / 粮食=食品)
        local res = Model.Resources[data.para]
        self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", res.Category).img)
        self._title.text = Tool.FormatNumberThousands(res.Amount)
    elseif data.type == DETAIL_TYPE.Item then
        --道具
        self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configItems", data.para).icon)
        if not Model.Items[data.para] then
            self._title.text = 0
        else
            self._title.text = Model.Items[data.para].Amount
        end
    end
end

function ItemDetailCenterList:OnBtnGoClick()
    if self.data.type == DETAIL_TYPE.Resource then
        --资源
        local res = Model.Resources[self.data.para]
        local reset_func = function()
            self:Init(self.index, self.data)
        end
        UIMgr:Open("ResourceDisplay", res.Category, nil, nil, reset_func)
    elseif self.data.type == DETAIL_TYPE.Item then
        --道具
        local cb_func = function()
            self:Init(self.index, self.data)
        end
        if self.data.para == GlobalItem.ItemUpgradeJointCommand then
            local mData = {
                from = CommonType.LONG_ITEM_BOX_DISPLAY.JointCommandUpgrade,
                cb = cb_func
            }
            UIMgr:Open("LongItemBox/LongItemDisplay", mData)
        else
            UIMgr:Open("Backpack", {cb = cb_func})
        end
    end
end

return ItemDetailCenterList
