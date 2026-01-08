# -*- mode: sh; eval: (sh-set-shell "zsh") -*-
#
# Plugin Name: emacs
# Repository: https://github.com/johnstonskj/zsh-emacs-plugin
#
# Description:
#
#   Simple environment setup for using `emacs` as primary editor.
#
# Public variables:
#
# * `EMACS`; plugin-defined global associative array with the following keys:
#   * \`_PLUGIN_DIR\`; the directory the plugin is sourced from.
#   * \`_FUNCTIONS\`; a list of all functions defined by the plugin.
#   * \`_OLD_ALTERNATE_EDITOR\`; the previous value of ALTERNATE_EDITOR.
#   * \`_OLD_EMACS_CONF\`; the previous value of EMACS_CONF.
#

############################################################################
# Standard Setup Behavior
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#zero-handling
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# See https://wiki.zshell.dev/community/zsh_plugin_standard#standard-plugins-hash
declare -gA EMACS
EMACS[_PLUGIN_DIR]="${0:h}"
EMACS[_ALIASES]=""
EMACS[_FUNCTIONS]=""

# Saving the current state for any modified global environment variables.
EMACS[_OLD_ALTERNATE_EDITOR]="${ALTERNATE_EDITOR}"
EMACS[_OLD_EMACS_CONF]="${EMACS_CONF}"

############################################################################
# Internal Support Functions
############################################################################

#
# This function will add to the `EMACS[_FUNCTIONS]` list which is
# used at unload time to `unfunction` plugin-defined functions.
#
# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
# See https://wiki.zshell.dev/community/zsh_plugin_standard#the-proposed-function-name-prefixes
#
.emacs_remember_fn() {
    builtin emulate -L zsh

    local fn_name="${1}"
    if [[ -z "${EMACS[_FUNCTIONS]}" ]]; then
        EMACS[_FUNCTIONS]="${fn_name}"
    elif [[ ",${EMACS[_FUNCTIONS]}," != *",${fn_name},"* ]]; then
        EMACS[_FUNCTIONS]="${EMACS[_FUNCTIONS]},${fn_name}"
    fi
}
.emacs_remember_fn .emacs_remember_fn

.emacs_define_alias() {
    local alias_name="${1}"
    local alias_value="${2}"

    alias ${alias_name}=${alias_value}

    if [[ -z "${EMACS[_ALIASES]}" ]]; then
        EMACS[_ALIASES]="${alias_name}"
    elif [[ ",${EMACS[_ALIASES]}," != *",${alias_name},"* ]]; then
        EMACS[_ALIASES]="${EMACS[_ALIASES]},${alias_name}"
    fi
}
.emacs_remember_fn .emacs_remember_alias

############################################################################
# Plugin Unload Function
############################################################################

# See https://wiki.zshell.dev/community/zsh_plugin_standard#unload-function
emacs_plugin_unload() {
    builtin emulate -L zsh

    # Remove all remembered functions.
    local plugin_fns
    IFS=',' read -r -A plugin_fns <<< "${EMACS[_FUNCTIONS]}"
    local fn
    for fn in ${plugin_fns[@]}; do
        whence -w "${fn}" &> /dev/null && unfunction "${fn}"
    done
    
    # Remove all remembered aliases.
    local aliases
    IFS=',' read -r -A aliases <<< "${EMACS[_ALIASES]}"
    local alias
    for alias in ${aliases[@]}; do
        unalias "${alias}"
    done

    # Reset global environment variables .
    export ALTERNATE_EDITOR="${EMACS[_OLD_ALTERNATE_EDITOR]}"
    export EMACS_CONF="${EMACS[_OLD_EMACS_CONF]}"

    # Remove the global data variable.
    unset EMACS

    # Remove this function.
    unfunction emacs_plugin_unload
}

############################################################################
# Plugin-defined Aliases
############################################################################

export ALTERNATE_EDITOR=
export EMACS_CONF="${HOME}/.emacs.d"

.emacs_define_alias emacs 'emacsclient -nw'
.emacs_define_alias gemacs 'emacsclient -c'

############################################################################
# Initialize Plugin
############################################################################

true
