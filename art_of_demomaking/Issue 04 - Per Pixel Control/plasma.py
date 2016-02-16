#!/usr/bin/env python
# 8-bit Plasma Effect in Python, version 1.4
# C++ code version and data by Alex Champandard.
# Ported to python by Sean McKean <smckean at yvn dot com>
#
# This distribution is placed in the public domain.
# Original plasma.cpp comment:
#
# /*
#  *                          The Art Of
#  *                      D E M O M A K I N G
#  *
#  *
#  *                     by Alex J. Champandard
#  *                          Base Sixteen
#  *
#  *
#  *                  Modified by Paulo Pinto (Moondevil)
#  *                         for using with SDL
#  *
#  *
#  *                http://www.flipcode.com/demomaking
#  *
#  *                This file is in the public domain.
#  *                      Use at your own risk.
#  *
#  *
#  *  Compile with DJGPP:    gcc *.cpp -s -O2 -o plasma.exe -lstdcxx
#  *
#  */
#
# This file is clearly a python source script, so you can ignore the
# compile instructions above (heh).

import sys
import os
from math import sin, cos, pi, hypot
from random import randint
import pygame

# Globals -- feel free to adjust these to your preference
ScreenSize = ScreenWidth, ScreenHeight = 320, 240
ScreenFlags = 0
SkipLogo = False
# Keep FpsTarget at 0 to run the program at full speed.
FpsTarget = 0

UsageString = """\
Usage: python %s [-size WIDTHxHEIGHT] [-fullscreen] [-nologo]
Displays a visually appealing plasma effect.

-size specifies a new screen resolution.
-fullscreen sets the program to run at fullscreen.
-nologo causes the program to not display the logo when run.
""" % (sys.argv[0], )

