# Not using zsh promptinit for now


# TODO: Generate this
export SEAROCKET_VERSION='0.1.0'

___searocket_preCommand (){
    PROMPT=$(searocket preCommand prompt)
    RPROMPT=$(searocket preCommand rprompt)
}

___searocket_preExec (){
    searocket preExec prompt
}

___searocket_onExit (){
    searocket onExit prompt
}


___spacerocket_setup() {
    autoload -Uz add-zsh-hook

    add-zsh-hook precmd ___searocket_preCommand
    add-zsh-hook preexec ___searocket_preExec
    add-zsh-hook zshexit ___searocket_onExit

    VIRTUAL_ENV_DISABLE_PROMPT=true
}

___spacerocket_setup

