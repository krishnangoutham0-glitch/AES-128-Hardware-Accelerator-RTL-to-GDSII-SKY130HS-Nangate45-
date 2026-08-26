`timescale 1ns/1ps

module mix_columns_tb;

    logic [127:0] state_in;
    logic [127:0] state_out;

    mix_columns dut (
        .state_in  (state_in),
        .state_out (state_out)
    );

    initial begin

        // First column = DB 13 53 45
        // Expected first column = 8E 4D A1 BC
        //
        // Remaining columns are zero for this isolated test.

        state_in = 128'hDB135345000000000000000000000000;

        #1;

        $display("Input : %032h", state_in);
        $display("Output: %032h", state_out);

        // We only care about the first column here.
        if (state_out[127:96] === 32'h8E4DA1BC) begin
            $display("MIX_COLUMNS FIRST COLUMN PASS");
        end
        else begin
            $display("MIX_COLUMNS FAIL");
            $display("Expected first column: 8E4DA1BC");
            $display("Got first column     : %08h", state_out[127:96]);
        end

        $finish;

    end

endmodule