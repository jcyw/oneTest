--author: 	Amu
--time:		2019-08-13 17:07:13

local ItemMailAllianceAssistanceTag = fgui.extension_class(GComponent)
fgui.register_extension("ui://Mail/itemMailAllianceAssistanceTag", ItemMailAllianceAssistanceTag)


function ItemMailAllianceAssistanceTag:ctor()
    self._textAllianceName = self:GetChild("textAllianceName")
    self._textCoordinate = self:GetChild("textCoordinate")
    self._textTime = self:GetChild("textTime")

    self:InitEvent()
end

function ItemMailAllianceAssistanceTag:InitEvent(  )
    self:AddListener(self._textCoordinate.onClick,function()
        TurnModel.WorldPos(self.pos.x, self.pos.y)
    end)
end

function ItemMailAllianceAssistanceTag:SetData(info, report)
    self.report = JSON.decode(info.Report)
    self._textAllianceName.text = string.format("(%s)%s", self.report.Alliance, self.report.Player)
    self.pos = {
        x =  math.ceil(report.X),
        y =  math.ceil(report.Y)
    }
    self._textCoordinate.text = StringUtil.GetI18n(I18nType.Commmon, "Ui_MTR_PlayPlace", {x = math.ceil(report.X), y = math.ceil(report.Y)})
    self._textTime.text = TimeUtil:StampTimeToYMDHMS(info.CreatedAt)
end

return ItemMailAllianceAssistanceTag