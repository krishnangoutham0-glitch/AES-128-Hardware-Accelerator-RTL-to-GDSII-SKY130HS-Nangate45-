module aes_core (
    input logic clk,
    input logic rst_n,
    input logic start,

    input logic [127:0] plaintext,
    input logic [127:0] key,

    output logic [127:0] ciphertext,
    output logic         busy,
    output logic         done
);

  // ============================================================
  // Controller signals
  // ============================================================

  logic [  3:0] round;

  logic         do_initial_key;
  logic         do_round;
  logic         do_final_round;


  // ============================================================
  // Key Expansion signals
  // ============================================================

  logic [127:0] round_key;
  logic [  3:0] key_round;
  logic         key_valid;
  logic         key_done;


  // ============================================================
  // State register
  // ============================================================

  logic [127:0] state_reg;
  logic [127:0] state_next;


  // ============================================================
  // Datapath intermediate signals
  // ============================================================

  logic [127:0] initial_key_out;
  logic [127:0] normal_round_out;
  logic [127:0] final_round_out;


  // ============================================================
  // Round Controller
  // ============================================================

  round_controller u_controller (
      .clk  (clk),
      .rst_n(rst_n),
      .start(start),

      .round(round),
      .busy (busy),
      .done (done),

      .do_initial_key(do_initial_key),
      .do_round      (do_round),
      .do_final_round(do_final_round)
  );


  // ============================================================
  // Key Expansion
  // ============================================================

  key_expansion u_key_expansion (
      .clk  (clk),
      .rst_n(rst_n),
      .start(start),

      .key_in(key),

      .round_key(round_key),
      .round    (key_round),
      .valid    (key_valid),
      .done     (key_done)
  );


  // ============================================================
  // Initial AddRoundKey
  //
  // Round 0:
  //
  // State = Plaintext XOR Key
  // ============================================================

  add_round_key u_initial_add_round_key (
      .state_in (plaintext),
      .round_key(round_key),
      .state_out(initial_key_out)
  );


  // ============================================================
  // Normal AES Round
  //
  // Rounds 1 through 9:
  //
  // SubBytes
  // ShiftRows
  // MixColumns
  // AddRoundKey
  // ============================================================

  aes_round u_aes_round (
      .state_in (state_reg),
      .round_key(round_key),
      .state_out(normal_round_out)
  );


  // ============================================================
  // Final AES Round
  //
  // Round 10:
  //
  // SubBytes
  // ShiftRows
  // AddRoundKey
  //
  // NO MixColumns
  // ============================================================

  aes_final_round u_aes_final_round (
      .state_in (state_reg),
      .round_key(round_key),
      .state_out(final_round_out)
  );


  // ============================================================
  // Select what gets written into the state register
  // ============================================================

  always_comb begin

    state_next = state_reg;

    if (do_initial_key) begin

      state_next = initial_key_out;

    end else if (do_round) begin

      state_next = normal_round_out;

    end else if (do_final_round) begin

      state_next = final_round_out;

    end

  end


  // ============================================================
  // State Register
  // ============================================================

  always_ff @(posedge clk or negedge rst_n) begin

    if (!rst_n) begin

      state_reg <= 128'h0;

    end else begin

      state_reg <= state_next;

    end

  end


  // ============================================================
  // Ciphertext
  // ============================================================

  assign ciphertext = state_reg;

endmodule
