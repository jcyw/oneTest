--[[
-- author:{lishu}
--- DateTime: 2020/7/18 15:45
]]

local FalconActivitiseTechRecordSharePopup = UIMgr:NewUI("FalconActivitiseTechRecordSharePopup")
local TechModel = import("Model/TechModel")
local WelfareModel = import("Model/WelfareModel")
local  itemData
function FalconActivitiseTechRecordSharePopup:OnInit()
    self._view = self.Controller.contentPane
    self._bgMask = self._view:GetChild("bgMask")
    self._title.text = ConfigMgr.GetI18n("configI18nCommons", "ACTIVITY_FALCONTIME_Tips2")

    self._btnRecorde = self._record:GetChild("btnShare")
    self._btnRecorde.text = ConfigMgr.GetI18n("configI18nCommons", "UI_FALCONTIME_Jump")

    self._recordList = self._record:GetChild("list")

    self:AddListener(self._bgMask.onClick,function ()
        UIMgr:Close("FalconActivitiseTechRecordSharePopup")
    end)

    self:AddListener(self._btnRecorde.onClick,
        function()
            if (Model.isFalconOpen) then
                if Model.Player.Level >= 4 then
                    UIMgr:Close("Chat")
                    UIMgr:Close("FalconActivitiseTechRecordSharePopup")
                    UIMgr:Open("WelfareMain", WelfareModel.WelfarePageType.FALCON_ACTIVITY)
                else
                    --TipUtil.TipByContent(nil, StringUtil.GetI18n(I18nType.Commmon, "UI_ACTIVITY_FALCONTIPS4"))
                    TipUtil.TipById(50353)
                end
            else
                TipUtil.TipByContentWithWaring(StringUtil.GetI18n(I18nType.Commmon, "UI_Activity_FALCONType"))
            end
        end
    )

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("FalconActivitiseTechRecordSharePopup")
        end
    )

    self._recordList.itemRenderer = function(index, gObject)
        itemData = self.recordInfo[index + 1]
        gObject:SetData(itemData.Uuid,
                itemData.MailId,
                index + 1,
                StringUtil.GetI18n(I18nType.Commmon, "ACTIVITY_FALCONTIME_Tips5", {monster_name = StringUtil.GetI18n(I18nType.Commmon, "MAP_MONTSTER_" .. math.ceil(itemData.Params[1])), technology_name = TechModel.GetTechName(math.ceil(itemData.Params[2]))}),
                _G.TimeUtil.StampTimeToYMD(itemData.CreateAt)
        )
    end
end

function FalconActivitiseTechRecordSharePopup:OnOpen(data)
    self:openRecords(data)
end

function FalconActivitiseTechRecordSharePopup:openRecords(data)
    self.recordInfo = data
    if(self.recordInfo == {})then
        self._recordList.numItems = 0
        return
    end
    table.sort(self.recordInfo, function(a, b)
        return a.CreateAt > b.CreateAt
    end)
    self._recordList.numItems = #self.recordInfo
end

return FalconActivitiseTechRecordSharePopup