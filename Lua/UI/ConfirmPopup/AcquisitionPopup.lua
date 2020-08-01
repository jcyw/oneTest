local UIMgr = _G.UIMgr
local AcquisitionPopup = UIMgr:NewUI("AcquisitionPopup")
function AcquisitionPopup:OnInit()
    local view = self.Controller.contentPane
    self._content = view:GetChild("_content")
    self._mask = view:GetChild("_mask")
    self._btnClose = view:GetChild("_btnClose")
    self._contentInfos = nil
    self._title = view:GetChild("titleName")
    --列表render
    self._content:SetVirtual()
    self._content.itemRenderer = function(index, item)
        item:SetData(self._contentInfos[index+1])
    end
    self:AddListener(self._btnClose.onClick,
        function()
            UIMgr:Close("AcquisitionPopup")
        end
    )
    self:AddListener(self._mask.onClick,
        function()
            UIMgr:Close("AcquisitionPopup")
        end
    )
end
--[[
    titleTxt标题
    contentInfos = array-{
        title
        icon 图标
        name 前往目的的名称
        click 点击回调
        btnTxt 按钮文本 没有就显示前往
    }
]]
function AcquisitionPopup:OnOpen(titleTxt,contentInfos)
    self._title.text = titleTxt
    self._contentInfos = contentInfos
    self._content.numItems = #self._contentInfos
end
return AcquisitionPopup