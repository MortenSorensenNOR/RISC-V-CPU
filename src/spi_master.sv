///////////////////////////////////////////////////////////////////////////////
// Description: SPI (Serial Peripheral Interface) Master
//              With single chip-select (AKA Slave Select) capability
//
//              Supports arbitrary length byte transfers.
//
//              Instantiates a SPI Master and adds single CS.
//              If multiple CS signals are needed, will need to use different
//              module, OR multiplex the CS from this at a higher level.
//
// Note:        clk must be at least 2x faster than i_SPI_Clk
//
// Parameters:  SPI_MODE, can be 0, 1, 2, or 3.  See above.
//              Can be configured in one of 4 modes:
//              Mode | Clock Polarity (CPOL/CKP) | Clock Phase (CPHA)
//               0   |             0             |        0
//               1   |             0             |        1
//               2   |             1             |        0
//               3   |             1             |        1
//
//              CLKS_PER_HALF_BIT - Sets frequency of o_SCK.  o_SCK is
//              derived from clk.  Set to integer number of clocks for each
//              half-bit of SPI data.  E.g. 100 MHz clk, CLKS_PER_HALF_BIT = 2
//              would create o_SPI_CLK of 25 MHz.  Must be >= 2
//
//              MAX_BYTES_PER_CS - Set to the maximum number of bytes that
//              will be sent during a single CS-low pulse.
//
//              CS_INACTIVE_CLKS - Sets the amount of time in clock cycles to
//              hold the state of Chip-Selct high (inactive) before next
//              command is allowed on the line.  Useful if chip requires some
//              time when CS is high between trasnfers.
///////////////////////////////////////////////////////////////////////////////

/* verilator lint_off LITENDIAN */

