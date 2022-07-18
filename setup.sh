# /bin/bash
FILE='.setup.log'
if [ -f .setup.log ] && [ $(grep COMPLETED=true .setup.log) ]
then
    printf "${GREEN} Your app is already setup!!\n"
    exit;
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NO_COLOR='\033[0m'

if [ $# -eq 0 ]
then
    echo "No arguments detected"
    exit
fi

init()
{
    cp .env.example .env
    cp setup/Dockerfile Dockerfile
}

setupForMac()
{
    if [ -z "$2" ]
    then
        printf "${RED}Setup fail: missing architecture information\n";
        exit
    fi
    if [ "$2" = "-h" ] || [ "$2" = "--help" ]
    then
        printf "${NO_COLOR} --arch=[architecture]       arm | x64\n";
        exit
    fi
    printf "\n${BLUE}Seting up for your mac...\n";

    case $2 in
        --arch=arm)
            cp setup/docker-compose.yml.mac-arm.example docker-compose.yml
            ;;
        --arch=x64)
            cp setup/docker-compose.yml.mac-x64.example docker-compose.yml
            ;;
        *)
        printf "${RED}Setup fail: unknown architecture information\n";
        exit;;
    esac
    printf "\n${BLUE}A docker-compose.yml has been made ...\n";
}

setupForUbuntu()
{
    printf "\n${BLUE}Seting up for your ubuntu machine... \n";
    cp setup/docker-compose.yml.ubuntu.example docker-compose.yml
}

completeSetup()
{
    printf "Completing setup ... \n"
    echo "" >> .gitignore
    echo "/Dockerfile" >> .gitignore
    printf "... \n"
    echo "/docker-compose.yml" >> .gitignore
    echo "/storage/minio" >> .gitignore
    docker compose up --build -d
    docker compose exec app composer install
    docker compose exec app php artisan key:generate
    $(printf "COMPLETED=true" > "$FILE")
    echo "/$FILE" >> .gitignore
    printf "${GREEN}Your setup is completed, Enjoy!!\n"

}

help()
{
    printf "\n${GREEN}./setup.sh --os=[Operating System] --arch=[architecture]\n";
    printf "${NO_COLOR}\n";
    printf "    - [Operating System]    macos | ubuntu\n";
    printf "    - [architecture]        arm   | x64       Only when operating system is 'mac'\n\n";
}

case $1 in
    --os=mac)
        init $#
        setupForMac $# $2
        completeSetup $#
        exit;;
    --os=ubuntu)
        init $#
        setupForUbuntu $# $2
        completeSetup $#
        exit;;
    -h | --help)
        help
        exit;;
    *)
    printf "${RED}Setup fail: Unknown OS\n";
    exit;;
esac