from libqtile import bar, layout, qtile, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
from libqtile.utils import guess_terminal
import subprocess, os

# ── Mod key & terminal ────────────────────────────────────────────────────────
mod = "mod4"
terminal = guess_terminal()

# ── Color palette (Tokyo Night-inspired) ─────────────────────────────────────
colors = {
    "bg":         "#1a1b26",   # bar background
    "bg_alt":     "#24283b",   # slightly lighter bg (separators, inactive)
    "fg":         "#c0caf5",   # default foreground text
    "fg_dim":     "#565f89",   # dimmed text (inactive groups)
    "accent":     "#7aa2f7",   # blue accent (active group, current layout)
    "green":      "#9ece6a",   # network / good state
    "yellow":     "#e0af68",   # CPU / warnings
    "red":        "#f7768e",   # high usage / urgent
    "magenta":    "#bb9af7",   # RAM
    "cyan":       "#7dcfff",   # clock
    "border_focus":   "#7aa2f7",
    "border_normal":  "#24283b",
}

# ── Workspace groups ──────────────────────────────────────────────────────────
# groups = [Group(i) for i in "123456789"]
groups = [Group(i) for i in "123456789zxcvyuiop"]

# ── Key bindings ──────────────────────────────────────────────────────────────
keys = [
    # Window focus (vim-style)
    Key([mod], "h", lazy.layout.left(),  desc="Focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "j", lazy.layout.down(),  desc="Focus down"),
    Key([mod], "k", lazy.layout.up(),    desc="Focus up"),
    Key([mod], "space", lazy.layout.next(), desc="Focus next window"),

    # Move windows
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(),  desc="Move left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(),  desc="Move down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(),    desc="Move up"),

    # Resize windows
    Key([mod, "control"], "h", lazy.layout.grow_left(),  desc="Grow left"),
    Key([mod, "control"], "l", lazy.layout.grow_right(), desc="Grow right"),
    Key([mod, "control"], "j", lazy.layout.grow_down(),  desc="Grow down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(),    desc="Grow up"),
    Key([mod], "n", lazy.layout.normalize(), desc="Reset sizes"),

    # Layout / window management
    Key([mod, "shift"], "Return", lazy.layout.toggle_split(), desc="Toggle split"),
    Key([mod], "Return", lazy.spawn(terminal),               desc="Terminal"),
    Key([mod], "Tab",   lazy.next_layout(),                  desc="Next layout"),
    Key([mod], "q",     lazy.window.kill(),                  desc="Kill window"),
    Key([mod], "t",     lazy.window.toggle_floating(),       desc="Toggle float"),
    Key([mod], "m",     lazy.window.toggle_fullscreen(),     desc="Fullscreen"),

    # Qtile control
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload config"),
    Key([mod, "control"], "q", lazy.shutdown(),      desc="Quit Qtile"),

    # App launchers
    Key([mod], "b", lazy.spawn("firefox"),           desc="Browser"),
    Key([mod], "e", lazy.spawn("pcmanfm"),           desc="File manager"),
    Key([mod], "d", lazy.spawn("rofi -show drun"),   desc="App launcher"),
    Key([mod], "r", lazy.spawncmd(),                 desc="Run prompt"),

    # Volume — scroll on the bar widget also works
    Key([], "F10", lazy.spawn("pamixer -d 5"),  desc="Vol -5"),
    Key([], "F11", lazy.spawn("pamixer -i 5"),  desc="Vol +5"),
    Key([], "F12", lazy.spawn("pamixer -t"),    desc="Vol mute"),

    # Screenshot utility
    Key([], "Print", lazy.spawn("flameshot gui")),
]

@hook.subscribe.startup_once
def autostart():
    subprocess.run([
        "xrandr",
        "--output", "DP-0",    "--primary", "--mode", "1920x1080", "--pos", "1920x1080", "--rotate", "normal",
        "--output", "DP-1",    "--off",
        "--output", "HDMI-0",  "--mode", "1920x1080", "--pos", "1920x0",    "--rotate", "normal",
        "--output", "DP-2",    "--mode", "1920x1080", "--pos", "0x1080",    "--rotate", "normal",
        "--output", "DP-3",    "--off",
        "--output", "DP-4",    "--mode", "1920x1080", "--pos", "3840x1080", "--rotate", "normal",
        "--output", "DP-5",    "--off",
        "--output", "USB-C-0", "--off",
    ])


# Wayland VT switching
for vt in range(1, 8):
    keys.append(
        Key(
            ["control", "mod1"],
            f"f{vt}",
            lazy.core.change_vt(vt).when(func=lambda: qtile.core.name == "wayland"),
            desc=f"Switch to VT{vt}",
        )
    )

# Group switching
for i in groups:
    keys.extend([
        Key([mod],          i.name, lazy.group[i.name].toscreen(),
            desc=f"Switch to {i.name}"),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name, switch_group=True),
            desc=f"Move window to {i.name}"),
    ])

