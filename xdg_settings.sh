# Configure XDG with e.g. an expected default web browser.
#
# Source'd by configuration apply script.
# Do not run directly.

apply_xdg_settings()
{
    local desktop_file_dirs=("/usr/share/applications" "/usr/local/share/applications" "~/.local/share/applications")
    # CONFIGURATION
    #--------------------------------------------------------------------------------
    local web_browser_priorities=(
        firefox
        qutebrowser
        org.qutebrowser.qutebrowser
        google-chrome
    )
    #--------------------------------------------------------------------------------
    desktop_file_exists()
    {
        local desktop_basename="$1"
        for dirpath in "${desktop_file_dirs[@]}"
        do
            if [ -f $dirpath/$desktop_basename.desktop ] ; then
                return 0
            fi
        done
        return 1
    }

    echo "Applying XDG settings..."
    local did_set_web_browser=0
    for app in "${web_browser_priorities[@]}"
    do
        if desktop_file_exists "$app"
        then
            echo "$app.desktop found, setting it to the default web browser."
            xdg-settings set default-web-browser "$app.desktop"
            did_set_web_browser=1
            break
        fi
    done
    if [ $did_set_web_browser -eq 0 ] ; then
        echo "Couldn't find any of the web browser priorities: (${web_browser_priorities[@]})"
        echo "Letting the system  use its own default web browser."
    fi
}
apply_xdg_settings
unset -f apply_xdg_settings
