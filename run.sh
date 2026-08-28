#!/usr/bin/env bash

clear

read -r -p "Do you want to build DestByte8? (yes/no): " answer

case "$answer" in
    yes|y|YES|Y)
        echo "Building DestByte8 with Verilator..."

        verilator --binary \
            --trace --trace-structs \
            --timing \
            -Wall \
            -Wno-fatal \
            -O3 \
            --x-assign fast \
            --x-initial fast \
            --top-module tb_test \
            -Mdir ./obj_dir \
            ./rtl/top.v \
            ./rtl/pc_next.v \
            ./rtl/decoder.v \
            ./rtl/pc.v \
            ./alu/alu.v \
            ./memory/registers_memory.v \
            ./rom/rom.v \
            ./sim/tb.v

        if [[ $? -ne 0 ]]; then
            echo "Build failed."
            exit 1
        fi

        echo "Build completed successfully."

        read -r -p "Do you want to run DestByte8? (yes/no): " run_answer

        case "$run_answer" in
            yes|y|YES|Y)
                echo "Starting DestByte8..."

                if [[ ! -x "./obj_dir/Vtb_test" ]]; then
                    echo "Error: ./obj_dir/Vtb_test was not found."
                    exit 1
                fi

                ./obj_dir/Vtb_test
                ;;

            no|n|NO|N)
                echo "DestByte8 was not started."
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
