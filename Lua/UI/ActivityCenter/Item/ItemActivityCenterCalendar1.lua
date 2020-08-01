--author: 	Amu,maxiaolong
--time:		2019-12-03 11:56:19


local ItemActivityCenterCalendar1 = fgui.extension_class(GComponent)
fgui.register_extension("ui://ActivityCenter/itemActivityCenterCalendar1", ItemActivityCenterCalendar1)

function ItemActivityCenterCalendar1:ctor()
    self._icon = self:GetChild("icon")
    self._title = self:GetChild("title")

    self._listView = self:GetChild("liebiao")

    self._viewW = self._listView.width
    self._width = self.width

    self:InitEvent()
end

function ItemActivityCenterCalendar1:InitEvent()
    self._listView.itemRenderer = function(index, item)
        if not index then
            return
        end
        item:SetData(self._info, index)
    end

    self:AddListener(self._listView.scrollPane.onScroll,
        function()
            Event.Broadcast(_G.ActivityModel.EVENT_DAY_SCROLL, self._listView.scrollPane.percX)
        end
    )

    self:AddEvent(
        _G.ActivityModel.EVENT_DAY_SCROLL,
        function(value)
            if self._listView.scrollPane.percX ~= value then
                self._listView.scrollPane.percX = value
            end
        end
    )
end

function ItemActivityCenterCalendar1:SetData(info, index)
    self._info = info
    self.index = index

    self.config = ConfigMgr.GetItem("configActivitys", self._info.Id)
    self._title.text = StringUtil.GetI18n(I18nType.Commmon, self.config.activity_name)
    self._icon.icon = UITool.GetIcon(self.config.icon)

    self:RefreshListView()
end

function ItemActivityCenterCalendar1:RefreshListView()
    self._listView.numItems = ActivityModel._SHOWDAY
    self.item = self._listView:GetChildAt(0)
    self._itemW = self.item.width
    self.width = self._width + self._itemW * ActivityModel._SHOWDAY - self._viewW
end

return ItemActivityCenterCalendar1
