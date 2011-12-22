# Wesllei apt-fast completion.

have apt-fast &&
_apt_fast()
{
    local cur prev special i

    COMPREPLY=()
    cur=`_get_cword`t
    prev=${COMP_WORDS[COMP_CWORD-1]}

    for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
        if [[ ${COMP_WORDS[i]} == @(install|remove|autoremove|purge|source|build-dep) ]]; then
            special=${COMP_WORDS[i]}
        fi
    done

    if [ -n "$special" ]; then
        case $special in
            remove|autoremove|purge)
                if [ -f /etc/debian_version ]; then
                    # Debian system
                    COMPREPLY=( $( _comp_dpkg_installed_packages $cur ) )
                else
                    # assume RPM based
                    _rpm_installed_packages
                fi
                return 0
                ;;
            *)
                COMPREPLY=( $( apt-cache --no-generate pkgnames "$cur" \
                    2> /dev/null ) )
                return 0
                ;;
        esac
    fi

    case "$prev" in
        -@(c|-config-file))
             _filedir
             return 0
             ;;
        -@(t|-target-release|-default-release))
             COMPREPLY=( $( apt-cache policy | \
                 grep "release.o=Debian,a=$cur" | \
                 sed -e "s/.*a=\(\w*\).*/\1/" | uniq 2> /dev/null) )
             return 0
             ;;
    esac

    if [[ "$cur" == -* ]]; then
        COMPREPLY=( $( compgen -W '-d -f -h -v -m -q -s -y -u -t -b -c -o \
            --download-only --fix-broken --help --version --ignore-missing \
            --fix-missing --no-download --quiet --simulate --just-print \
            --dry-run --recon --no-act --yes --assume-yes --show-upgraded \
            --only-source --compile --build --ignore-hold --target-release \
            --no-upgrade --force-yes --print-uris --purge --reinstall \
            --list-cleanup --default-release --trivial-only --no-remove \
            --diff-only --no-install-recommends --tar-only --config-file \
            --option --auto-remove' -- "$cur" ) )
    else
        COMPREPLY=( $( compgen -W 'update upgrade dselect-upgrade \
            dist-upgrade install remove purge source build-dep \
            check clean autoclean autoremove' -- "$cur" ) )
    fi

    return 0
} &&
complete -F _apt_fast $filenames apt-fast

# Debian apt-cache(8) completion.
#
have apt-cache &&
_apt_cache()
{
    local cur prev special i

    COMPREPLY=()
    cur=`_get_cword`
    prev=${COMP_WORDS[COMP_CWORD-1]}


    if [ "$cur" != show ]; then
        for (( i=0; i < ${#COMP_WORDS[@]}-1; i++ )); do
        if [[ ${COMP_WORDS[i]} == @(add|depends|dotty|madison|policy|rdepends|show?(pkg|src|)) ]]; then
            special=${COMP_WORDS[i]}
        fi
        done
    fi


    if [ -n "$special" ]; then
        case $special in
        add)
            _filedir
            return 0
            ;;

        showsrc)
            COMPREPLY=( $( apt-cache dumpavail | \
                            grep "^Source: $cur" | sort | \
                            uniq | cut -f2 -d" " ) )
            return 0
            ;;

        *)
            COMPREPLY=( $( apt-cache --no-generate pkgnames "$cur" 2> /dev/null ) )
            return 0
            ;;

        esac
    fi


    case "$prev" in
         -@(c|p|s|-config-file|-@(pkg|src)-cache))
             _filedir
             return 0
             ;;
         search)
             if [[ "$cur" != -* ]]; then
                return 0
             fi
             ;;
    esac

    if [[ "$cur" == -* ]]; then

        COMPREPLY=( $( compgen -W '-h -v -p -s -q -i -f -a -g -c \
                -o --help --version --pkg-cache --src-cache \
                --quiet --important --full --all-versions \
                --no-all-versions --generate --no-generate \
                --names-only --all-names --recurse \
                --config-file --option --installed' -- "$cur" ) )
    else

        COMPREPLY=( $( compgen -W 'add gencaches show showpkg showsrc \
                stats dump dumpavail unmet search search \
                depends rdepends pkgnames dotty xvcg \
                policy madison' -- "$cur" ) )

    fi


    return 0
} &&
complete -F _apt_cache $filenames apt-cache

# Local variables:
# mode: shell-script
# sh-basic-offset: 4
# sh-indent-comment: t
# indent-tabs-mode: nil
# End:
# ex: ts=4 sw=4 et filetype=sh