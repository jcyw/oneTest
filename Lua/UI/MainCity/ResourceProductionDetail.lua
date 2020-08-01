--author: 	Amu
--time:		2019-10-31 20:32:33
local GD = _G.GD
local BuildModel = import("Model/BuildModel")
local ArmiesModel = import("Model/ArmiesModel")

local ResourceProductionDetail = UIMgr:NewUI("ResourceProductionDetail")
local callback

function ResourceProductionDetail:OnInit()
    self._view = self.Controller.contentPane

    self._btnReturn = self._view:GetChild("btnReturn")
    self._textTime = self._view:GetChild("textTime")

    self._resList = {
        [RES_TYPE.Food] = {
            item = self._item2,
            btn = self._view:GetChild("bgFood"),
            title = self._view:GetChild("textFood"),
            lockText = self._view:GetChild("textLockFood"),
            outPutText = self._view:GetChild("textNumFood"),
            useUpText = self._view:GetChild("textAllNumFood"),
        },
        [RES_TYPE.Wood] = {
            item = self._item1,
            btn = self._view:GetChild("bgIron"),
            title = self._view:GetChild("textIron"),
            lockText = self._view:GetChild("textLockIron"),
            outPutText = self._view:GetChild("textNumIron"),
        },
        [RES_TYPE.Iron] = {
            item = self._item3,
            btn = self._view:GetChild("bgOil"),
            title = self._view:GetChild("textOil"),
            lockText = self._view:GetChild("textLockOil"),
            outPutText = self._view:GetChild("textNumOil"),
        },
        [RES_TYPE.Stone] = {
            item = self._item4,
            btn = self._view:GetChild("bgEarth"),
            title = self._view:GetChild("textEarth"),
            lockText = self._view:GetChild("textLockEarth"),
            outPutText = self._view:GetChild("textNumEarth"),
        },
    }

    for k,v in pairs(self._resList)do
        local _iconInfo = ConfigMgr.GetItem("configResourcess", k).img128
        v.item:SetShowData(_iconInfo, GD.ResAgent.GetIconQuality(k))
    end

    self:InitEvent()
end

function ResourceProductionDetail:InitEvent(  )
    self:AddListener(self._btnReturn.onClick,function()
        self:Close()
    end)

    for type,item in pairs(self._resList)do
        self:AddListener(item.btn.onClick,function()
            if self.centerLevel >= RES_LOCK[type] then
                local data = {
                    title = item.title.text
                }
                UIMgr:Open("ResourceProductionDetailPopup", type, data)
            else
                TipUtil.TipById(50113)
            end
        end)
    end

    callback = function()
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "System_Time", 
        {time = os.date("%Y-%m-%d %H:%M:%S", TimeUtil.UTCTime(), TimeUtil.UTCTime()/1000)})
    end

end

function ResourceProductionDetail:OnOpen()
    self.centerLevel = BuildModel.GetCenterLevel()
    self:RefreshInfo()
    self:Schedule(callback, 1)
end

function ResourceProductionDetail:RefreshInfo( )
    for type,item in pairs(self._resList)do
        if self.centerLevel >= RES_LOCK[type] then
            item.lockText.visible = false
            --item.lockIcon.visible = false
            item.outPutText.visible = true
            item.item:SetLockTypeMidde(false)
            item.item._icon.enabled = true
            item.item._bg.enabled = true
            
            if type == RES_TYPE.Food then
                item.useUpText.visible = true
                item.useUpText.text = "-"..Tool.FormatNumberThousands(ArmiesModel.GetAllArmyCost()).."".."/h"
            end
            item.outPutText.text = Tool.FormatNumberThousands(GD.ResAgent.GetResOutPut(type)).."/h"
        else
            item.lockText.visible = true
            --item.lockIcon.visible = true
            item.item:SetLockTypeMidde(true)
            item.item._icon.enabled = false
            item.item._bg.enabled = false

            item.lockText.text = StringUtil.GetI18n(I18nType.Commmon, "UI_Buildings_Locked", { building_level = RES_LOCK[type]})
            item.outPutText.visible = false
            if type == RES_TYPE.Food then
                item.useUpText.visible = false
            end
            
        end
    end
end

function ResourceProductionDetail:Close()
    UIMgr:Close("ResourceProductionDetail")
end

function ResourceProductionDetail:OnClose()
    self:UnSchedule(callback)
end

return ResourceProductionDetail
