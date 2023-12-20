# see https://codereview.stackexchange.com/questions/174019
set_PS1()
{
    local RESET=$(tput sgr0 )
    local BOLD=$(tput bold )
    local RED=$(tput setaf 1 )
    local GREEN=$(tput setaf 2 )
    local YELLOW=$(tput setaf 3 )
    local BLUE=$(tput setaf 4 )
    local MAGENTA=$(tput setaf 5 )
    local MAGENTABG=$(tput setab 5 )
    local CYAN=$(tput setaf 6 )
    local WHOAMI='\u'
    local WHERE='\w'
    local HOSTNAME='\h'
    local DATE='\D{%Y-%m-%d %H:%M:%S}'
    local EXECUTE=$
    local LAST_RET={?#0}
    local NIX=$( if [[ -n "$IN_NIX_SHELL" ]];
                 then echo "nix-shell";
                 else echo ""; fi )
    local LINE_1a="$YELLOW$DATE $GREEN$WHOAMI$MAGENTA@$CYAN$HOSTNAME"
    local LINE_1b="$BLUE$BOLD$WHERE$RESET"
    local LINE_2="\\[$MAGENTA\\]$EXECUTE$LAST_RET\\[$RESET\\]$NIX"'\$ '
    PS1="$LINE_1a $LINE_1b\n$LINE_2"
}

set_PS1
