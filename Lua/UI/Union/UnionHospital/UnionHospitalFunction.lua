--[[
    Author: songzeming
    Function: 联盟医院功能
]]
local UnionHospitalFunction = UIMgr:NewUI("UnionHospital/UnionHospitalFunction")

function UnionHospitalFunction:OnInit()
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close('UnionHospital/UnionHospitalFunction')
        end
    )

    local desc1 = StringUtil.GetI18n(I18nType.Commmon, 'Alliance_hospital_Accommodate')
    local desc2 = StringUtil.GetI18n(I18nType.Commmon, 'Alliance_hospital_ cure')
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local _desc = item:GetChild('text')
        _desc.text = i == 1 and desc1 or desc2
    end
end

function UnionHospitalFunction:OnOpen()
end

return UnionHospitalFunction
