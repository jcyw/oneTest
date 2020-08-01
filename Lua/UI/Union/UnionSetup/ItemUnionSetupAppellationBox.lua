--[[
    Author: songzeming
    Function: 联盟设置 修改联盟称谓列表Item
]]
local ItemUnionSetupAppellationBox = fgui.extension_class(GComponent)
fgui.register_extension('ui://Union/itemUnionReviseClassAppellationItem', ItemUnionSetupAppellationBox)

local CTR = {
    Normal = 'Normal', --未修改
    Correct = 'Correct', --修改满足条件
    Error = 'Error' --修改不满足条件
}

function ItemUnionSetupAppellationBox:ctor()
    self._ctr = self:GetController('Controller')

    self:AddListener(self._name.onChanged,function()
        self._name.text = string.gsub(self._name.text, "[\t\n\r[%]]+", "")
    end)
    self:AddListener(self._name.onFocusOut,function()
        self:CheckName()
    end)
end

function ItemUnionSetupAppellationBox:CheckName()
    local title = self._title.text
    local name = self._name.text
    if name == "" then
        self._ctr.selectedPage = CTR.Normal
    else
        local gbLen = Util.GetGBLength(name)
        self._ctr.selectedPage = (gbLen >= 3 and gbLen <= 10 and name ~= title) and CTR.Correct or CTR.Error
    end
end

function ItemUnionSetupAppellationBox:Init(title)
    self._title.text = title
    self._name.text = ''
    self._ctr.selectedPage = CTR.Normal
end

function ItemUnionSetupAppellationBox:GetName()
    return self._name.text
end

function ItemUnionSetupAppellationBox:GetValid()
    return self._ctr.selectedPage == CTR.Correct
end

return ItemUnionSetupAppellationBox
