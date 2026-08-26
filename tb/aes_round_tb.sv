`timescale 1ns/1ps

module aes_round_tb;

    logic [127:0] state_in;
    logic [127:0] round_key;
    logic [127:0] state_out;

    aes_round dut (
        .state_in  (state_in),
        .round_key (round_key),
        .state_out (state_out)
    );

    initial begin

        // State entering AES Round 1
        state_in = 128'h00102030405060708090A0B0C0D0E0F0;

        // AES-128 Round 1 key
        round_key = 128'hD6AA74FDD2AF72FADAA678F1D6AB76FE;

        #1;

        $display("State In  : %032h", state_in);
        $display("Round Key : %032h", round_key);
        $display("State Out : %032h", state_out);

        // Expected output after:
        // SubBytes
        // ShiftRows
        // MixColumns
        // AddRoundKey

        if (state_out === 128'h89D810E8855ACE682D1843D8CB128FE4) begin
            $display("AES_ROUND PASS");
        end
        else begin
            $display("AES_ROUND FAIL");
            $display("Expected  : 89D810E8855ACE682D1843D8CB128FE4");
        end

        $finish;

    end

endmodule