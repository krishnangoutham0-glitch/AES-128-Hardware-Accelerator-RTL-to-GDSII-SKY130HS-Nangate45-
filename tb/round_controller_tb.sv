`timescale 1ns/1ps

module round_controller_tb;

    logic       clk;
    logic       rst_n;
    logic       start;

    logic [3:0] round;
    logic       busy;
    logic       done;

    logic       do_initial_key;
    logic       do_round;
    logic       do_final_round;

    round_controller dut (
        .clk            (clk),
        .rst_n          (rst_n),
        .start          (start),
        .round          (round),
        .busy           (busy),
        .done           (done),
        .do_initial_key (do_initial_key),
        .do_round       (do_round),
        .do_final_round (do_final_round)
    );

    // ------------------------------------------------------------
    // Clock
    // ------------------------------------------------------------

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    integer errors;
    integer i;

    // ------------------------------------------------------------
    // Test
    // ------------------------------------------------------------

    initial begin

        errors = 0;
        start  = 1'b0;
        rst_n  = 1'b0;

        // --------------------------------------------------------
        // Reset
        // --------------------------------------------------------

        #12;
        rst_n = 1'b1;

        // Controller should now be IDLE
        #1;

        if (busy || done) begin
            $display("IDLE FAIL");
            errors = errors + 1;
        end
        else begin
            $display("IDLE PASS");
        end

        // --------------------------------------------------------
        // Start operation
        // --------------------------------------------------------

        @(negedge clk);
        start = 1'b1;

        @(posedge clk);
        #1;

        start = 1'b0;

        // --------------------------------------------------------
        // INIT
        // --------------------------------------------------------

        if (do_initial_key && busy && round == 4'd0) begin
            $display("INIT      PASS  round=%0d", round);
        end
        else begin
            $display("INIT      FAIL");
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // ROUND 1 through ROUND 9
        // --------------------------------------------------------

        for (i = 1; i <= 9; i = i + 1) begin

            @(posedge clk);
            #1;

            if (do_round && busy && round == i[3:0]) begin
                $display(
                    "ROUND %0d   PASS",
                    round
                );
            end
            else begin
                $display(
                    "ROUND %0d   FAIL  actual_round=%0d",
                    i,
                    round
                );

                errors = errors + 1;
            end

        end

        // --------------------------------------------------------
        // FINAL ROUND 10
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        if (do_final_round && busy && round == 4'd10) begin
            $display("FINAL     PASS");
        end
        else begin
            $display(
                "FINAL     FAIL  actual_round=%0d",
                round
            );

            errors = errors + 1;
        end

        // --------------------------------------------------------
        // DONE
        // --------------------------------------------------------

        @(posedge clk);
        #1;

        if (done && !busy) begin
            $display("DONE      PASS");
        end
        else begin
            $display("DONE      FAIL");
            errors = errors + 1;
        end

        // --------------------------------------------------------
        // Final result
        // --------------------------------------------------------

        if (errors == 0) begin
            $display("");
            $display("ROUND_CONTROLLER PASS");
        end
        else begin
            $display("");
            $display(
                "ROUND_CONTROLLER FAIL: %0d errors",
                errors
            );
        end

        $finish;

    end

endmodule