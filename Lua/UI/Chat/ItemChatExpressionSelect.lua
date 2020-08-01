--author: 	Amu
--time:		2019-07-16 14:32:38
local Emojies = import("Utils/Emojies")

local ItemChatExpressionSelect = fgui.extension_class(GComponent)
fgui.register_extension("ui://Common/itemChatExpressionSelect", ItemChatExpressionSelect)

ItemChatExpressionSelect.tempList = {}

function ItemChatExpressionSelect:ctor()
    self._text = self:GetChild("textRecentUse")
    self._line = self:GetChild("line")
    self._liebiaoR = self:GetChild("liebiaoR")
    self._liebiaoX = self:GetChild("liebiaoX")
    self._liebiaoPoint = self:GetChild("liebiaoPoint")

    self._textX = self._text.x
    self._lineX = self._line.x

    self._ctrView = self:GetController("c1")

    self._btnAdd = self:GetChild("btnExpressionAdd")
    self._btnList = {
        {
            type = EMOJIES_TYPE.First,
            btn = self:GetChild("btnExpression1")
        },
        {
            type = EMOJIES_TYPE.BigFirst,
            btn = self:GetChild("btnExpression2")
        },
    }

    self:InitEvent()
    self:InitListView()
    self:ShieldBigEmojie(true) -- 屏蔽大表情
end

function ItemChatExpressionSelect:InitEvent()
    self:AddListener(self._btnAdd.onClick,function()
        TipUtil.TipById(50323)
        -- UIMgr:Open("ChatExpression")
    end)

    self:AddListener(self._liebiaoX.scrollPane.onScroll,function()
        self:InvalidateBatchingState()
        self._text.x = self._textX - self._liebiaoX.scrollPane.scrollingPosX 
        -- self._line.x = self._lineX - self._liebiaoX.scrollPane.scrollingPosX 
    end)

    for _,v in pairs(self._btnList)do
        self:AddListener(v.btn.onClick,function()
            if v.type == self.emojiesType then
                return
            end
            self.selectBtn.selected = false
            self.selectBtn = v.btn
            self.emojies = Emojies:GetEmokoesIdByType(v.type)
            self.emojiesType = v.type
            if v.type == EMOJIES_TYPE.First then
                self._ctrView.selectedIndex = 0
            else
                self._ctrView.selectedIndex = 1
            end

            self:RefreshListView(v.type)
        end)
    end

    self._liebiaoR.itemRenderer = function(index, item)
        if not index and not self.emojies[index+1] then 
            return
        end
        item:GetChild("icon").icon = UITool.GetIcon(self.emojies[index+1])
    end

    self:AddListener(self._liebiaoR.onClickItem,function(context)
        local item = context.data
        self.callback(item, self.emojiesType)
    end)

    self:AddListener(self._liebiaoR.scrollPane.onScrollEnd,function(context)
        self:RefreshPointListView()
    end)

    -- self._liebiaoR:SetVirtual()

    self._liebiaoX.itemRenderer = function(index, item)
        if not index then
            return
        end
        if index == 2 and not self.addLine then
            item:AddChild(self._line)
            self._line.xy = Vector2(item.width, 10)
            self.addLine = true
        end
        item:SetData(self.emojies[index+1])
    end
    self:AddListener(self._liebiaoX.onClickItem,function(context)
        local item = context.data
        local data = item:GetData()
        self.callback(item, self.emojiesType)
        -- local url = item:GetChild("icon").icon
        Emojies:SaveEmojie(data)
    end)

    self:AddListener(self._liebiaoX.scrollPane.onScrollEnd,function(context)
        self:RefreshPointListView()
    end)

    self:AddListener(self._liebiaoPoint.onClickItem,function(context)
        local item = context.data
        self:SetCurPage(item:GetIndex())
        self:RefreshPointListView()
    end)

    self._liebiaoPoint.itemRenderer = function(index, item)
        if not index then 
            return
        end
        -- if index == self:GetCurPage() then
        --     item:GetChild("point").visible = false
        -- else
        --     item:GetChild("point").visible = true
        -- end
        item:SetData(self:GetCurPage(), index)
    end

    self._liebiaoPoint:SetVirtual()

    -- self._liebiaoL.itemRenderer = function(index, item)
    --     if not index then 
    --         return
    --     end
    --     item:GetChild("icon").icon = self.usedEmojies[index+1]
    -- end

    -- self:AddListener(self._liebiaoL.onClickItem,function(context)
    --     local item = context.data
    --     self.callback(item, self.emojiesType)
    --     local url = item:GetChild("icon").icon
    --     self:SaveEmojie(url)
    -- end)

    -- self._liebiaoL:SetVirtual()
