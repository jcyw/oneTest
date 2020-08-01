--[[
    Author: songzeming
    Function: 联盟设置 修改联盟旗帜
]]
local ItemUnionSetupFlag = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionReviseFlag", ItemUnionSetupFlag)

local UnionInfoModel = import("Model/Union/UnionInfoModel")

function ItemUnionSetupFlag:ctor()
    self:AddListener(self._icon.onTouchEnd,
        function()
            UIMgr:Open("PlayerFlag", FLAG_TYPE.Alliance)
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceInfoExchanged,
        function()
            self:Init()
        end
    )
end

function ItemUnionSetupFlag:Init()
    local info = UnionInfoModel.GetInfo()
    self._icon.icon = UITool.GetIcon(ConfigMgr.GetItem("configFlags", info.Flag).icon)
end

return ItemUnionSetupFlag
