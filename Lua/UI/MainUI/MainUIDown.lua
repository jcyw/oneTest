--[[
    Author: songzeming
    Function: 主界面UI 下排面板
]]
local MainUIDown = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/mainDown", MainUIDown)

local UnionModel = import("Model/UnionModel")
import("UI/MainUI/ItemBtnMainDown")

function MainUIDown:ctor()
    self.fairyBatching = true
    self:CheckUnion()
    self._btnUnion:InitUnionPoint()

    self:AddListener(self._btnUnion.onClick,
        function()
            self:OnBtnUnionClick()
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceOpen,
        function()
            self:OnBtnUnionClick()
            self:CheckUnion()
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceJoin,
        function()
            self:CheckUnion()
            PlayerDataModel:SetData(PlayerDataEnum.AddedUnion, true)
        end
    )
    self:AddEvent(
        EventDefines.UIAllianceCreate,
        function()
            PlayerDataModel:SetData(PlayerDataEnum.AddedUnion, true)
        end
    )
    self:AddEvent(
        UNION_EVENT.Exit,
        function()
            self:CheckUnion()
        end
    )
    self:AddEvent(
        _G.EventDefines.UIMainAllianceIconRefresh,
        function()
            self:CheckUnion()
            _G.CuePointModel:ResetUnion()
        end
    )
end

--检测是否加入联盟
function MainUIDown:CheckUnion()
    self._btnUnion:CheckJoinUnion(UnionModel.CheckJoinUnion())
end

--点击联盟按钮进入联盟
function MainUIDown:OnBtnUnionClick()
    --是否加入联盟
    local isJoinUnion = UnionModel.CheckJoinUnion()
    if not isJoinUnion then
        --没有联盟 打开联盟列表
        UIMgr:Open("UnionView/UnionView")
    else
        --有联盟 获取联盟信息
        UnionModel.RequestUnionInfo(
            function()
                UIMgr:Open("UnionMain/UnionMain")
            end
        )
    end
end

return MainUIDown
