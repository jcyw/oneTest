--[[
    author:{author}
    time:2020-04-29 19:28:47
    function:{desc}
]]
local ItemMonsterClassPreview = fgui.extension_class(GComponent)
fgui.register_extension("ui://Monster/itemMonsterClassPreview", ItemMonsterClassPreview)

local MonsterModel = import("Model/MonsterModel")

function ItemMonsterClassPreview:ctor()
    self._story = self._textStory:GetChild("textStory")
end

function ItemMonsterClassPreview:Init(id, level)
	local realID = MonsterModel.GetMonsterRealID(id, level)
    local conf = ConfigMgr.GetItem("configArmys", realID)
	local name, desc = MonsterModel.GetMonsterNames(realID)

	self._textName.text = ArmiesModel.GetLevelText(level) .. " " .. name
	self._textAttackNum.text = Tool.FormatNumberThousands(conf.attack)
	self._textDefenseNum.text = Tool.FormatNumberThousands(conf.defence)
	self._texttextLifeNum.text = Tool.FormatNumberThousands(conf.health)
	self._textAttackDistanceNum.text = Tool.FormatNumberThousands(conf.range < 1 and 1 or conf.range)
	self._textSpeedNum.text = Tool.FormatNumberThousands(conf.speed)
    self._textWeightBearingNum.text = Tool.FormatNumberThousands(conf.load)
    self._textCombatNum.text = Tool.FormatNumberThousands(conf.power)
    self._story.text = MonsterModel.GetMonsterStory(realID)
    self._image.url = UITool.GetIcon(conf.army_view)
end

return ItemMonsterClassPreview
