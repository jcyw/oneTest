--[[
    author:{author}
    time:2020-01-17 15:01:08
    function:{desc}
]]
local ItemStageRanking = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemStageRanking", ItemStageRanking)

function ItemStageRanking:ctor()
    self._c1 = self:GetController("c1")
    self._content = self:GetChild("title")
    self._rankIndex = self:GetChild("text")
end

function ItemStageRanking:SetData(data, rankCatgroal)
    if rankCatgroal == 1 then
        self._c1.selectedIndex = 3
        self._rankIndex.text = data.Rank
    elseif rankCatgroal == 2 then
        if data.Rank == 1 then
            self._c1.selectedIndex = 0
        elseif data.Rank == 2 then
            self._c1.selectedIndex = 1
        elseif data.Rank == 3 then
            self._c1.selectedIndex = 2
        else
            self._c1.selectedIndex = 3
        end
        self._rankIndex.text = data.Rank
    end
    if data.AllianceShortName == nil or data.AllianceShortName == '' then
        self._content.text = data.UserName
    else
        self._content.text = "(" .. data.AllianceShortName .. ")" .. data.UserName
    end
end

return ItemStageRanking
