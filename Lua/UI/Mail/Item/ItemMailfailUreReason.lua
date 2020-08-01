--author: 	Amu
--time:		2020-02-11 14:28:18
local GD = _G.GD
local ItemMailfailUreReason = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailfailUreReason", ItemMailfailUreReason)

local TrainModel = import("Model/TrainModel")

function ItemMailfailUreReason:ctor()
    self._arrowR = self:GetChild("tagBg")
    self._btnGo = self:GetChild("btnGo")
    self._textTagName = self:GetChild("textTagName")
    self._textDescribe = self:GetChild("textDescribe")
    self._listView = self:GetChild("liebiao")
    self._item1 = self:GetChild("itemProp1")
    self._item2 = self:GetChild("itemProp2")
    self._item3 = self:GetChild("itemProp3")
    self._item1:SetTitleColor(Color.black)
    self._item2:SetTitleColor(Color.black)
    self._item3:SetTitleColor(Color.black)

    self._tagBg = self:GetChild("tagBg")
    self._bg = self:GetChild("bg")

    self._ctrView = self:GetController("c1")

    self:InitEvent()
end

function ItemMailfailUreReason:InitEvent()
    self:AddListener(self._arrowR.onClick,function()
        if self._select then
            if self._index == 1 then
                self._ctrView.selectedIndex = 1
            elseif self._index == 2 then
                self._ctrView.selectedIndex = 2
            elseif self._index == 3 then
                self._ctrView.selectedIndex = 3
            elseif self._index == 4 then
                self._ctrView.selectedIndex = 4
            end
            self._select = false
        else
            self._select = true
            self._ctrView.selectedIndex = 0
        end
        self:Refresh()
        self._panel:RefreshView()
    end)

    self:AddListener(self._btnGo.onClick,function()
        if self._index == 1 then
            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingTankFactory then
                    TurnModel.TrainArmy(v)
                    return
                end
            end
        elseif self._index == 2 then
            UIMgr:Open("BaseGain", Global.PageBaseBuff)
        elseif self._index == 3 then
            UIMgr:Open("Backpack", {StoreTag = 0})
        elseif self._index == 4 then

            for _, v in pairs(Model.Buildings) do
                if v.ConfId == Global.BuildingTankFactory then
                    TurnModel.EnterMyCityFunc(function()
                        if v.Level >= BuildModel.GetConf(v.ConfId).max_level then
                            TipUtil.TipById(50067)
                        else
                            UIMgr:ClosePopAndTopPanel()
                            UIMgr:Open("BuildRelated/BuildUpgrade", v.Pos)
                        end
                    end)
                    return
                end
            end
        end
    end)

    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end

        local armyConf = ConfigMgr.GetItem("configArmys", Global.MailBattleHelpForce[index + 1].id)
        item:GetChild("icon").icon = TrainModel.GetImageAvatar(Global.MailBattleHelpForce[index + 1].id)
        local armyTypeConf = ConfigMgr.GetItem("configArmyTypes", armyConf.arm)
        item:GetChild("iconTroop").icon = UITool.GetIcon(armyTypeConf.icon)
        item:GetChild("textTroop").text = ArmiesModel.GetLevelText(armyConf.level)
    end
end

function ItemMailfailUreReason:SetData(index, panel)
    self._panel = panel
    self._index = index
    if self._select then
        if self._index == 1 then
            self._ctrView.selectedIndex = 1
        elseif self._index == 2 then
            self._ctrView.selectedIndex = 2
        elseif self._index == 3 then
            self._ctrView.selectedIndex = 3
        elseif self._index == 4 then
            self._ctrView.selectedIndex = 4
        end
    else
        self._ctrView.selectedIndex = 0
    end
    self:Refresh()
end

function ItemMailfailUreReason:Refresh()
    if self._index == 1 then
        self._textTagName.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_01")
        self._textDescribe.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_02")
        self._listView.numItems = #Global.MailBattleHelpForce
        if self._select then
            self._listView.y = self._textDescribe.y + self._textDescribe.displayObject.height + 5
            self._btnGo.y = self._textDescribe.y + self._textDescribe.displayObject.height + self._listView.height + 10
            self.height = self._textDescribe.y + self._textDescribe.displayObject.height + self._listView.height + self._btnGo.height + 10
            self._bg.height = self.height - self._tagBg.height
        else
            self.height = self._tagBg.height
        end
    elseif self._index == 2 then
        self._textTagName.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_04")
        self._textDescribe.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_05")
        self:SetItem(self._item1, Global.MailBattleHelpBuff[1])
        self:SetItem(self._item2, Global.MailBattleHelpBuff[2])
        if self._select then
            self._item1.y = self._textDescribe.y + self._textDescribe.displayObject.height + 5
            self._item2.y = self._textDescribe.y + self._textDescribe.displayObject.height + 5
            self._btnGo.y = self._textDescribe.y + self._textDescribe.displayObject.height + self._item1.height + 60
            self.height = self._textDescribe.y + self._textDescribe.displayObject.height + self._item1.height + self._btnGo.height + 60
            self._bg.height = self.height - self._tagBg.height
        else
            self.height = self._tagBg.height
        end
    elseif self._index == 3 then
        self._textTagName.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_06")
        self._textDescribe.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_07")
        self:SetItem(self._item3, Global.MailBattleHelpNum[1])
        if self._select then
            self._item3.y = self._textDescribe.y + self._textDescribe.displayObject.height + 5
            self._btnGo.y = self._textDescribe.y + self._textDescribe.displayObject.height + self._item3.height + 60
            self.height = self._textDescribe.y + self._textDescribe.displayObject.height + self._item3.height + self._btnGo.height + 60
            self._bg.height = self.height - self._tagBg.height
        else
            self.height = self._tagBg.height
        end
    elseif self._index == 4 then
        self._textTagName.text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_08")
        self._textDescribe  .text = StringUtil.GetI18n("configI18nCommons", "Ui_Mail_FailureAnalysis_09")
        if self._select then
            self._btnGo.y = self._textDescribe.y + self._textDescribe.displayObject.height + 10
            self.height = self._textDescribe.y + self._textDescribe.displayObject.height + self._btnGo.height + 10
            self._bg.height = self.height - self._tagBg.height
        else
            self.height = self._tagBg.height
        end
    end
end

function ItemMailfailUreReason:SetItem(item, info)
    local conf = ConfigMgr.GetItem("configItems", info.id)
    local itemName = GD.ItemAgent.GetItemNameByConfId(conf.id)
    item:SetAmount(conf.icon, conf.color, info.num, itemName, GD.ItemAgent.GetItemInnerContent(info.id))
end

function ItemMailfailUreReason:SetArmyItem(item, info)

end

return ItemMailfailUreReason