# Radarr Genre Sort

This script will automatically sort new downloaded movies based on filter functions selected & their parameters defined in the .env file

## Installation

1. Clone the repo into folder accessible by radarr 
2. Make sure all files have permissions and are executable
3. Add script to Radarr
    1. Settings > Connect > Add Custom Script
    2. Give script title
    3. Only check 'On Movie Added'
    4. Click Save
4. Rename .env.example file to .env

## Edit .env file

1. `RADARR_URL` - your radarr ip/domain for api access. 

2. `RADARR_API_KEY` - your radarr API Key
    * Found in Radarr > Settings > General > API Key

3. `#Genres` - defined genres
    * Add desired genre
    * Follow the `GENRE_<CHANGE>` format

4. `#Directories` - defined directories
    * Add location for the files
    * Follow the `DIR_<CHANGE>` format
