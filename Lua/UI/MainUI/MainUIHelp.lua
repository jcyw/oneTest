--[[
    Author: songzeming
    Function: 主界面UI 右侧帮助按钮
]]
local MainUIHelp = fgui.extension_class(GButton)
fgui.register_extension("ui://Common/btnMainHelp", MainUIHelp)

local BuildModel = import("Model/BuildModel")
local UnionHelpModel = import("Model/Union/UnionHelpModel")
import("UI/Common/ItemPointGreen")

function MainUIHelp:ctor()
    self:AddListener(self.onClick,
        function()
            self:OnBtnClick()
        end
    )

    self.visible = false
    self:Init()
end

function MainUIHelp:Init()
    UnionHelpModel.Init(self)
    self:AddEvent(
        EventDefines.UIAllianceHelpInfoExg,
        function()
            self:SetHelpNumber(#UnionHelpModel.GetUnionHelpOtherInfo())
        end
    )
    self:AddEvent(
        UNION_EVENT.Exit,
        function()
            self:SetHelpNumber()
            for _, v in pairs(Model.Buildings) do
                BuildModel.GetObject(v.Id):HelpAnim(false)
            end
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceJoin,
        function()
            for _, v in pairs(Model.Buildings) do
                BuildModel.GetObject(v.Id):ResetCD()
            end
        end
    )
end

function MainUIHelp:SetHelpNumber(number)
    if not number then
        number = 0
    end
    self.visible = number > 0
    CuePointModel:SetSingle(CuePointModel.Type.GreenNumber, number, self, CuePointModel.Pos.RightUp15)
    UnionHelpModel.SetHelpNumber(number)
    Event.Broadcast(EventDefines.UIUnionHelp)
end

function MainUIHelp:OnBtnClick()
    Net.AllianceHelp.All(
        Model.Player.AllianceId,
        function()
            TipUtil.TipById(50120)
            UnionHelpModel.ClearUnionHelpOtherInfo()
            self:SetHelpNumber(0)
        end
    )
end

return MainUIHelp
