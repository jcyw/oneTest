--[[
    Author: songzeming
    Function: 联盟设置 修改联盟宣言
]]
local ItemUnionSetupDeclaration = fgui.extension_class(GComponent)
fgui.register_extension('ui://Union/itemUnionReviseDeclaration', ItemUnionSetupDeclaration)

local UnionInfoModel = import('Model/Union/UnionInfoModel')

function ItemUnionSetupDeclaration:ctor()

    self._limiteText = self:GetChild("text")

    self:AddListener(self._btnSave.onClick,
        function()
            self:ExgDeclaration()
        end
    )
    self:AddListener(self._btnEdit.onClick,
        function()
            self:ResetShow(true)
        end
    )

    self:AddListener(self._desc.onChanged,function()
        self:RefreshText()
    end)
end

function ItemUnionSetupDeclaration:Init()
    self:ResetShow(false)

    local info = UnionInfoModel.GetInfo()
    self._desc.text = info.Desc
    local len = _G.Util.GetGBLength( info.Desc)
    self._limiteText.text = string.format("(%d/200)", len)
end

function ItemUnionSetupDeclaration:ResetShow(flag)
    self._desc.touchable = flag
    self._btnSave.enabled = flag
    self:RefreshText()
end

function ItemUnionSetupDeclaration:RefreshText()
    self._desc.text = string.gsub(self._desc.text, "[\t\n\r[%]]+", "")
    local len = Util.GetGBLength(self._desc.text)
    if len > 200 then
        self._desc.text = self.lastText
        len = Util.GetGBLength(self._desc.text)
        self._limiteText.text = string.format("(%d/200)", len)
    else
        self._limiteText.text = string.format("(%d/200)", len)
    end
    self.lastText = self._desc.text
end

function ItemUnionSetupDeclaration:ExgDeclaration()
    local desc = self._desc.text
    Net.Alliances.ChangeDesc(
        desc,
        function()
            TipUtil.TipById(50166)
            local info = UnionInfoModel.GetInfo()
            info.Desc = desc
            self:ResetShow(false)
        end
    )
end

return ItemUnionSetupDeclaration
