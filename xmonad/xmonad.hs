import XMonad
import XMonad.Util.EZConfig (additionalKeys)
import XMonad.Layout.NoBorders

main = xmonad $ def
    { modMask = mod4Mask -- Use the Windows key as the mod key
    , layoutHook = noBorders Full
    }
    `additionalKeys`
    [ ((mod4Mask, xK_i), spawn "xcalib -invert -alter")
    ]
