--author: 	Amu
--time:		2019-11-01 20:09:05
local GD = _G.GD
local BuffItemModel = import("Model/BuffItemModel")

local ItemResourceProductionDetailPopup1 = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemResourceProductionDetailPopup1", ItemResourceProductionDetailPopup1)

function ItemResourceProductionDetailPopup1:ctor()
    self.vipAddText = self:GetChild("textNum1")
    self.vipAddProgress = self:GetChild("progressBar1")
    self.estateAddText = self:GetChild("textNum2")
    self.estateAddProgress = self:GetChild("progressBar2")
    self.skillAddText = self:GetChild("textNum3")
    self.skillAddProgress = self:GetChild("progressBar3")
    self.itemAddText = self:GetChild("textNum4")
    self.itemAddProgress = self:GetChild("progressBar4")
    self.allianceDomainAddText = self:GetChild("textNum6")
    self.allianceDomainAddProgress = self:GetChild("progressBar6")
    self.girlAddText = self:GetChild("textNum7")
    self.girlAddProgress = self:GetChild("progressBar7")
    self.otherAddText = self:GetChild("textNum5")
    self.otherAddProgress = self:GetChild("progressBar5")

    self:InitEvent()
end

function ItemResourceProductionDetailPopup1:InitEvent()

end

function ItemResourceProductionDetailPopup1:SetData(info, type, resBuildList)
    local vipBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffVip)
    local techBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffTech)
    local skillBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffHero)
    local itemBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffItem)
    local allianceDomainBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffAllianceDomain)
    local girlBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffGirl)
    local otherBonus = BuffItemModel.GetResBonus(type, BuffItem.TypedBuffKingdomSkill)
                    + BuffItemModel.GetResBonus(type, BuffItem.TypedBuffAllianceTech)
                    + BuffItemModel.GetResBonus(type, BuffItem.TypedBuffBeastTech)
                    + BuffItemModel.GetResBonus(type, BuffItem.TypedBuffEquip)
                    + BuffItemModel.GetResBonus(type, BuffItem.TypedBuffOfficialTitle)

    for _,v in ipairs(resBuildList)do
        if v.BuffExpireAt > Tool.Time() then
            itemBonus = itemBonus + v.Produce
        end
    end
    local selfFormat = function (value)
        return value >= 0 and ("+%s"):format(Tool.FormatNumberThousands(value)) or ("%s"):format(Tool.FormatNumberThousands(value))
    end
    self.vipAddText.text = ("%s/h"):format(selfFormat(vipBonus))
    self.vipAddProgress.value = self:GetPro(vipBonus)
    self.estateAddText.text = ("%s/h"):format(selfFormat(techBonus))
    self.estateAddProgress.value = self:GetPro(techBonus)
    self.skillAddText.text = ("%s/h"):format(selfFormat(skillBonus))
    self.skillAddProgress.value = self:GetPro(skillBonus)
    self.itemAddText.text = ("%s/h"):format(selfFormat(itemBonus))
    self.itemAddProgress.value = self:GetPro(itemBonus)
    self.allianceDomainAddText.text = ("%s/h"):format(selfFormat(math.ceil(allianceDomainBonus)))
    self.allianceDomainAddProgress.value = self:GetPro(allianceDomainBonus)
    self.girlAddText.text = ("%s/h"):format(selfFormat(math.ceil(girlBonus)))
    self.girlAddProgress.value = self:GetPro(girlBonus)
    self.otherAddText.text = ("%s/h"):format(selfFormat(math.ceil(otherBonus)))
    self.otherAddProgress.value = self:GetPro(otherBonus)

    self.type = type
end

function ItemResourceProductionDetailPopup1:GetPro(value)
    -- local valueList = split(value, ",")
    -- value = ""
    -- for _,v in ipairs(valueList)do
    --     if v ~= "," then
    --         value = value..v
    --     end
    -- end
    -- value = tonumber(value)
    local ResourceHubMax = tonumber(Global.ResourceHubMax)
    local ResourceHubMaxAdd = tonumber(Global.ResourceHubMaxAdd)
    if value > (ResourceHubMax - ResourceHubMaxAdd) then
        -- local _add = math.ceil((value-ResourceHubMax)/ResourceHubMaxAdd)*ResourceHubMaxAdd
        return value/(value + ResourceHubMaxAdd)*100
    end
    return value/ResourceHubMax*100
end

return ItemResourceProductionDetailPopup1