--[[
    author:{zhanzhang}
    time:2019-07-02 13:50:02
    function:{联盟战争多人防御Item}
]]
local ItemUnionWarfareDefenseArmies = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionWarfareDefenseArmies", ItemUnionWarfareDefenseArmies)

local UnionWarfareModel = import("Model/Union/UnionWarfareModel")

function ItemUnionWarfareDefenseArmies:ctor()
    self._iconBuild = self:GetChild("iconBuild")
    self._textNameL = self:GetChild("textNameL")
    self._textCoordinateL = self:GetChild("textCoordinateL")
    self._textActionTime = self:GetChild("textActionTime")
    self._textBattleNum = self:GetChild("textBattleNum")
    self._contentAttackMember = self:GetChild("liebiaoMy")
    self._btnBg = self:GetChild("bgRT")
    self._btnArrow = self:GetChild("btnArrow")

    self._textWeName = self:GetChild("textWeName")
    self._textEnemyName = self:GetChild("textEnemyName")

    self:OnRegister()
end
function ItemUnionWarfareDefenseArmies:OnRegister()
    self.calTimeFunc = function()
        self:RefreshDenseCountDown()
    end
    self:AddListener(self._btnBg.onClick,
        function()
            self:onBtnAssistanceClick()
        end
    )
    -- self._b
end

function ItemUnionWarfareDefenseArmies:Init(data)
    self.data = data
    self._textNameL.text = data.TargetName
    self._textWeName.text = data.TargetName
    self._textBattleNum.text = data.power
    if data.FinishAt > Tool.Time() then
        self:RefreshDenseCountDown()
        self:Schedule(self.calTimeFunc, 1, true)
    end
end

function ItemUnionWarfareDefenseArmies:RefreshDenseCountDown()
    local delayTime = self.data.FinishAt - Tool.Time()
    self._textActionTime.text = TimeUtil.SecondToHMS(delayTime)
end
--[[
此处两种情况
1.被援助人点进来应该看到援助详情
2、其他点直接出兵
]]
function ItemUnionWarfareDefenseArmies:onBtnAssistanceClick()
    --[[此处应该判断
        1.是否同意同一联盟
        2.是否有足够的出征部队数量
        3.防守队伍是否有足够的空位
    ]]
    local posNum = self.data.X * 10000 + self.data.Y
    -- local mission = UnionWarfareModel.GetMissionByBattleId()
    local armyCount = 0
    if self.data.Armies then
        for i = 1, #self.data.Armies do
            armyCount = armyCount + self.data.Armies[i].Amount
        end
    end
    local totalCount = self.data.MaxRally - armyCount
    UIMgr:Open("UnionAggregation", self.data)
end

return ItemUnionWarfareDefenseArmies
-- 回复-集结信息
-- path=AllianceBattleInfosRsp
-- params={Battles: array-AllianceBattle, Missions: array-AllianceBattleMission, Defences: array-AllianceBattle, Assists: array-AllianceBattleMission}

--     请求-援助士兵
-- path=AllianceBattleAssistParams
-- params={UserId: string, X: int32, Y: int32, HeroId: string, Armies: array-Army}

--     请求-取消联盟援助
-- path=AllianceBattleCancelAssistParams
-- params={EventId: string}
