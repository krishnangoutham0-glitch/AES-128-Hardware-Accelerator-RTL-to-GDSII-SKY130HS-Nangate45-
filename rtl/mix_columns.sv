module mix_columns (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    // ------------------------------------------------------------
    // Multiply a byte by 2 in GF(2^8)
    // AES irreducible polynomial = x^8 + x^4 + x^3 + x + 1
    // Polynomial representation = 8'h1B
    // ------------------------------------------------------------
    function automatic logic [7:0] xtime(input logic [7:0] x);
        begin
            if (x[7])
                xtime = {x[6:0], 1'b0} ^ 8'h1B;
            else
                xtime = {x[6:0], 1'b0};
        end
    endfunction

    // ------------------------------------------------------------
    // Multiply by 3 in GF(2^8)
    //
    // 3*x = (2*x) XOR x
    // ------------------------------------------------------------
    function automatic logic [7:0] mul3(input logic [7:0] x);
        begin
            mul3 = xtime(x) ^ x;
        end
    endfunction

    // ------------------------------------------------------------
    // Temporary bytes
    // ------------------------------------------------------------
    logic [7:0] b0,  b1,  b2,  b3;
    logic [7:0] b4,  b5,  b6,  b7;
    logic [7:0] b8,  b9,  b10, b11;
    logic [7:0] b12, b13, b14, b15;

    logic [7:0] c0, c1, c2, c3;
    logic [7:0] c4, c5, c6, c7;
    logic [7:0] c8, c9, c10, c11;
    logic [7:0] c12, c13, c14, c15;

    always @* begin 

        // --------------------------------------------------------
        // Extract input bytes
        // --------------------------------------------------------

        b0  = state_in[127:120];
        b1  = state_in[119:112];
        b2  = state_in[111:104];
        b3  = state_in[103:96];

        b4  = state_in[95:88];
        b5  = state_in[87:80];
        b6  = state_in[79:72];
        b7  = state_in[71:64];

        b8  = state_in[63:56];
        b9  = state_in[55:48];
        b10 = state_in[47:40];
        b11 = state_in[39:32];

        b12 = state_in[31:24];
        b13 = state_in[23:16];
        b14 = state_in[15:8];
        b15 = state_in[7:0];

        // --------------------------------------------------------
        // Mix Column 0
        //
        // [b0]       [02 03 01 01]   [c0]
        // [b1]  ---> [01 02 03 01]   [c1]
        // [b2]       [01 01 02 03]   [c2]
        // [b3]       [03 01 01 02]   [c3]
        // --------------------------------------------------------

        c0 = xtime(b0) ^ mul3(b1) ^ b2 ^ b3;
        c1 = b0 ^ xtime(b1) ^ mul3(b2) ^ b3;
        c2 = b0 ^ b1 ^ xtime(b2) ^ mul3(b3);
        c3 = mul3(b0) ^ b1 ^ b2 ^ xtime(b3);

        // --------------------------------------------------------
        // Mix Column 1
        // --------------------------------------------------------

        c4 = xtime(b4) ^ mul3(b5) ^ b6 ^ b7;
        c5 = b4 ^ xtime(b5) ^ mul3(b6) ^ b7;
        c6 = b4 ^ b5 ^ xtime(b6) ^ mul3(b7);
        c7 = mul3(b4) ^ b5 ^ b6 ^ xtime(b7);

        // --------------------------------------------------------
        // Mix Column 2
        // --------------------------------------------------------

        c8  = xtime(b8) ^ mul3(b9) ^ b10 ^ b11;
        c9  = b8 ^ xtime(b9) ^ mul3(b10) ^ b11;
        c10 = b8 ^ b9 ^ xtime(b10) ^ mul3(b11);
        c11 = mul3(b8) ^ b9 ^ b10 ^ xtime(b11);

        // --------------------------------------------------------
        // Mix Column 3
        // --------------------------------------------------------

        c12 = xtime(b12) ^ mul3(b13) ^ b14 ^ b15;
        c13 = b12 ^ xtime(b13) ^ mul3(b14) ^ b15;
        c14 = b12 ^ b13 ^ xtime(b14) ^ mul3(b15);
        c15 = mul3(b12) ^ b13 ^ b14 ^ xtime(b15);

        // --------------------------------------------------------
        // Reconstruct 128-bit state
        // --------------------------------------------------------

        state_out = {
            c0,  c1,  c2,  c3,
            c4,  c5,  c6,  c7,
            c8,  c9,  c10, c11,
            c12, c13, c14, c15
        };

    end

endmodule