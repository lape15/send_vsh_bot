#!/bin/bash


# set -a
# source .env
# set +a


URL="https://service.berlin.de/terminvereinbarung/termin/taken/"
BASE_URL="https://service.berlin.de/terminvereinbarung/termin/taken/?dienstleister="
INTERVAL=180  
RUN_COUNT=0
MAX_RUNS=3


DIESTLEISTER_IDS=("325853" "351438" "351444" "122626" "122628" "351636" "122659" "122664" "122666" "325987" "351435" "122671")
DISTRICT_NAMES=("Charlottenburg-Wilmersdorf" "Friedrichshain-Kreuzberg" "Friedrichshain-Kreuzberg" "Lichtenberg" "Hellersdorf" "Mitte" "Neukölln" "Reinickendorf" "Spandau" "Steglitz-Zehlendorf" "Tempelhof-Schöneberg" "Treptow-Köpenick")

# Function to send message to Telegram
send_telegram() {
    MESSAGE="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$MESSAGE" \
        -d parse_mode="Markdown" > /dev/null
}


if [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Please set TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID in .env"
    exit 1
fi

while [ "$RUN_COUNT" -lt "$MAX_RUNS" ]; do
    TIMESTAMP=$(date)

    # Iterate through all dienstleister IDs and check for appointment availability
    for i in "${!DIESTLEISTER_IDS[@]}"; do
        DIESTLEISTER_ID="${DIESTLEISTER_IDS[$i]}"
        DISTRICT_NAME="${DISTRICT_NAMES[$i]}"
        URL="${BASE_URL}${DIESTLEISTER_ID}"
        # CONTENT=$(curl -s "$URL")
        CONTENT=$(curl -s --max-filesize 10485760 "$URL")


        if [ -z "$CONTENT" ]; then
            echo "[$TIMESTAMP] 📍 No content returned for $DISTRICT_NAME ($DIESTLEISTER_ID). Skipping..."
            echo "$CONTENT"
            continue
        fi
        # Check if there are no available appointments
        if echo "$CONTENT" | grep -q "Leider sind aktuell keine Termine für ihre Auswahl verfügbar"; then
            echo "[$TIMESTAMP] ❌ No appointments available for $DISTRICT_NAME  ."
            # echo "$CONTENT"
        else
            echo "[$TIMESTAMP] 🚨 Appointments might be available for $DISTRICT_NAME ($DIESTLEISTER_ID)! Check now!"

            MESSAGE="🚨 *Appointment available!*\n📍 *$DISTRICT_NAME*\n👉 [Jetzt buchen](https://service.berlin.de/terminvereinbarung/termin/taken/?dienstleister=${DIESTLEISTER_ID})\n\nSchnell sein!"
            send_telegram "$MESSAGE"

        fi
    done

    RUN_COUNT=$((RUN_COUNT + 1))
    if [ "$RUN_COUNT" -lt "$MAX_RUNS" ]; then
        echo "[$TIMESTAMP] 😴 Waiting $INTERVAL seconds before the next check..."
        sleep "$INTERVAL"
    fi
done

echo "Script finished after $MAX_RUNS runs."