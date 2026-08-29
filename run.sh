#!/usr/bin/env bash

clear

read -r -p "Do you want to build DestByte8? (yes/no): " answer

case "$answer" in
    yes|y|YES|Y)
        echo "Building DestByte8 data memory test with Verilator..."

verilator --cc --exe --build --public-flat-rw \
    --top-module top \
    rtl/top.v \
    rtl/pc.v \
    rtl/pc_next.v \
    rtl/decoder.v \
    alu/alu.v \
    rom/rom.v \
    memory/registers_memory.v \
    memory/data_memory.v \
    sim/sim_main.cpp

        if [[ $? -ne 0 ]]; then
            echo "Build failed."
            exit 1
        fi

        echo "Build completed successfully."

        read -r -p "Do you want to run the memory test? (yes/no): " run_answer

        case "$run_answer" in
            yes|y|YES|Y)
                echo "Starting data memory test..."

                if [[ ! -x "./obj_dir/Vtop" ]]; then
                    echo "Error: ./obj_dir/Vtop was not found."
                    exit 1
                fi

                ./obj_dir/Vtop
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
