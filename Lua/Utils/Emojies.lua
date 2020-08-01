-- author:{Amu}
-- time:2019-06-17 19:28:02

local Emojies = {}

local default = {}
local emojieList = {}
local emojieNameList = {}

function Emojies:Init()
    emojieList = ConfigMgr.GetList("configEmojis")
    for _,v in ipairs(emojieList)do
        EmojiesMgr:AddEmojie(string.format("0x%s", v.icon[2]), v.icon[1], v.icon[2])
        emojieNameList[v.icon[2]] = v.emojieName
    end
    default = ConfigMgr.GetVar("DefaultEmoji")
end

function Emojies:GetEmokoesIdByType(type)
    local emojies = {}
    if not emojies[type] then
        emojies[type] = {}
        for _,v in ipairs(emojieList)do
            if v.emojiTab == type then
                table.insert(emojies[type],v.icon)
            end
        end
    end
    if type == EMOJIES_TYPE.First then
        self.usedEmojies = PlayerDataModel:GetData(PlayerDataEnum.ChatUsedEmojies)
        if self.usedEmojies then
            local i = 1
            while(#self.usedEmojies < 12)do
                table.insert(self.usedEmojies, default[i])
                i = i + 1
            end
        else
            self.usedEmojies = default
        end
        local index = 1
        for i = 0, 3 do
            for j = 1, 3 do
                table.insert(emojies[type], j+i*8, self.usedEmojies[index])
                index = index + 1
            end
        end

    end
    return emojies[type]
end

function Emojies:GetEmojieNameByIcon(icon)
    return emojieNameList[icon]
end

function Emojies:SaveEmojie(url)
    local used = PlayerDataModel:GetData(PlayerDataEnum.ChatUsedEmojies)
    used = used and used or {}
    for k,v in ipairs(used)do
        if v == url then
            table.remove(used, k)
            break
        end
    end
    table.insert(used, 1, url)
    PlayerDataModel:SetData(PlayerDataEnum.ChatUsedEmojies, used)
end

return Emojies