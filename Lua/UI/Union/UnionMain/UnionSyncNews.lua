--[[
    Author: songzeming,maxiaolong
    Function: 联盟动态消息
]]
local UnionSyncNews = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/UnionSyncNews", UnionSyncNews)

import("UI/Union/UnionMain/ItemUnionSyncNew")
import("UI/Union/UnionMain/ItemUnionSyncNewsList")
local timeInterval = 60
function UnionSyncNews:ctor()
    self:AddListener(self._btnUp.onClick,
        function()
            self.cb()
        end
    )
    self:AddListener(self._btnArrow.onClick,
        function()
            self.cb()
        end
    )

    self:AddEvent(
        EventDefines.UIAllianceNoticeUpdate,
        function()
            self:UpdateData()
        end
    )

    self._list.itemProvider = function(index)
        if not index then 
            return
        end
        if index == 0 then
            return "ui://Union/itemUnionSyncNew"
        else
            return "ui://Union/itemUnionSyncNewsList"
        end
    end

    self._list.itemRenderer = function(index, item)
        if index == 0 then
            item:SetData(index)
            self._noticeItem = item
        else
            item:Init(self.newsTable[index])
        end
    end

    self:AddListener(self._list.onClickItem,function(context)
        local item = context.data
        if item.GetIndex and item:GetIndex() == 0 then
            UIMgr:Open("AmendmentNotice")
        end
    end)


    self._list:SetVirtual()
    -- self:AddListener(self._list.scrollPane.onPullUpRelease,
    --     function()
    --         self:RequestData()
    --     end
    -- )
end

function UnionSyncNews:Init(cb, data)
    self.cb = cb
    self.data = data.News
    self:UpdateData()
    self:RequestData()
end

function UnionSyncNews:ListViewScrollUp()
    self._list.scrollPane:ScrollUp()
end

function UnionSyncNews:GetNoticeItem()
    return self._noticeItem
end

--向服务器请求数据
function UnionSyncNews:RequestData()
    local num = #self.data
    Net.Alliances.SyncNews(
        num,
        num + 10,
        function(rsp)
            if next(rsp.News) == nil then
                return
            end
            for _, v in ipairs(rsp.News) do
                table.insert(self.data, v)
            end
            self:UpdateData()
        end
    )
end


--刷新数据
function UnionSyncNews:UpdateData()
    local newsTable = {}
    for i = 1, #self.data do
        local createTime = self.data[i].CreatedAt
        local keyTime = math.abs(Tool.Time() - (createTime - timeInterval))
        if newsTable[keyTime] == nil then
            newsTable[keyTime] = {self.data[i]}
        else
            local isContain = false
            for j = 1 , #newsTable[keyTime] do
                if newsTable[keyTime][j].Category == self.data[i].Category and newsTable[keyTime][j].Content ==self.data[i].Content and newsTable[keyTime][j].CreatedAt == self.data[i].CreatedAt  then
                    isContain = true
                end
            end
            if not isContain then
                table.insert(newsTable[keyTime], {Category = self.data[i].Category, Content = self.data[i].Content, CreatedAt = self.data[i].CreatedAt})
            end
        end
    end
    local count = 0
    local tempNewsData = {}
    for k, v in pairs(newsTable) do
        count = count + 1
        table.insert(tempNewsData, v)
    end
    table.sort(
        tempNewsData,
        function(a, b)
            return a[1].CreatedAt > b[1].CreatedAt
        end
    )
    self.newsTable = tempNewsData
    self._list.numItems = (count + 1)
end

return UnionSyncNews
