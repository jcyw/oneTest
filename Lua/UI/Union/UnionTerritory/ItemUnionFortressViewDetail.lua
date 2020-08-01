--[[
    author:{zhanzhang}
    time:2019-07-29 13:56:36
    function:{联盟堡垒item}
]]
local GD = _G.GD
local ItemUnionFortressViewDetail = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionFortressViewDetail", ItemUnionFortressViewDetail)

FortressViewDetailItemType = {
    SaveRes = 1, -- 联盟仓库资源存储
    Add = 2 -- 点击加入按钮
}

function ItemUnionFortressViewDetail:ctor()
    self._textName = self:GetChild("textUnionName")
    self._textType = self:GetChild("textGarrison")
    self._controller = self:GetController("typeControl")

    local btnBg = self:GetChild("btnBg")
    self:AddListener(btnBg.onClick,
        function()
            if self.type == FortressViewDetailItemType.Add then
                if self.cb ~= nil then
                    self.cb()
                end
            elseif self.type == FortressViewDetailItemType.SaveRes then
                if self._controller.selectedPage == "normal" then
                    self._controller.selectedPage = "saveRes"
                    self.height = self.openHeight
                else
                    self._controller.selectedPage = "normal"
                    self.height = self.closeHeight
                end
            end
        end
    )
end

function ItemUnionFortressViewDetail:Init(type, info)
    self.type = type
    self.info = info
    if type == FortressViewDetailItemType.Add then
        self:InitAdd()
    elseif type == FortressViewDetailItemType.SaveRes then
        self:InitSaveRes()
    end
end

function ItemUnionFortressViewDetail:InitAdd()
    self._controller.selectedPage = "addBtn"
    self.cb = self.info.cb
    self._textName.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse_prompt")
end

function ItemUnionFortressViewDetail:InitSaveRes()
    self._controller.selectedPage = "normal"
    self._textName.text = self.info.Name
    self._textType.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse_State")
    self._textTroops.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceWarehouse_StorageQuantity")
    -- CommonModel.SetUserAvatar(self._iconHead, tonumber(self.info.Avatar))
    self._iconHead:SetAvatar(self.info)
    local amount = 0
    local list = self:GetChild("itemResourcesOpen"):GetChild("liebiao")
    list:RemoveChildrenToPool()
    for _, v in pairs(self.info.StoreGoods) do
        local config = ConfigMgr.GetItem("configResourcess", v.Category)
        local item = list:AddItemFromPool()
        item:GetChild("icon").url = GD.ResAgent.GetIconUrl(v.Category)
         --UIPackage.GetItemURL("Common", config.img)
        item:GetChild("title").text = Tool.FormatNumberThousands(v.Amount)
        amount = amount + v.Amount * config.ratio
    end
    list:ResizeToFit(#self.info.StoreGoods)

    self.closeHeight = 128
    self.openHeight = list.height + self.closeHeight + 10

    self.height = self.closeHeight
    self._textTroopsNum.text = Tool.FormatNumberThousands(amount) .. "/" .. Tool.FormatNumberThousands(self.info.Load)
end

return ItemUnionFortressViewDetail
