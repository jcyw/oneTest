--author: 	Amu
--time:		2019-07-10 10:28:58


local ItemUnionVoteResult = fgui.extension_class(GComponent)
fgui.register_extension("ui://Union/itemUnionVoteResult", ItemUnionVoteResult)

ItemUnionVoteResult.tempList = {}

function ItemUnionVoteResult:ctor()
    self._title = self:GetChild("title")
    self._titleNum = self:GetChild("titleNum")
    self._progressBar = self:GetChild("ProgressBar")

    self:InitEvent()
end

function ItemUnionVoteResult:InitEvent()
end

function ItemUnionVoteResult:SetData(info, index, isTranslated)
    self.info = info
    if isTranslated then
        self._title.text = self.info.TOptions[index+1]
    else
        self._title.text = self.info.Options[index+1]
    end
    
    local num = 0
    for _,v in ipairs(info.members)do
        for _,title in pairs(v.Votes)do
            if title == self._title.text then
                num = num + 1
                break
            end
        end
    end
    self._titleNum.text = string.format("%d/%d", num, #info.members)
    self._progressBar.value = num/#info.members*100
end

return ItemUnionVoteing