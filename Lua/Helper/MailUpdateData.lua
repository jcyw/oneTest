--author: 	Amu
--time:		2019-08-27 11:14:51
--主要记录本地邮件和服务器邮件的差异片段


local MailUpdateData = {}

function MailUpdateData:Init()
    self.data = PlayerDataModel:GetData(PlayerDataEnum.MailsUpdateData)
    if not self.data or self.data == JSON.null then
        self.data = {}
    end
end

function MailUpdateData:SavaData()
    PlayerDataModel:SetData(PlayerDataEnum.MailsUpdateData, self.data)
end

function MailUpdateData:InsertData(type, data)
    if not self.data[type] or self.data[type] == JSON.null then
        self.data[type] = {}
    end
    for _,v in ipairs(self.data[type])do
        if v._e == data._e and v._f == data._f then
            return
        end
    end
    table.insert(self.data[type], data)
    self:SavaData()
end

function MailUpdateData:Pop(type)
    local data = table.remove(self.data[type])
    self:SavaData()
    return data
end

function MailUpdateData:GetData(type)
    if self.data[type] and self.data[type] ~= JSON.null and #self.data[type] > 0 then
        return self.data[type][#self.data[type]]
    else
        return {}
    end
end

function MailUpdateData:ClearData()
    self.data = {}
    self:SavaData()
end

return MailUpdateData
