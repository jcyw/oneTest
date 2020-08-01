--[[
    author:{zhanzhang}
    time:2019-07-02 14:02:52
    function:{联盟战争进攻Item}
]]

local ItemUnionWarfareing = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionWarfareing", ItemUnionWarfareing)

function ItemUnionWarfareing:ctor()
    self._iconHeadL = self:GetChild("iconHeadL")
    self._textNameL = self:GetChild("textNameL")
    self._textCoordinateL = self:GetChild("textCoordinateL")
    self._iconHeadR = self:GetChild("iconHeadR")
    self._textNameR = self:GetChild("textNameR")
    self._textActionTime =self:GetChild("textActionTime")
    self._textBattleNum = self:GetChild("textBattleNum")

end

function ItemUnionWarfareing:Init()
end

return ItemUnionWarfareing