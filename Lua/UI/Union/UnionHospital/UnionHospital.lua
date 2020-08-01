--[[
    Author: songzeming
    Function: 联盟医院
]]
local UnionHospital = UIMgr:NewUI("UnionHospital/UnionHospital")

local UnionModel = import('Model/UnionModel')
import('UI/Union/UnionHospital/ItemUnionHospital')
local CONTROLLER = {
    Build = "Build", --建造中
    Work = "Work" --工作中
}

function UnionHospital:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController('Controller')

    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close('UnionHospital/UnionHospital')
        end
    )
end

function UnionHospital:OnOpen()
    UnionModel.GetUnionInfo(
        function(data)
            self:UnionInfo(data)

            self._list.numItems = 1
            for i = 1, self._list.numChildren do
                local item = self._list:GetChildAt(i - 1)
                local title = StringUtil.GetI18n(I18nType.Commmon, 'Button_AllianceHospital_Cure')
                item:Init(
                    title,
                    function()
                        UIMgr:Open("CureRelated/CureArmy", BuildType.CUREARMY.Union)
                    end
                )
            end
        end
    )
end

--设置联盟信息
function UnionHospital:UnionInfo(data)
    self._icon.icon = UnionModel.GetUnionBadgeIcon(data.Emblem)
    self._name.text = '(' .. data.ShortName .. ')' .. StringUtil.GetI18n(I18nType.Commmon, "Ui_AllianceHospital")

    -- 是否在工作中 建筑值
    -- local info = UnionTrritoryModel.GetTerritorDetail(Global.AllianceBuildingHospital)
end

return UnionHospital
