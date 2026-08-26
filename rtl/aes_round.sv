module aes_round (
    input  logic [127:0] state_in,
    input  logic [127:0] round_key,

    output logic [127:0] state_out
);

    logic [127:0] sub_bytes_out;
    logic [127:0] shift_rows_out;
    logic [127:0] mix_columns_out;

    // ------------------------------------------------------------
    // SubBytes
    // ------------------------------------------------------------

    sub_bytes u_sub_bytes (
        .state_in  (state_in),
        .state_out (sub_bytes_out)
    );

    // ------------------------------------------------------------
    // ShiftRows
    // ------------------------------------------------------------

    shift_rows u_shift_rows (
        .state_in  (sub_bytes_out),
        .state_out (shift_rows_out)
    );

    // ------------------------------------------------------------
    // MixColumns
    // ------------------------------------------------------------

    mix_columns u_mix_columns (
        .state_in  (shift_rows_out),
        .state_out (mix_columns_out)
    );

    // ------------------------------------------------------------
    // AddRoundKey
    // ------------------------------------------------------------

    add_round_key u_add_round_key (
        .state_in  (mix_columns_out),
        .round_key (round_key),
        .state_out (state_out)
    );

endmodule