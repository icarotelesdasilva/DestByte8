#!/usr/bin/env bash

clear

read -r -p "Do you want to build DestByte8 memory test? (yes/no): " answer

case "$answer" in
    yes|y|YES|Y)
        echo "Building DestByte8 data memory test with Verilator..."

        verilator --binary \
            --timing \
            -Wall \
            -Wno-fatal \
            -Wno-BLKSEQ \
            -O3 \
            --x-assign fast \
            --x-initial fast \
            --top-module tb_memory \
            -Mdir ./obj_dir_memory \
            ./memory/data_memory.v \
            ./sim/tb_memory.v

        if [[ $? -ne 0 ]]; then
            echo "Build failed."
            exit 1
        fi

        echo "Build completed successfully."

        read -r -p "Do you want to run the memory test? (yes/no): " run_answer

        case "$run_answer" in
            yes|y|YES|Y)
                echo "Starting data memory test..."

                if [[ ! -x "./obj_dir_memory/Vtb_memory" ]]; then
                    echo "Error: ./obj_dir_memory/Vtb_memory was not found."
                    exit 1
                fi

                ./obj_dir_memory/Vtb_memory
                ;;

            no|n|NO|N)
                echo "Memory test was not started."
                ;;

            *)
                echo "Invalid input. Please answer yes or no."
                exit 1
                ;;
        esac
        ;;

    no|n|NO|N)
        echo "Build cancelled."
        exit 0
        ;;

    *)
        echo "Invalid input. Please answer yes or no."
        exit 1
        ;;
esac
