#!/bin/bash



# # URL="https://service.berlin.de/terminvereinbarung/termin/taken/?mdt=302261&anliegen[]=120686&dienstleister=122210&herkunft=direct"
# URL="https://service.berlin.de/terminvereinbarung/termin/taken/"

# url="https://service.berlin.de/dienstleistung/351180/"
# BASE_URL="https://service.berlin.de/terminvereinbarung/termin/taken/?dienstleister="
# INTERVAL=180  # check every 3 minutes


# # DIESTLEISTER_IDS=(
# #     "325853"  # Charlottenburg-Wilmersdorf
# #     "351438"  # Friedrichshain-Kreuzberg
# #     "351444"  # Friedrichshain-Kreuzberg
# #     "122626"   # Lichtenberg
# #     "122628"    # Hellersdorf
# #     "351636" #  Mitte
# #     "122659" # Neukölln
# #     "122664" #Reinickendorf
# #     "122666" # Spandau
# #     "325987" #Steglitz-Zehlendorf
# #     "351435" # Tempelhof-Schöneberg
# #     "122671" # Treptow-Köpenick
# # )

# declare -A DIESTLEISTER_IDS=(
#     ["325853"]="Charlottenburg-Wilmersdorf"
#     ["351438"]="Friedrichshain-Kreuzberg"
#     ["351444"]="Friedrichshain-Kreuzberg"
#     ["122626"]="Lichtenberg"
#     ["122628"]="Hellersdorf"
#     ["351636"]="Mitte"
#     ["122659"]="Neukölln"
#     ["122664"]="Reinickendorf"
#     ["122666"]="Spandau"
#     ["325987"]="Steglitz-Zehlendorf"
#     ["351435"]="Tempelhof-Schöneberg"
#     ["122671"]="Treptow-Köpenick"
# )

# send_telegram() {
#     MESSAGE="$1"
#     curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
#         -d chat_id="$CHAT_ID" \
#         -d text="$MESSAGE" > /dev/null
#         -d parse_mode="Markdown" > /dev/null
# }


# while true; do
#     TIMESTAMP=$(date)
    
#     # Iterate through all dienstleister IDs and check for appointment availability
#     for DIESTLEISTER_ID in "${!DIESTLEISTER_IDS[@]}"; do
#         DISTRICT_NAME="${DIESTLEISTER_IDS[$DIESTLEISTER_ID]}"
#         URL="${BASE_URL}${DIESTLEISTER_ID}"
#         CONTENT=$(curl -s "$URL")
        
#         # Check if there are no available appointments
#         if echo "$CONTENT" | grep -q "Leider sind aktuell keine Termine für ihre Auswahl verfügbar"; then
#             echo "[$TIMESTAMP] ❌ No appointments available for $DISTRICT_NAME ($DIESTLEISTER_ID) ($URL)."
#         else
#             echo "[$TIMESTAMP] 🚨 Appointments might be available for $DISTRICT_NAME ($DIESTLEISTER_ID)! Check now!"
            
           
#             MESSAGE="🚨 *Termin verfügbar!*\n\n📍 *$DISTRICT_NAME*\n👉 [Jetzt buchen](https://service.berlin.de/terminvereinbarung/termin/taken/?dienstleister=${DIESTLEISTER_ID})\n\nSchnell sein!"
            
#             curl -s -X POST "https://api.telegram.org/bot$BOT_TOKEN/sendMessage" \
#                 -d chat_id="$CHAT_ID" \
#                 -d text="$MESSAGE" \
#                 -d text="$url"
#                 -d parse_mode="Markdown" > /dev/null
#         fi
#     done

   
#     sleep $INTERVAL
# done


# Load env vars
# set -a
# source .env
# set +a

URL="https://service.berlin.de/terminvereinbarung/termin/taken/"
BASE_URL="https://service.berlin.de/terminvereinbarung/termin/taken/?dienstleister="
INTERVAL=180  # check every 3 minutes

BOT_TOKEN="7575720770:AAEPPKjSNoe2kXEfTdh9OmP7p44nNeNLEY4"
CHAT_ID="6060529404"

# Arrays of dienstleister IDs and corresponding district names 
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

# while true; do
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

    # Wait before the next round of checks
    # sleep $INTERVAL
# done
