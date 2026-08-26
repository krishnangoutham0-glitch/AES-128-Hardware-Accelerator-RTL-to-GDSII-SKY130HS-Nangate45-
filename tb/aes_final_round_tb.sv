`timescale 1ns/1ps

module aes_final_round_tb;

    logic [127:0] state_in;
    logic [127:0] round_key;
    logic [127:0] state_out;

    aes_final_round dut (
        .state_in  (state_in),
        .round_key (round_key),
        .state_out (state_out)
    );

    initial begin

        state_in  = 128'hBD6E7C3DF2B5779E0B61216E8B10B689;
        round_key = 128'h13111D7FE3944A17F307A78B4D2B30C5;

        #1;

        $display("State In  : %032h", state_in);
        $display("Round Key : %032h", round_key);
        $display("State Out : %032h", state_out);

        if (state_out === 128'h69C4E0D86A7B0430D8CDB78070B4C55A) begin
            $display("AES_FINAL_ROUND PASS");
        end
        else begin
            $display("AES_FINAL_ROUND FAIL");
            $display("Expected  : 69C4E0D86A7B0430D8CDB78070B4C55A");
        end

        $finish;

    end

endmodule