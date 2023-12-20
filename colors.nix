{
# Terminal colors, RGB Hex values, picked with OKHSL.
  # We want to max diffs in *perceptual* color,
  # subject to constant perceptual luminosity
  # so that all colors (e.g. blue) are readable on dark screens.
  # Other benefits: all text usually readable under transparency
  # We want gentle on the eyes, especially in dark environments.
  # https://bottosson.github.io/misc/colorpicker
  black = "000000"; #"161616" # saturation to 0, luminousity to 0
  # L40 for OKHSL
  red = "b10b00"; # H30  # usually too dark
  green = "007232"; # H150 # color space is large on usual color pickers
  yellow = "745b00"; # H90 # usually far too bright
  blue = "3123ff"; # H270 # usually far too dark
  magenta = "9b0097"; # H330 # usually too bright
  cyan = "006a78"; # H210 # usually too bright
  # luminosity 50, saturation 0, semantically and actually gray
  white = "777777";
  # Semantically dark gray, basically: S0 L30
  brightblack = "464646";
      # bump luminosity to 60 where chroma maxes
  brightred = "ff3d2b";
  brightgreen = "00ae50";
  brightyellow = "b18c00";
  brightblue = "6786ff";
  brightmagenta = "eb00e4";
  brightcyan = "00a3b7";
  # luminosity 70
  brightwhite = "ababab";
}
