--[[
    Author: songzeming
    Function: 联盟医院详情
]]
local UnionHospitalDetail = UIMgr:NewUI("UnionHospital/UnionHospitalDetail")

import('UI/Union/UnionHospital/ItemUnionHospitalDetail')

function UnionHospitalDetail:OnInit()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close('UnionHospital/UnionHospitalDetail')
        end
    )
end

function UnionHospitalDetail:OnOpen()
    --联盟医院信息
    Net.AllianceHospital.Infos(
        Model.Player.AllianceId,
        function(rsp)
            if not rsp.InjuredAllies or next(rsp.InjuredAllies) == nil then
                self:Show(0)
                return
            end
            self._list.numItems = #rsp.InjuredAllies
            self:Show(self._list.numChildren)
            for k, v in pairs(rsp.InjuredAllies) do
                local item = self._list:GetChildAt(k - 1)
                item:Init(v)
            end
        end
    )
end

function UnionHospitalDetail:Show(number)
    local values = {
        number = number
    }
    self._textDesc.text = StringUtil.GetI18n(I18nType.Commmon, 'Ui_AllianceHospital_player', values)
end

return UnionHospitalDetail
