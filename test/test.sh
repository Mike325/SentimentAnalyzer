#!/usr/bin/env bash

#
#                              -`
#              ...            .o+`
#           .+++s+   .h`.    `ooo/
#          `+++%++  .h+++   `+oooo:
#          +++o+++ .hhs++. `+oooooo:
#          +s%%so%.hohhoo'  'oooooo+:
#          `+ooohs+h+sh++`/:  ++oooo+:
#           hh+o+hoso+h+`/++++.+++++++:
#            `+h+++h.+ `/++++++++++++++:
#                     `/+++ooooooooooooo/`
#                    ./ooosssso++osssssso+`
#                   .oossssso-````/osssss::`
#                  -osssssso.      :ssss``to.
#                 :osssssss/  Mike  osssl   +
#                /ossssssss/   8a   +sssslb
#              `/ossssso+/:-        -:/+ossss'.-
#             `+sso+:-`                 `.-/+oso:
#            `++:.                           `-/+/
#            .`                                 `/

_VERBOSE=0
_NOCOLOR=0
_NOLOG=0
_WARN_COUNT=0
_ERR_COUNT=0
_IGNORE=0

_NAME="$0"
_NAME="${_NAME##*/}"
_LOG="${_NAME%%.*}.log"

_SCRIPT_PATH="$0"

_SCRIPT_PATH="${_SCRIPT_PATH%/*}"

trap '{ exit_append; fix_path; }' EXIT

if hash realpath 2>/dev/null; then
    _SCRIPT_PATH=$(realpath "$_SCRIPT_PATH")
else
    pushd "$_SCRIPT_PATH" 1> /dev/null || exit 1
    _SCRIPT_PATH="$(pwd -P)"
    popd 1> /dev/null || exit 1
fi

# _DEFAULT_SHELL="${SHELL##*/}"
_CURRENT_SHELL="bash"

if [ -z "$SHELL_PLATFORM" ]; then
    export SHELL_PLATFORM='UNKNOWN'
    if [[ -n $TRAVIS_OS_NAME ]]; then
        export SHELL_PLATFORM="$TRAVIS_OS_NAME"
    else
        case "$OSTYPE" in
            *'linux'*   ) export SHELL_PLATFORM='linux' ;;
            *'darwin'*  ) export SHELL_PLATFORM='osx' ;;
            *'freebsd'* ) export SHELL_PLATFORM='bsd' ;;
            *'cygwin'*  ) export SHELL_PLATFORM='cygwin' ;;
            *'msys'*    ) export SHELL_PLATFORM='msys' ;;
        esac
    fi
fi

function is_windows() {
    if [[ $SHELL_PLATFORM == 'msys' ]] || [[ $SHELL_PLATFORM == 'cygwin' ]] || [[ $SHELL_PLATFORM == 'windows' ]]; then
        return 0
    fi
    return 1
}

function is_osx() {
    if [[ $SHELL_PLATFORM == 'osx' ]]; then
        return 0
    fi
    return 1
}

# shellcheck disable=SC2009,SC2046
_CURRENT_SHELL="$(ps | grep $$ | grep -Eo '(ba|z|tc|c)?sh')"
_CURRENT_SHELL="${_CURRENT_SHELL##*/}"
_CURRENT_SHELL="${_CURRENT_SHELL##*:}"
if ! is_windows; then
    # Hack when using sudo
    if [[ $_CURRENT_SHELL == "sudo" ]] || [[ $_CURRENT_SHELL == "su" ]]; then
        _CURRENT_SHELL="$(ps | head -4 | tail -n 1 | awk '{ print $4 }')"
    fi
fi

# colors
# shellcheck disable=SC2034
black="\033[0;30m"
# shellcheck disable=SC2034
red="\033[0;31m"
# shellcheck disable=SC2034
green="\033[0;32m"
# shellcheck disable=SC2034
yellow="\033[0;33m"
# shellcheck disable=SC2034
blue="\033[0;34m"
# shellcheck disable=SC2034
purple="\033[0;35m"
# shellcheck disable=SC2034
cyan="\033[0;36m"
# shellcheck disable=SC2034
white="\033[0;37;1m"
# shellcheck disable=SC2034
orange="\033[0;91m"
# shellcheck disable=SC2034
normal="\033[0m"
# shellcheck disable=SC2034
reset_color="\033[39m"

function help_user() {
    cat<<EOF
Description

Usage:
    $_NAME [OPTIONAL]

    Optional Flags

        --nolog
            Disable log writting

        --nocolor
            Disable color output

        -v, --verbose
            Enable debug messages

        -h, --help
            Display help, if you are seeing this, that means that you already know it (nice)
EOF
}

