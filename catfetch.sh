de=""
distro=""

trim_quotes() {
    trim_output="${1//\'}"
    trim_output="${trim_output//\"}"
    printf "%s" "$trim_output"
}

get_os() {
            if [[ -f "/bedrock/etc/bedrock-release" && "$PATH" == */bedrock/cross/* ]]; then
                distro="Bedrock Linux"
            elif [[ -f "/etc/redstar-release" ]]; then
                    distro="Red Star OS"

            elif [[ -f "/etc/siduction-version" ]]; then
                distro="Siduction"

            elif type -p lsb_release >/dev/null; then
                distro="$(lsb_release -si)"

            elif [[ -f "/etc/GoboLinuxVersion" ]]; then
                    distro="GoboLinux"

            elif type -p guix >/dev/null; then
                    distro="GuixSD"

            elif type -p tazpkg >/dev/null; then
                distro="SliTaz $(< /etc/slitaz-release)"

            elif type -p kpt >/dev/null && \
                 type -p kpm >/dev/null; then
                distro="KSLinux"

            elif [[ -f "/etc/os-release" || \
                    -f "/usr/lib/os-release" || \
                    -f "/etc/openwrt_release" ]]; then
                files=("/etc/os-release" "/usr/lib/os-release" "/etc/openwrt_release")

                # Source the os-release file
                for file in "${files[@]}"; do
                    source "$file" && break
                done

                distro="${NAME:-${DISTRIB_ID:-${TAILS_PRODUCT_NAME}}}"
            else
                for release_file in /etc/*-release; do
                    distro+="$(< "$release_file")"
                done

                if [[ -z "$distro" ]]; then
                        distro="$kernel_name"

                    distro="${distro/DragonFly/DragonFlyBSD}"

                    # Workarounds for FreeBSD based distros.
                    [[ -f "/etc/pcbsd-lang" ]] &&  distro="PCBSD"
                    [[ -f "/etc/trueos-lang" ]] && distro="TrueOS"

                    # /etc/pacbsd-release is an empty file
                    [[ -f "/etc/pacbsd-release" ]] && distro="PacBSD"
                fi
            fi

            distro="$(trim_quotes "$distro")"
            distro="${distro/NAME=}"
}

#credits to neofetch
get_de() {
  if [[ "$XDG_CURRENT_DESKTOP" ]]; then
    de="${XDG_CURRENT_DESKTOP/X\-}"
    de="${de/Budgie:GNOME/Budgie}"
    de="${de/:Unity7:ubuntu}"

  elif [[ "$DESKTOP_SESSION" ]]; then
    de="${DESKTOP_SESSION##*/}"

  elif [[ "$GNOME_DESKTOP_SESSION_ID" ]]; then
    de="GNOME"

  elif [[ "$MATE_DESKTOP_SESSION_ID" ]]; then
    de="MATE"

  elif [[ "$TDE_FULL_SESSION" ]]; then
    de="Trinity"
  fi

  # Fallback to using xprop.
  [[ "$DISPLAY" && -z "$de" ]] && type -p xprop &>/dev/null &&
    \
    de="$(xprop -root | awk
  '/KDE_SESSION_VERSION|^_MUFFIN|xfce4|xfce5/')"

  # Format strings.
  case "$de" in
    "KDE_SESSION_VERSION"*) de="KDE${de/* = }" ;;
    *"xfce4"*) de="Xfce4" ;;
    *"xfce5"*) de="Xfce5" ;;
    *"xfce"*)  de="Xfce" ;;
    *"mate"*)  de="MATE" ;;

    *"MUFFIN"* | "Cinnamon")
      de="$(cinnamon --version)"; de="${de:-Cinnamon}"
      ;;

    *"GNOME"*)
      de="$(gnome-shell --version)"
      de="${de/Shell }"
      ;;
  esac

}

get_os

OS_NAME="$distro"
KERNEL_VER=$(uname -r)
UPTIME=$(uptime -p)
UPTIME=${UPTIME#"up "}

P_BLACK="$(tput setaf 0)"
P_RED="$(tput setaf 1)"
P_GREEN="$(tput setaf 2)"
P_YELLOW="$(tput setaf 3)"
P_BLUE="$(tput setaf 4)"
P_MAGENTA="\[$(tput setaf 5)"
P_CYAN="$(tput setaf 6)"
P_WHITE="$(tput setaf 7)"
P_RESET="$(tput sgr0)"

get_de

echo -e "\e[8;12;56t"
clear

case "$1" in
'-cat')
echo "                       ________________________________
                      /
$P_BLUE   /\\ ___ /\\     $P_RESET    / O: $P_BLUE$OS_NAME $P_RESET
$P_BLUE  (  o   o  )      $P_RESET /  K: $P_BLUE$KERNEL_VER $P_RESET
$P_BLUE   \\  >#<  /      $P_RESET  \\  D: $P_BLUE$de $P_RESET
$P_BLUE   /       \\      $P_RESET   \\ U: $P_BLUE$UPTIME $P_RESET
$P_BLUE  /         \    ^ $P_RESET   \\________________________________
$P_BLUE  |         |   // $P_RESET
$P_BLUE   \       /  //   $P_RESET
$P_BLUE    /// /// --     $P_RESET"
;;

'-dog')
echo "               ______________________________________
              /
$P_BLUE   /^ ^\\   $P_RESET  / O: $P_BLUE$OS_NAME $P_RESET
$P_BLUE  / 0 0 \\  $P_RESET /  K: $P_BLUE$KERNEL_VER $P_RESET
$P_BLUE  V\\ Y /V  $P_RESET \\  D: $P_BLUE$de $P_RESET
$P_BLUE   / - \\   $P_RESET  \\ U: $P_BLUE$UPTIME $P_RESET
$P_BLUE  /    |    $P_RESET  \\______________________________________
$P_BLUE V__) ||    $P_RESET
"
;;
*)
echo "usage: catfetch [-dog/-cat]"
;;
esac
