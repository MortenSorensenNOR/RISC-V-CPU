#pragma once
#include <vector>
#include <deque>
#include <verilated.h>
#include "Signal.h"

#define SPI_WRITE_BUFFER_SIZE 1024

class SPI_Master {
private:
    enum class SPI_STATE {
        IDLE,
        WRITING,
        DONE
    };
    SPI_STATE state = SPI_STATE::IDLE;

    std::deque<char> write_buffer;

public:
    SPI_Master() {
        write_buffer.resize(0);
    }

    void transfer(char data) {
        write_buffer.push_back(data);
    }

    int finished() {
        return write_buffer.empty() && state == SPI_STATE::IDLE;
    }

    void update(int clk, int& SCK, int& CSn, int& MOSI, int& MISO) {
        static int write_bit_count = 0;

        switch (state) {
            case SPI_STATE::IDLE:
                SCK = 0;
                CSn = 1;
                if (!write_buffer.empty()) {
                    state = SPI_STATE::WRITING;
                    CSn   = 0;

                    char current_byte = write_buffer.front();
                    bool bit = current_byte & (1 << (7 - write_bit_count));
                    MOSI = bit;
                    write_bit_count++;
                }
                break;

            case SPI_STATE::WRITING: {
                CSn = 0;
                SCK ^= 1;

                if (SCK == 0) {
                    char current_byte = write_buffer.front();
                    bool bit = current_byte & (1 << (7 - write_bit_count));
                    MOSI = bit;
                    write_bit_count++;

                } else if (SCK == 1) {
                    if (write_bit_count == 8) {
                        write_bit_count = 0;
                        write_buffer.pop_front();
                        state = SPI_STATE::DONE;
                    }
                }

                break;
            }

            case SPI_STATE::DONE: {
                static int wait_done_cycles = 0;

                MOSI = 0;
                SCK  = 0;

                if (wait_done_cycles++ == 2) {
                    state = SPI_STATE::IDLE;
                    wait_done_cycles = 0;
                }
                break;
            }
        }

    }

private:
};
