#Requires AutoHotkey v2.0
A_MaxHotkeysPerInterval := 500
; VolumeFixerWindows - AutoHotkey script for 1% volume increments
; Uses COM object to control volume with Windows-like UI

volume(offset)
{
    static o := ComObject("{C2F03A33-21F5-47FA-B4BB-156362A2F239}", "{00000000-0000-0000-C000-000000000046}")
       , q := ComObjQuery(o, "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}", "{41f9d2fb-7834-4ab6-8b1b-73e74064b465}")
    DllCall(NumGet(NumGet(q.Ptr + 0, "Ptr") + 3 * A_PtrSize, "Ptr"), "Ptr",q.Ptr, "Int",0, "UInt",0)
}

; Volume Up - Increase by 1%
Volume_Up::
{
    volume(1)
    SoundSetVolume("+1")
}

; Volume Down - Decrease by 1%
Volume_Down::
{
    volume(-1)
    SoundSetVolume("-1")
}

; Volume Mute - Toggle mute
~Volume_Mute::
{
    volume(0)
}
