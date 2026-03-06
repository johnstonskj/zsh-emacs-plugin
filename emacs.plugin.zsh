# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# @name emacs
# @brief Simple environment setup for using `emacs` as primary editor.
# @repository https://github.com/johnstonskj/zsh-emacs-plugin
#

############################################################################
# @section Public
# @description Useful Cargo functions.
#

emacs_plugin_init() {
    builtin emulate -L zsh

    if [[ "${EMACS_CONF}" != "${HOME}/.emacs.d" ]]; then
        @zplugins_envvar_save emacs EMACS_CONF
        export EMACS_CONF="${HOME}/.emacs.d"
    fi

    @zplugins_envvar_save emacs EDITOR
    if [[ -n "${SSH_CONNECTION}" ]]; then
        export EDITOR=vim
    else
        export EDITOR='emacsclient -nw'
    fi

    if [[ -n "${ALTERNATE_EDITOR}" ]]; then
        @zplugins_envvar_save emacs ALTERNATE_EDITOR
        export ALTERNATE_EDITOR=''
    fi

    if [[ "${VISUAL}" != "emacs" ]]; then
        @zplugins_envvar_save emacs VISUAL
        export VISUAL=emacs
    fi

    @zplugins_define_alias emacs emacs 'emacsclient -nw'
    @zplugins_define_alias emacs gemacs 'emacsclient -c'
}

# @internal
emacs_plugin_unload() {
    builtin emulate -L zsh

    @zplugins_envvar_restore emacs EMACS_CONF
    @zplugins_envvar_restore emacs EDITOR
    @zplugins_envvar_restore emacs ALTERNATE_EDITOR
    @zplugins_envvar_restore emacs VISUAL
}
