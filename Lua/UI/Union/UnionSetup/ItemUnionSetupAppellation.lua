--[[
    Author: songzeming
    Function: 联盟设置 修改联盟称谓列表
]]
local ItemUnionSetupAppellation = fgui.extension_class(GComponent)
fgui.register_extension('ui://Union/itemUnionReviseClassAppellation', ItemUnionSetupAppellation)

local UnionModel = import('Model/UnionModel')
local UnionInfoModel = import('Model/Union/UnionInfoModel')
import('UI/Union/UnionSetup/ItemUnionSetupAppellationBox')
local function GetPos(index)
    return 5 - index + 1
end

function ItemUnionSetupAppellation:ctor()
    self._list.numItems = 5
    self:AddListener(self._btnSave.onClick,
        function()
            self:ExgAppellation()
        end
    )
end

function ItemUnionSetupAppellation:Init()
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local index = GetPos(i)
        local title = UnionModel.GetAppellation(index)
        item:Init(title)
    end
end

function ItemUnionSetupAppellation:ExgAppellation()
    local info = UnionInfoModel.GetInfo()
    local isExg = false
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local isValid = item:GetValid()
        if isValid then
            isExg = true
            local name = item:GetName()
            local index = GetPos(i)
            Net.Alliances.ChangePosName(
                index,
                name,
                function()
                    info['NameR' .. index] = name
                end
            )
        end
    end
    if not isExg then
        TipUtil.TipById(50164)
    else
        TipUtil.TipById(50165)
    end
end

return ItemUnionSetupAppellation
