--[[
    Author: songzeming
    Function: 主界面右上角 金币按钮 金币数量刷新 通用
]]
local ItemBtnGold = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnGold", ItemBtnGold)

function ItemBtnGold:ctor()
    self._title = self:GetChild("textNumber")

    self:AddListener(self.onClick,function()
        if UnlockModel:UnlockCenter(UnlockModel.Center.Gift) then
            UIMgr:Open("RechargeMain")
        else
            TipUtil.TipById(50288)
        end
    end)

    self:AddEvent(EventDefines.UIGemAmount, function(amount)
        Model.Player.Gem = amount
        self:SetNumber()
    end)
    self:SetNumber()
end

function ItemBtnGold:SetNumber()
    self._title.text = Tool.FormatNumberThousands(Model.Player.Gem)
end

return ItemBtnGold