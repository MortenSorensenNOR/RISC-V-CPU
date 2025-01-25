#pragma once

template <typename T>
class Signal {
private:
    T prev_val;
    T new_val;

public:
    Signal(T initial_val) {
        prev_val = initial_val;
        new_val = initial_val;
    }

    void update(T val) {
        prev_val = new_val;
        new_val = val;
    }

    bool posedge() {
        if (prev_val < new_val) {
            return true;
        } 
        return false;
    }

    bool negedge() {
        if (prev_val > new_val) {
            return true;
        } 
        return false;
    }
};

