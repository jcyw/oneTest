--[[
    Author: zixiao
    Function: 怪兽图鉴
]]
local MonsterClassPreview = UIMgr:NewUI("MonsterClassPreview")
local MonsterModel = import("Model/MonsterModel")

local MaxLv = 10

function MonsterClassPreview:OnInit()
	local view = self.Controller.contentPane
	self._textTitle = view:GetChild("titleName")

	self:InitEvent()
end

function MonsterClassPreview:InitEvent()
	self:AddListener(self._btnClose.onClick,function ( )
		UIMgr:Close("MonsterClassPreview")
	end)

	self:AddListener(self._bgMask.onClick,function ( )
		UIMgr:Close("MonsterClassPreview")
	end)

	self:AddListener(self._list.scrollPane.onScrollEnd,
		function()
			local curPage = self._list.scrollPane.currentPageX + 1
			for k, v in pairs(self.points) do
				if k == curPage then
					v:GetController("button").selectedIndex = 1
				else
					v:GetController("button").selectedIndex = 0
				end
			end
        end
    )
end


function MonsterClassPreview:OnOpen(info)
	self.index = info.Level
	self.info = info

	local conf = ConfigMgr.GetItem("configArmys", self.info.Id)
	local typeConf = ConfigMgr.GetItem("configArmyTypes", conf.arm)
	self._bgMonster.icon = UITool.GetIcon(typeConf.beast_preview)

	self:RefrehWindow()
end

function MonsterClassPreview:RefrehWindow()

	self._list:RemoveChildrenToPool()
	for i=1, MaxLv do
		local realID = MonsterModel.GetMonsterRealID(self.info.Id, i)
		local item = self._list:AddItemFromPool()
		item:Init(self.info.Id, i)
	end
	
	self._listPoint:RemoveChildrenToPool()
    self.points = {}
    for i=1, MaxLv do
		local point = self._listPoint:AddItemFromPool()
		point.scale = _G.Vector2(0.7,0.7)
        if i == self.index then
            point:GetController("button").selectedIndex = 1
        else
            point:GetController("button").selectedIndex = 0
        end
        table.insert(self.points, point)
	end
	
	self._list:ScrollToView(self.index - 1, false)
end

return MonsterClassPreview