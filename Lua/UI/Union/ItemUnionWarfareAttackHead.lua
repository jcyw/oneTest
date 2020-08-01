--[[
    author:{zhanzhang}
    time:2019-07-02 16:01:05
    function:{联盟战争进攻方头像}
]]
local ItemUnionWarfareAttackHead = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionWarfareAttackHead", ItemUnionWarfareAttackHead)

function ItemUnionWarfareAttackHead:ctor()
    self._btnAdd = self:GetChild("btnAdd")
    self._icon = self:GetChild("icon")
    self._typeControl = self:GetController("c1")

    self:AddListener(self._btnAdd.onClick,function()
        if self.cb then
            self.cb()
        end
    end)
end

function ItemUnionWarfareAttackHead:Init(index, data, cb)
    self.cb = cb
    if data then
        self._typeControl.selectedIndex = 0
        CommonModel.SetUserAvatar(self._icon, data.Avatar, data.UserId)
    else
        self._typeControl.selectedIndex = 1
    end
end

function ItemUnionWarfareAttackHead:Clear()
    self._typeControl.selectedIndex = 1
end

return ItemUnionWarfareAttackHead
