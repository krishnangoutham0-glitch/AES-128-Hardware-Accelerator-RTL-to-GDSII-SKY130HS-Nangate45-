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

    typedef enum logic [2:0] {
        IDLE,
        INIT,
        ROUND,
        FINAL,
        DONE
    } state_t;

    state_t state, next_state;

    // ------------------------------------------------------------
    // State register
    // ------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state <= IDLE;
            round <= 4'd0;
        end
        else begin
            state <= next_state;

            if (state == IDLE && start)
                round <= 4'd0;

            else if (state == INIT)
                round <= 4'd1;

            else if (state == ROUND)
                round <= round + 4'd1;

        end

    end

    // ------------------------------------------------------------
    // Next-state logic
    // ------------------------------------------------------------

    always_comb begin

        next_state = state;

        case (state)

            IDLE: begin

                if (start)
                    next_state = INIT;

            end

            INIT: begin

                // Initial AddRoundKey
                next_state = ROUND;

            end

            ROUND: begin

                if (round == 4'd9)
                    next_state = FINAL;
                else
                    next_state = ROUND;

            end

            FINAL: begin

                next_state = DONE;

            end

            DONE: begin

                next_state = IDLE;

            end

            default: begin

                next_state = IDLE;

            end

        endcase

    end

    // ------------------------------------------------------------
    // Output control signals
    // ------------------------------------------------------------

    always_comb begin

        busy = 1'b0;
        done = 1'b0;

        do_initial_key = 1'b0;
        do_round       = 1'b0;
        do_final_round = 1'b0;

        case (state)

            INIT: begin
                busy = 1'b1;
                do_initial_key = 1'b1;
            end

            ROUND: begin
                busy = 1'b1;
                do_round = 1'b1;
            end

            FINAL: begin
                busy = 1'b1;
                do_final_round = 1'b1;
            end

            DONE: begin
                done = 1'b1;
            end

            default: begin
            end

        endcase

    end

endmodule