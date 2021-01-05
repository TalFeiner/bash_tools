#!/bin/bash

GREEN_TXT='\e[0;32m'
WHITE_TXT='\e[1;37m'
RED_TXT='\e[31m'
NO_COLOR='\033[0m'

P=`pwd`

SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
  DIR="$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE" # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
done
cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && DIR=`pwd`
cd $P
 
echo -e "\n"
read -p "Please, insert workspace name: " workspace

cd $HOME
dir_ws=`sudo find -name "$workspace"`
if [ ! -z "$dir_ws" ]; then
    dir_ws=(${dir_ws// .// })
    dir_ws=${dir_ws:1}
    echo -e "${WHITE_TXT}\nIs this: $HOME$dir_ws the correct path to the workspace? <y/n> ${NO_COLOR}\c"
    read -n 2 path

    case $path in
        y)
        
        echo -e "${WHITE_TXT}Starts making the necessary changes and installations...${NO_COLOR}"
        sudo apt-get -y update
        #sudo apt-get -y upgrade
        mkdir $HOME/tmp
        rm -rf $HOME/$workspace/src/CMakeLists.txt
        cp -TR $HOME/$workspace/src $HOME/tmp
        cd $HOME
        rm -rf $HOME/$workspace
        mkdir -p $HOME/$workspace/src
        sudo apt-get -y install python3-empy  
        sudo apt-get -y install python3-catkin-pkg-modules
        sudo apt-get -y install python3-rospkg-modules
        cd $HOME/$workspace/
        catkin_make -DPYTHON_EXECUTABLE=/usr/bin/python3
        if [ $? -eq 0 ]; then
            cp -TR $HOME/tmp $HOME/$workspace/src
            catkin_make
            if [ $? -eq 0 ]; then
                rm -rf $HOME/tmp
            fi
            echo -e "${GREEN_TXT}\nDone, $workspace is compatible for python3 alongside python2.${NO_COLOR}\n"
        else
            echo -e "\n${RED_TXT}Error occurred. Sorry, something went wrong. Please, try again or look for different method.${NO_COLOR}"
            echo -e "${RED_TXT}Note: we backed up your $workspace/src for you at $HOME/tmp${NO_COLOR}"
        fi
                
        ;;
        n)
        read -p "Please, insert the full path to the workspace including the workspace name: " path_dir_ws
        if [[ $path_dir_ws != /* ]]; then
            path_dir_ws="/"$path_dir_ws
        fi
        echo -e "${WHITE_TXT}\nIs this: $path_dir_ws the correct path to the workspace? <y/n> ${NO_COLOR}\c"
        read -n 2 path2

        case $path2 in
            y)
            
            echo -e "${WHITE_TXT}Starts making the necessary changes and installations...${NO_COLOR}"
            sudo apt-get -y update
            #sudo apt-get -y upgrade
            mkdir $HOME/tmp
            rm -rf $path_dir_ws/src/CMakeLists.txt
            cp -TR $path_dir_ws/src $HOME/tmp
            rm -rf $path_dir_ws
            mkdir -p $path_dir_ws/src
            sudo apt-get -y install python3-empy  
            sudo apt-get -y install python3-catkin-pkg-modules
            sudo apt-get -y install python3-rospkg-modules
            cd $path_dir_ws/
            catkin_make -DPYTHON_EXECUTABLE=/usr/bin/python3
            cp -TR $HOME/tmp $path_dir_ws/src
            catkin_make
            if [ $? -eq 0 ]; then
                echo -e "${GREEN_TXT}\nDone, $path_dir_ws is compatible for python3 alongside python2.${NO_COLOR}\n"
                rm -rf $HOME/tmp
            else
                echo -e "\n${RED_TXT}Error occurred. Sorry, something went wrong. Please, try again or look for different method.${NO_COLOR}"
                echo -e "${RED_TXT}Note: we backed up your $path_dir_ws/src for you at $HOME/tmp${NO_COLOR}"
            fi

            ;;

            n)

            echo -e "${RED_TXT}Error occurred, could not find the path $path_dir_ws, please try again or look for different method${NO_COLOR}"
            ;;
            *)

            echo -e "${RED_TXT}\nSorry, invalid input. Please try again${NO_COLOR}"
            cd $DIR
            ./ros-workspace_py2-alongside-py3.sh
            
        esac

        ;;
        *)

        echo -e "${RED_TXT}\nSorry, invalid input. Please try again${NO_COLOR}"
        cd $DIR
        ./ros-workspace_py2-alongside-py3.sh
        ;;

    esac

else
    echo -e "\n${RED_TXT}Error occurred, could not find path to. Please try again $workspace.${NO_COLOR}"
    cd $DIR
    ./ros-workspace_py2-alongside-py3.sh
fi
cd $P
exit 0