class PlasmaEffect:
    """Handles the initialization code and main loop that draws the
    plasma effect to the screen.
    """

    def __init__(self, size, flags):
        self.palette = [[0] * 3 for x in range(256)]
        pygame.init()
        pygame.display.set_caption('8-bit Plasma Effect')
        pygame.mouse.set_visible(False)
        self.screen = pygame.display.set_mode(size, flags, 8)
        self.clock = pygame.time.Clock()
        self.time = pygame.time.get_ticks()
        sf_size = (size[0] * 2, size[1] * 2)
        sh_pathname = self.AddPathToFile('sin_hyp.raw')
        sc_pathname = self.AddPathToFile('sin_cos.raw')
        if ( not os.path.exists(sh_pathname) or
             not os.path.exists(sc_pathname) or
             os.path.getsize(sh_pathname) != sf_size[0] * sf_size[1] or
             os.path.getsize(sc_pathname) != sf_size[0] * sf_size[1] ):
            self.CreateRawFiles((sh_pathname, sc_pathname), sf_size)
        arg_list = [(sh_pathname, sf_size), (sc_pathname, sf_size)]
        if not SkipLogo == True:
            arg_list.append((self.AddPathToFile('image.raw'), None))
        self.CreateSurfaces(arg_list)
        self.BlitPlasmaSurfacesToScreen()
        self.UpdatePalette()

    def AddPathToFile(self, fname):
        """Adjusts the filename to be relative to the current working
        directory.
        """
        return os.path.join(os.path.dirname(sys.argv[0]), fname)

    def CreateRawFiles(self, fnames, size):
        """Creates a couple of 2-dimensional functions as string data
        and saves them in specified .raw files.
        """
        w, h = size
        data_sh = ''
        data_sc = ''
        for y in range(h):
            # In case the user wants to exit the program before the
            # computations are done...
            if pygame.event.peek((pygame.QUIT, pygame.KEYDOWN)):
                sys.exit()
            for x in range(w):
                hyp = hypot(h / 2 - y, w / 2 - x)
                # These functions are copied for the most part identical
                # to the functions from the original C++ source.
                data_sh += chr(int(64 + 63 * sin(hyp / 16.0)))
                data_sc += chr( int( 63 * sin(x / (37 + 15 * cos(y / 74.0))) *
                                cos(y / (31 + 11 * sin(x / 57.0))) + 64 ) )
        sin_hyp_file = file(fnames[0], 'wb')
        sin_hyp_file.write(data_sh)
        sin_hyp_file.close()
        sin_cos_file = file(fnames[1], 'wb')
        sin_cos_file.write(data_sc)
        sin_cos_file.close()

    def CreateSurfaces(self, arg_list):
        """Handles general surface creation for the program.
        Surfaces are rendered from information found in .raw files,
        which contain a pixel of information for each byte.
        """
        self.plasma_sfs = []
        self.plasma_locs = []
        for fname, size in arg_list:
            self.CreateASurface(fname, size)
        self.sin_hyp_x, self.sin_hyp_y = self.plasma_locs[0]
        self.sin_cos_x, self.sin_cos_y = self.plasma_locs[1]

    def CreateASurface(self, fname, size=None):
        "Generates a surface from the given .raw file"
        raw_file = file(fname, 'rb')
        text = raw_file.read()
        raw_file.close()
        if size is None:
            data_start = text.find(')') + 1
            w, h = eval(text[: data_start])
            byte_list = map(ord, text[data_start: ])
        else:
            w, h = size
            byte_list = map(ord, text)
        self.plasma_sfs.append(pygame.Surface((w, h)).convert())
        self.plasma_sfs[-1].fill(0)
        self.plasma_locs.append((w / 4, h / 4))
        for y in range(h):
            # In case the user wants to exit the program before loading
            # is done...
            if pygame.event.peek((pygame.QUIT, pygame.KEYDOWN)):
                sys.exit()
            for x in range(w):
                self.plasma_sfs[-1].set_at((x, y), byte_list[x + y * w])

    def BlitPlasmaSurfacesToScreen(self):
        """Blits the various surfaces to the screen, with position
        depending on the time elapsed.
        """
        t = self.time >> 3
        x1 = self.sin_hyp_x + (self.sin_hyp_x * cos(t/97.0))
        x2 = self.sin_cos_x + (self.sin_cos_x * sin(-t/114.0))
        x3 = self.sin_cos_x + (self.sin_cos_x * sin(-t/137.0))
        y1 = self.sin_hyp_y + (self.sin_hyp_y * sin(t/123.0))
        y2 = self.sin_cos_y + (self.sin_cos_y * cos(-t/75.0))
        y3 = self.sin_cos_y + (self.sin_cos_y * cos(-t/108.0))
        self.screen.fill(0)
        self.screen.blit(self.plasma_sfs[0], (-x1, -y1))
        self.screen.blit( self.plasma_sfs[1], (-x2, -y2), None,
                          pygame.BLEND_AOF )
        self.screen.blit( self.plasma_sfs[1], (-x3, -y3), None,
                          pygame.BLEND_AOF )
        if not SkipLogo == True:
            text_rtg = self.plasma_sfs[2].get_rect()
            text_rtg.center = ScreenWidth / 2, ScreenHeight / 2
            self.screen.blit( self.plasma_sfs[2], text_rtg, None,
                              pygame.BLEND_AOF )

    def UpdatePalette(self):
        """Creates an interesting circular palette that changes over
        time.
        """
        t = self.time >> 3
        for index, color in enumerate(self.palette):
            color[0] = 128 + int(127 * cos(index * pi / 128 + t / 74.0))
            color[1] = 128 + int(127 * sin(index * pi / 128 + t / 63.0))
            color[2] = 128 + int(127 * cos(index * pi / 128 + t / 81.0))
        # Set the whole palette once each time around.
        pygame.display.set_palette(self.palette)

    def MainLoop(self):
        while True:
            for event in pygame.event.get():
                if event.type in (pygame.QUIT, pygame.KEYDOWN):
                    return
            self.time = pygame.time.get_ticks()
            self.BlitPlasmaSurfacesToScreen()
            self.UpdatePalette()
            # Keeps track of average frames per second, keeping at or
            # below FpsTarget.
            self.clock.tick(FpsTarget)
            pygame.display.flip()

if __name__ == '__main__':
    if len(sys.argv) > 1:
        options = sys.argv[1: ]
        print_usage = False
        skip_next_arg = False
        for index, arg in enumerate(options):
            if skip_next_arg is True:
                skip_next_arg = False
                continue
            elif arg == '-size':
                if len(sys.argv) > index + 1:
                    size_string = options[index + 1].lower().replace('x', ',')
                    ScreenSize = eval(size_string)
                    ScreenWidth, ScreenHeight = ScreenSize
                    skip_next_arg = True
            elif arg == '-fullscreen':
                ScreenFlags = pygame.FULLSCREEN
            elif arg == '-nologo':
                SkipLogo = True
            else:
                print_usage = True
        if print_usage is True:
            print UsageString
            sys.exit()
    main = PlasmaEffect(ScreenSize, ScreenFlags)
    main.MainLoop()

    # Print out exit info and statistics.
    print "                             The Art Of"
    print "                         D E M O M A K I N G "
    print
    print "                       by Alex J. Champandard"
    print
    print "                     Python version by Sean McKean"
    print
    print "Go to http://www.flipcode.com/archives/The_Art_of_Demomaking-Issue_04_Per_Pixel_Control.shtml for more information."
    print
    print "Average frames per second: %.2f" % (main.clock.get_fps(), )
