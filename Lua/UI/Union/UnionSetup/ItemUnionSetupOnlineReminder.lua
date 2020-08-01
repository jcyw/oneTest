--[[
    Author: songzeming
    Function: 联盟设置 修改联盟成员上线提示
]]
local ItemUnionSetupOnlineReminder = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionOnLinePrompt", ItemUnionSetupOnlineReminder)

local UnionModel = import("Model/UnionModel")
import("UI/Union/UnionMember/ItemMemberSort")
local function GetPos(index)
    return 5 - index + 1
end

function ItemUnionSetupOnlineReminder:ctor()
    self:AddListener(self._btnSave.onClick,function()
        self:ExgOnlineReminder()
    end)

    self.defaultHeight = self.height - self._list.height
end

function ItemUnionSetupOnlineReminder:Init(members)
    self.height = self.defaultHeight
    self._list.numItems = 0
    if not members then
        self._btnSave.enabled = false
        return
    end
    self._btnSave.enabled = true
    self.exgArr = {}
    self.sortMembers = UnionModel.MemberSort(members)
    self._list.numItems = 5
    for i = 1, self._list.numChildren do
        local index = GetPos(i)
        local item = self._list:GetChildAt(i - 1)
        local member = self.sortMembers[index]
        item:InitExg(self.exgArr, function(exgArr)
            self.exgArr = exgArr
        end)
        item:InitOnlineRemind(index, member, function()
            self:ResetSize()
        end)
        item:CheckSort()
        self:ResetSize()
    end
end

function ItemUnionSetupOnlineReminder:ExgOnlineReminder()
    if not self.exgArr or next(self.exgArr) == nil then
        return
    end
    local add = {}
    local del = {}
    for k, v in pairs(self.exgArr) do
        table.insert(v and add or del, k)
    end
    Net.Alliances.ChangeOnlineNotice(add, del, function()
        for id, flag in pairs(self.exgArr) do
            for _, members in pairs(self.sortMembers) do
                local isFind = false
                for _, member in pairs(members) do
                    if id == member.Id then
                        member.OnlineNotice = flag
                        isFind = true
                        break
                    end
                end
                if isFind then
                    break
                end
            end
        end
        self.exgArr = {}
        TipUtil.TipById(50176)
    end)
end

function ItemUnionSetupOnlineReminder:ResetSize()
    self._list:EnsureBoundsCorrect()
    self.height = self.defaultHeight + self._list.scrollPane.contentHeight
end

return ItemUnionSetupOnlineReminder