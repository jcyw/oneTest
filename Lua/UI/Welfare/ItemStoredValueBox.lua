--[[
    author:{maxiaolong}
    time:2019-10-23 11:51:56
    function:{宝箱单个组件}
]]
local ItemStoredValueBox = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/itemStoredValueBox", ItemStoredValueBox)
import("UI/Welfare/CumulativeAttendancePopup")

function ItemStoredValueBox:ctor()
    self._box1 = self:GetChild("box1")
    self.c1 = self._box1:GetController("c1")
    self._title = self:GetChild("title")
    self:AddListener(self._box1.onClick,
        function()
            UIMgr:Open("CumulativeAttendancePopup", self.award)
        end
    )
end

function ItemStoredValueBox:SetShow(isShow)
    self.visible = isShow
    if self.visible == false then
        self.x = 0
    end
end

function ItemStoredValueBox:GetShow()
    return self.visible
end

function ItemStoredValueBox:SetData(award, finishNum)
    self.award = award
    self._title.text = finishNum
    if tonumber(award[2]) == 0 then
        self.c1.selectedIndex = 0
    elseif tonumber(award[2]) == 1 then
        self.c1.selectedIndex = 2
    elseif tonumber(award[2]) == 2 then
        self.c1.selectedIndex = 1
    end
end
return ItemStoredValueBox
