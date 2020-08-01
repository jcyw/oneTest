local ChatBarModel = {}

local bar = nil

function ChatBarModel.GetChatBar()
    if not bar then
        bar = UIMgr:CreatePopup("Common", "itemChatBar")
    end

    return bar
end

return ChatBarModel