# ── Layouts ───────────────────────────────────────────────────────────────────
layout_theme = dict(
    border_width=2,
    border_focus=colors["border_focus"],
    border_normal=colors["border_normal"],
    margin=6,           # gaps between windows
)

layouts = [
    layout.Columns(**layout_theme),
    layout.MonadTall(**layout_theme),
    layout.Max(**layout_theme),
    layout.Floating(**layout_theme),
]

# ── Widget helpers ────────────────────────────────────────────────────────────
def sep():
    """Thin separator between widget groups."""
    return widget.Sep(
        linewidth=1,
        padding=10,
        foreground=colors["bg_alt"],
        background=colors["bg"],
    )

def pill_left(fg, bg):
    return widget.TextBox(
        text="",
        fontsize=18,
        padding=0,
        foreground=fg,
        background=bg,
    )

def pill_right(fg, bg):
    return widget.TextBox(
        text="",
        fontsize=18,
        padding=0,
        foreground=fg,
        background=bg,
    )

# ── Bar / Widgets ─────────────────────────────────────────────────────────────
widget_defaults = dict(
    font="JetBrains Mono Nerd Font",
    fontsize=13,
    padding=4,
    background=colors["bg"],
    foreground=colors["fg"],
)
extension_defaults = widget_defaults.copy()

