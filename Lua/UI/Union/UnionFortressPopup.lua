--[[
    author:{zhanzhang}
    time:2019-07-24 14:48:23
    function:{联盟领地解锁条件}
]]
local UnionFortressPopup = UIMgr:NewUI("UnionFortressPopup")
local UnionTrritoryModel = import("Model/Union/UnionTrritoryModel")
local UnionInfoModel = import("Model/Union/UnionInfoModel")
local UnionModel = import("Model/UnionModel")

function UnionFortressPopup:OnInit()
    local view = self.Controller.contentPane

    self._txtTitle = view:GetChild("titleName")
    self._btnClose = view:GetChild("btnClose")
    self._contentList = view:GetChild("liebiao")
    self._mask = view:GetChild("bgMask")
    self:OnRegister()
end

function UnionFortressPopup:OnRegister()
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("UnionFortressPopup")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("UnionFortressPopup")
        end
    )
end

function UnionFortressPopup:OnOpen(data)
    if Model.Player.AllianceId == "" then
        return
    end

    self._txtTitle.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceBuild_" .. data.ConfId)
    self._contentList:RemoveChildrenToPool()
    local info = ConfigMgr.GetItem("configAllianceFortresss", data.ConfId)

    local func = function()
        local unionInfo = UnionInfoModel.GetInfo()

        if info.Fortress_request then
            local item = self._contentList:AddItemFromPool()
            item:Init(
                StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Buldiing_Number") .. info.Fortress_request,
                UnionTrritoryModel.GetAmountOfCompletedFortress(),
                info.Fortress_request,
                UITool.GetIcon(Global.AllianceBulidingcondition4)
            )
        else
            if info.condition1 then
                local item = self._contentList:AddItemFromPool()
                item:Init(
                    StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_People_Number") .. info.condition1,
                    unionInfo.Member,
                    math.floor(info.condition1),
                    UITool.GetIcon(Global.AllianceBulidingcondition1)
                )
            end
            if info.condition2 then
                local item = self._contentList:AddItemFromPool()
                item:Init(
                    StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Power_Number") .. info.condition2,
                    unionInfo.Power,
                    math.floor(info.condition2),
                    UITool.GetIcon(Global.AllianceBulidingcondition2)
                )
            end
            if info.condition3 then
                local item = self._contentList:AddItemFromPool()
                item:Init(
                    StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_Tech_Level") .. info.condition3,
                    unionInfo.TechTotalLevel,
                    math.floor(info.condition3),
                    UITool.GetIcon(Global.AllianceBulidingcondition3)
                )
            end
        end
    end

    local union = UnionInfoModel.GetInfo()
    if not union or next(union) == nil then
        UnionModel.RequestUnionInfo(func)
    else
        func()
    end
end

return UnionFortressPopup
