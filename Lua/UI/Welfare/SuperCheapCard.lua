--[[
    author:{lishu}
    time:2019-09-28 16:34:54
    function:{超值礼包}
]]
local SuperCheapCard = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/SuperCheapCard", SuperCheapCard)
local WelfareModel = import("Model/WelfareModel")

function SuperCheapCard:ctor()
    self:SetShow(false)
end

function SuperCheapCard:OnOpen()
    self:SetShow(true)
    for i = 1, #Model.DiamondFundInfo do
        --print("Model.DiamondFundInfo[i].Tier = ".. Model.DiamondFundInfo[i].Tier)
        if(Model.DiamondFundInfo[i].Tier == 0)then
            --print("Model.DiamondFundInfo[i].Tier 000 = ".. Model.DiamondFundInfo[i].Tier)
            self._commonMonthCard:SetData(i)
        elseif(Model.DiamondFundInfo[i].Tier == 1)then
            --print("Model.DiamondFundInfo[i].Tier 111 = ".. Model.DiamondFundInfo[i].Tier)
            self._SuperMonthCard:SetData(i)
        elseif(Model.DiamondFundInfo[i].Tier == 2)then
            --print("Model.DiamondFundInfo[i].Tier 111 = ".. Model.DiamondFundInfo[i].Tier)
            self._ThirdMonthCard:SetData(i)
        end
    end
    local list = {self._commonMonthCard,self._SuperMonthCard,self._ThirdMonthCard}
    for i=1,3 do
        AnimationLayer.UIHorizontalMove(self,list[i],i,0.2,AnimationType.UILeftToRight)
    end
end

function SuperCheapCard:SetContext(context)
    self.context = context
end

function SuperCheapCard:SetShow(isShow)
    self.visible = isShow
end

return SuperCheapCard
