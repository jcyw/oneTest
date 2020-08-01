--author: 	Amu
--time:		2019-07-01 11:39:38
local GD = _G.GD
local ShopModel = import("Model/ShopModel")
local UnionModel = import("Model/UnionModel")

local ItemUnionShop = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionShop", ItemUnionShop)

ItemUnionShop.tempList = {}

function ItemUnionShop:ctor()
    self._iconHeart = self:GetChild("iconHeart")
    self._btnAdd = self:GetChild("btnAdd")
    self._textName = self:GetChild("textName")
    self._iconHonor = self:GetChild("iconHonor")
    self._textHonor = self:GetChild("textHonor")
    self._wantname = self:GetChild("textWant")
    self._wantText = self:GetChild("textWantNum")
    self._bgWant = self:GetChild("bgWant")
    self._tagState = self:GetController("tagstate")
    -- self._wantText.text = string.format( "wantx%d",0)

    self._item = self:GetChild("itemProp")

    self:InitEvent()
end

function ItemUnionShop:InitEvent()
    self:AddListener(self._btnAdd.onClick,function()
        local level = Model.Player.AlliancePos
        local itemInfo = {
            ConfId = self._info.itemInfo.item_id,
            Id = self._info.ConfId,
            Amount = 100000000,
            Mark = self._info.Mark,
        }
        if level < 4 then
            UIMgr:Open("UnionShopRemind", itemInfo)
        else
            local gold = {
                Amount = self._info.itemInfo.stock_price,
                type = RES_TYPE.UnionCredit,
                allGold = self.credit
            }
            UIMgr:Open("UnionShopReplenishment", SHOP_TYPE.UnionAddShop, itemInfo, gold)
        end
    end)

    self:AddListener(self._iconHeart.onClick,function()
        if self._info.Amount > 0 then
            TipUtil.TipById(50200)
        else
            local itemInfo = {
                ConfId = self._info.itemInfo.item_id,
                Id = self._info.ConfId,
                Amount = self._info.Amount,
            }
            UIMgr:Open("UnionShopRemind", itemInfo)
        end
    end)

    self:AddListener(self._item.onClick,function()
        local level = Model.Player.AlliancePos
        local itemInfo = {
            ConfId = self._info.itemInfo.item_id,
            Id = self._info.ConfId,
            Amount = self._info.Amount,
            Mark = self._info.Mark,
        }
        local gold = {
            Amount = self._info.itemInfo.buy_price,
            type = RES_TYPE.UnionHonor,
            allGold = self.honor
        }
        if self._info.Amount == 0 then
            if level>= 4 then
                TipUtil.TipById(50369)
            else
                UIMgr:Open("UnionShopRemind", itemInfo)
            end
        else
            UIMgr:Open("UnionShopReplenishment", SHOP_TYPE.UnionShop, itemInfo, gold) 
        end
    end)
end

function ItemUnionShop:SetData(info, honor, credit)
    self._info = info
    self.honor = honor
    self.credit = credit

    self:RefreshItem()
end

function ItemUnionShop:RefreshItem(  )
    local data = {}
    data.Amount = self._info.Amount
    data.ConfId = self._info.itemInfo.item_id
    local confItem = ConfigMgr.GetItem("configItems", data.ConfId)
    local midNum = GD.ItemAgent.GetItemInnerContent(data.ConfId)
    self._item:SetShowData(confItem.icon, confItem.color, data.Amount, nil, midNum)

    local itemInfo = GD.ItemAgent.GetItemModelByConfId(data.ConfId)

    self._textName.text = GD.ItemAgent.GetItemNameByConfId(data.ConfId)
    self._textHonor.text = Tool.FormatNumberThousands(self._info.itemInfo.buy_price)
    -- self._wantText.text = string.format( "wantx%d",self._info.Mark)
    self._wantText.text = self._info.Mark
    -- if self._info.Amount > 0 then
    --     self._iconHeart.visible = true
    --     self._btnAdd.visible = false
    --     self._wantText.visible = false
    -- else
        if Model.Player.AlliancePos <  ALLIANCEPOS.R4 then
            if self._info.Amount > 0 then
                self._iconHeart.visible = false
            else
                self._iconHeart.visible = true
            end
            self._btnAdd.visible = false
            -- self._wantText.visible = true
        else
            self._iconHeart.visible = false
            self._btnAdd.visible = true
            -- self._wantText.visible = true
        end
    -- end
    if self._info.Mark <= 0 then
        self._wantText.visible = false
        self._bgWant.visible = false
        --self._wantname.visible = false
        self._tagState.selectedIndex = 0
    else
        self._wantText.visible = true
        self._bgWant.visible = true
        --self._wantname.visible = true
        self._tagState.selectedIndex = 1
    end
end

function ItemUnionShop:SetChoose(flag)
    self._item:SetChoose(flag)
end

function ItemUnionShop:GetData(  )
    return self._info
end

return ItemUnionShop