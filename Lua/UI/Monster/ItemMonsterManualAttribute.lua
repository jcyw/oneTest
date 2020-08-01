--[[
    Author: zixiao
    Function: 怪兽图鉴
]]
local ItemMonsterManualAttribute = fgui.extension_class(GComponent)
fgui.register_extension("ui://Monster/itemMonsterManualAttribute", ItemMonsterManualAttribute)
local MonsterModel = import("Model/MonsterModel")

function ItemMonsterManualAttribute:ctor()
	self._textTitle = self:GetChild("title")
	self._textNum = self:GetChild("text")
	self._progressBarBlue = self:GetChild("ProgressBarBlue")
	self._progressBarRed = self:GetChild("ProgressBarRed")
	self._progressBarGreen = self:GetChild("ProgressBarGreen")
	self._ctr = self:GetController("Blood")
	self._ctrBarColor = self:GetController("BarColor")
end

function ItemMonsterManualAttribute:SetTitle(text)
	self._textTitle.text = text
end

function ItemMonsterManualAttribute:SetMax(num)
	self._progressBarBlue.max = num
	self._progressBarRed.max = num
	self._progressBarGreen.max = num
end

function ItemMonsterManualAttribute:SetPercent(percent)
	local num = self._progressBarBlue.max * percent
	self._progressBarBlue.value = num
	self._progressBarRed.value = num
	self._progressBarGreen.value = num
	self._ctr.selectedIndex = percent == 1 and 0 or 1
end
function ItemMonsterManualAttribute:SetTextNum(num)
	self._textNum.text = Tool.FormatNumberThousands(num)
end

function ItemMonsterManualAttribute:SetBarColor(color)
	self._ctrBarColor.selectedPage = color
end

function ItemMonsterManualAttribute:SetBarScaleX(vecX)
	if vecX>1 then
		vecX = 1
	end
	if not self.baseWidth then
		self.baseWidth = self._progressBarBlue.width
	end
	self._progressBarBlue.width = self.baseWidth*vecX
	self._progressBarRed.width = self.baseWidth*vecX
	self._progressBarGreen.width = self.baseWidth*vecX
end

return ItemMonsterManualAttribute