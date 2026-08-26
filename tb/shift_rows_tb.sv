`timescale 1ns/1ps

module shift_rows_tb;

    logic [127:0] state_in;
    logic [127:0] state_out;

    shift_rows dut (
        .state_in  (state_in),
        .state_out (state_out)
    );

    initial begin

        state_in = 128'h00112233445566778899AABBCCDDEEFF;

        #1;

        $display("Input : %032h", state_in);
        $display("Output: %032h", state_out);

        if (state_out === 128'h0055AAFF4499EE3388DD2277CC1166BB) begin
            $display("SHIFT_ROWS PASS");
        end
        else begin
            $display("SHIFT_ROWS FAIL");
            $display("Expected: 0055AAFF4499EE338822DD77CC1166BB");
        end

        $finish;

    end

endmodule