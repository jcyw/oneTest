--author: 	Amu
--time:		2019-11-28 10:04:21
local GD = _G.GD

local ItemMailSecretBase = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailSecretBase", ItemMailSecretBase)


function ItemMailSecretBase:ctor()
    self._titlelab = self:GetChild("textSuccess")
    self._timelab = self:GetChild("textTime")

    self._describe = self:GetChild("textExplain")

    self._icon = self:GetChild("iconMy")
    self._nameLab = self:GetChild("textName")
    self._posLab = self:GetChild("textPlace")

    self._textDescribe = self:GetChild("textDescribe")
    self._timeText = self:GetChild("textTime")

    self._bg = self:GetChild("bg")

    self._resMainItem = self:GetChild("btnDrop-downBox")
    self._resMainItem.visible = false

    self._resMainItem:GetChild("textTitle").text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_SearchSpoils")

    self._itemX =  self._resMainItem.x
    self._itemY =  self._resMainItem.y

    self._bgH = self._bg.height

    self._height = self.height

    self._nameLab.visible = false

    self._titlelab.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_SearchSuccess")
    self._nameLab.text = ConfigMgr.GetI18n("configI18nCommons", "Ui_Mail_SearchCommander")

    self.resItemList = {}
    
    --设置Banner
    self._banner.icon = UITool.GetIcon(GlobalBanner.MailKillActivity)
end

function ItemMailSecretBase:SetData(index, _info)
    self.info = _info
    self.subType = _info.SubCategory
    self.report = JSON.decode(self.info.Report)

    self._textDescribe.text = _info.Content
    self._timeText.text = TimeUtil:GetTimesAgo(_info.CreatedAt)

    self:InitList()
end

function ItemMailSecretBase:InitList()
    local _h = 0

    local index = 1
    if self.report.Rewards ~= JSON.null then      --资源  2
        self._resMainItem.visible = true
        _h = _h + self._resMainItem.height
        for _,v in ipairs(self.report.Rewards) do
            if not self.resItemList[index] then
                local temp = UIMgr:CreateObject("Mail", "itemItemMailScoutState1")
                self:AddChild(temp)
                self.resItemList[index] = temp
            end
            self.resItemList[index]:GetChild("textIconName1").text = ConfigMgr.GetI18n("configI18nCommons", "RESOURE_TYPE_"..math.ceil(v.Category))
            self.resItemList[index]:GetChild("textIconNameNumber1").color = UITool.Green
            self.resItemList[index]:GetChild("textIconNameNumber1").text = Tool.FormatAmountUnit(v.Amount)
            self.resItemList[index]:GetChild("icon1").icon = GD.ResAgent.GetIconUrl(v.Category)
            self.resItemList[index].visible = true
            self.resItemList[index].x = self._itemX
            self.resItemList[index].y = self._itemY + _h
            _h = _h + self.resItemList[index].height
            index = index + 1
        end

        for i = index, #self.resItemList do
            self.resItemList[i].visible = false
        end
    else
        self._resMainItem.visible = false
        for k,v in pairs(self.resItemList)do
            v.visible = false
        end
    end

    self:SetSize(self.width, self._height+_h - self._resMainItem.height)
    self._bg:SetSize(self._bg.width, self._bgH+_h - self._resMainItem.height)
end

return ItemMailSecretBase