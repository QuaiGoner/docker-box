print_header "Configure Selkies WebRTC"

# Optional: pick port (Selkies default is often 8080 or 8181 depending on build)
DYNAMIC_PORT_SELKIES=$(get_next_unused_port 32100)
export PORT_SELKIES=${PORT_SELKIES:-$DYNAMIC_PORT_SELKIES}

print_step_header "Configure Selkies port '${PORT_SELKIES}'"

if ([ "${MODE}" != "s" ] && [ "${MODE}" != "secondary" ]); then

    if [ "${WEB_UI_MODE:-}" = "selkies" ]; then
        print_step_header "Enable Selkies server"

        # Example supervisor file you must create:
        sed -i 's|^autostart.*=.*$|autostart=true|' /etc/supervisor.d/selkies.ini

    else
        print_step_header "Disable Selkies server"
        sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/selkies.ini
    fi

else
    print_step_header "Selkies not available in secondary mode"
    sed -i 's|^autostart.*=.*$|autostart=false|' /etc/supervisor.d/selkies.ini
fi

echo -e "\e[34mDONE\e[0m"