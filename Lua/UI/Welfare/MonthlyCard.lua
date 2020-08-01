--[[
    author:{maxiaolong}
    time:2019-09-28 16:34:54
    function:{月卡功能}
]]
local MonthlyCard = fgui.extension_class(GComponent)
fgui.register_extension("ui://Welfare/MonthlyCard", MonthlyCard)
local WelfareModel = import("Model/WelfareModel")

function MonthlyCard:ctor()
    self:SetShow(false)
    self._listView = self:GetChild("liebiao")
    self._bgImage = self:GetChild("bgBox")
    local allData = ConfigMgr.GetList("configMonthlyPacks")
    self.monthCardAllDatas = {}
    for _, v in ipairs(allData) do
        if v.open == 1 and (not v.newType or v.newType == 0) then
            table.insert(self.monthCardAllDatas, v)
        end
    end
    self.length = #self.monthCardAllDatas
    self._listView.numItems = self.length
    self._listView.itemRenderer = function(index, item)
        local itemParams = self.monthCardAllDatas[index + 1]
        item:SetData(itemParams)
    end
    --刷新数据显示
    self:AddEvent(
        EventDefines.RefreshMonthData,
        function(msg)
            if self.visible then
                local index = 0
                local tempIndex=0
                for _, v in ipairs(self.monthCardAllDatas) do
                    index = index + 1
                    if v.id == msg.Id then
                        tempIndex=index
                        break
                    end
                end
                WelfareModel.UpdateMonthCardData(msg)
                self._listView:GetChildAt(tempIndex-1):SetData(self.monthCardAllDatas[tempIndex])
            end
        end
    )
end

function MonthlyCard:OnOpen()
    self:SetShow(true)
    for i = 1, self._listView.numChildren do
        local item = self._listView:GetChildAt(i - 1)
        item.x = -item.width
    end
    Net.Purchase.GetCardStatus(
        1,
        function(params)
            WelfareModel.SetMonthCardData(params.Info)
            self._listView.scrollPane:ScrollTop()
            AnimationLayer.PlayListLeftToRightAnim(AnimationType.UILeftToRight,self._listView,0.2,self)
            self._listView.numItems = self.length

        end
    )
end

function MonthlyCard:SetContext(context)
    self.context = context
end

function MonthlyCard:SetShow(isShow)
    self.visible = isShow
end

return MonthlyCard
