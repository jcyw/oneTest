--[[
    author:{laofu}
    time:2020-06-10 19:30:02
    function:{新城竞赛任务页}
]]
local GD = _G.GD
local NewWarZoneTasksPage = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/NewWarZoneTasks", NewWarZoneTasksPage)

function NewWarZoneTasksPage:ctor()
    self._c1 = self:GetController("c1")

    self._btns = {}
    for i = 0, 2, 1 do
        local btn = self:GetChild("btn" .. i)
        self._btns[i] = btn
    end

    self._list = self:GetChild("list")
    self._list:SetVirtual()

    self._btns[0].title = StringUtil.GetI18n(I18nType.Commmon, "UI_POWER_TARGET_NEWA_WARZONE")
    self._btns[1].title = StringUtil.GetI18n(I18nType.Commmon, "UI_CENTRE_TARGET_NEWA_WARZONE")
    self._btns[2].title = StringUtil.GetI18n(I18nType.Commmon, "UI_LEVEL_TARGET_NEWA_WARZONE")

    self:InitEvent()
end

function NewWarZoneTasksPage:InitEvent()
    for type, btn in pairs(self._btns) do
        self:AddListener(
            btn.onClick,
            function()
                self:SetList(type)
            end
        )
    end

    self._list.itemRenderer = function(index, item)
        local taskInfo = self.taskInfoSort[index + 1]
        item:SetData(taskInfo)
    end
end

local function SortInfo(type)
    local info = GD.NewWarZoneActivityAgent.SortTaskInfo(type)
    table.sort(
        info,
        function(a, b)
            local flag
            if a.finished and not b.finished then
                return false
            elseif not a.finished and b.finished then
                return true
            end
            flag = a.id < b.id
            return flag
        end
    )
    return info
end

--设置列表内容
function NewWarZoneTasksPage:SetList(type)
    self._c1.selectedIndex = type
    --整理后的任务信息(包括config数据和服务端数据)
    self.taskInfoSort = SortInfo(type)
    self._list.numItems = #self.taskInfoSort
    self._list.scrollPane:ScrollTop()
end

--NewWarZoneActivity切换页面的时候会走这里
function NewWarZoneTasksPage:OpenPage()
    self:SetList(self._c1.selectedIndex)
end

return NewWarZoneTasksPage
