`timescale 1ns/1ps

module sub_bytes_tb;

    logic [127:0] state_in;
    logic [127:0] state_out;

    sub_bytes dut (
        .state_in  (state_in),
        .state_out (state_out)
    );

    initial begin

        // Test vector containing all 16 byte values
        state_in = 128'h00112233445566778899AABBCCDDEEFF;

        #1;

        $display("Input : %032h", state_in);
        $display("Output: %032h", state_out);

        // Expected:
        // 63CAB7040953D051CD60E0E7BA70E18C

        if (state_out === 128'h638293C31BFC33F5C4EEACEA4BC12816) begin
            $display("SUB_BYTES PASS");
        end
        else begin
            $display("SUB_BYTES FAIL");
            $display("Expected: 638293C31BFC33F5C4EEACEA4BC12816");
        end

        $finish;
    end

endmodule