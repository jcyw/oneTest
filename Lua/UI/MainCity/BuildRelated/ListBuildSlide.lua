--[[
    Author: songzeming
    Function: 城建 创建建筑 滑动列表
]]
local ListBuildSlide = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/slideBuild", ListBuildSlide)

import("UI/MainCity/BuildRelated/ItemListBuildSlide")
local BLANK_HALF = 2 --占位

function ListBuildSlide:ctor()
    self._list.itemRenderer = function(index, item)
        item:Init(index, self.posType, function()
            self._list.scrollPane:SetPosX(item.x - (item.width+self._list.columnGap) * 2, true)
        end)
    end
    self:AddListener(self._list.scrollPane.onScroll,function()
        self:SlideControl()
    end)

    -- self:AddListener(self._btnL.onClick,function()
    --     self:OnBtnArrowClick(-1)
    -- end)
    -- self:AddListener(self._btnR.onClick,function()
    --     self:OnBtnArrowClick(1)
    -- end)

    -- self:GetChild("maskL").visible = false
    -- self:GetChild("maskR").visible = false
end

--初始化 pos创建位置 confId推荐创建
function ListBuildSlide:Init(cb, pos, confId)
    self.cb = cb
    self.confId = confId
    self.posType = BuildModel.GetBuildPosTypeByPos(pos)

    if self.posType == Global.BuildingZoneInnter then
        --城内
        self._list.numItems = #BuildModel.InnerCreateConf(true, pos) + BLANK_HALF * 2
    elseif self.posType == Global.BuildingZoneWild then
        --城外
        local outer = BuildModel.OuterConf()
        self._list.numItems = #outer + BLANK_HALF * 2
    elseif self.posType == Global.BuildingZoneBeast then
        --巨兽
        local beast = BuildModel.BeastCreateConf(true, pos)
        self._list.numItems = #beast + BLANK_HALF * 2
    end

    self._list:EnsureBoundsCorrect()

    self.showIndex = nil
    self:SlideControl()
    self:RefreshList()
end

function ListBuildSlide:SetRecommendPos(confId, flag)
    self.confId = confId
    local len = self._list.numChildren
    for i = 1 + BLANK_HALF, len - BLANK_HALF do
        local item = self._list:GetChildAt(i - 1)
        if confId == item:GetConfId() then
            self._list.scrollPane:SetPosX(item.x - (item.width+self._list.columnGap) * 2, flag)
            return
        end
    end
end

--获取城内可创建建筑
function ListBuildSlide:GetInnerShow()
    return self.innerShow
end

--滑动控制 缩放/光圈显示/选中
function ListBuildSlide:SlideControl()
    local center = self._list.scrollPane.posX + self._list.viewWidth / 2
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        local iCenter = item.x + item.width / 2
        local distance = math.abs(center - iCenter)
        if distance < item.width / 2 + self._list.columnGap / 2 then
            self.itemIndex = i
            --local scale = 1 + (item.width / (item.width + distance) - 0.5) * 0.2
            --item:SetScale(scale, scale)
            local index = item:GetIndex()
            if index ~= self.showIndex then
                self.showIndex = index
                self:SetArrowActive()
                if self.cb then
                    self.cb()
                end
                self:HideLight()
                item:SetLight(true)
            end
        --else
        --    item:SetScale(1, 1)
        end
    end
end

function ListBuildSlide:GetShowItem()
    return self._list:GetChildAt(self.showIndex)
end

--点击箭头滑动
function ListBuildSlide:OnBtnArrowClick(dir)
    local index = self.showIndex + dir
    if index >= BLANK_HALF and index < self._list.numChildren - BLANK_HALF then
        local itemIndex = self.itemIndex + dir - 1
        local item = self._list:GetChildAt(itemIndex)
        local mvx = item.x + item.width / 2 - self._list.viewWidth / 2
        self._list.scrollPane:SetPosX(mvx, true)
    end
end

--设置左右箭头是否显示
function ListBuildSlide:SetArrowActive()
    -- self._btnL.visible = self.showIndex > BLANK_HALF
    -- self._btnR.visible = self.showIndex + 1 < self._list.numChildren - BLANK_HALF
end

--隐藏光圈
function ListBuildSlide:HideLight()
    for i = 1, self._list.numChildren do
        local item = self._list:GetChildAt(i - 1)
        item:SetLight(false)
    end
end

--推荐跳转到指定建筑
function ListBuildSlide:RefreshList()
    if not self.confId then
        self._list.scrollPane:SetPosX(0)
        return
    end
    local len = self._list.numChildren
    for i = 1 + BLANK_HALF, len - BLANK_HALF do
        local item = self._list:GetChildAt(i - 1)
        if item:GetConfId() == self.confId then
            self._list.scrollPane:SetPosX(item.x - (item.width+self._list.columnGap) * BLANK_HALF)
            return
        end
    end
    self._list.scrollPane:SetPosX(0)
end

--是否解锁
function ListBuildSlide:GetUnlockByIndex(index)
    local item = self._list:GetChildAt(index - 1)
    if not item then return end
    return item:GetBuildUnlock()
end

return ListBuildSlide
