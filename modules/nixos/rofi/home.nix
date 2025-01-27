{ pkgs, lib, config, inputs, home, bconfig, ... }: {
  home.packages = with pkgs; [ rofi ];
  home.file.".config/rofi/config.rasi".text = ''
      configuration {
        modi: "drun";
        display-drun:  "Run";
        sidebar-mode: false;
    }

    @theme "/dev/null"

    * {
        bg:	#${config.colorScheme.palette.base00};
        fg: #${config.colorScheme.palette.base01} ;
        button: #${config.colorScheme.palette.base04};

        background-color: @bg;
        text-color: @fg;
    }

    window {
        transparency: "real";
        border-radius: 7px;
        width: 50%;
        padding: 5px;
        border: 1px;
        border-color: #${config.colorScheme.palette.base04};
    }

    prompt {
        enabled: true;
        horizontal-align: 0.5;
        vertical-align: 0.5;
        background-color: @button;
        border: 2px;
        border-color: @bg;
        border-radius: 7px;
        font: "$font 10";
        padding: 0 1% 0;
    }

    entry {
        placeholder: "search";
        expand: true;
        padding: 2%;
        background-color: @button;
        placeholder-color: @fg;
        border: 2px;
        border-color: @bg;
        border-radius: 7px;
        cursor: text;
    }

    inputbar {
        children: [ prompt, entry ];
        expand: false;
        spacing: 1%;
    }

    listview {
        columns: 1;
        lines: 12;
        cycle: false;
        dynamic: true;
        layout: vertical;
    }

    mainbox {
        children: [ inputbar, listview ];
        spacing: 1%;
        padding: 1% 1% 1% 1%;
    }

    element {
        orientation: vertical;
        border-radius: 7px;
        padding: 1% 1%;
    }

    element-text {
        expand: true;
        vertical-align: 0.5;
        background-color: inherit;
        text-color: inherit;
    }

    element selected {
        background-color: @button;
        text-color: @fg;
        border-radius: 7px;
    }

    listview, element, element selected, element-icon, element-text {
        cursor:				pointer;
    }
  '';
}
