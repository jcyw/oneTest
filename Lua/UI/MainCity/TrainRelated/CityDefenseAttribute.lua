--[[
    Author: songzeming
    Function: 安保工厂详情
]]
local CityDefenseAttribute = UIMgr:NewUI("TrainRelated/CityDefenseAttribute")

local TrainModel = import('Model/TrainModel')
import('UI/Common/ItemSlide')
import('UI/MainCity/TrainRelated/ItemDefenseAttribute')
import('UI/City/ItemResourcesAdd')

function CityDefenseAttribute:OnInit()
    self:AddListener(self._btnFire.onClick,
        function()
            self:OnBtnFireClick()
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("TrainRelated/CityDefenseAttribute")
        end
    )
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("TrainRelated/CityDefenseAttribute")
        end
    )
end

function CityDefenseAttribute:OnOpen(armyId)
    self.armyId = armyId

    self._title.text = TrainModel.GetName(armyId)
    self._desc.text = TrainModel.GetDesc(armyId)
    self._icon.icon = TrainModel.GetImageNormal(armyId)
    --兵种属性
    for i = 1, self._listAttributes.numChildren do
        local item = self._listAttributes:GetChildAt(i - 1)
        item:Init(i, armyId)
    end

    self.max = TrainModel.GetArmAmount(armyId)
    self._num.text = self.max
end

--点击解散兵种
function CityDefenseAttribute:OnBtnFireClick()
    local num = tonumber(self._num.text)
    local fire_func = function()
        self:OnOpen(self.armyId)
    end
    UIMgr:Open("TroopsDetailsFirePopup", self.armyId, num, fire_func)
end

return CityDefenseAttribute
