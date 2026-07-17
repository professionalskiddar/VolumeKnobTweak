#Requires AutoHotkey v2.0
#NoTrayIcon
#MaxThreadsPerHotkey 2

; Global variables
global volGui, volProgress, volText, volIcon, currentVolume := 50, isMuted := false
global hue := 0, storedVolume := 50

; 1. Build a Custom Slider that mimics the exact Windows 11 Flyout Layout
volGui := Gui("+AlwaysOnTop -Caption +ToolWindow +E0x08000000") ; E0x08000000 stops window focus stealing
volGui.BackColor := "0D1117"  ; Dark background to make neon colors pop
volGui.SetFont("s10 cFFFFFF", "Segoe UI Variable Display") ; Clean native Win11 Font

; Add elements inside the capsule: Speaker Icon, Progress Bar, and Percent Text
volIcon := volGui.Add("Text", "x15 y14 w35 h20", "High")
volProgress := volGui.Add("Progress", "x55 y18 w120 h4 cFFFFFF Background1E2329") ; White on dark background
volText := volGui.Add("Text", "x185 y14 w40 h20 Right", "50%")

; Apply modern Windows 11 rounded corners to the whole window popup
DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", volGui.Hwnd, "UInt", 33, "Int*", 2, "UInt", 4)

; Initialize volume on startup
currentVolume := SoundGetVolume()
storedVolume := currentVolume
UpdateAndShowOSD(currentVolume, false)
volGui.Hide()  ; Hide initially

; Start background color animation
SetTimer(AnimateBackground, 15)  ; Even faster smooth animation updates

$Volume_Up:: {
    global currentVolume, isMuted, storedVolume
    if (isMuted) {
        storedVolume := Min(100, storedVolume + 1)
        currentVolume := storedVolume
    } else {
        currentVolume := Min(100, SoundGetVolume() + 1)
        SoundSetVolume(currentVolume)
        storedVolume := currentVolume
    }
    UpdateAndShowOSD(currentVolume)
}

$Volume_Down:: {
    global currentVolume, isMuted, storedVolume
    if (isMuted) {
        storedVolume := Max(0, storedVolume - 1)
        currentVolume := storedVolume
    } else {
        currentVolume := Max(0, SoundGetVolume() - 1)
        SoundSetVolume(currentVolume)
        storedVolume := currentVolume
        isMuted := (currentVolume == 0)
    }
    UpdateAndShowOSD(currentVolume)
}

$Volume_Mute:: {
    global currentVolume, isMuted, storedVolume
    if (isMuted) {
        if (storedVolume == 0)
            storedVolume := 50  ; Default to 50 if stored volume is 0
        SoundSetVolume(storedVolume)
        currentVolume := storedVolume
        isMuted := false
    } else {
        storedVolume := SoundGetVolume()
        if (storedVolume == 0)
            storedVolume := 50  ; Store 50 if current volume is 0
        SoundSetVolume(0)
        currentVolume := 0
        isMuted := true
    }
    UpdateAndShowOSD(currentVolume)
}

UpdateAndShowOSD(vol, showWindow := true) {
    global volGui, volProgress, volText, volIcon, isMuted, storedVolume
    RoundVol := Round(vol)
    
    ; Dynamic Icon: Changes visual speaker state based on volume level
    if (isMuted)
        volIcon.Value := "Mute"
    else if (RoundVol == 0)
        volIcon.Value := "Mute"
    else if (RoundVol < 33)
        volIcon.Value := "Low"
    else if (RoundVol < 66)
        volIcon.Value := "Med"
    else
        volIcon.Value := "High"
    
    ; Dynamic color based on volume level
    if (isMuted)
        volProgress.Opt("cFF0055 Background1E2329")  ; Neon red for mute
    else
        volProgress.Opt("cFFFFFF Background1E2329")  ; White for normal volume
        
    ; Show stored volume when muted, otherwise show current volume
    displayVolume := isMuted ? storedVolume : RoundVol
    volText.Value := displayVolume . "%"
    volProgress.Value := displayVolume
    
    ; Only show window if requested (skip on startup)
    if (showWindow) {
        ; Positions the pill smoothly right in the bottom center (just above the taskbar)
        volGui.Show("w240 h45 X" . (A_ScreenWidth/2 - 120) . " Y" . (A_ScreenHeight - 110) . " NoActivate")
        
        ; Clear any existing timer and set new one
        try SetTimer(() => volGui.Hide(), -2000)
    }
}

AnimateBackground() {
    global volGui, hue
    
    ; Increment hue for smooth color cycling
    hue := Mod(hue + 2, 360)
    
    ; Create brighter RGB effect - shift hue with higher brightness
    color := HSVToRGB(hue, 0.8, 0.35)  ; Even higher brightness for better visibility
    volGui.BackColor := color
}

HSVToRGB(h, s, v) {
    ; Convert HSV to RGB hex color
    c := v * s
    x := c * (1 - Abs(Mod(h / 60, 2) - 1))
    m := v - c
    
    if (h < 60)
        r := c, g := x, b := 0
    else if (h < 120)
        r := x, g := c, b := 0
    else if (h < 180)
        r := 0, g := c, b := x
    else if (h < 240)
        r := 0, g := x, b := c
    else if (h < 300)
        r := x, g := 0, b := c
    else
        r := c, g := 0, b := x
    
    ; Convert to 0-255 range and hex
    r := Round((r + m) * 255)
    g := Round((g + m) * 255)
    b := Round((b + m) * 255)
    
    return Format("{:02X}{:02X}{:02X}", r, g, b)
}
