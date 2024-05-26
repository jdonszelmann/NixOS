{ ... }: {
  dconf = {
    enable = true;

    settings = {
      "org/gnome/shell" = {
        # pinned app bar
        favorite-apps = [
          "firefox.desktop"
          "org.gnome.Nautilus.desktop"
          "org.gnome.Settings.desktop"
          "org.gnome.Terminal.desktop"
          "jetbrains-clion-ec2b1366-55e3-4ecc-8780-ab6c7542eb56.desktop"
          "discord-canary.desktop"
          "io.element.Element.desktop"
          "mattermost-desktop.desktop"
          "org.mozilla.Thunderbird.desktop"
          "spotify.desktop"
        ];
        disable-user-extensions = false;
        enabled-extensions = [
          "horizontal-workspaces@gnome-shell-extensions.gcampax.github.com"
          "org.gnome-shell.desktop-icons"
          "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        ];
      };

      "org/gnome/desktop/background" = rec {
        # picture-uri ="file:///${home.homeDirectory}/Pictures/backgrounds/2023-09-01-14-56-45-Road-saturated.png";
        # picture-uri-dark = picture-uri;
      };

      "org/gnome/desktop/input-sources" = {
        per-window = false;
        show-all-sources = false;
        sources = [ "('xkb', 'us')" ];
        xkb-options =
          [ "lv3:switch" "caps:escape" "eurosign:4" "compose:ralt" ];
      };

      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        cursor-theme = "Adwaita";
        enable-animations = true;
        enable-hot-corners = true;
        font-name = "Noto Sans,  10";
      };

      "org/gnome/desktop/peripherals/mouse" = {
        accel-profile = "adaptive";
        natural-scroll = false;
      };

      "org/gnome/desktop/peripherals/touchpad" = {
        click-method = "fingers";
        disable-while-typing = false;
        edge-scrolling-enabled = false;
        natural-scroll = false;
        send-events = "enabled";
        speed = 0.536764705882353;
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/desktop/sound" = {
        allow-volume-above-100-percent = true;
        event-sounds = true;
      };

      "org/gnome/desktop/wm/keybindings" = {
        begin-move = [ "@as []" ];
        begin-resize = [ "@as []" ];
        close = [ "<Super>q" ];
        lower = [ "@as []" ];
        maximize = [ "@as []" ];
        minimize = [ "<Super>w" ];
        move-to-monitor-down = [ "<Super>Down" ];
        move-to-monitor-left = [ "<Super>Left" ];
        move-to-monitor-right = [ "<Super>Right" ];
        move-to-monitor-up = [ "<Super>Up" ];
        move-to-workspace-1 = [ "<Shift><Super>exclam" ];
        move-to-workspace-2 = [ "<Shift><Super>at" ];
        move-to-workspace-3 = [ "<Shift><Super>numbersign" ];
        move-to-workspace-4 = [ "<Shift><Super>dollar" ];
        move-to-workspace-5 = [ "<Shift><Super>percent" ];
        move-to-workspace-6 = [ "<Shift><Super>asciicircum" ];
        move-to-workspace-down = [ "<Shift><Super>k" ];
        move-to-workspace-last = [ "<Shift><Super>parenright" ];
        move-to-workspace-up = [ "<Shift><Super>j" ];
        panel-main-menu = [ "" ];
        raise-or-lower = [ "<Super>s" ];
        switch-applications = [ "<Super>Tab" ];
        switch-applications-backward = [ "<Shift><Super>Tab" ];
        switch-input-source = [ "@as []" ];
        switch-input-source-backward = [ "@as []" ];
        switch-to-workspace-1 = [ "<Super>1" ];
        switch-to-workspace-2 = [ "<Super>2" ];
        switch-to-workspace-3 = [ "<Super>3" ];
        switch-to-workspace-4 = [ "<Super>4" ];
        switch-to-workspace-5 = [ "<Super>5" ];
        switch-to-workspace-6 = [ "<Super>6" ];
        switch-to-workspace-down = [ "<Super>j" ];
        switch-to-workspace-last = [ "<Super>0" ];
        switch-to-workspace-up = [ "<Super>k" ];
        switch-windows = [ "@as []" ];
        switch-windows-backward = [ "@as []" ];
        toggle-fullscreen = [ "<Super>f" ];
        toggle-maximized = [ "<Super>d" ];
        unmaximize = [ "@as []" ];
      };

      "org/gnome/desktop/wm/preferences" = {
        auto-raise = false;
        button-layout = ":,maximize,minimize,close";
        focus-mode = "click";
        mouse-button-modifier = "<Super>";
        num-workspaces = 6;
        resize-with-right-button = false;
        visual-bell = false;
      };

      "org/gnome/mutter" = {
        center-new-windows = true;
        dynamic-workspaces = false;
        edge-tiling = true;
        experimental-features = [ "scale-monitor-framebuffer" ];
        overlay-key = "Super_L";
        workspaces-only-on-primary = true;
      };

      "org/gnome/mutter/keybindings" = {
        switch-monitor = [ "<Super>o" ];
        toggle-tiled-left = [ "<Super>bracketleft" ];
        toggle-tiled-right = [ "<Super>bracketright" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys" = {
        area-screenshot = [ "@as []" ];
        area-screenshot-clip = [ "<Shift><Super>s" ];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        ];
        email = [ "Display" ];
        home = [ "<Super>e" ];
        mic-mute = [ "AudioMicMute" ];
        next = [ "<Super>period" ];
        on-screen-keyboard = [ "@as []" ];
        pause = [ "@as []" ];
        play = [ "<Super>slash" ];
        previous = [ "<Super>comma" ];
        screensaver = [ "<Super>l" ];
        screenshot = [ "@as []" ];
        screenshot-clip = [ "@as []" ];
        stop = [ "@as []" ];
        volume-down = [ "AudioLowerVolume" ];
        volume-mute = [ "AudioMute" ];
        volume-up = [ "AudioRaiseVolume" ];
        window-screenshot = [ "@as []" ];
        window-screenshot-clip = [ "@as []" ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" =
        {
          binding = "<Shift><Super>Return";
          command = "gnome-terminal";
          name = "Launch terminal";
        };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" =
        {
          command = ''
            dbus-send - -session - -type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:" Main.overview.show(); "'';
          name = "Show Overview";
        };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" =
        {
          binding = "<Super>z";
          command = "gnome-system-monitor";
          name = "launch system monitor";
        };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" =
        {
          binding = "<Super>Return";
          command = "gnome-terminal";
          name = "focus-terminal";
        };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" =
        {
          binding = "F12";
          command = ((import ../cli-programs/scripts.nix) pkgs).calc;
          name = "calculator";
        };

      "org/gnome/settings-daemon/plugins/power" = {
        ambient-enabled = false;
        idle-dim = false;
        power-button-action = "nothing";
        power-saver-profile-on-low-battery = true;
        sleep-inactive-ac-timeout = 7200;
        sleep-inactive-ac-type = "nothing";
        sleep-inactive-battery-timeout = 7200;
        sleep-inactive-battery-type = "suspend";
      };
      "org/gnome/shell/extensions/auto-move-windows" = {
        application-list = [
          "firefox.desktop:1"
          "discord.desktop:3"
          "jetbrains-clion.desktop:2"
          "jetbrains-goland.desktop:2"
          "jetbrains-pycharm.desktop:2"
          "jetbrains-idea.desktop:2"
          "spotify.desktop:5"
        ];
      };

      "org/gnome/shell/keybindings" = {
        open-application-menu = [ "Menu" ];
        show-screenshot-ui = [ "<Shift><Super>s" ];
        switch-to-application-1 = [ "@as []" ];
        switch-to-application-2 = [ "@as []" ];
        switch-to-application-3 = [ "@as []" ];
        switch-to-application-4 = [ "@as []" ];
        switch-to-application-5 = [ "@as []" ];
        switch-to-application-6 = [ "@as []" ];
        switch-to-application-7 = [ "@as []" ];
        switch-to-application-8 = [ "@as []" ];
        switch-to-application-9 = [ "@as []" ];
        toggle-message-tray = [ "@as []" ];
        toggle-overview = [ "<Super>p" ];
      };

      "org/gnome/terminal/legacy" = {
        menu-accelerator-enabled = false;
        mnemonics-enabled = true;
        new-terminal-mode = "window";
        shortcuts-enabled = true;
        theme-variant = "dark";
      };

      "org/gnome/terminal/legacy/keybindings" = { zoom-in = "<Primary>equal"; };
    };
  };
}

