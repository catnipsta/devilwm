/* devilwm - minimalist window manager for X11
 * Copyright (C) 1999-2022 Ciaran Anscomb <evilwm@6809.org.uk>
 * Copyright (C) 2026 Nikolai Klover <nick8klover@outlook.com>
 * see README for license and other details. */

// This file is not generated, it is used to sanity check compile options.

// INFOBANNER_MOVERESIZE depends on INFOBANNER

#if defined(INFOBANNER_MOVERESIZE) && !defined(INFOBANNER)
# define INFOBANNER
#endif

