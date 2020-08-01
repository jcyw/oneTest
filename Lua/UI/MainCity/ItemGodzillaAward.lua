--[[
    author:{laofu}
    time:2020-04-20 16:24:38
    function:{哥斯拉奖励Item}
]]
local ItemGodzillaAward = fgui.extension_class(GComponent)
fgui.register_extension("ui://MainCity/itemGodzillaAward", ItemGodzillaAward)
local Status = {
    --已获得
    Geted = 0,
    --可获得
    Notget = 1
}

function ItemGodzillaAward:ctor()
    self._c1 = self:GetController("c1")
    self._title = self:GetChild("title")
    self:AddListener(self._touch.onClick,
        function()
            if not self.data then
                return
            end
            local state = self.data.status == 2 and Status.Geted or Status.Notget
            UIMgr:Open("CumulativeAttendancePopup", {self.data.gift, state})
        end
    )
end

--[[ 
    data结构：
        id：自己本身的id
        titleName:标题名称
        gift:奖励id，用于索引gift表对应的奖励列表
        status:状态，0是未完成，1是可领取，2是领取完
 ]]
function ItemGodzillaAward:SetData(data)
    self.data = data
    self._c1.selectedIndex = data.status
    self._title.text = data.titleName
end
