--[[
    Author: songzeming
    Function: 靶场转盘 幸运币不足弹框
]]
local RangeChipPrompt = fgui.extension_class(GComponent)
fgui.register_extension('ui://Casino/RangeChipPrompt', RangeChipPrompt)

function RangeChipPrompt:ctor()
    self._btnMore.icon = UITool.GetIcon(ConfigMgr.GetItem("configResourcess", Global.ResCasinoCounter).img)
    self:AddListener(self._btnMore.onClick,function()
        UIMgr:Open("RangeChip", "Normal", self.casinoData)
    end)
end

function RangeChipPrompt:Init(casinoData)
    self.casinoData = casinoData

    self:SetPromptVisible(true)
    self:UpdataData()
end

function RangeChipPrompt:SetPromptVisible(flag)
    self.visible = flag
    if not flag then
        if self.cd_func then
            self:UnSchedule(self.cd_func)
        end
    end
end

function RangeChipPrompt:UpdataData()
    if self.cd_func then
        self:UnSchedule(self.cd_func)
    end
    local function get_time()
        return self.casinoData.NextFreeAt - Tool.Time()
    end
    local cd_func = function()
        local t = get_time()
        local values = {
            time = Tool.FormatTime(t)
        }
        self._textTime.text = StringUtil.GetI18n(I18nType.Commmon, "ShootingReward_12", values)
    end
    cd_func()
    self.cd_func = function()
        if get_time() >= 0 then
            cd_func()
            return
        end
        --倒计时结束 重置免费次数
        self.casinoData.Free = true
        Event.Broadcast(EventDefines.UIRangeTurntableData, self.casinoData)
        self:SetPromptVisible(false)
    end
    self:Schedule(self.cd_func, 1)
end

return RangeChipPrompt