module spi_master #(
    parameter unsigned SPI_MODE = 0,
    parameter unsigned CLKS_PER_HALF_BIT = 2,
    parameter unsigned MAX_BYTES_PER_CS = 2,
    parameter unsigned CS_INACTIVE_CLKS = 1
) (
    // Control/Data Signals,
    input logic rstn,     // FPGA Reset
    input logic clk,       // FPGA Clock

    // TX (MOSI) Signals
    input logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] i_TX_Count,  // # bytes per CS low
    input logic [7:0]  i_TX_Byte,       // Byte to transmit on MOSI
    input logic  i_TX_DV,         // Data Valid Pulse with i_TX_Byte
    output logic o_TX_Ready,      // Transmit Ready for next byte

    // RX (MISO) Signals
    output logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] o_RX_Count,  // Index RX byte
    output logic                                o_RX_DV,     // Data Valid pulse (1 clock cycle)
    output logic [7:0]                          o_RX_Byte,   // Byte received on MISO

    // SPI Interface
    output logic o_SCK,
    input  logic i_MISO,
    output logic o_MOSI,
    output logic o_CSn
);

    typedef enum logic [1:0] {
        IDLE,
        TRANSFER,
        CS_INACTIVE
    } state_t;

    state_t current_state = IDLE;

    logic r_CS_n;
    logic [$clog2(CS_INACTIVE_CLKS)-1:0] r_CS_Inactive_Count;
    logic [$clog2(MAX_BYTES_PER_CS+1)-1:0] r_TX_Count;
    logic w_Master_Ready;

    // Instantiate Master
    spi_master_driver #(
        .SPI_MODE(SPI_MODE),
        .CLKS_PER_HALF_BIT(CLKS_PER_HALF_BIT)
    ) spi_master_driver_inst (
        // Control/Data Signals,
        .rstn(rstn),                    // FPGA Reset
        .clk(clk),                      // FPGA Clock

        // TX (MOSI) Signals
        .i_TX_Byte(i_TX_Byte),          // Byte to transmit
        .i_TX_DV(i_TX_DV),              // Data Valid Pulse
        .o_TX_Ready(w_Master_Ready),    // Transmit Ready for Byte

        // RX (MISO) Signals
        .o_RX_DV(o_RX_DV),              // Data Valid pulse (1 clock cycle)
        .o_RX_Byte(o_RX_Byte),          // Byte received on MISO

        // SPI Interface
        .o_SCK(o_SCK),
        .i_MISO(i_MISO),
        .o_MOSI(o_MOSI)
    );


    // Purpose: Control CS line using State Machine
    always @(posedge clk) begin
        if (~rstn) begin
            current_state <= IDLE;
            r_CS_n  <= 1'b1;   // Resets to high
            r_TX_Count <= 0;
            r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
        end else begin
            case (current_state)
                IDLE: begin
                    // Start of transmission
                    if (r_CS_n & i_TX_DV) begin
                        r_TX_Count <= i_TX_Count - 1'b1;    // Register TX Count
                        r_CS_n     <= 1'b0;                 // Drive CS low
                        current_state    <= TRANSFER;             // Transfer bytes
                    end
                end

                TRANSFER: begin
                    // Wait until SPI is done transferring do next thing
                    if (w_Master_Ready) begin
                        if (r_TX_Count > 0) begin
                            if (i_TX_DV) begin
                                r_TX_Count <= r_TX_Count - 1'b1;
                            end
                        end else begin
                            r_CS_n  <= 1'b1; // we done, so set CS high
                            r_CS_Inactive_Count <= CS_INACTIVE_CLKS;
                            current_state             <= CS_INACTIVE;
                        end
                    end
                end

                CS_INACTIVE: begin
                    if (r_CS_Inactive_Count > 0) begin
                        r_CS_Inactive_Count <= r_CS_Inactive_Count - 1'b1;
                    end else begin
                        current_state <= IDLE;
                    end
                end

                default: begin
                    r_CS_n  <= 1'b1; // we done, so set CS high
                    current_state <= IDLE;
                end
            endcase
        end
    end


    // Purpose: Keep track of RX_Count
    always @(posedge clk) begin
        if (r_CS_n) begin
            o_RX_Count <= 0;
        end else if (o_RX_DV) begin
            o_RX_Count <= o_RX_Count + 1'b1;
        end
    end

    assign o_CSn = r_CS_n;
    assign o_TX_Ready  = ((current_state == IDLE) | (current_state == TRANSFER && w_Master_Ready == 1'b1 && r_TX_Count > 0)) & ~i_TX_DV;
endmodule

// SPI Master w/o CS

module spi_master_driver #(
    parameter unsigned SPI_MODE = 0,
    parameter unsigned CLKS_PER_HALF_BIT = 2
) (
    // Control/Data Signals,
    input        rstn,       // FPGA Reset
    input        clk,        // FPGA Clock

    // TX (MOSI) Signals
    input [7:0]  i_TX_Byte,        // Byte to transmit on MOSI
    input        i_TX_DV,          // Data Valid Pulse with i_TX_Byte
    output logic   o_TX_Ready,       // Transmit Ready for next byte

    // RX (MISO) Signals
    output logic       o_RX_DV,     // Data Valid pulse (1 clock cycle)
    output logic [7:0] o_RX_Byte,   // Byte received on MISO

    // SPI Interface
    output logic o_SCK,
    input      i_MISO,
    output logic o_MOSI
);

    // SPI Interface (All Runs at SPI Clock Domain)
    logic w_CPOL;     // Clock polarity
    logic w_CPHA;     // Clock phase

    logic [$clog2(CLKS_PER_HALF_BIT*2)-1:0] r_SPI_Clk_Count;
    logic r_SPI_Clk;
    logic [4:0] r_SPI_Clk_Edges;
    logic r_Leading_Edge;
    logic r_Trailing_Edge;
    logic       r_TX_DV;
    logic [7:0] r_TX_Byte;

    logic [2:0] r_RX_Bit_Count;
    logic [2:0] r_TX_Bit_Count;

    // CPOL: Clock Polarity
    // CPOL=0 means clock idles at 0, leading edge is rising edge.
    // CPOL=1 means clock idles at 1, leading edge is falling edge.
    assign w_CPOL  = (SPI_MODE == 2) | (SPI_MODE == 3);

    // CPHA: Clock Phase
    // CPHA=0 means the "out" side changes the data on trailing edge of clock
    //              the "in" side captures data on leading edge of clock
    // CPHA=1 means the "out" side changes the data on leading edge of clock
    //              the "in" side captures data on the trailing edge of clock
    assign w_CPHA  = (SPI_MODE == 1) | (SPI_MODE == 3);


    // Purpose: Generate SPI Clock correct number of times when DV pulse comes
    always @(posedge clk) begin
        if (~rstn) begin
            o_TX_Ready      <= 1'b0;
            r_SPI_Clk_Edges <= 0;
            r_Leading_Edge  <= 1'b0;
            r_Trailing_Edge <= 1'b0;
            r_SPI_Clk       <= w_CPOL; // assign default state to idle state
            r_SPI_Clk_Count <= 0;
        end else begin

            // Default assignments
            r_Leading_Edge  <= 1'b0;
            r_Trailing_Edge <= 1'b0;

            if (i_TX_DV) begin
                o_TX_Ready      <= 1'b0;
                r_SPI_Clk_Edges <= 16;  // Total # edges in one byte ALWAYS 16
            end else if (r_SPI_Clk_Edges > 0) begin
                o_TX_Ready <= 1'b0;

                if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT*2-1) begin
                    r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
                    r_Trailing_Edge <= 1'b1;
                    r_SPI_Clk_Count <= 0;
                    r_SPI_Clk       <= ~r_SPI_Clk;
                end else if (r_SPI_Clk_Count == CLKS_PER_HALF_BIT-1) begin
                    r_SPI_Clk_Edges <= r_SPI_Clk_Edges - 1'b1;
                    r_Leading_Edge  <= 1'b1;
                    r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
                    r_SPI_Clk       <= ~r_SPI_Clk;
                end else begin
                    r_SPI_Clk_Count <= r_SPI_Clk_Count + 1'b1;
                end
            end else begin
                o_TX_Ready <= 1'b1;
            end
        end // else: !if(~rstn)
    end // always @ (posedge clk or negedge rstn)


    // Purpose: Register i_TX_Byte when Data Valid is pulsed.
    // Keeps local storage of byte in case higher level module changes the data
    always @(posedge clk) begin
        if (~rstn) begin
            r_TX_Byte <= 8'h00;
            r_TX_DV   <= 1'b0;
        end else begin
            r_TX_DV <= i_TX_DV; // 1 clock cycle delay
            if (i_TX_DV) begin
                r_TX_Byte <= i_TX_Byte;
            end
        end
    end

    // Purpose: Generate MOSI data
    // Works with both CPHA=0 and CPHA=1
    always @(posedge clk) begin
        if (~rstn) begin
            o_MOSI     <= 1'b0;
            r_TX_Bit_Count <= 3'b111; // send MSb first
        end else begin
            if (o_TX_Ready) begin
                // If ready is high, reset bit counts to default
                r_TX_Bit_Count <= 3'b111;
            end else if (r_TX_DV & ~w_CPHA) begin
                // Catch the case where we start transaction and CPHA = 0
                o_MOSI     <= r_TX_Byte[3'b111];
                r_TX_Bit_Count <= 3'b110;
            end else if ((r_Leading_Edge & w_CPHA) | (r_Trailing_Edge & ~w_CPHA)) begin
                r_TX_Bit_Count <= r_TX_Bit_Count - 1'b1;
                o_MOSI     <= r_TX_Byte[r_TX_Bit_Count];
            end
        end
    end


    // Purpose: Read in MISO data.
    always @(posedge clk) begin
        if (~rstn) begin
            o_RX_Byte      <= 8'h00;
            o_RX_DV        <= 1'b0;
            r_RX_Bit_Count <= 3'b111;
        end else begin
            // Default Assignments
            o_RX_DV   <= 1'b0;

            if (o_TX_Ready) begin
                // Check if ready is high, if so reset bit count to default
                r_RX_Bit_Count <= 3'b111;
            end else if ((r_Leading_Edge & ~w_CPHA) | (r_Trailing_Edge & w_CPHA)) begin
                o_RX_Byte[r_RX_Bit_Count] <= i_MISO;  // Sample data
                r_RX_Bit_Count            <= r_RX_Bit_Count - 1'b1;
                if (r_RX_Bit_Count == 3'b000) begin
                    o_RX_DV   <= 1'b1;   // Byte done, pulse Data Valid
                end
            end
        end
    end

    // Purpose: Add clock delay to signals for alignment.
    always @(posedge clk) begin
        if (~rstn) begin
            o_SCK  <= w_CPOL;
        end else begin
            o_SCK <= r_SPI_Clk;
        end
    end

endmodule
