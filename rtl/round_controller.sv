module round_controller (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,

    output logic [3:0] round,
    output logic       busy,
    output logic       done,

    output logic       do_initial_key,
    output logic       do_round,
    output logic       do_final_round
);

    // ============================================================
    // One-hot FSM states
    //
    // Only one state bit is HIGH at a time.
    //
    // IDLE   = 00001
    // INIT   = 00010
    // ROUND  = 00100
    // FINAL  = 01000
    // DONE   = 10000
    // ============================================================

    localparam logic [4:0] S_IDLE  = 5'b00001;
    localparam logic [4:0] S_INIT  = 5'b00010;
    localparam logic [4:0] S_ROUND = 5'b00100;
    localparam logic [4:0] S_FINAL = 5'b01000;
    localparam logic [4:0] S_DONE  = 5'b10000;

    logic [4:0] state;
    logic [4:0] next_state;


    // ============================================================
    // State and round registers
    // ============================================================

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            state <= S_IDLE;
            round <= 4'd0;

        end
        else begin

            state <= next_state;

            // ----------------------------------------------------
            // Start a new encryption
            //
            // Accepted from IDLE or immediately from DONE.
            // This preserves back-to-back operation.
            // ----------------------------------------------------

            if ((state == S_IDLE || state == S_DONE) && start) begin

                round <= 4'd0;

            end

            // ----------------------------------------------------
            // INIT -> first AES round
            // ----------------------------------------------------

            else if (state == S_INIT) begin

                round <= 4'd1;

            end

            // ----------------------------------------------------
            // ROUND 1 -> ROUND 2 -> ... -> ROUND 9
            // ----------------------------------------------------

            else if (state == S_ROUND) begin

                round <= round + 4'd1;

            end

        end

    end


    // ============================================================
    // Next-state logic
    // ============================================================

    always_comb begin

        // Default: stay in current state
        next_state = state;

        case (state)

            // ----------------------------------------------------
            // IDLE
            // ----------------------------------------------------

            S_IDLE: begin

                if (start)
                    next_state = S_INIT;

            end


            // ----------------------------------------------------
            // INIT
            //
            // Performs initial AddRoundKey.
            // round = 0
            // ----------------------------------------------------

            S_INIT: begin

                next_state = S_ROUND;

            end


            // ----------------------------------------------------
            // ROUND
            //
            // Performs AES rounds 1 through 9.
            // ----------------------------------------------------

            S_ROUND: begin

                if (round == 4'd9)
                    next_state = S_FINAL;

                else
                    next_state = S_ROUND;

            end


            // ----------------------------------------------------
            // FINAL
            //
            // Performs AES round 10.
            // ----------------------------------------------------

            S_FINAL: begin

                next_state = S_DONE;

            end


            // ----------------------------------------------------
            // DONE
            //
            // Accept START immediately for back-to-back operation.
            // ----------------------------------------------------

            S_DONE: begin

                if (start)
                    next_state = S_INIT;

                else
                    next_state = S_IDLE;

            end


            // ----------------------------------------------------
            // Safety state
            // ----------------------------------------------------

            default: begin

                next_state = S_IDLE;

            end

        endcase

    end


    // ============================================================
    // Output logic
    //
    // These are direct decodes of the one-hot state.
    // This avoids the large binary-state decode network.
    // ============================================================

    always_comb begin

        do_initial_key = state[1];
        do_round       = state[2];
        do_final_round = state[3];

        done = state[4];

        busy = state[1] |
               state[2] |
               state[3];

    end

endmodule