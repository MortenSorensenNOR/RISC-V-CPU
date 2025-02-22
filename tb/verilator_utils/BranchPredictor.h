#pragma once

#include <stdio.h>
#include <cstdint>
#include <cassert>
#include <math.h>
#include <vector>

class BranchPredictor {
private:
    int N;
    int TableSize;
    std::vector<char> table;

    int TableBits;

public:
    BranchPredictor(int table_entry_bits, int table_size) {
        N = table_entry_bits;
        TableSize = table_size;
        table.resize(TableSize, (1 << N) - 1);

        TableBits = std::log2(TableSize);
        assert((1 << TableBits) == TableSize && "Table size is not a power of 2");
    }

    void Update(uint32_t ex_pc, bool ex_branch_decision, bool ex_branch_update) {
        if (ex_branch_update) {
            // ex_pc[TableBits+1:2]
            uint32_t update_table_index = (ex_pc >> 2) & ((1 << TableBits)-1);
            char update_table_entry = table[update_table_index];

            if (ex_branch_decision == 1 && update_table_entry != (1 << N)-1) {
                table[update_table_index] = update_table_entry+1;
            } else if (ex_branch_decision == 0 && update_table_entry != 0) {
                table[update_table_index] = update_table_entry-1;
            }
        }
    }

    bool Predict(uint32_t id_pc) {
        // id_pc[N+1:2]
        uint32_t query_table_index = (id_pc >> 2) & ((1 << TableBits)-1);
        char query_table_entry = table[query_table_index];

        bool predict_taken = query_table_entry > (1 << (N - 1));
        // printf("Predict: pc: 0x%04x -> %s(%d)\n", id_pc, predict_taken ? "taken" : "not taken", query_table_entry);

        // table[index] > 2^{N-1}
        return query_table_entry > (1 << (N - 1));
    }
};
