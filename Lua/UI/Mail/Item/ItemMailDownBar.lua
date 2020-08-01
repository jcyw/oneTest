-- author:{Amu}
-- time:2019-06-11 11:12:03

local ItemMailDownBar = fgui.extension_class(GButton)
fgui.register_extension("ui://Mail/itemMailDownBar", ItemMailDownBar)

function ItemMailDownBar:ctor()
    self._delBtn = self:GetChild("btnDel")
    -- self._shareBtn = self:GetChild("btnShare")
    self._favoriteBtn = self:GetChild("btnCollection")

    -- self._favoriteText = self:GetChild("textCollection")

    self:InitEvent()
end

function ItemMailDownBar:InitEvent()
    self:AddListener(self._delBtn.onClick,function()
        if self.info.IsFavorite then
            TipUtil.TipById(50081)
        elseif not self.info.IsClaimed then
            TipUtil.TipById(50082)
        else
            Net.Mails.Delete(self.info.Category, {self.info.Uuid},function()
                MailModel:deleteData(self.info.Category, {self.info.Uuid})
                Event.Broadcast(EventDefines.UIDelMiil)
                self._panel:Close()
            end)
        end
    end)

    -- self:AddListener(self._shareBtn.onClick,function()
        
    -- end)

    self:AddListener(self._favoriteBtn.onClick,function()
        if self._favoriteBtn.asButton.selected then
            Net.Mails.MarkFavorite(true, {self.info.Uuid},function()
                -- self._favoriteText.text = "取消收藏"
                TipUtil.TipById(50083)
                local info = MailModel:updateIsFavoriteData(self.info.Category, self.info.Number, true)
                self._panel:RefreshData(info)
            end)
        else
            Net.Mails.MarkFavorite(false, {self.info.Uuid},function()
                -- self._favoriteText.text = "收藏"
                TipUtil.TipById(50084)
                local info = MailModel:updateIsFavoriteData(self.info.Category, self.info.Number, false)
                self._panel:RefreshData(info)
            end)
        end
    end)
end

function ItemMailDownBar:SetData(_info, panel)
    self.info = _info
    self._panel = panel
    self._favoriteBtn.asButton.selected = _info.IsFavorite
    -- if _info.IsFavorite then
    --     self._favoriteText.text = "取消收藏"
    -- else
    --     self._favoriteText.text = "收藏"
    -- end

end

return ItemMailDownBar