end

function ItemChatExpressionSelect:ShieldBigEmojie(flag)
    if flag then
        for _,v in ipairs(self._btnList)do
            if v.type ~= EMOJIES_TYPE.First then
                v.btn.visible = false
            end
        end
    else
        for _,v in ipairs(self._btnList)do
            if v.type ~= EMOJIES_TYPE.First then
                v.btn.visible = true
            end
        end
    end
end

function ItemChatExpressionSelect:InitListView()
    self.emojiesType = EMOJIES_TYPE.First
    self.selectBtn = self._btnList[1].btn
    self.emojies = Emojies:GetEmokoesIdByType(self.emojiesType)

    
    -- self._liebiaoPoint.numItems = 5
    self:RefreshListView(self.emojiesType)
end

function ItemChatExpressionSelect:RefreshListView(type)
    if type<100 then
        self._liebiaoX.numItems = #self.emojies
        self._liebiaoX:SetBoundsChangedFlag()
        self._liebiaoX:EnsureBoundsCorrect()
        self._liebiaoPoint.numItems = self._liebiaoX.scrollPane.contentWidth/self._liebiaoX.scrollPane.viewWidth
    elseif type>=100 then
        self._liebiaoR.numItems = #self.emojies
        self._liebiaoR:SetBoundsChangedFlag()
        self._liebiaoR:EnsureBoundsCorrect()
        self._liebiaoPoint.numItems = self._liebiaoR.scrollPane.contentWidth/self._liebiaoR.scrollPane.viewWidth
    end
end

function ItemChatExpressionSelect:RefreshPointListView()
    if self.emojiesType<100 then
        self._liebiaoPoint.numItems = self._liebiaoX.scrollPane.contentWidth/self._liebiaoX.scrollPane.viewWidth
    elseif self.emojiesType>=100 then
        self._liebiaoPoint.numItems = self._liebiaoR.scrollPane.contentWidth/self._liebiaoR.scrollPane.viewWidth
    end
end

function ItemChatExpressionSelect:GetCurAmountPage()
    if self.emojiesType<100 then
        return self._liebiaoX.scrollPane.contentWidth/self._liebiaoX.scrollPane.viewWidth
    elseif self.emojiesType>=100 then
        return self._liebiaoR.scrollPane.contentWidth/self._liebiaoR.scrollPane.viewWidth
    end
    return 0
end

function ItemChatExpressionSelect:GetCurPage()
    if self.emojiesType<100 then
        return self._liebiaoX.scrollPane.currentPageX
    elseif self.emojiesType>=100 then
        return self._liebiaoR.scrollPane.currentPageX
    end
    return 0
end

function ItemChatExpressionSelect:SetCurPage(index)
    if self.emojiesType<100 then
        self._liebiaoX.scrollPane.currentPageX = index
    elseif self.emojiesType>=100 then
        self._liebiaoR.scrollPane.currentPageX = index
    end
end

function ItemChatExpressionSelect:SetData(cb, type)
    self.callback = cb
    -- self:Refresh()
end

function ItemChatExpressionSelect:Refresh()
    -- self.usedEmojies = PlayerDataModel:GetData(PlayerDataEnum.ChatUsedEmojies)
    -- if self.usedEmojies then
    --     self._liebiaoL.numItems = #self.usedEmojies
    -- else
    --     self._liebiaoL.numItems = 0
    -- end
    self.emojies = Emojies:GetEmokoesIdByType(self.emojiesType)
    self:RefreshListView(self.emojiesType)
end

-- function ItemChatExpressionSelect:SaveEmojie(url)
--     local used = PlayerDataModel:GetData(PlayerDataEnum.ChatUsedEmojies)
--     used = used and used or {}
--     for k,v in ipairs(used)do
--         if v == url then
--             table.remove(used, k)
--             break
--         end
--     end
--     table.insert(used, 1, url)
--     PlayerDataModel:SetData(PlayerDataEnum.ChatUsedEmojies, used)
-- end

return ItemChatExpressionSelect
