# GRC colorizes nifty unix tools all over the place
if (( $+commands[grc] )) && (( $+commands[brew] ))
then
    GRC="$(which grc)"
    if [ "$TERM" != dumb ] && [ -n "$GRC" ]; then
        alias colourify="$GRC -es --colour=auto"
        alias diff='colourify diff'
        alias docker='colourify docker'
        alias docker-machine='colourify docker-machine'
        alias du='colourify du'
        alias env='colourify env'
        alias make='colourify make'
        alias gcc='colourify gcc'
        alias g++='colourify g++'
        alias netstat='colourify netstat'
        alias ping='colourify ping'
        alias traceroute='colourify traceroute'
        alias traceroute6='colourify traceroute6'
        alias head='colourify head'
        alias tail='colourify tail'
        alias dig='colourify dig'
        alias mount='colourify mount'
        alias ps='colourify ps'
        alias ifconfig='colourify ifconfig'
    fi
fi
