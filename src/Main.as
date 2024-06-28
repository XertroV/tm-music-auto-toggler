const string PluginName = Meta::ExecutingPlugin().Name;
const string MenuIconColor = "\\$f5d";
const string PluginIcon = Icons::Cogs;
const string MenuTitle = MenuIconColor + PluginIcon + "\\$z " + PluginName;

uint g_MapMwIdValue = 0;

void Main() {
    auto app = GetApp();
    while (true) {
        yield(3);
        if (app.RootMap is null) {
            if (g_MapMwIdValue != 0) {
                SetVolumeToNoCustomMusic();
                g_MapMwIdValue = 0;
            }
        } else {
            if (g_MapMwIdValue != app.RootMap.Id.Value) {
                if (app.RootMap.CustomMusicPackDesc !is null && app.RootMap.CustomMusic is null) continue;
                g_MapMwIdValue = app.RootMap.Id.Value;
                SetVolumeBasedOnMapMusic(app.RootMap);
            }
        }
    }
}

void SetVolumeBasedOnMapMusic(CGameCtnChallenge@ map) {
    if (map is null || map.CustomMusicPackDesc is null) {
        SetVolumeToNoCustomMusic();
        return;
    } else {
        SetVolumeToCustomMusic();
    }
}

[Setting hidden]
bool S_Enabled = true;

[Setting hidden]
float S_MusicVolWithCustomMusic = -0;

[Setting hidden]
float S_MusicVolWithoutCustomMusic = -40;

[SettingsTab name="Music Volume"]
void R_S_MusicVolume() {
    S_Enabled = UI::Checkbox("Enabled Auto-setting music volume when a map has custom music", S_Enabled);
    UI::AlignTextToFramePadding();
    UI::TextWrapped("\\$iNote: custom music (for whatever reason) typically plays at a lower volume than normal in-game music, so you might like to set the volume a bit higher than you would normally.");
    UI::PushItemWidth(UI::GetWindowContentRegionWidth() * 0.4f);
    auto newWithCustMusic = UI::SliderFloat("Music Volume - Map with Custom Music", S_MusicVolWithCustomMusic, -40, 0, "%.1f");
    auto newWithoutCustMusic = UI::SliderFloat("Music Volume - not in Map or No Custom Music", S_MusicVolWithoutCustomMusic, -40, 0, "%.1f");
    UI::PopItemWidth();

    if (newWithCustMusic != S_MusicVolWithCustomMusic || newWithoutCustMusic != S_MusicVolWithoutCustomMusic) {
        // will update
        g_MapMwIdValue = 0;
    }

    S_MusicVolWithCustomMusic = newWithCustMusic;
    S_MusicVolWithoutCustomMusic = newWithoutCustMusic;
}

void SetVolumeToCustomMusic() {
    if (!S_Enabled) return;
    auto app = GetApp();
    app.AudioPort.MusicVolume = S_MusicVolWithCustomMusic;
}

void SetVolumeToNoCustomMusic() {
    if (!S_Enabled) return;
    auto app = GetApp();
    app.AudioPort.MusicVolume = S_MusicVolWithoutCustomMusic;
}
