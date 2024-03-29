#!/bin/bash

[ "$BASH_SOURCE" != "$0" ] &&
    echo "This file meant to be executed, like that: ./<file_name>" &&
        return 88


GREEN_TXT='\e[0;32m'
WHITE_TXT='\e[1;37m'
RED_TXT='\e[31m'
NO_COLOR='\033[0m'

NVIDIA_VERSOIN=410
CUDA_VERSOIN=10.0
CUDNN_VERSOIN=7.6.0
CUDA_FILE=cuda_10.0.130_410.48_linux.run
CUDNN_FILE=cudnn-10.0-linux-x64-v7.6.0.64.tgz
CUDA_URL=https://developer.nvidia.com/compute/cuda/10.0/Prod/local_installers/cuda_10.0.130_410.48_linux.run
CUDNN_URL=https://developer.nvidia.com/compute/machine-learning/cudnn/secure/v7.6.0.64/prod/10.0_20190516/cudnn-10.0-linux-x64-v7.6.0.64.tgz
FILE_NAME=$(readlink -f "${BASH_SOURCE[0]}")
FILE_NAME=${FILE_NAME// .//}


reboot_func(){
    echo -e "\n${WHITE_TXT}Reboot is required would you like to reboot now? <y/n>${NO_COLOR}\c"

    read reboot

    case $reboot in
        y)
        reboot
        ;;
        n)
        echo -e "\n${RED_TXT}Please, reboot now${NO_COLOR}"
        exit 0
        ;;
        *)
        echo -e "${WHITE_TXT}Invalid input.${NO_COLOR}"
        echo -e "\n${RED_TXT}Please, reboot now${NO_COLOR}"
        exit 0
    esac
}


