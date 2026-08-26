`timescale 1ns/1ps

module add_round_key_tb;

    logic [127:0] state_in;
    logic [127:0] round_key;
    logic [127:0] state_out;

    add_round_key dut (
        .state_in  (state_in),
        .round_key (round_key),
        .state_out (state_out)
    );

    initial begin

        // Test input
        state_in  = 128'h00112233445566778899AABBCCDDEEFF;
        round_key = 128'h000102030405060708090A0B0C0D0E0F;

        #1;

        $display("State     : %032h", state_in);
        $display("Round Key : %032h", round_key);
        $display("Output    : %032h", state_out);

        // Expected:
        // 00112233...FF
        // XOR
        // 00010203...0F
        // =
        // 00102030405060708090A0B0C0D0E0F0

        if (state_out === 128'h00102030405060708090A0B0C0D0E0F0) begin
            $display("ADD_ROUND_KEY PASS");
        end
        else begin
            $display("ADD_ROUND_KEY FAIL");
            $display("Expected  : 00102030405060708090A0B0C0D0E0F0");
        end

        $finish;

    end

endmodule