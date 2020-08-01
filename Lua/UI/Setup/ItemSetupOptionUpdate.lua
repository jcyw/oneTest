--author: 	Amu
--time:		2020-01-03 10:50:02

local ItemSetupOptionUpdate = fgui.extension_class(GComponent)
fgui.register_extension("ui://Setup/itemSetupOptionUpdate", ItemSetupOptionUpdate)

local NetSaveModel = _G.NetSaveModel

function ItemSetupOptionUpdate:ctor()
    self._textName = self:GetChild("textName")
    self._textDescribe = self:GetChild("textDescribe")

    self._sliderMusic = self:GetChild("sliderMusic")
    self._sliderSound = self:GetChild("sliderSound")

    self._btnMusic = self:GetChild("btnMusicOpen")
    self._btnSound = self:GetChild("btnSoundOpen")
    self._btnGoTo = self:GetChild("btnGo")
    self._btnClear = self:GetChild("btnRed")
    self._btnOpen = self:GetChild("n51")

    self._ctrView = self:GetController("c1")
    self._musicCtrView = self:GetController("music")
    self._soundCtrView = self:GetController("sound")

    self:InitEvent()
end

function ItemSetupOptionUpdate:InitEvent()
    self:AddListener(self._btnMusic.onClick,function()
        if self._btnMusic.selected then
            self._musicCtrView.selectedIndex = 1
        else
            self._musicCtrView.selectedIndex = 0
        end
        self.data.musicSelected = self._btnMusic.selected
        AudioManager.MusicMute = self.data.musicSelected
        PlayerDataModel:SetData("SyetemSet"..self._info.id, self.data)
        Util.SetPlayerData("LoginAudioRecord", JSON.encode(self.data))
    end)

    self:AddListener(self._btnSound.onClick,function()
        if self._btnSound.selected then
            self._soundCtrView.selectedIndex = 1
        else
            self._soundCtrView.selectedIndex = 0
        end
        self.data.soundSelected = self._btnSound.selected
        AudioManager.ClipMute = self.data.soundSelected
        PlayerDataModel:SetData("SyetemSet"..self._info.id, self.data)
        Util.SetPlayerData("LoginAudioRecord", JSON.encode(self.data))
    end)

    self:AddListener(self._sliderMusic.onChanged,function()
        self.data.musicVolume = self._sliderMusic.value
        AudioManager.MusicVolume = self._sliderMusic.value/100
        if self.data.musicVolume <= 0 then
            self.data.musicSelected = true
            self._btnMusic.selected = true
            self._musicCtrView.selectedIndex = 1
        else
            self.data.musicSelected = false
            self._btnMusic.selected = false
            self._musicCtrView.selectedIndex = 0
        end
        AudioManager.MusicMute = self.data.musicSelected
        PlayerDataModel:SetData("SyetemSet"..self._info.id, self.data)
        Util.SetPlayerData("LoginAudioRecord", JSON.encode(self.data))
    end)

    self:AddListener(self._sliderSound.onChanged,function()
        self.data.soundVolume = self._sliderSound.value
        AudioManager.SoundVolume = self._sliderSound.value/100
        if self.data.soundVolume <= 0 then
            self.data.soundSelected = true
            self._btnSound.selected = true
            self._soundCtrView.selectedIndex = 1
        else
            self.data.soundSelected = false
            self._btnSound.selected = false
            self._soundCtrView.selectedIndex = 0
        end
        AudioManager.ClipMute = self.data.soundSelected
        PlayerDataModel:SetData("SyetemSet"..self._info.id, self.data)
        Util.SetPlayerData("LoginAudioRecord", JSON.encode(self.data))
    end)

    self:AddListener(self._btnOpen.onClick,function()
        if self._btnOpen.selected then

        else
            
        end
        if self._info.id == 30009 then
            local callback = function (rsp)
            end
            if self._btnOpen.selected then
                NetSaveModel.SetValue(NetSaveModel.key.EquipShow,0,callback)
            else
                NetSaveModel.SetValue(NetSaveModel.key.EquipShow,1,callback)
            end
        end
        self.data.btnSelected = self._btnOpen.selected
        PlayerDataModel:SetData("SyetemSet"..self._info.id, self.data)
        SystemSetModel.RefreshSystemSetting(self._info.id)
    end)

    self:AddListener(self._btnGoTo.onClick,function()
        SystemSetModel.GoTo(self._info.id)
    end)

    self:AddListener(self._btnClear.onClick,function()
        SystemSetModel.Clear(self._info.id)
        self._panel:RefreshListView()
    end)
end

function ItemSetupOptionUpdate:SetData(info, panel)
    self._info = info
    self._panel = panel
    self.data = PlayerDataModel:GetData("SyetemSet"..info.id)
    if info.type == SET_TYPE.SoundVolume then
        self._ctrView.selectedIndex = 0
        if not self.data then
            self.data = {
                soundVolume = 100,
                musicVolume = 100,
                soundSelected = (info.reset > 0 and {false} or {true})[1],
                musicSelected = (info.reset > 0 and {false} or {true})[1],
            }
            PlayerDataModel:SetData("SyetemSet"..info.id, self.data)
        end
        self._btnSound.selected = self.data.soundSelected
        self._btnMusic.selected = self.data.musicSelected
        self._sliderSound.value = self.data.soundVolume
        self._sliderMusic.value = self.data.musicVolume

        if self.data.musicSelected then
            self._musicCtrView.selectedIndex = 1
        else
            self._musicCtrView.selectedIndex = 0
        end
        if self.data.soundSelected then
            self._soundCtrView.selectedIndex = 1
        else
            self._soundCtrView.selectedIndex = 0
        end

    elseif info.type == SET_TYPE.GoTo then
        self._ctrView.selectedIndex = 1
    elseif info.type == SET_TYPE.Open then
        self._ctrView.selectedIndex = 3
        if not self.data then
            self.data = {
                btnSelected = (info.reset > 0 and {false} or {true})[1],
            }
            PlayerDataModel:SetData("SyetemSet"..info.id, self.data)
        end
        if info.id == 30001 then
            self._btnOpen.enabled = false
        elseif self._info.id == 30009 then
            self._btnOpen.selected = NetSaveModel.GetValue(NetSaveModel.key.EquipShow) ~= 1
        else
            self._btnOpen.selected = self.data.btnSelected
        end
    elseif info.type == SET_TYPE.Clear then
        self._ctrView.selectedIndex = 2
    end

    self._textName.text = StringUtil.GetI18n("configI18nSettings", info.title)
    self._textDescribe.text = StringUtil.GetI18n("configI18nSettings", info.desc)
end

function ItemSetupOptionUpdate:GetData()
    return self.info
end

return ItemSetupOptionUpdate