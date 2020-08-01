--[[
    author:{zhanzhang}
    time:2019-11-29 21:34:53
    function:{黑骑士查看排名奖励}
]]
local BlackKnightHistoryRank = UIMgr:NewUI("BlackKnightHistoryRank")

function BlackKnightHistoryRank:OnInit()
    local view = self.Controller.contentPane
    self._controller = view:GetController("c1")
    self:OnRegister()
end

function BlackKnightHistoryRank:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("BlackKnightHistoryRank")
        end
    )
    self._rankContent:SetVirtual()
    self._rankContent.itemRenderer = function(index, item)
        item:Init(index, self.list[index + 1], self.showType)
    end
end

function BlackKnightHistoryRank:OnOpen(showType, list)
    self.showType = showType
    self.list = list
    if not list or #list == 0 then
        self._controller.selectedIndex = 1
    else
        self._controller.selectedIndex = 0
        self._textTagName.text = StringUtil.GetI18n(I18nType.Commmon, showType == 1 and "UI_PERSONAL_RANK" or "UI_UNION_RANK")
    end
    self._rankContent.numItems = #list
end
--未加入联盟前往联盟页面
function BlackKnightHistoryRank:GoUnionView()
end

return BlackKnightHistoryRank
