module key_expansion (
    input  logic         clk,
    input  logic         rst_n,
    input  logic         start,

    input  logic [127:0] key_in,

    output logic [127:0] round_key,
    output logic [3:0]   round,
    output logic         valid,
    output logic         done
);

    logic [127:0] key_reg;
    logic [7:0]   rcon;

    logic [31:0] w0, w1, w2, w3;
    logic [31:0] t;
    logic [31:0] sub_word;

    logic [31:0] nw0, nw1, nw2, nw3;

    logic [7:0] sbox_in0;
    logic [7:0] sbox_in1;
    logic [7:0] sbox_in2;
    logic [7:0] sbox_in3;

    logic [7:0] sbox_out0;
    logic [7:0] sbox_out1;
    logic [7:0] sbox_out2;
    logic [7:0] sbox_out3;


    // ------------------------------------------------------------
    // Four S-boxes for SubWord
    // ------------------------------------------------------------

    aes_sbox sbox0 (
        .in  (sbox_in0),
        .out (sbox_out0)
    );

    aes_sbox sbox1 (
        .in  (sbox_in1),
        .out (sbox_out1)
    );

    aes_sbox sbox2 (
        .in  (sbox_in2),
        .out (sbox_out2)
    );

    aes_sbox sbox3 (
        .in  (sbox_in3),
        .out (sbox_out3)
    );


    // ------------------------------------------------------------
    // Key expansion combinational logic
    // ------------------------------------------------------------

    always @* begin

        // Current key = four 32-bit words
        w0 = key_reg[127:96];
        w1 = key_reg[95:64];
        w2 = key_reg[63:32];
        w3 = key_reg[31:0];


        // --------------------------------------------------------
        // RotWord
        //
        // Example:
        //
        // [A B C D] -> [B C D A]
        // --------------------------------------------------------

        t = {
            w3[23:16],
            w3[15:8],
            w3[7:0],
            w3[31:24]
        };


        // --------------------------------------------------------
        // SubWord
        // --------------------------------------------------------

        sbox_in0 = t[31:24];
        sbox_in1 = t[23:16];
        sbox_in2 = t[15:8];
        sbox_in3 = t[7:0];

        sub_word = {
            sbox_out0,
            sbox_out1,
            sbox_out2,
            sbox_out3
        };


        // --------------------------------------------------------
        // Generate next four words
        //
        // W4  = W0 XOR SubWord(RotWord(W3)) XOR Rcon
        // W5  = W1 XOR W4
        // W6  = W2 XOR W5
        // W7  = W3 XOR W6
        // --------------------------------------------------------

        nw0 = w0 ^ sub_word ^ {rcon, 24'h000000};
        nw1 = w1 ^ nw0;
        nw2 = w2 ^ nw1;
        nw3 = w3 ^ nw2;

    end


    // ------------------------------------------------------------
    // Rcon generation
    // ------------------------------------------------------------

    function automatic logic [7:0] rcon_next(
        input logic [7:0] r
    );
        begin
            if (r[7])
                rcon_next = {r[6:0], 1'b0} ^ 8'h1B;
            else
                rcon_next = {r[6:0], 1'b0};
        end
    endfunction


    // ------------------------------------------------------------
    // Sequential controller
    // ------------------------------------------------------------

    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin

            key_reg   <= 128'h0;
            round_key <= 128'h0;
            round     <= 4'd0;
            rcon      <= 8'h01;

            valid <= 1'b0;
            done  <= 1'b0;

        end
        else begin

            valid <= 1'b0;
            done  <= 1'b0;


            // ----------------------------------------------------
            // Load original key
            // ----------------------------------------------------

            if (start) begin

                key_reg   <= key_in;
                round_key <= key_in;

                round <= 4'd0;
                rcon  <= 8'h01;

                valid <= 1'b1;

            end


            // ----------------------------------------------------
            // Generate rounds 1 through 10
            // ----------------------------------------------------

            else if (round < 4'd10) begin

                key_reg <= {
                    nw0,
                    nw1,
                    nw2,
                    nw3
                };

                round_key <= {
                    nw0,
                    nw1,
                    nw2,
                    nw3
                };

                round <= round + 4'd1;

                rcon <= rcon_next(rcon);

                valid <= 1'b1;

            end


            // ----------------------------------------------------
            // Finished
            // ----------------------------------------------------

            else begin

                done <= 1'b1;

            end

        end

    end

endmodule