nvidia_driver_installation(){
    echo -e "${WHITE_TXT}Nvidia driver ${NVIDIA_VERSOIN} installation${NO_COLOR}"
    cd $HOME
    echo -e "\n${WHITE_TXT}Ethernet connection is required${NO_COLOR}"
    echo -e "\n${RED_TXT}First step uninstall cuda, please uninstall all the option that going to appear!${NO_COLOR}"
    echo -e "${WHITE_TXT}Press any key to continue${NO_COLOR}"
    while [ true ] ; do
        read -t 10 -n 1
        if [ $? = 0 ] ; then
            break ;
        else
            echo -e "${WHITE_TXT}waiting for the keypress${NO_COLOR}"
        fi
    done
    sudo /usr/local/cuda/bin/cuda-uninstaller
    cd /usr/local
    sudo rm -rf *cuda*
    cd $HOME
    sudo rm -rf *NVIDIA_CUDA-*_Samples*
    sudo apt -y purge *cudnn*
    sudo apt -y purge *cuda*
    sudo apt -y purge *nvidia*
    sudo add-apt-repository --remove ppa:graphics-drivers/ppa
    cd /etc/apt/sources.list.d
    sudo rm *graphic*
    sudo rm *nvidia*
    sudo rm *cuda*
    sudo rm *cudnn*
    cd $HOME
    sudo apt -y autoremove
    sudo apt -y autoclean
    cd /var/cache/apt/archives
    sudo rm -rf *nvidia*
    sudo rm -rf *cuda*
    sudo rm -rf *cudnn*
    sudo rm *nvidia*
    sudo rm *cuda*
    sudo rm *cudnn*
    cd $HOME
    cd /etc/modprobe.d
    sudo rm *nouveau*
    cd $HOME
    sudo apt update

    sudo update-initramfs -u

    sudo apt -y install nvidia-driver-${NVIDIA_VERSOIN} --fix-missing --fix-broken
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN_TXT}nvidia-driver-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
    else
        sudo apt -y install nvidia-graphics-driver-${NVIDIA_VERSOIN} --fix-missing --fix-broken
        if [ $? -eq 0 ]; then
            echo -e "\n${GREEN_TXT}nvidia-graphics-driver-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
        else
            sudo apt -y install nvidia-${NVIDIA_VERSOIN} --fix-missing --fix-broken
            if [ $? -eq 0 ]; then
                echo -e "\n${GREEN_TXT}nvidia-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
            else
                sudo add-apt-repository ppa:graphics-drivers/ppa
                sudo apt-get update
                sudo apt -y install nvidia-driver-${NVIDIA_VERSOIN} --fix-missing --fix-broken
                if [ $? -eq 0 ]; then
                    echo -e "\n${GREEN_TXT}nvidia-driver-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
                else
                    sudo apt -y install nvidia-graphics-driver-${NVIDIA_VERSOIN} --fix-missing --fix-broken
                    if [ $? -eq 0 ]; then
                        echo -e "\n${GREEN_TXT}nvidia-graphics-driver-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
                    else
                        sudo apt -y install nvidia-${NVIDIA_VERSOIN} --fix-missing --fix-broken
                        if [ $? -eq 0 ]; then
                            echo -e "\n${GREEN_TXT}nvidia-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
                        else
                            cat /etc/apt/sources.list | egrep -m 1 "^deb http://archive.ubuntu.com/ubuntu"
                            if [ $? -eq 0 ]; then
                                echo -e "\n${RED_TXT}Couldn't find Nvidia driver ${NVIDIA_VERSOIN} installation for you, please try different installation.${NO_COLOR}"
                                exit 1
                            else
                                sudo cp /etc/apt/sources.list /etc/apt/sources.list.tmp
                                del=`cat /etc/apt/sources.list | egrep -m 1 "^deb http://"`
                                del=${del##*deb http://}
                                del=${del%%/*}
                                sudo sed -i 's|^deb http://'${del}'|deb http://archive.ubuntu.com|g' /etc/apt/sources.list
                                sudo apt update
                                sudo apt -y install nvidia-driver-${NVIDIA_VERSOIN} --fix-missing --fix-broken
                                if [ $? -eq 0 ]; then
                                    sudo cp /etc/apt/sources.list.tmp /etc/apt/sources.list
                                    sudo rm /etc/apt/sources.list.tmp
                                    echo -e "\n${GREEN_TXT}nvidia-driver-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
                                else
                                    sudo apt -y install nvidia-graphics-driver-${NVIDIA_VERSOIN} --fix-missing --fix-broken
                                    if [ $? -eq 0 ]; then
                                        sudo cp /etc/apt/sources.list.tmp /etc/apt/sources.list
                                        sudo rm /etc/apt/sources.list.tmp
                                        echo -e "\n${GREEN_TXT}nvidia-graphics-driver-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
                                    else
                                        sudo apt -y install nvidia-${NVIDIA_VERSOIN} --fix-missing --fix-broken
                                        if [ $? -eq 0 ]; then
                                            sudo cp /etc/apt/sources.list.tmp /etc/apt/sources.list
                                            sudo rm /etc/apt/sources.list.tmp
                                            echo -e "\n${GREEN_TXT}nvidia-${NVIDIA_VERSOIN} installation is done${NO_COLOR}"
                                        else
                                            # sudo cp /etc/apt/sources.list /etc/apt/sources.list.main_server.bak
                                            sudo cp /etc/apt/sources.list.tmp /etc/apt/sources.list
                                            sudo rm /etc/apt/sources.list.tmp
                                            echo -e "\n${RED_TXT}Nvidia ${NVIDIA_VERSOIN} driver, installation failed.${NO_COLOR}"
                                            echo -e "\n${RED_TXT}Please go to \"Software & Updates\" then change the \"Download from:\" to \"Main server\" different server of your choice, click Close then click reload. and try to run this file once more.${NO_COLOR}"
                                            echo -e "${RED_TXT}For better detailed explanation look at the attached link below:${NO_COLOR}"
                                            echo -e "${RED_TXT}https://askubuntu.com/a/1229972${NO_COLOR}"
                                            echo -e "\n${RED_TXT}If the \"Download from:\" is already on the \"Main server\" or you already tried changing it, most likely this file can't help you. Try different installation.${NO_COLOR}"
                                            exit 1
                                        fi
                                    fi
                                fi
                            fi
                        fi
                    fi
                fi
            fi
        fi
    fi
}


cuda_installation(){
    echo -e "\n${WHITE_TXT}cuda ${CUDA_VERSOIN} installation${NO_COLOR}"
    if [ ! -x /$(dirname "${FILE_NAME:1}")/$(basename "${FILE_NAME}") ]; then
        chmod a+x /$(dirname "${FILE_NAME:1}")/$(basename "${FILE_NAME}")
    fi
    echo -e "\n${WHITE_TXT}If you don't have cuda run file (${CUDA_FILE}) Ethernet connection is required${NO_COLOR}"
    echo -e "\n${RED_TXT}Please, go to tty by pressing Ctrl+Alt+F3/F2/F1\nThen use the command:${NO_COLOR}"

    echo -e "${WHITE_TXT}cd /$(dirname "${FILE_NAME:1}")\n./$(basename "${FILE_NAME}")${NO_COLOR}"
    echo -e "${WHITE_TXT}To run this file once more from the tty.${NO_COLOR}"
    echo -e "${RED_TXT}You can proceed without opening tty, but it's NOT recommended!${NO_COLOR}"
    echo -e "${WHITE_TXT}Are you in the tty? <y/n> ${NO_COLOR}\c"

    read tty

    case $tty in
        y)
        echo -e "${WHITE_TXT}Great let's start${NO_COLOR}"
        ;;
        n)
        echo -e "\n${WHITE_TXT}Please, go to tty.${NO_COLOR}"
        echo -e "${RED_TXT}Or proceed but it's NOT recommended!${NO_COLOR}"
        echo -e "${WHITE_TXT}\nPress any key to continue or Ctrl+c to exit${NO_COLOR}"
        while [ true ] ; do
            read -t 10 -n 1
            if [ $? = 0 ] ; then
                break ;
            else
                echo -e "${WHITE_TXT}waiting for the keypress${NO_COLOR}"
            fi
        done
        ;;
        *)
        echo -e "\n${WHITE_TXT}Sorry, invalid input please try again${NO_COLOR}"
        exit 1
    esac
    cd $HOME
    Fcuda=`sudo find  | egrep -m 1 ${CUDA_FILE}`
    if [ $? -eq 0 ]; then
        Fcuda=(${Fcuda// .// })
        echo -e "\n${WHITE_TXT}You already have cuda run file no need to download!${NO_COLOR}"
    else
        echo -e "\n${WHITE_TXT}Downloading cuda run file${NO_COLOR}"
        cd $HOME/Downloads
        wget ${CUDA_URL}
        cd $HOME
    fi

    sudo apt -y purge nvidia-cuda*
    sudo apt -y autoremove
    sudo apt -y autoclean
    echo -e "blacklist nouveau\noptions nouveau modeset=0" | sudo tee /etc/modprobe.d/blacklist-nouveau.conf

    sudo update-initramfs -u

    case $tty in
        y)
        echo -e "${WHITE_TXT}Your screen might turn black or you might see weird stuff on your screen, that's fine. Just try to go back to the tty by pressing Ctrl+Alt+F3/F2/F1 and proceed to follow the instruction normally.${NO_COLOR}"
        echo -e "${WHITE_TXT}Press any key to continue${NO_COLOR}"
        while [ true ] ; do
            read -t 10 -n 1
            if [ $? = 0 ] ; then
                break ;
            else
                echo -e "${WHITE_TXT}waiting for the keypress${NO_COLOR}"
            fi
        done

        sudo service gdm stop
        if [ $? -eq 0 ]; then
            echo -e "\n${WHITE_TXT}gdm service have been found${NO_COLOR}"
        else
            echo -e "${WHITE_TXT}An error occurred, couldn't find gdm service looking for gdm3 service instead${NO_COLOR}"
            sudo service gdm3 stop
            if [ $? -eq 0 ]; then
                echo -e "${WHITE_TXT}gdm3 service have been found${NO_COLOR}"
            else
                echo -e "${WHITE_TXT}An error occurred, couldn't find gdm3 service looking for lightdm service instead${NO_COLOR}"
                sudo service lightdm stop
                if [ $? -eq 0 ]; then
                    echo -e "${WHITE_TXT}lightdm service have been found${NO_COLOR}"
                else
                    echo -e "\n${RED_TXT}An error occurred, couldn't find lightdm service. You need to find which service are you using instead of lightdm gdm3 gdm${NO_COLOR}"
                    exit 1
                fi
            fi
        fi
        ;;
    esac

    echo -e "\n${RED_TXT}Follow the terminal instructions\n  PLEASE NOTE:\n  1) Make sure that you say y for the cuda installation, for cuda Samples and for the symbolic link\n  2) Do not install anything else${NO_COLOR}"
    echo -e "${WHITE_TXT}\nPress any key to continue${NO_COLOR}"
    while [ true ] ; do
        read -t 10 -n 1
        if [ $? = 0 ] ; then
            break ;
        else
            echo -e "${WHITE_TXT}waiting for the keypress${NO_COLOR}"
        fi
    done

    echo -e "\n${WHITE_TXT}Third-party Libraries Installation${NO_COLOR}"
    sudo apt-get -y install g++ freeglut3-dev build-essential libx11-dev libxmu-dev libxi-dev libglu1-mesa libglu1-mesa-dev  --fix-missing --fix-broken
    cd $HOME
    Fcuda=`sudo find  | egrep -m 1 ${CUDA_FILE}`
    if [ $? -eq 0 ]; then
        Fcuda=(${Fcuda// .// })
        cd $HOME
        cd $(dirname "${Fcuda:2}")
        sudo sh ${CUDA_FILE} --override
        if [ $? -eq 0 ]; then
            cd $HOME
            grep -qxF '# >>> set PATH for cuda '${CUDA_VERSOIN}' installation >>>' .bashrc || echo -e '\n# >>> set PATH for cuda '${CUDA_VERSOIN}' installation >>>' >> .bashrc
            grep -qxF 'export PATH=/usr/local/cuda-'${CUDA_VERSOIN}'/bin${PATH:+:${PATH}}' .bashrc || echo -e 'export PATH=/usr/local/cuda-'${CUDA_VERSOIN}'/bin${PATH:+:${PATH}}' >> .bashrc
            grep -qxF 'export LD_LIBRARY_PATH=/usr/local/cuda-'${CUDA_VERSOIN}'/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' .bashrc || echo -e 'export LD_LIBRARY_PATH=/usr/local/cuda-'${CUDA_VERSOIN}'/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}' >> .bashrc
            grep -qxF 'export CPATH=$CPATH:$HOME/NVIDIA_CUDA-'${CUDA_VERSOIN}'_Samples/common/inc' .bashrc || echo -e 'export CPATH=$CPATH:$HOME/NVIDIA_CUDA-'${CUDA_VERSOIN}'_Samples/common/inc' >> .bashrc
            grep -qxF '# <<< cuda '${CUDA_VERSOIN}' <<<' .bashrc || echo -e '# <<< cuda <<<' >> .bashrc

            echo -e "\n${GREEN_TXT}cuda ${CUDA_VERSOIN} installation is done${NO_COLOR}"
            echo -e "${GREEN_TXT}You can try to compile and run cuda samples to check if everything installed as expected. In new regular terminal run:${NO_COLOR}"
            echo -e "${GREEN_TXT}cd ~/NVIDIA_CUDA-${CUDA_VERSOIN}_Samples/5_Simulations/nbody${NO_COLOR}"
            echo -e "${GREEN_TXT}make${NO_COLOR}"
            echo -e "${GREEN_TXT}./nbody${NO_COLOR}"
        else
            echo -e "\n${RED_TXT}An error occurred, cuda ${CUDA_VERSOIN} installation failed.${NO_COLOR}"
        fi
    else
        echo -e "\n${RED_TXT}An error occurred, Couldn't find the right path to ${CUDA_FILE}.${NO_COLOR}"
        echo -e "\n${WHITE_TXT}You could try to find the right path to ${CUDA_FILE}, then go to the file location and run it with:${NO_COLOR}"
        echo -e "${WHITE_TXT}$ sudo sh ${CUDA_FILE} --override${NO_COLOR}"
        case $tty in
        y)
            sudo service gdm start
            if [ $? -eq 0 ]; then
                echo -e "\n${WHITE_TXT}gdm service have been found${NO_COLOR}"
            else
                echo -e "${WHITE_TXT}An error occurred, couldn't find gdm service looking for gdm3 service instead${NO_COLOR}"
                sudo service gdm3 start
                if [ $? -eq 0 ]; then
                    echo -e "${WHITE_TXT}gdm3 service have been found${NO_COLOR}"
                else
                    echo -e "${WHITE_TXT}An error occurred, couldn't find gdm3 service looking for lightdm service instead${NO_COLOR}"
                    sudo service lightdm start
                    if [ $? -eq 0 ]; then
                        echo -e "${WHITE_TXT}lightdm service have been found${NO_COLOR}"
                    else
                        echo -e "\n${RED_TXT}An error occurred, couldn't find lightdm service. You need to find which service are you using instead of lightdm gdm3 gdm${NO_COLOR}"
                        exit 1
                    fi
                fi
            fi
            ;;
        esac
        exit 0
    fi
}


cudnn_installation(){
    echo -e "\n${WHITE_TXT}cudnn ${CUDNN_VERSOIN} installation${NO_COLOR}"
    cd $HOME
    Fcudnn=`sudo find  | egrep -m 1 ${CUDNN_FILE}`
    if [ $? -eq 0 ]; then
        Fcudnn=(${Fcudnn// .// })
        echo -e "\n${WHITE_TXT}Starts cudnn installation!${NO_COLOR}"
    else
        echo -e "\n${RED_TXT}Couldn't find cudnn installation files.${NO_COLOR}"
        echo -e "${WHITE_TXT}Please make sure you have the correct file (${CUDNN_FILE}) then try to install cudnn once more.${NO_COLOR}"
        echo -e "${WHITE_TXT}You may use the attached link below:${NO_COLOR}"
        echo -e "${WHITE_TXT}${CUDNN_URL}${NO_COLOR}"
        exit 1
    fi
    cd $HOME$(dirname "${Fcudnn:1}")
    tar -xzf $(basename "${Fcudnn}")
    cd cuda
    sudo cp -P include/cudnn.h /usr/include
    sudo cp -P lib64/libcudnn* /usr/lib/x86_64-linux-gnu/
    sudo chmod a+r /usr/lib/x86_64-linux-gnu/libcudnn*

    sudo cp include/cudnn.h /usr/local/cuda/include
    sudo cp lib64/libcudnn* /usr/local/cuda/lib64
    sudo chmod a+r /usr/local/cuda/lib64/libcudnn*

    cat /usr/local/cuda/include/cudnn.h | grep CUDNN -A 2
    if [ $? -eq 0 ]; then
        echo -e "\n${GREEN_TXT}cudnn ${CUDNN_VERSOIN} installation is done${NO_COLOR}"
    else
        echo -e "\n${RED_TXT}An error occurred, couldn't install cudnn ${CUDNN_VERSOIN}. You could try to install cudnn manually::${NO_COLOR}"
        echo -e "${WHITE_TXT}cd $HOME$(dirname "${Fcudnn:1}")${NO_COLOR}"
        echo -e "${WHITE_TXT}tar -xzf $(basename "${Fcudnn}")${NO_COLOR}"
        echo -e "${WHITE_TXT}cd cuda${NO_COLOR}"
        echo -e "${WHITE_TXT}sudo cp -P include/cudnn.h /usr/include${NO_COLOR}"
        echo -e "${WHITE_TXT}sudo cp -P lib64/libcudnn* /usr/lib/x86_64-linux-gnu/${NO_COLOR}"
        echo -e "${WHITE_TXT}sudo chmod a+r /usr/lib/x86_64-linux-gnu/libcudnn*${NO_COLOR}"

        echo -e "${WHITE_TXT}sudo cp include/cudnn.h /usr/local/cuda/include${NO_COLOR}"
        echo -e "${WHITE_TXT}sudo cp lib64/libcudnn* /usr/local/cuda/lib64${NO_COLOR}"
        echo -e "${WHITE_TXT}sudo chmod a+r /usr/local/cuda/lib64/libcudnn*${NO_COLOR}"

        echo -e "\n${WHITE_TXT}Check cudnn installation with:${NO_COLOR}"
        echo -e "${WHITE_TXT}cat /usr/local/cuda/include/cudnn.h | grep CUDNN -A 2${NO_COLOR}"
    fi
}


ubuntuV=`lsb_release -rs`
ubuntuV=${ubuntuV/.*}
if [  "$ubuntuV" -ne 18  ]; then
    if [  "$ubuntuV" -ne 20  ]; then
        if [  "$ubuntuV" -ne 16  ]; then
            echo -e "${RED_TXT}Sorry, your ubuntu version ($ubuntuV) is not supported. you can proceed but it's NOT recommended!${NO_COLOR}"
        fi
    fi
fi

echo -e "\n${WHITE_TXT}Hi, what would you like to install?\n  press (1) for Nvidia driver ${NVIDIA_VERSOIN},\n  press (2) for cuda ${CUDA_VERSOIN},\n  press (3) for cudnn ${CUDNN_VERSOIN},\n  press (4) for all of them at once,\nwhat is your choice? <1/2/3/4> ${NO_COLOR}\c"

read install

case $install in
    1)
    nvidia_driver_installation
    reboot_func
    exit 0
	;;
    2)
    cuda_installation
    reboot_func
    case $tty in
        y)
        sudo service gdm start
        if [ $? -eq 0 ]; then
            echo -e "\n${WHITE_TXT}gdm service have been found${NO_COLOR}"
        else
            echo -e "${WHITE_TXT}An error occurred, couldn't find gdm service looking for gdm3 service instead${NO_COLOR}"
            sudo service gdm3 start
            if [ $? -eq 0 ]; then
                echo -e "${WHITE_TXT}gdm3 service have been found${NO_COLOR}"
            else
                echo -e "${WHITE_TXT}An error occurred, couldn't find gdm3 service looking for lightdm service instead${NO_COLOR}"
                sudo service lightdm start
                if [ $? -eq 0 ]; then
                    echo -e "${WHITE_TXT}lightdm service have been found${NO_COLOR}"
                else
                    echo -e "\n${RED_TXT}An error occurred, couldn't find lightdm service. You need to find which service are you using instead of lightdm gdm3 gdm${NO_COLOR}"
                    exit 1
                fi
            fi
        fi
        ;;
    esac
    exit 0
    ;;
    3)
    cudnn_installation
    exit 0
    ;;
    4)
    echo -e "\n${WHITE_TXT}Good luck with it!${NO_COLOR}"
    ;;
    *)
    echo -e "\n${WHITE_TXT}Sorry, invalid input please try again${NO_COLOR}"
    exit 1
esac

if [ ! -x /$(dirname "${FILE_NAME:1}")/$(basename "${FILE_NAME}") ]; then
    chmod a+x /$(dirname "${FILE_NAME:1}")/$(basename "${FILE_NAME}")
fi

echo -e "\n${WHITE_TXT}Ethernet connection is required${NO_COLOR}"
echo -e "\n${RED_TXT}Please, go to tty by pressing Ctrl+Alt+F3/F2/F1\nThen use the command:${NO_COLOR}"

echo -e "${WHITE_TXT}cd /$(dirname "${FILE_NAME:1}")\n./$(basename "${FILE_NAME}")${NO_COLOR}"
echo -e "${WHITE_TXT}To run this file once more from the tty.${NO_COLOR}"
echo -e "${RED_TXT}You can proceed without opening tty, but it's NOT recommended!${NO_COLOR}"
echo -e "${WHITE_TXT}\nPress any key to continue or Ctrl+c to exit${NO_COLOR}"
while [ true ] ; do
    read -t 10 -n 1
    if [ $? = 0 ] ; then
        break ;
    else
        echo -e "${WHITE_TXT}waiting for the keypress${NO_COLOR}"
    fi
done

nvidia_driver_installation
cuda_installation
cudnn_installation

cd $HOME
echo -e "\n${GREEN_TXT}You can try to compile and run cuda samples to check if everything installed as expected. In new regular terminal run:${NO_COLOR}"
echo -e "${GREEN_TXT}cd ~/NVIDIA_CUDA-${CUDA_VERSOIN}_Samples/5_Simulations/nbody${NO_COLOR}"
echo -e "${GREEN_TXT}make${NO_COLOR}"
echo -e "${GREEN_TXT}./nbody${NO_COLOR}"

reboot_func

case $tty in
y)
    sudo service gdm start
    if [ $? -eq 0 ]; then
        echo -e "\n${WHITE_TXT}gdm service have been found${NO_COLOR}"
    else
        echo -e "${WHITE_TXT}An error occurred, couldn't find gdm service looking for gdm3 service instead${NO_COLOR}"
        sudo service gdm3 start
        if [ $? -eq 0 ]; then
            echo -e "${WHITE_TXT}gdm3 service have been found${NO_COLOR}"
        else
            echo -e "${WHITE_TXT}An error occurred, couldn't find gdm3 service looking for lightdm service instead${NO_COLOR}"
            sudo service lightdm start
            if [ $? -eq 0 ]; then
                echo -e "${WHITE_TXT}lightdm service have been found${NO_COLOR}"
            else
                echo -e "\n${RED_TXT}An error occurred, couldn't find lightdm service. You need to find which service are you using instead of lightdm gdm3 gdm${NO_COLOR}"
                exit 1
            fi
        fi
    fi
    ;;
esac

echo -e "Good luck! And my the gods be with you it might help :)"
exit 0
