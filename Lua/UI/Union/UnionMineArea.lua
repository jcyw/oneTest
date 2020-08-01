--[[
    author:{zhanzhang}
    time:2019-08-01 17:32:16
    function:{联盟矿}
]]
local UnionMineArea = UIMgr:NewUI("UnionMineArea")

local MapModel = import("Model/MapModel")

function UnionMineArea:OnInit()
    -- body
    local view = self.Controller.contentPane

    self._btnReturn = view:GetChild("btnReturn")
    self._btnDismantle = view:GetChild("btnDismantle")
    self._contentList = view:GetChild("liebiao")

    --剩余资源量
    self._textSurplusNum = view:GetChild("textSurplusNum")
    --采集资源速度
    self._textConstructionNum = view:GetChild("textConstructionNum")
    --已采集量
    self._textDestroyNum = view:GetChild("textDestroyNum")

    self:OnRegister()

    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.UnionGift)
end

function UnionMineArea:OnRegister()
    self.RemainAmount = 0
    self:AddListener(self._btnReturn.onClick,
        function()
            UIMgr:Close("UnionMineArea")
        end
    )
    self:AddListener(self._btnDismantle.onClick,
        function()
            -- 请求-拆除联盟建筑
            Net.AllianceBuildings.Destroy(confId)
        end
    )
    self.calTimeFunc = function()
        self:RefreshMineInfo()
    end

    self._contentList.itemRenderer = function(index, item)
        item:Init(self.ArmyList[index])
    end
    self._contentList:SetVirtual()
end

function UnionMineArea:OnOpen(chunkInfo)
    Net.MapInfos.AllianceMineInfo(
        chunkInfo.Id,
        function(rsp)
            self:InitMineInfo(rsp.AllianceMineInfo)
            self:InitMineArmy(rsp.AllianceMiners)
        end
    )
end

function UnionMineArea:OnClose()
    self:UnSchedule(self.calTimeFunc)
end

function UnionMineArea:InitMineInfo(data)
    -- AllianceId:"bl1vqakllhci892p2n1g"
    -- FinishAt:1564753028
    -- MaxAmount:200000000
    -- MaxMember:10
    -- Member:1
    -- MineAt:0
    -- MineId:210031
    -- MineSpeed:54000
    -- RemainAmount:200000000
    self._textConstructionNum.text = data.MineSpeed
    self.MineSpeed = data.MineSpeed
    self.RemainAmount = data.RemainAmount
    if data.FinishAt > 0 then
        self:Schedule(self.calTimeFunc, 1, true)
    end
end
function UnionMineArea:InitMineArmy(list)
    self.ArmyList = list
    self._contentList.numItems = #list
end
--倒计时刷新时状态
function UnionMineArea:RefreshMineInfo()
    self.RemainAmount = self.RemainAmount - self.MineSpeed
    self._textSurplusNum.text = self.RemainAmount
end

return UnionMineArea
