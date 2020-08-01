--[[
    联盟管理修改堡垒名称界面
    author:{Temmie}
    time:2019-07-31
]]
local ItemUnionSetupFortressName = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionReviseClassFortressAppellation", ItemUnionSetupFortressName)


function ItemUnionSetupFortressName:ctor()
    self._list = self:GetChild("liebiao")
    self._txtTip = self:GetChild("textdescribe")
    self._btnSave = self:GetChild("btnSave")
    self.editList = {}

    self:AddListener(self._btnSave.onClick,function()
        Net.AllianceBuildings.Rename(self.editList, function(rsp)
            if rsp.Fail then
                return
            end

            self:Init(self.infos)
        end)
    end)
end

function ItemUnionSetupFortressName:Init(infos)
    self._list:RemoveChildrenToPool()
    self.infos = infos
    self.editList = {}
    for _,v in pairs(infos) do
        local item = self._list:AddItemFromPool()
        item:Init(v, function(confid, name)
            table.insert(self.editList, {ConfId = confid, Name = name})

            for _,v in pairs(self.infos) do
                if v.ConfId == confid then
                    v.Name = name
                    break
                end
            end
        end)
    end
end

return ItemUnionSetupFortressName