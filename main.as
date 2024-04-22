[Setting hidden]
bool Setting_UseMotionSicknessFix = false;

float CAM_STIFFNESS_DEFAULT = 5.0f;
float CAM_STIFFNESS_FIX = 8.0f;
uint CAM_STIFFNESS_OFFSET = 92;

CMwNod@ cam2Nod;

void Main() {
    CSystemFidsFolder@ folder = Fids::GetGameFolder("GameData/Vehicles/Cars/CarSport/Camera");
    @cam2Nod = Fids::Preload(folder.Leaves[1]);

    float camStiff = Dev::GetOffsetFloat(cam2Nod, CAM_STIFFNESS_OFFSET);
    if (camStiff != CAM_STIFFNESS_DEFAULT)  {
        throw("sanity check failed, could not get default cam stiffness at offset " + CAM_STIFFNESS_OFFSET);
    }

    Set();
}

void Set() {
    if (Setting_UseMotionSicknessFix) {
        Dev::SetOffset(cam2Nod, CAM_STIFFNESS_OFFSET, CAM_STIFFNESS_FIX);
    } else {
        Dev::SetOffset(cam2Nod, CAM_STIFFNESS_OFFSET, CAM_STIFFNESS_DEFAULT);
    }
}

[SettingsTab name="Apply"]
void RenderSettings() {
    UI::SetNextItemWidth(300);
    if (UI::Checkbox("Use motion sickness fix", Setting_UseMotionSicknessFix)) {
        Setting_UseMotionSicknessFix = true;
    }
    else {
        Setting_UseMotionSicknessFix = false;
    }

    Set();
}