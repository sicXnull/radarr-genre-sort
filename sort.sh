#!/bin/bash

# Load values from the .env file
ENV_FILE="$(dirname "${BASH_SOURCE[0]}")/.env"
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
else
    echo "Error: .env file not found. Please create a .env file with the required variables." >&2
    exit 1
fi

LOG_FILE="$(dirname "${BASH_SOURCE[0]}")/script_log.txt"

function log_info() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') [INFO]: $message" >> "$LOG_FILE"
}

function log_error() {
    local message=$1
    echo "$(date +'%Y-%m-%d %H:%M:%S') [ERROR]: $message" >> "$LOG_FILE"
}

function get_latest_movie_id() {
    local url="${RADARR_URL}/movie"
    local headers=("X-Api-Key: ${RADARR_API_KEY}")
    local response=$(curl -s -H "${headers[@]}" "${url}")

    if [[ $? -eq 0 ]]; then
        local movie_id=$(echo "${response}" | jq -r '.[-1].id')
        echo "${movie_id}"
    else
        echo ""
    fi
}

function check_movie_genre() {
    local movie_id=$1
    local url="${RADARR_URL}/movie/${movie_id}"
    local headers=("X-Api-Key: ${RADARR_API_KEY}")
    local response=$(curl -s -H "${headers[@]}" "${url}")

    if [[ $? -eq 0 ]]; then
        echo "Response for movie_id=${movie_id}:"
        echo "${response}" | tee -a "$LOG_FILE"

        local genres=$(echo "${response}" | jq -r '.genres[] | ascii_downcase')
        echo "Genres for movie_id=${movie_id}:"
        echo "${genres}" | tee -a "$LOG_FILE"

        for genre in $genres; do
            # Convert genre to uppercase
            genre=${genre^^}

            # Check if the genre is defined in the .env file
            local genre_variable="GENRE_${genre}"
            local dir_variable="DIR_${genre}"
            if [[ -v "${genre_variable}" && -v "${dir_variable}" ]]; then
                echo "Movie ID ${movie_id} has the genre: ${genre}"

                # Move the movie to the corresponding genre directory
                local destination_directory="${!dir_variable}"
                if [[ ! -d "$destination_directory" ]]; then
                    mkdir -p "$destination_directory"
                    log_info "Created directory: $destination_directory"
                fi

                # Move the movie to the corresponding directory
                if change_movie_path "$movie_id" "$destination_directory"; then
                    log_info "Movie ID: ${movie_id} moved to $destination_directory successfully."
                else
                    log_error "Failed to move Movie ID: ${movie_id} to $destination_directory."
                fi
                return
            fi
        done

        echo "Movie ID ${movie_id} does not have a specified genre in the .env file."
    else
        echo "Error: Unable to fetch movie information for movie_id=${movie_id}" >&2 | tee -a "$LOG_FILE"
        echo "${response}" >&2 | tee -a "$LOG_FILE"
    fi
}