screens = [
    Screen(
        wallpaper="~/Pictures/wallpapers/default.png",
        wallpaper_mode="fill",

        top=bar.Bar(
            [
                # ── Left ──────────────────────────────────────────
                widget.TextBox(
                    text="  ",
                    fontsize=16,
                    foreground=colors["accent"],
                    background=colors["bg"],
                    mouse_callbacks={"Button1": lambda: qtile.spawn("rofi -show drun")},
                ),
                sep(),

                # Workspaces
                widget.GroupBox(
                    font="JetBrains Mono Nerd Font",
                    fontsize=12,
                    margin_y=3,
                    margin_x=4,
                    padding_y=5,
                    padding_x=6,
                    borderwidth=2,
                    active=colors["fg"],
                    inactive=colors["fg_dim"],
                    rounded=True,
                    highlight_method="block",
                    this_current_screen_border=colors["accent"],
                    this_screen_border=colors["bg_alt"],
                    other_current_screen_border=colors["accent"],
                    other_screen_border=colors["bg_alt"],
                    foreground=colors["fg"],
                    background=colors["bg"],
                    urgent_alert_method="block",
                    urgent_border=colors["red"],
                ),
                sep(),

                # Current layout
                widget.CurrentLayout(
                    foreground=colors["accent"],
                    background=colors["bg"],
                ),
                sep(),

                # Task list — shows open windows in current group, clickable
                widget.TaskList(
                    icon_size=16,
                    foreground=colors["fg"],
                    background=colors["bg"],
                    border=colors["accent"],
                    unfocused_border=colors["bg_alt"],
                    urgent_border=colors["red"],
                    markup_focused="<b>{}</b>",
                    markup_unfocused="{}",
                    markup_minimized="<i>{}</i>",
                    txt_floating="󰉨 ",
                    txt_maximized="󰊓 ",
                    txt_minimized="󰖰 ",
                    padding=4,
                    max_title_width=200,
                    title_width_method="uniform",
                    rounded=True,
                ),

                # ── Right ─────────────────────────────────────────
                # Network
                widget.TextBox(
                    text="󰤨 ",
                    foreground=colors["green"],
                    background=colors["bg"],
                ),
                widget.Net(
                    interface="wlp0s20f0u1",   # change to e.g. "eth0" or "wlan0" if needed
                    format="↓{down:.1f}{down_suffix} ↑{up:.1f}{up_suffix}",
                    foreground=colors["green"],
                    background=colors["bg"],
                    update_interval=2,
                ),
                sep(),

                # CPU
                widget.TextBox(
                    text="󰍛 ",
                    foreground=colors["yellow"],
                    background=colors["bg"],
                ),
                widget.CPU(
                    format="{load_percent:.0f}%",
                    foreground=colors["yellow"],
                    background=colors["bg"],
                    update_interval=2,
                    mouse_callbacks={"Button1": lambda: qtile.spawn(terminal + " -e htop")},
                ),
                sep(),

                # RAM
                widget.TextBox(
                    text="󰘚 ",
                    foreground=colors["magenta"],
                    background=colors["bg"],
                ),
                widget.Memory(
                    format="{MemUsed:.0f}{mm}/{MemTotal:.0f}{mm}",
                    measure_mem="G",
                    foreground=colors["magenta"],
                    background=colors["bg"],
                    update_interval=2,
                    mouse_callbacks={"Button1": lambda: qtile.spawn(terminal + " -e htop")},
                ),
                sep(),

                # ── Volume: icon + slider bar + percentage ─────────
                widget.TextBox(
                    text="󰕾 ",
                    foreground=colors["accent"],
                    background=colors["bg"],
                    mouse_callbacks={
                        "Button1": lambda: qtile.spawn("pamixer -t"),
                    },
                ),
                widget.PulseVolume(
                    fmt="{}",
                    foreground=colors["accent"],
                    background=colors["bg"],
                    mouse_callbacks={
                        "Button4": lambda: qtile.spawn("pamixer -i 2"),
                        "Button5": lambda: qtile.spawn("pamixer -d 2"),
                    },
                    # Show a visual bar — Qtile's built-in volume widget supports
                    # bar_colour_high / bar_colour_normal / bar_colour_mute
                    # when using the volume_app and limit_max_volume options.
                    limit_max_volume=True,
                    update_interval=0.2,
                ),
                # Graphical slider using ProgressBar-style via GenPollText
                widget.GenPollText(
                    func=lambda: _vol_bar(),
                    update_interval=0.5,
                    foreground=colors["accent"],
                    background=colors["bg"],
                    font="JetBrains Mono Nerd Font",
                    fontsize=12,
                    mouse_callbacks={
                        "Button4": lambda: qtile.spawn("pamixer -i 2"),
                        "Button5": lambda: qtile.spawn("pamixer -d 2"),
                        "Button1": lambda: qtile.spawn("pamixer -t"),
                    },
                ),
                sep(),

                # Systray
                widget.Systray(
                    background=colors["bg"],
                    icon_size=16,
                    padding=4,
                ),
                sep(),

                # Clock
                widget.TextBox(
                    text="󰸗 ",
                    foreground=colors["cyan"],
                    background=colors["bg"],
                ),
                widget.Clock(
                    format="%a %d %b  %H:%M",
                    foreground=colors["cyan"],
                    background=colors["bg"],
                ),
                widget.TextBox(text=" ", background=colors["bg"]),
            ],
            28,
            opacity=0.95,
            border_width=[0, 0, 2, 0],
            border_color=[colors["bg"], colors["bg"], colors["accent"], colors["bg"]],
            margin=[4, 6, 0, 6],   # gaps around bar (top, right, bottom, left)
        ),
    ),

    Screen(
        wallpaper="~/Pictures/wallpapers/default.png",
        wallpaper_mode="fill",
    ),
    Screen(
        wallpaper="~/Pictures/wallpapers/default.png",
        wallpaper_mode="fill",
    ),
    Screen(
        wallpaper="~/Pictures/wallpapers/default.png",
        wallpaper_mode="fill",
    ),
]



def _vol_bar() -> str:
    """Return a Unicode block-character progress bar for the current volume."""
    try:
        muted = subprocess.check_output(
            ["pamixer", "--get-mute"], text=True
        ).strip() == "true"
        vol = int(subprocess.check_output(
            ["pamixer", "--get-volume"], text=True
        ).strip())
    except Exception:
        return " [??]"

    if muted:
        return " [muted]"

    filled = round(vol / 10)          # 0–10 blocks
    bar = "█" * filled + "░" * (10 - filled)
    return f" [{bar}]"


# ── Mouse bindings ────────────────────────────────────────────────────────────
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(),
         start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(),
         start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# ── Misc settings ─────────────────────────────────────────────────────────────
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
floats_kept_above = True
cursor_warp = False

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),
        Match(wm_class="makebranch"),
        Match(wm_class="maketag"),
        Match(wm_class="ssh-askpass"),
        Match(title="branchdialog"),
        Match(title="pinentry"),
    ],
    border_focus=colors["border_focus"],
    border_normal=colors["border_normal"],
    border_width=2,
)

auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
