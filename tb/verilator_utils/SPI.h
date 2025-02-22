#pragma once
#include <iterator>
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
};

class SPI_Slave {
private:
    enum class SPI_STATE {
        IDLE,
        READING
    };
    SPI_STATE state = SPI_STATE::IDLE;
    SPI_STATE next_state = SPI_STATE::IDLE;

    Signal<int> SCK_s;
    Signal<int> CSn_s;

    std::deque<char> read_buffer;

public:
    SPI_Slave() : SCK_s(0), CSn_s(1) {
        read_buffer.resize(0);
    }

    int get_char(char& c) {
        if (read_buffer.empty())
            return 0;
        c = read_buffer.front();
        read_buffer.pop_front();
        return 1;
    }

    void update(int SCK, int CSn, int MOSI) {
        static char RX_Byte;
        static int  read_bit_count = 0;

        // Update signals
        SCK_s.update(SCK);
        CSn_s.update(CSn);

        // Update state
        state = next_state;

        switch (state) {
            case SPI_STATE::IDLE:
                if (CSn_s.negedge())
                    next_state = SPI_STATE::READING;
                break;

            case SPI_STATE::READING: {
                if (CSn_s.posedge()) {
                    read_bit_count = 0;
                    next_state = SPI_STATE::IDLE;
                } else {
                    if (SCK_s.posedge()) {
                        RX_Byte = (RX_Byte << 1) | (MOSI & 1);
                        read_bit_count++;

                        if (read_bit_count == 8) {
                            read_buffer.push_back(RX_Byte);
                            read_bit_count = 0;
                        }
                    }
                }
                break;
            }
        }

    }
};
