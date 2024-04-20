bool ShowWindow = false;

class Cam2Settings_V1 {
    CMwNod@ cam2Nod;
    string SETTINGS_FILE_NAME = "cam2.settings";

    Cam2Settings_V1() {}

    void Init() {
        CSystemFidsFolder@ folder = Fids::GetGameFolder("GameData/Vehicles/Cars/CarSport/Camera");
        print(folder.FullDirName);
        print(folder.Leaves[1].FileName);
        @cam2Nod = Fids::Preload(folder.Leaves[1]);

        Load();
    }

    void Save() {
        string path = IO::FromStorageFolder(SETTINGS_FILE_NAME);
        IO::File fw(path, IO::FileMode::Write);
        fw.Write(VERSION);
        fw.Write(camStiffness);
        fw.Close();
    }

    void Load() {
        string path = IO::FromStorageFolder(SETTINGS_FILE_NAME);
        if (!IO::FileExists(path)) {
            Save();
        }

        IO::File fr(path, IO::FileMode::Read);
        MemoryBuffer@ mem = fr.Read(fr.Size());
        uint ver = mem.ReadUInt32();
        if (ver != VERSION) throw("expected version to be " + VERSION + ", got: " + ver);

        camStiffness = mem.ReadFloat();
        fr.Close();

        // check sanity
        float camStiff = Dev::GetOffsetFloat(cam2Nod, CAM_STIFFNESS_OFFSET);
        if (camStiff != CAM_STIFFNESS_DEFAULT && camStiff != camStiffness)  {
            throw("sanity check failed, could not get cam stiffness at offset " + CAM_STIFFNESS_OFFSET);
        }

        Set();
    }

    void Set() {
        Dev::SetOffset(cam2Nod, CAM_STIFFNESS_OFFSET, camStiffness);
    }

    void DrawUI() {
        UI::SetNextItemWidth(300);
        if (UI::Checkbox("Use motion sickness fix", camStiffness == CAM_STIFFNESS_FIX)) {
            camStiffness = CAM_STIFFNESS_FIX;
        }
        else {
            camStiffness = CAM_STIFFNESS_DEFAULT;
        }
        Set();

        if (UI::Button("Save Settings")) {
            Save();
        }
    }

    uint VERSION = 1;

    float CAM_STIFFNESS_DEFAULT = 5.0f;
    float CAM_STIFFNESS_FIX = 8.0f;
    uint CAM_STIFFNESS_OFFSET = 92;
    float camStiffness = CAM_STIFFNESS_DEFAULT;
}

Cam2Settings_V1 settings();

void Main() {
    settings.Init();
}

void RenderMenu() {
    if (UI::MenuItem("Cam 2 Motion Sickness Fix")) ShowWindow = !ShowWindow;
}

void Render() {
    if (!ShowWindow) return;
    UI::SetNextWindowSize(600, 400, UI::Cond::Appearing);
    if (UI::Begin("Cam 2 Motion Sickness Fix", ShowWindow, 0)) {
        settings.DrawUI();
    }
    UI::End();
}