// Copyright EPFL and Politecnico di Torino contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

module aes #(
    parameter type reg_req_t = logic,
    parameter type reg_rsp_t = logic
) (
    input logic clk_i,
    input logic rst_ni,


    // Register interface connected to the X-HEEP peripheral subsystem
    input  reg_req_t reg_req_i,
    output reg_rsp_t reg_rsp_o


);


  // ------------------------------------------------------------------------
  // Register interface signals
  // ------------------------------------------------------------------------

  aes_reg_pkg::aes_reg2hw_t reg2hw;
  aes_reg_pkg::aes_hw2reg_t hw2reg;


  // ------------------------------------------------------------------------
  // AES internal signals
  // ------------------------------------------------------------------------

  logic [127:0] aes_plaintext;
  logic [127:0] aes_key;
  logic [127:0] aes_ciphertext;

  logic aes_start;
  logic aes_busy;
  logic aes_done;


  // ------------------------------------------------------------------------
  // Generated register block
  // ------------------------------------------------------------------------

  aes_reg_top #(
      .reg_req_t(reg_req_t),
      .reg_rsp_t(reg_rsp_t)
  ) i_aes_reg_top (
      .clk_i,
      .rst_ni,

      .reg2hw,
      .hw2reg,

      .reg_req_i,
      .reg_rsp_o,

      .devmode_i(1'b0)
  );


  // ------------------------------------------------------------------------
  // Assemble 128-bit plaintext
  //
  // PLAINTEXT_0 = bits [127:96]
  // PLAINTEXT_1 = bits [95:64]
  // PLAINTEXT_2 = bits [63:32]
  // PLAINTEXT_3 = bits [31:0]
  // ------------------------------------------------------------------------

  assign aes_plaintext = {
    reg2hw.plaintext_0.q, reg2hw.plaintext_1.q, reg2hw.plaintext_2.q, reg2hw.plaintext_3.q
  };


  // ------------------------------------------------------------------------
  // Assemble 128-bit AES key
  //
  // KEY_0 = bits [127:96]
  // KEY_1 = bits [95:64]
  // KEY_2 = bits [63:32]
  // KEY_3 = bits [31:0]
  // ------------------------------------------------------------------------

  assign aes_key = {reg2hw.key_0.q, reg2hw.key_1.q, reg2hw.key_2.q, reg2hw.key_3.q};


  // ------------------------------------------------------------------------
  // START generation
  //
  // CONTROL has hwqe enabled in aes.hjson. Therefore:
  //
  //   control.q  = current value of the START register bit
  //   control.qe = asserted when software writes the CONTROL register
  //
  // Start AES only when software writes START = 1 and the AES core is idle.
  // ------------------------------------------------------------------------

  assign aes_start = reg2hw.control.qe && reg2hw.control.q && !aes_busy;


  // ------------------------------------------------------------------------
  // AES-128 core
  // ------------------------------------------------------------------------

  aes_core i_aes_core (
      .clk  (clk_i),
      .rst_n(rst_ni),

      .start(aes_start),

      .plaintext(aes_plaintext),
      .key      (aes_key),

      .ciphertext(aes_ciphertext),

      .busy(aes_busy),
      .done(aes_done)
  );


  // ------------------------------------------------------------------------
  // Hardware-to-register connections
  // ------------------------------------------------------------------------

  always_comb begin

    // Default values
    hw2reg = '0;


    // --------------------------------------------------------------------
    // STATUS
    //
    // BUSY = 1 while AES is processing.
    // DONE = asserted when the AES operation completes.
    // --------------------------------------------------------------------

    hw2reg.status.busy.d = aes_busy;
    hw2reg.status.busy.de = 1'b1;

    hw2reg.status.done.d = aes_done;
    hw2reg.status.done.de = 1'b1;


    // --------------------------------------------------------------------
    // CIPHERTEXT
    //
    // CIPHERTEXT_0 = bits [127:96]
    // CIPHERTEXT_1 = bits [95:64]
    // CIPHERTEXT_2 = bits [63:32]
    // CIPHERTEXT_3 = bits [31:0]
    // --------------------------------------------------------------------

    hw2reg.ciphertext_0.d = aes_ciphertext[127:96];
    hw2reg.ciphertext_0.de = 1'b1;

    hw2reg.ciphertext_1.d = aes_ciphertext[95:64];
    hw2reg.ciphertext_1.de = 1'b1;

    hw2reg.ciphertext_2.d = aes_ciphertext[63:32];
    hw2reg.ciphertext_2.de = 1'b1;

    hw2reg.ciphertext_3.d = aes_ciphertext[31:0];
    hw2reg.ciphertext_3.de = 1'b1;

  end


endmodule

