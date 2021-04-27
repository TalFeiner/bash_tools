#!/bin/bash

PS3='Terminator options: '
options=("default" "Split 1" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "default")
            config=default
            break
            ;;
        "Split 1")
            config=config-1
            break
            ;;
        *)
            exit
            ;;
    esac
done

cd ~/.config/terminator
cp config config
cp $config config
cd
terminator &
