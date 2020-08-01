--[[
    author:Temmie
    time:2019-10-24 16:34:16
    function:部队解散弹窗
]]
local TroopsDetailsFirePopup = UIMgr:NewUI("TroopsDetailsFirePopup")

import('UI/Common/ItemSlide')

function TroopsDetailsFirePopup:OnInit()
    self:AddListener(self._btnMask.onClick,function()
        UIMgr:Close("TroopsDetailsFirePopup")
    end)
    -- self:AddListener(self._btnClose.onClick,function()
    --     UIMgr:Close("TroopsDetailsFirePopup")
    -- end)

    self:AddListener(self._btnDismiss.onClick,function()
        if self.dismiss <= 0 then
            TipUtil.TipById(50115)
            return
        end

        UIMgr:Close("TroopsDetailsFirePopup")
        local armies = {
            {
                ConfId = self.configId,
                Amount = self.dismiss,
            }
        }
        if self.armyType == "InjuredArmy" then
            Net.Armies.DeleteInjured(armies, function(rsp)
                for _, v in pairs(rsp.InjuredArmies) do
                    Model.Create(ModelType.InjuredArmies, v.ConfId, v)
                end
                Event.Broadcast(EventDefines.UIInjuredArmyDel)

                local config = ConfigMgr.GetItem("configArmys", armies[1].ConfId)
                local data = {
                    army_amount = armies[1].Amount,
                    army_name = StringUtil.GetI18n(I18nType.Army, config.id.."_NAME")
                }
                TipUtil.TipById(50116, data)

                if self.cb then
                    self.cb()
                end
            end)
        else
            local config = ConfigMgr.GetItem("configArmys", armies[1].ConfId)
            local content = ConfigMgr.GetI18n(I18nType.Commmon, "Fire_Army")
            if config.is_defence then
                content = ConfigMgr.GetI18n(I18nType.Commmon, "Defense_Weapon_Remove")
            end
            local data = {
                content = content,
                sureCallback = function()
                    -- 发送解散信息
                    if self.dismiss <= 0 then
                        TipUtil.TipById(50117)
                        return
                    end
                    self.visible = false
                    Net.Armies.Delete(armies, function(rsp)
                        if rsp.Fail then
                            return
                        end
                        local data = {
                            army_amount = armies[1].Amount,
                            army_name = StringUtil.GetI18n(I18nType.Army, config.id.."_NAME")
                        }
                        TipUtil.TipById(50116, data)

                        if self.cb then
                            self.cb()
                        end
                    end)
                end
            }
            UIMgr:Open("ConfirmPopupText", data)
        end
    end)
end

function TroopsDetailsFirePopup:OnOpen(confId, amount, cb, armyType)
    self.dismiss = 0
    self.configId = confId
    self.Amount = amount
    self.cb = cb
    self.armyType = armyType
    if armyType == "InjuredArmy" then
        self._textText.text = StringUtil.GetI18n(I18nType.Commmon, "Fire_Wounded_Army")
    else
        self._textText.text = StringUtil.GetI18n(I18nType.Commmon, "Fire_Army")
    end
    self._textNum.text = "/"..amount
    self._slide:Init('Normal', 0, self.Amount, function()
        self.dismiss = self._slide:GetNumber()
    end)
end

return TroopsDetailsFirePopup