function __parse_args() {
    if [[ $# -lt 2 ]]; then
        echo ""
    fi

    local arg="$1"
    local test="$2"

    local pattern="^--${test}[=][a-zA-Z0-9._-/~]+$"

    if [[ -n "$3" ]]; then
        local pattern="^--${test}[=]$3$"
    fi

    if [[ $arg =~ $pattern ]]; then
        local left_side="${arg#*=}"
        echo "${left_side/#\~/$HOME}"
    else
        echo "$arg"
    fi
}

function warn_msg() {
    local warn_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${yellow}[!] Warning:${reset_color}\t %s\n" "$warn_message"
    else
        printf "[!] Warning:\t %s\n" "$warn_message"
    fi
    _WARN_COUNT=$(( _WARN_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[!] Warning:\t %s\n" "$warn_message" >> "${_LOG}"
    fi
    return 0
}

function error_msg() {
    local error_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${red}[X] Error:${reset_color}\t %s\n" "$error_message" 1>&2
    else
        printf "[X] Error:\t %s\n" "$error_message" 1>&2
    fi
    _ERR_COUNT=$(( _ERR_COUNT + 1 ))
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[X] Error:\t\t %s\n" "$error_message" >> "${_LOG}"
    fi
    return 0
}

function status_msg() {
    local status_message="$1"
    if [[ $_NOCOLOR -eq 0 ]]; then
        printf "${green}[*] Info:${reset_color}\t %s\n" "$status_message"
    else
        printf "[*] Info:\t %s\n" "$status_message"
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[*] Info:\t\t %s\n" "$status_message" >> "${_LOG}"
    fi
    return 0
}

function verbose_msg() {
    local debug_message="$1"
    if [[ $_VERBOSE -eq 1 ]]; then
        if [[ $_NOCOLOR -eq 0 ]]; then
            printf "${purple}[+] Debug:${reset_color}\t %s\n" "$debug_message"
        else
            printf "[+] Debug:\t %s\n" "$debug_message"
        fi
    fi
    if [[ $_NOLOG -eq 0 ]]; then
        printf "[+] Debug:\t\t %s\n" "$debug_message" >> "${_LOG}"
    fi
    return 0
}

function initlog() {
    if [[ $_NOLOG -eq 0 ]]; then
        rm -f "${_LOG}" 2>/dev/null
        touch "${_LOG}" &>/dev/null
        if [[ -f "${_SCRIPT_PATH}/shell/banner" ]]; then
            cat "${_SCRIPT_PATH}/shell/banner" > "${_LOG}"
        fi
    fi
    return 0
}

function fix_path() {
    if [[ -n "$OLD_PPATH" ]]; then
        export PYTHONPATH="$OLD_PPATH"
        unset OLD_PPATH
    fi
    return 0
}

function exit_append() {
    if [[ $_NOLOG -eq 0 ]]; then
        if [[ $_WARN_COUNT -gt 0 ]] || [[ $_ERR_COUNT -gt 0 ]]; then
            printf "\n\n" >> "${_LOG}"
        fi

        if [[ $_WARN_COUNT -gt 0 ]]; then
            printf "[*] Warnings:\t%s\n" "$_WARN_COUNT" >> "${_LOG}"
        fi
        if [[ $_ERR_COUNT -gt 0 ]]; then
            printf "[*] Errors:\t\t%s\n" "$_ERR_COUNT" >> "${_LOG}"
        fi
    fi
    return 0
}

while [[ $# -gt 0 ]]; do
    key="$1"
    case "$key" in
        --nolog)
            _NOLOG=1
            ;;
        --nocolor)
            _NOCOLOR=1
            ;;
        -v|--verbose)
            _VERBOSE=1
            ;;
        -h|--help)
            help_user
            exit 0
            ;;
        -i|--ignore|--ignore_error)
            _IGNORE=1
            ;;
        *)
            initlog
            error_msg "Unknown argument $key"
            help_user
            exit 1
            ;;
    esac
    shift
done

initlog

if [[ $_VERBOSE -eq 1 ]]; then
    # shellcheck disable=SC2034
    DEBUG=1
fi

if is_windows; then
    python="python"
else
    python="python3"
fi

status_msg "Using python $($python --version)"

status_msg 'Checking format compliance'
# shellcheck disable=SC2046
if ! flake8 --count --ignore=E501,E402 --show-source --statistics $(git ls-files "**/*.py"); then
    error_msg 'Format is not compliance with the repo'
    if [[ $_IGNORE -eq 0 ]]; then
        exit 2
    fi
fi

status_msg 'Making Django Migrations'
if ! $python manage.py makemigrations --noinput; then
    error_msg 'Failed to make migrations'
    if [[ $_IGNORE -eq 0 ]]; then
        exit 3
    fi
fi

status_msg 'Migrating Django Models'
if ! $python manage.py migrate --noinput; then
    error_msg 'Failed to migrate models'
    if [[ $_IGNORE -eq 0 ]]; then
        exit 4
    fi
fi

_settings_path="$(pwd)/server/apps/crawler/social/settings.json"
if { [[ -z $TWITTER_TOKEN_KEY ]] || [[ -z $TWITTER_TOKEN_SECRET ]] ; } && [[ ! -f $_settings_path ]]; then
    error_msg "Could not start tests because tokens are missing"
    cat<<EOF
    Please either set the twitter tokens as

    export TWITTER_TOKEN_KEY="SUPER_SECRET_PERSONAL_KEY"
    export TWITTER_TOKEN_SECRET="SUPER_SECRET_PERSONAL_SECRET"

    or create a json file with the format

    {
        "twitter": {
            "token": {
                "key": "SUPER_SECRET_PERSONAL_KEY",
                "secret": "SUPER_SECRET_PERSONAL_SECRET"
            }
        }
    }

    in the following path $_settings_path
EOF
    exit 5
fi

status_msg 'Running Django tests'
if ! $python manage.py test --tag=init ; then
    error_msg 'Django tests failed'
    if [[ $_IGNORE -eq 0 ]]; then
        exit 6
    fi
fi

if [[ -n "$PYTHONPATH" ]]; then
    export OLD_PPATH="$PYTHONPATH"
else
    export OLD_PPATH="."
    export PYTHONPATH="."
fi

export PYTHONPATH="$(pwd -P)/server:$PYTHONPATH"

status_msg 'Test standalone script'
warn_msg "Trend extraction is temporally disable"
if ! $python ./server/apps/crawler/apps.py --query "#amlo,#jalisco" --trend "Mexico" --logging "info" --pull 3; then
    error_msg 'Standalone script fail'
    if [[ $_IGNORE -eq 0 ]]; then
        exit 7
    fi
fi

exit 0
