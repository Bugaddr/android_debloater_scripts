#!/usr/bin/env bash
set -euo pipefail

# Note: Enable usb debugging & Disable Permission Monitoring (To clear app data) in settings
# This script debloats only for user 0, edit for other user

# Define colors natively in bash
RED=$'\e[0;31m'
GREEN=$'\e[0;32m'
YELLOW=$'\e[0;33m'
CYAN=$'\e[0;36m'
NC=$'\e[0m' # No Color

# Ensure adb is installed
if ! command -v adb &> /dev/null; then
    echo -e "${RED}Error: 'adb' is not installed or not in your PATH.${NC}"
    exit 1
fi

# Ensure a device is connected and authorized
if ! adb get-state 1>/dev/null 2>&1; then
    echo -e "${RED}Error: No device connected or device unauthorized.${NC}"
    echo -e "${YELLOW}Please plug in your phone, enable USB Debugging, and authorize the computer.${NC}"
    exit 1
fi

# Get user id, default to 0 if not provided
USER_ID="${1:-0}"

# Validate USER_ID is a number
if ! [[ "$USER_ID" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}Error: USER_ID must be a number.${NC}"
    exit 1
fi

echo -e "${GREEN}Starting debloat process for USER_ID: ${USER_ID}${NC}"
echo -e "${CYAN}----------------------------------------${NC}"

# Fetch package lists once to massively speed up checks
echo -e "${YELLOW}Fetching list of installed and disabled packages...${NC}"
# Use tr to remove carriage returns (\r) from adb output to prevent matching bugs
INSTALLED_APPS=$(adb shell pm list packages --user "$USER_ID" | tr -d '\r' | sed 's/^package://')
DISABLED_APPS=$(adb shell pm list packages -d --user "$USER_ID" | tr -d '\r' | sed 's/^package://')

# App lists
uninstall_user=(
	#com.phonepe.app                           # Phonepe
	#com.realme.link                           # Realme link
	#com.snapchat.android                      # Snapchat
	com.block.juggle                          # Block blast
	com.byjus.thelearningapp                  # Byju
	com.cardfeed.video_public                 # Public news app
	com.coloros.backuprestore                 # Clone phone
	com.coloros.note                          # Notes
	com.coloros.onekeylockscreen              # Screen lock
	com.eterno                                # Dailyhunt
	com.eterno.shortvideos                    # Josh
	com.facebook.katana                       # Facebook
	com.flipkart.android                      # Flipkart
	com.google.android.apps.chromecast.app    # Google home
	com.google.android.apps.docs              # Google docs
	com.google.android.apps.magazines         # Google news
	com.google.android.apps.podcasts          # Google podcast
	com.google.android.apps.subscriptions.red # Google one
	com.google.android.apps.tachyon           # Google meet
	com.google.android.apps.youtube.music     # Youtube music
	com.google.android.videos                 # Google tv
	com.jio.media.ondemand                    # Jio cinema
	com.katanlabs.bridgerunio                 # Bridge run
	com.king.candycrushsaga                   # Candycrush
	com.linkedin.android                      # Linkedin
	com.nearme.gamecenter                     # Nearme game center
	com.oneplus.brickmode                     # Zen space
	com.opos.cs                               # Hot apps
	com.os.docvault                           # Realme docvault
	com.realmecomm.app                        # Realme community
	com.realmestore.app                       # Realme store
	com.spotify.music                         # Spotify
	in.amazon.mShop.android.shopping          # Amazon
	in.mohalla.sharechat                      # Sharechat
	in.mohalla.video                          # Moj
	net.one97.paytm                           # Paytm
)

uninstall_system=(
	#com.google.android.apps.googleassistant # Google assistant
	#com.google.android.apps.maps            # Google maps
	#com.google.android.apps.nbu.files       # Google files
	#com.google.android.apps.photos          # Google photos
	#com.google.android.calendar             # Google calendar
	#com.google.android.googlequicksearchbox # Google search
	#com.google.android.youtube              # Youtube
	#com.oplus.games                         # Games
	com.android.chrome                      # Google chrome
	com.applovin.array.apphub.vincere       # Apphub
	com.coloros.assistantscreen             # Shelf
	com.coloros.compass2                    # Compass
	com.coloros.filemanager                 # Realme Filemanager
	com.coloros.oshare                      # Realme share
	com.coloros.phonemanager                # Phone manager
	com.coloros.video                       # Video
	com.coloros.weather2                    # Weather
	com.facebook.appmanager                 # Meta app manager
	com.facebook.services                   # Meta services
	com.facebook.system                     # Meta app installer
	com.finshell.fin                        # Finshell pay
	com.glance.internet                     # Glance for realme
	com.google.android.apps.nbu.paisa.user  # Google pay
	com.google.android.apps.restore         # Data restore tool
	com.google.android.gm                   # Gmail
	com.google.android.keep                 # Keep notes
	com.google.ar.lens                      # Google lens
	com.heytap.browser                      # Heytap Browser
	com.heytap.cloud                        # Heytap cloud
	com.heytap.music                        # Music
	com.heytap.pictorial                    # Lock screen magazine
	com.heytap.themestore                   # Theme store
	com.heytap.usercenter                   # My realme
	com.oplus.account                       # Account centre
	com.oplus.aiunit                        # Ai service
	com.oplus.melody                        # Wireless earphones (firmware updater for realme/oplus earphone)
	com.oppo.quicksearchbox                 # Global search
	com.redteamobile.roaming                # ORoaming
)

disable_system=(
	com.android.bluetoothmidiservice                 # Bluetooth midi service
	com.android.bookmarkprovider                     # Bookmark Provider
	com.android.calllogbackup                        # Call log backup/restore
	com.android.dreams.basic                         # Basic daydreams
	com.android.email.partnerprovider                # Email partner provider
	com.android.nfc                                  # NFC Service
	com.android.providers.partnerbookmarks           # Partner bookmark
	com.android.stk                                  # Sim toolkit
	com.android.systemui.plugin.globalactions.wallet # Google Wallet toggle in QS
	com.coloros.activation                           # E-warranty card
	com.coloros.healthcheck                          # Diagnostics
	com.coloros.operationManual                      # Help & feedback
	com.coloros.securepay                            # Payment protection
	com.coloros.smartsidebar                         # Smart sidebar
	com.coloros.weather.service                      # Weather service
	com.google.android.as                            # Android system intelligence
	com.google.android.feedback                      # Market feedback agent
	com.google.android.gms.location.history          # Google location history
	com.google.android.marvin.talkback               # Android accessiblity suite
	com.google.android.onetimeinitializer            # Google one time init
	com.google.android.partnersetup                  # Google partner setup
	com.google.android.printservice.recommendation   # Print service recommendation service
	com.google.android.setupwizard                   # Android setup
	com.heytap.accessory                             # Quick device connect
	com.heytap.market                                # App picks
	com.heytap.mcs                                   # System messages
	com.mediatek.omacp                               # Omacp
	com.oplus.apprecover                             # Recover system app
	com.oplus.cosa                                   # App enhancement service
	com.oplus.crashbox                               # Crashbox
	com.oplus.encryption                             # Private safe
	com.oplus.healthservice                          # Healthservice
	com.oplus.lfeh                                   # Oplus LFEHer
	com.oplus.linker                                 # OPSynergy
	com.oplus.logkit                                 # Feedback
	com.oplus.ocloud                                 # Oplus cloud
	com.oplus.olc                                    # Olc
	com.oplus.onetrace                               # OneTrace
	com.oplus.pay                                    # Secure payment (Cant uninstall)
	com.oplus.qualityprotect                         # QualityProtect
	com.oplus.securitykeyboard                       # Secure keyboard
	com.oplus.statistics.rom                         # User experience program
	com.oplus.synergy                                # HeySynergy
	com.oplus.themestore                             # Theme store
	com.oplus.wifibackuprestore                      # Wifi backup/restore
	com.qualcomm.atfwd                               # ATFWD (AT commands)
	com.qualcomm.embms                               # EMBMS (LTE broadcasr)
	com.qualcomm.qti.uim                             # R-UIM (Remote sim lock service)
	com.realme.movieshot                             # Combine captions
	com.realme.securitycheck                         # Security analysis
	com.ses.entitlement.o2                           # O2 (UK sim)
	com.tencent.soter.soterserver                    # AIDL server demo
	com.wapi.wapicertmanage                          # WAPI certificate
)

# Reusable function for processing apps
process_apps() {
    local action="$1"
    shift
    local apps=("$@")

    for app in "${apps[@]}"; do
        # Format the output so the colors are wrapping the padded string placeholder correctly
        printf "  ${YELLOW}%-50s${NC} " "$app"

        # Check if the app is currently installed.
        # -F: Fixed strings (treat dots as dots, not regex)
        # -x: Exact line match
        if ! grep -q -F -x "$app" <<< "$INSTALLED_APPS"; then
            echo -e "[ ${NC}NOT INSTALLED${NC} ]"
            continue
        fi

        if [ "$action" = "uninstall" ]; then
            if adb shell pm uninstall --user "$USER_ID" "$app" >/dev/null 2>&1; then
                echo -e "[ ${GREEN}SUCCESS${NC} ]"
            else
                echo -e "[ ${RED}FAILED${NC} ]"
            fi
        elif [ "$action" = "disable" ]; then
            # Avoid re-disabling if it is already disabled
            if grep -q -F -x "$app" <<< "$DISABLED_APPS"; then
                echo -e "[ ${NC}ALREADY DISABLED${NC} ]"
                continue
            fi

            if adb shell "pm disable-user --user $USER_ID $app && am force-stop --user $USER_ID $app && pm clear --user $USER_ID $app" >/dev/null 2>&1; then
                echo -e "[ ${GREEN}SUCCESS${NC} ]"
            else
                echo -e "[ ${RED}FAILED${NC} ]"
            fi
        fi
    done
}

echo -e "\n${CYAN}---> Uninstalling User Apps <---${NC}"
process_apps "uninstall" "${uninstall_user[@]}"

echo -e "\n${CYAN}---> Uninstalling System Apps <---${NC}"
process_apps "uninstall" "${uninstall_system[@]}"

echo -e "\n${CYAN}---> Disabling & Clearing System Apps <---${NC}"
process_apps "disable" "${disable_system[@]}"

# Reboot phone
echo -e "\n${CYAN}----------------------------------------${NC}"
echo -e "${GREEN}Debloat complete!${NC}"
echo -e "${YELLOW}It is recommended to reboot your device.${NC}"
echo -e "${CYAN}Run 'adb reboot' or restart your device manually.${NC}"
