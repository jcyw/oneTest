--[[
    author:{zhanzhang}
    time:2019-07-04 19:43:31
    function:{集结进攻Item}
]]
local ItemUnionAggregation = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemUnionAggregation", ItemUnionAggregation)

-- local UnionWarfareModel = import("Model/Union/UnionWarfareModel")

ItemUnionAggregation.TypeEnum = {
    Arrived = "arrived",
    Coming = "coming",
    Common = "common",
    Add = "add",
    Lock = "lock",
}

function ItemUnionAggregation:ctor()
    self._list = self._boxSoldierInfo:GetChild("liebiao")
    self._controller = self:GetController("c1")

    self.primeHeight = 126
    self.height = self.primeHeight

    self:OnRegister()
end

function ItemUnionAggregation:OnRegister()

    self.calTimeFunc = function()
        self:RefreshAttackCountDown()
    end
    
    self._list.itemRenderer = function(index, item)

        if index < self.beastNum then
            if index + 1 == self.beastNum and math.fmod(self.beastNum, 2) == 1 then
                item.width = self._list.width
            else
                item.width = self._list.width / 2 - 0.5
            end
            item:BeastInit(self.beastInfo[index + 1])
            item:ShowBtn(false)
            item.visible = true

            return
        end

        if self.armyInfo then
            -- local num = (self.beastInfo and next(self.beastInfo)) and 2 or 0
            local curIndex = index + 1 - self.beastNum
            item.visible = true
            if curIndex <= #self.armyInfo then
                item:Init(self.armyInfo[curIndex])
                item.width = self._list.width / 2 - 0.5
                item:ShowBtn(false)
            else
                if (curIndex + self.beastNum) == self._list.numItems then
                    item.width = self._list.width
                    item:ShowBtn(true)
                    item:SetCb(function()
                        self._listBtnCb()
                    end)
                else
                    item.visible = false
                end
            end
        end
    end

    self:AddListener(self._touchBar.onClick,
        function()
            if self.clickCb then
                self.clickCb()
            end
        end
    )

    self:AddListener(self._btnSpeedUp.onClick,
        function()
            if self.itemBtnCb then
                self.itemBtnCb()
            end
        end
    )
end

function ItemUnionAggregation:Init(type, clickCb, itemBtnCb)
    -- self.armyInfo = armies
    self._controller.selectedPage = type
    self:UnSchedule(self.calTimeFunc)
    self._textSoldiers.text = ""
    self._textSoldiersNum.text = ""
    self._textTroops.text = ""
    self._textTroopsNum.text = ""
    self._list.numItems = 0

    self.clickCb = clickCb      --点击item
    self.itemBtnCb = itemBtnCb

    self:CloseList()
end

--刷新进攻行动时间
function ItemUnionAggregation:RefreshAttackCountDown()
    local delayTime = self.finish - Tool.Time()
    if (delayTime < 0) then
        self:UnSchedule(self.calTimeFunc)
        return
    end
    local total = self.duration
    self._textTime.text = TimeUtil.SecondToHMS(delayTime)
    self._barTime.value = (total - delayTime) / total * 100
end

--设置头像、名字
function ItemUnionAggregation:SetPlayerInfo(info, name, id)
    -- CommonModel.SetUserAvatar(self._iconHead, info.Avatar, id)
    self._iconHead:SetAvatar(info, nil, id)
    self._textPlayer.text = name
end

--设置第一行信息
function ItemUnionAggregation:SetContent(title, value)
    self._textSoldiers.text = title
    self._textSoldiersNum.text = value
end

--设置第二行信息
function ItemUnionAggregation:SetSubContent(title, value)
    self._textTroops.text = title
    self._textTroopsNum.text = value
end

--设置加入按钮的文本
function ItemUnionAggregation:SetAddBtnContent(value)
    self._textTip.text = value
end

--设置状态文本
function ItemUnionAggregation:SetStatusContent(value)
    self._textAggregation.text = value
end

--开始计时
function ItemUnionAggregation:StartTimer(finish, duration)
    self.finish = finish
    self.duration = duration

    self:Schedule(self.calTimeFunc, 1, true)
end

function ItemUnionAggregation:GetSelected()
    return self.selected
end

function ItemUnionAggregation:OpenList(armies, beasts, btnCb)

    self.selected = true
    self.armyInfo = armies
    self.beastInfo = beasts
    self._listBtnCb = btnCb
    self._boxSoldierInfo.visible = true
    self._btnArrow.rotation = -90

    self.beastNum = 0
    for _,v in pairs(self.beastInfo) do
        self.beastNum = self.beastNum + 1
    end

    if self._listBtnCb then
        -- 有遣返按钮
        local count = #self.armyInfo
        count = count + self.beastNum
        self._list.numItems = count + 1 + math.fmod(count, 2)
    else
        -- 没有遣返按钮
        local count = #self.armyInfo
        count = count + self.beastNum
        self._list.numItems = count
    end

    self._list:ResizeToFit(self._list.numItems)
    self.height = self.primeHeight + self._list.height
end

function ItemUnionAggregation:CloseList()
    self.selected = false
    self.armyInfo = nil
    self.beastInfo = nil
    self._listBtnCb = nil
    self._boxSoldierInfo.visible = false
    self.height = self.primeHeight
    self._btnArrow.rotation = 180
end

return ItemUnionAggregation
