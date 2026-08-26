`timescale 1ns/1ps

module key_expansion_tb;

    logic         clk;
    logic         rst_n;
    logic         start;

    logic [127:0] key_in;
    logic [127:0] round_key;
    logic [3:0]   round;
    logic         valid;
    logic         done;

    key_expansion dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .key_in    (key_in),
        .round_key (round_key),
        .round     (round),
        .valid     (valid),
        .done      (done)
    );

    // Clock
    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    // ------------------------------------------------------------
    // Correct AES-128 round keys
    // ------------------------------------------------------------

    logic [127:0] expected_keys [0:10];

    initial begin
        expected_keys[0]  = 128'h000102030405060708090A0B0C0D0E0F;
        expected_keys[1]  = 128'hD6AA74FDD2AF72FADAA678F1D6AB76FE;
        expected_keys[2]  = 128'hB692CF0B643DBDF1BE9BC5006830B3FE;
        expected_keys[3]  = 128'hB6FF744ED2C2C9BF6C590CBF0469BF41;
        expected_keys[4]  = 128'h47F7F7BC95353E03F96C32BCFD058DFD;
        expected_keys[5]  = 128'h3CAAA3E8A99F9DEB50F3AF57ADF622AA;
        expected_keys[6]  = 128'h5E390F7DF7A69296A7553DC10AA31F6B;
        expected_keys[7]  = 128'h14F9701AE35FE28C440ADF4D4EA9C026;
        expected_keys[8]  = 128'h47438735A41C65B9E016BAF4AEBF7AD2;
        expected_keys[9]  = 128'h549932D1F08557681093ED9CBE2C974E;
        expected_keys[10] = 128'h13111D7FE3944A17F307A78B4D2B30C5;
    end

    integer errors;
    integer i;

    initial begin

        errors = 0;

        key_in = 128'h000102030405060708090A0B0C0D0E0F;

        start = 1'b0;
        rst_n = 1'b0;

        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #12;
        rst_n = 1'b1;

        // --------------------------------------------------------
        // Assert START
        // --------------------------------------------------------

        @(negedge clk);
        start = 1'b1;

        // --------------------------------------------------------
        // IMPORTANT:
        // The next posedge generates Round 0.
        // Check it here BEFORE deasserting start.
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        $display(
            "Round %0d : %032h",
            round,
            round_key
        );

        if (valid && round == 4'd0 &&
            round_key === expected_keys[0]) begin

            $display("          PASS");

        end
        else begin

            $display("          FAIL");
            $display(
                "          Expected: %032h",
                expected_keys[0]
            );

            errors = errors + 1;

        end

        // --------------------------------------------------------
        // Deassert START
        // --------------------------------------------------------

        @(negedge clk);
        start = 1'b0;

        // --------------------------------------------------------
        // Rounds 1 through 10
        // --------------------------------------------------------

        for (i = 1; i <= 10; i = i + 1) begin

            @(posedge clk);
            #1;

            $display(
                "Round %0d : %032h",
                round,
                round_key
            );

            if (valid &&
                round == i[3:0] &&
                round_key === expected_keys[i]) begin

                $display("          PASS");

            end
            else begin

                $display("          FAIL");

                $display(
                    "          Expected: %032h",
                    expected_keys[i]
                );

                errors = errors + 1;

            end

        end

        // --------------------------------------------------------
        // Check DONE
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        if (done) begin
            $display("KEY_EXPANSION DONE");
        end
        else begin
            $display("DONE NOT ASSERTED");
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------

        if (errors == 0) begin
            $display("");
            $display("KEY_EXPANSION PASS");
        end
        else begin
            $display("");
            $display(
                "KEY_EXPANSION FAIL: %0d errors",
                errors
            );
        end

        $finish;

    end

endmodule