--[[
    author:{zhanzhang}
    time:2019-06-29 09:44:07
    function:{战斗记录}
]]
local UnionBattleRecords = UIMgr:NewUI("UnionBattleRecords")
--单次请求战报条数
local onceCount = 20
local thresholdVal = 10

function UnionBattleRecords:OnInit()
    -- body
    local view = self.Controller.contentPane
    self._btnReturn = view:GetChild("btnReturn")
    self._contentList = view:GetChild("liebiao")

    self:OnRegister()
end

function UnionBattleRecords:OnRegister()
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionBattleRecords")
        end
    )
    self._contentList:SetVirtual()
    self._contentList.itemRenderer = function(index, item)
        -- self.nowIndex = math.ceil(index / 10)
        -- --战斗记录小于10
        -- if #self.list - index < thresholdVal then
        -- end
        item:Init(index, self.list[index + 1])
    end
end
function UnionBattleRecords:OnOpen()
    self:GetRecords(0)
end

function UnionBattleRecords:GetRecords(index)
    Net.AllianceBattle.Logs(
        index,
        onceCount,
        function(rsp)
            self.list = rsp.Logs
            self._contentList.numItems = #self.list
            if rsp.Offset == 0 and #rsp.Logs == 0 then
                self._textEmpty.visible = true
                return
            end
            self._textEmpty.visible = false
        end
    )
end

return UnionBattleRecords
