--[[
    author:Temmie
    time:2019-12-19 11:22:18
    function:援助查看
]]
local TroopAssistance = UIMgr:NewUI("TroopAssistance")

local ItemUnionAggregation = import("UI/Union/ItemUnionAggregation")

function TroopAssistance:OnInit()
    local view = self.Controller.contentPane
    self._typeController = view:GetController("typeController")

    self._list.itemRenderer = function(index, item)
        if index < #self.datas then
            local data = self.datas[index + 1]
            local itemClickFunc = function()
                if item:GetSelected() then
                    for k,v in pairs(self.curSelectedList) do
                        if v == data.UserId then
                            table.remove(self.curSelectedList, k)
                            break
                        end
                    end
                else
                    table.insert(self.curSelectedList, data.UserId)
                end
                self._list:RefreshVirtualList()
            end
            item:Init(ItemUnionAggregation.TypeEnum.Common, itemClickFunc)

            --选中项展开士兵列表
            for _,v in pairs(self.curSelectedList) do
                if v == data.UserId then
                    item:OpenList(data.Team.Armies, data.Team.Beasts, function()
                        --遣返
                        Net.AllianceBattle.RemovalAssist(data.UserId, data.Team.EventId, function(rsp)
                            if rsp.Fail then
                                return
                            end

                            for k,v in pairs(self.datas) do
                                if v.UserId == data.UserId then
                                    table.remove(self.datas, k)
                                    break
                                end
                            end
                            self._list.numItems = #self.datas
                            if #self.datas <= 0 then
                                self._typeController.selectedPage = "empty"
                            else
                                self._typeController.selectedPage = "normal"
                            end
                        end)
                    end)
                    break
                end
            end

            local total = 0
            local power = 0
            for _,v in pairs(data.Team.Armies) do
                total = total + v.Amount
                power = power + math.floor(ConfigMgr.GetItem("configArmys", v.ConfId).power * v.Amount)
            end
            item:SetContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Power"), power)
            item:SetSubContent(StringUtil.GetI18n(I18nType.Commmon, "Ui_Alliance_ASsistance_Num"), total)
            item:SetPlayerInfo(data, data.Name, data.UserId)
        end
    end
    self._list:SetVirtual()

    self:AddListener(self._btnRecord.onClick,function()
        UIMgr:Open("TroopAssistanceRecord")
    end)

    self:AddListener(self._btnExplain.onClick,function()
        Sdk.AiHelpShowSingleFAQ(ConfigMgr.GetItem("configWindowhelps", 1009).article_id)
    end)

    self:AddListener(self._btnReturn.onClick,function()
        UIMgr:Close("TroopAssistance")
    end)
end

function TroopAssistance:OnOpen(rsp)
    local datas = rsp.Garrisons
    local max = rsp.MaxAssist

    if not datas or #datas <= 0 then
        self._typeController.selectedPage = "empty"
    else
        self._typeController.selectedPage = "normal"
    end

    self.datas = datas
    self.curSelectedList = {}
    self._list.numItems = #datas

    local total = 0
    for _,v in pairs(datas) do
        for _,v1 in pairs(v.Team.Armies) do
            total = total + v1.Amount
        end
    end
    self._textTroopsNum.text = total.."/"..max
end

return TroopAssistance