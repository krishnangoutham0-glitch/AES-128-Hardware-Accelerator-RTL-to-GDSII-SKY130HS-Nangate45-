`timescale 1ns/1ps

module aes_core_tb;

    logic         clk;
    logic         rst_n;
    logic         start;

    logic [127:0] plaintext;
    logic [127:0] key;

    logic [127:0] ciphertext;
    logic         busy;
    logic         done;


    // ------------------------------------------------------------
    // AES Core
    // ------------------------------------------------------------

    aes_core dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .start      (start),
        .plaintext  (plaintext),
        .key        (key),
        .ciphertext (ciphertext),
        .busy       (busy),
        .done        (done)
    );


    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end


    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        // Standard AES-128 test vector
        plaintext = 128'h00112233445566778899AABBCCDDEEFF;

        key = 128'h000102030405060708090A0B0C0D0E0F;

        start = 1'b0;
        rst_n = 1'b0;


        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #12;
        rst_n = 1'b1;


        // --------------------------------------------------------
        // Start encryption
        // --------------------------------------------------------

        @(negedge clk);

        start = 1'b1;

        @(negedge clk);

        start = 1'b0;


        // --------------------------------------------------------
        // Wait for encryption to finish
        // --------------------------------------------------------

        wait (done == 1'b1);

        #1;


        // --------------------------------------------------------
        // Display result
        // --------------------------------------------------------

        $display("");
        $display("==========================================");
        $display("        AES-128 ENCRYPTION TEST");
        $display("==========================================");

        $display("Plaintext  : %032h", plaintext);
        $display("Key        : %032h", key);
        $display("Ciphertext : %032h", ciphertext);

        $display("Expected   : 69C4E0D86A7B0430D8CDB78070B4C55A");


        // --------------------------------------------------------
        // Check ciphertext
        // --------------------------------------------------------

        if (ciphertext === 128'h69C4E0D86A7B0430D8CDB78070B4C55A) begin

            $display("");
            $display("AES_CORE PASS");

        end
        else begin

            $display("");
            $display("AES_CORE FAIL");

        end


        $display("==========================================");

        $finish;

    end

endmodule