`timescale 1ns/1ps

module aes_sbox_tb;

    logic [7:0] in;
    logic [7:0] out;

    aes_sbox dut (
        .in  (in),
        .out (out)
    );

    task automatic check_sbox(
        input logic [7:0] test_in,
        input logic [7:0] expected
    );
        begin
            in = test_in;
            #1;

            if (out !== expected) begin
                $display(
                    "FAIL: input=%02h expected=%02h got=%02h",
                    test_in, expected, out
                );
            end
            else begin
                $display(
                    "PASS: input=%02h output=%02h",
                    test_in, out
                );
            end
        end
    endtask

    initial begin

        // Known AES S-box values
        check_sbox(8'h00, 8'h63);
        check_sbox(8'h01, 8'h7C);
        check_sbox(8'h02, 8'h77);
        check_sbox(8'h03, 8'h7B);

        check_sbox(8'h10, 8'hCA);
        check_sbox(8'h20, 8'hB7);
        check_sbox(8'h30, 8'h04);
        check_sbox(8'h40, 8'h09);

        // Important AES example:
        check_sbox(8'h53, 8'hED);

        check_sbox(8'h63, 8'hFB);
        check_sbox(8'h7C, 8'h10);
        check_sbox(8'hFF, 8'h16);

        $display("S-box test completed.");

        $finish;
    end

endmodule