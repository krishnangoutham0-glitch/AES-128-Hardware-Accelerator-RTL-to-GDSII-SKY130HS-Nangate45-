module sub_bytes (
    input  logic [127:0] state_in,
    output logic [127:0] state_out
);

    genvar i;

    generate
        for (i = 0; i < 16; i++) begin : sbox_instances

            aes_sbox sbox_inst (
                .in  (state_in[127 - i*8 -: 8]),
                .out (state_out[127 - i*8 -: 8])
            );

        end
    endgenerate

endmodule