--[[
    Author: songzeming
    Function: 信息条 详情信息列表Item
]]
local ItemDetailInfoList = fgui.extension_class(GComponent)
fgui.register_extension('ui://MainCity/itemDetailInfoList', ItemDetailInfoList)

function ItemDetailInfoList:ctor()
    self:AddListener(self._btnDetail.onClick,function()
        self:OnBtnDetailClick()
    end)
end

function ItemDetailInfoList:Init(index, title, base, add)
    self._title.text = title
    if Tool.Integer(base) then
        base = Tool.FormatNumberThousands(base)
    end
    if Tool.Integer(add) then
        add = Tool.FormatNumberThousands(add)
    end
    self._text.text = UITool.GetTextColor(GlobalColor.White, base) .. UITool.GetTextColor(GlobalColor.Green, add)

    local single = index % 2 == 1
    -- self._barBgLight.visible = single
    -- self._barBgDark.visible = not single
    self._barBgLight.visible = false
    self._barBgDark.visible = true
    self:SetBtnDetailActive(false)
end

function ItemDetailInfoList:SetBtnDetailActive(flag, content)
    self._btnDetail.visible = flag
    self.contentDetail = content and content or nil
end

function ItemDetailInfoList:OnBtnDetailClick()
    local data = {
        title = StringUtil.GetI18n(I18nType.Commmon, 'Tips_TITLE'),
        info = self.contentDetail
    }
    UIMgr:Open("ConfirmPopupTextList", data)
end

return ItemDetailInfoList
