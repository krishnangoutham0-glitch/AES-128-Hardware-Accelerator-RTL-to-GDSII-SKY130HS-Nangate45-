============================================================
AES-128 HARDWARE ACCELERATOR — VERILOG SPECIFICATION
============================================================

PROJECT:
AES-128 Encryption Accelerator for X-HEEP

CURRENT HARDWARE STATUS:
Standalone AES-128 encryption core is complete and verified.

TOP-LEVEL AES CORE:
    rtl/aes_core.sv

The AES core is independent of X-HEEP.
X-HEEP will be connected later through a peripheral wrapper.


============================================================
1. AES CORE INTERFACE
============================================================

Module:

    aes_core

Ports:

    input  logic         clk
    input  logic         rst_n
    input  logic         start

    input  logic [127:0] plaintext
    input  logic [127:0] key

    output logic [127:0] ciphertext
    output logic         busy
    output logic         done


FUNCTION:

    plaintext + key
            |
            v
        AES-128
            |
            v
       ciphertext


CONTROL:

    start = 1
        -> begins one AES-128 encryption operation

    busy = 1
        -> AES core is currently processing

    done = 1
        -> encryption has completed
        -> ciphertext is valid


The AES core is MULTI-CYCLE.

Software MUST NOT assume that ciphertext is available
immediately after asserting start.

Software should:

    1. Write plaintext
    2. Write key
    3. Assert START
    4. Wait until DONE
    5. Read ciphertext


============================================================
2. AES-128 DATA FORMAT
============================================================

AES operates on:

    128-bit plaintext
    128-bit key
    128-bit ciphertext

Each 128-bit value contains:

    16 bytes

Example plaintext:

    00112233445566778899AABBCCDDEEFF

Bytes:

    00 11 22 33 44 55 66 77
    88 99 AA BB CC DD EE FF


============================================================
3. SOFTWARE ↔ HARDWARE 32-BIT WORD MAPPING
============================================================

Because the RISC-V CPU uses 32-bit registers, each
128-bit AES value is divided into four 32-bit words.

PLAINTEXT:

    PLAINTEXT_0 = 00112233
    PLAINTEXT_1 = 44556677
    PLAINTEXT_2 = 8899AABB
    PLAINTEXT_3 = CCDDEEFF

The hardware reconstructs:

    plaintext =
        {PLAINTEXT_0,
         PLAINTEXT_1,
         PLAINTEXT_2,
         PLAINTEXT_3};


KEY:

    KEY_0 = 00010203
    KEY_1 = 04050607
    KEY_2 = 08090A0B
    KEY_3 = 0C0D0E0F

The hardware reconstructs:

    key =
        {KEY_0,
         KEY_1,
         KEY_2,
         KEY_3};


CIPHERTEXT:

    CIPHERTEXT_0 = ciphertext[127:96]
    CIPHERTEXT_1 = ciphertext[95:64]
    CIPHERTEXT_2 = ciphertext[63:32]
    CIPHERTEXT_3 = ciphertext[31:0]


============================================================
4. PROPOSED X-HEEP MEMORY-MAPPED REGISTER INTERFACE
============================================================

These are the proposed addresses for the X-HEEP wrapper.

IMPORTANT:
These addresses are the planned interface.
They are NOT yet implemented in the current standalone
AES core.

OFFSET      REGISTER          ACCESS
------------------------------------------------
0x00        PLAINTEXT_0       WRITE
0x04        PLAINTEXT_1       WRITE
0x08        PLAINTEXT_2       WRITE
0x0C        PLAINTEXT_3       WRITE

0x10        KEY_0             WRITE
0x14        KEY_1             WRITE
0x18        KEY_2             WRITE
0x1C        KEY_3             WRITE

0x20        CONTROL           WRITE
0x24        STATUS            READ

0x28        CIPHERTEXT_0      READ
0x2C        CIPHERTEXT_1      READ
0x30        CIPHERTEXT_2      READ
0x34        CIPHERTEXT_3      READ


============================================================
5. CONTROL REGISTER
============================================================

Address:

    0x20

CONTROL[0]:

    START

    0 = no action
    1 = start AES encryption


Software sequence:

    CONTROL = 1;


The hardware starts the encryption operation.


============================================================
6. STATUS REGISTER
============================================================

Address:

    0x24


STATUS[0]:

    BUSY

    0 = AES core idle
    1 = AES core processing


STATUS[1]:

    DONE

    0 = encryption not completed
    1 = encryption completed


Expected software behavior:

    while (STATUS & BUSY)
        ;


or:

    while (!(STATUS & DONE))
        ;


After DONE becomes 1:

    ciphertext registers contain valid ciphertext.


============================================================
7. CIPHERTEXT REGISTERS
============================================================

Addresses:

    0x28 = CIPHERTEXT_0
    0x2C = CIPHERTEXT_1
    0x30 = CIPHERTEXT_2
    0x34 = CIPHERTEXT_3


For ciphertext:

    69C4E0D86A7B0430D8CDB78070B4C55A

Registers contain:

    CIPHERTEXT_0 = 69C4E0D8
    CIPHERTEXT_1 = 6A7B0430
    CIPHERTEXT_2 = D8CDB780
    CIPHERTEXT_3 = 70B4C55A


============================================================
8. AES INTERNAL RTL MODULES
============================================================

The current RTL hierarchy is:

    aes_core
    |
    +-- round_controller
    |
    +-- key_expansion
    |      |
    |      +-- aes_sbox
    |
    +-- add_round_key
    |
    +-- aes_round
    |      |
    |      +-- sub_bytes
    |      |      |
    |      |      +-- aes_sbox
    |      |
    |      +-- shift_rows
    |      |
    |      +-- mix_columns
    |      |
    |      +-- add_round_key
    |
    +-- aes_final_round
           |
           +-- sub_bytes
           |      |
           |      +-- aes_sbox
           |
           +-- shift_rows
           |
           +-- add_round_key


============================================================
9. AES S-BOX
============================================================

Module:

    aes_sbox

Input:

    8-bit byte

Output:

    8-bit substituted byte

The S-box is the STANDARD AES S-box.

It is not a custom S-box.

Example:

    input  = 8'h00
    output = 8'h63

    input  = 8'h53
    output = 8'hED

The S-box was individually tested.


============================================================
10. SUB_BYTES
============================================================

Module:

    sub_bytes

Input:

    128-bit AES state

Operation:

    Apply AES S-box independently to all 16 bytes.

Example:

    input:
        00112233445566778899AABBCCDDEEFF

    output:
        63CAB7040953D051CD60E0E7BA70E18C


============================================================
11. SHIFT_ROWS
============================================================

Module:

    shift_rows

Input:

    128-bit AES state

Operation:

    AES ShiftRows byte permutation.

Row 0:

    shift by 0

Row 1:

    shift by 1

Row 2:

    shift by 2

Row 3:

    shift by 3

No arithmetic is performed.

It is purely a byte permutation/wiring operation.


============================================================
12. MIX_COLUMNS
============================================================

Module:

    mix_columns

Input:

    128-bit AES state

Operation:

    AES MixColumns transformation.

The calculation is performed in:

    GF(2^8)

Each AES column consists of four bytes.

The standard AES MixColumns matrix is used.

The module was individually tested.


============================================================
13. ADD_ROUND_KEY
============================================================

Module:

    add_round_key

Inputs:

    state_in  = 128 bits
    round_key = 128 bits

Output:

    state_out = 128 bits

Operation:

    state_out = state_in XOR round_key

No other mathematical operation is performed.


============================================================
14. KEY EXPANSION
============================================================

Module:

    key_expansion

Input:

    128-bit original AES key

Output:

    Round Keys 0 through 10

AES-128 requires:

    11 round keys

Round:

    0  -> initial key
    1  -> round 1 key
    2  -> round 2 key
    ...
    10 -> round 10 key


Key expansion uses:

    RotWord
    SubWord
    Rcon
    XOR operations


The AES S-box is reused for SubWord.


============================================================
15. AES ROUND
============================================================

Module:

    aes_round

Used for:

    AES rounds 1 through 9


Data path:

    State
      |
      v
    SubBytes
      |
      v
    ShiftRows
      |
      v
    MixColumns
      |
      v
    AddRoundKey
      |
      v
    New State


One physical aes_round module is reused for
multiple AES rounds.

We DO NOT instantiate nine separate AES round blocks.


============================================================
16. AES FINAL ROUND
============================================================

Module:

    aes_final_round

Used for:

    AES round 10


Data path:

    State
      |
      v
    SubBytes
      |
      v
    ShiftRows
      |
      v
    AddRoundKey
      |
      v
    Ciphertext


IMPORTANT:

    MixColumns is NOT performed in Round 10.


============================================================
17. ROUND CONTROLLER
============================================================

Module:

    round_controller

Controls the AES encryption sequence.

Sequence:

    IDLE
      |
      | start
      v
    INIT
      |
      v
    ROUND 1
      |
      v
    ROUND 2
      |
      v
    ROUND 3
      |
      v
    ...
      |
      v
    ROUND 9
      |
      v
    FINAL ROUND 10
      |
      v
    DONE
      |
      v
    IDLE


Round numbering:

    round = 0
        -> initial AddRoundKey

    round = 1 ... 9
        -> normal AES round

    round = 10
        -> final AES round


============================================================
18. AES CORE ARCHITECTURE
============================================================

The AES core uses an ITERATIVE architecture.

There is only:

    ONE aes_round datapath

That hardware is reused for:

    Round 1
    Round 2
    ...
    Round 9


Conceptually:

             +-------------+
             |  aes_round  |
             +------+------+
                    |
                    v
              state register
                    |
                    | next clock
                    v
             +-------------+
             |  aes_round  |
             +------+------+
                    |
                    v
              state register
                    |
                   ...


ADVANTAGE:

    Smaller hardware area.

TRADEOFF:

    More clock cycles per encryption.

This gives an important VLSI area-vs-performance
tradeoff for analysis.


============================================================
19. COMPLETE AES ENCRYPTION FLOW
============================================================

Input:

    Plaintext
    Key

        |
        v

    Initial AddRoundKey
        |
        v
    Round 1
        |
        v
    Round 2
        |
        v
       ...
        |
        v
    Round 9
        |
        v
    Round 10
        |
        v
    Ciphertext


Round 1-9:

    SubBytes
    ShiftRows
    MixColumns
    AddRoundKey


Round 10:

    SubBytes
    ShiftRows
    AddRoundKey


============================================================
20. OFFICIAL AES-128 TEST VECTOR
============================================================

Plaintext:

    00112233445566778899AABBCCDDEEFF

Key:

    000102030405060708090A0B0C0D0E0F

Expected ciphertext:

    69C4E0D86A7B0430D8CDB78070B4C55A


32-bit representation:

Plaintext:

    00112233
    44556677
    8899AABB
    CCDDEEFF

Key:

    00010203
    04050607
    08090A0B
    0C0D0E0F

Ciphertext:

    69C4E0D8
    6A7B0430
    D8CDB780
    70B4C55A


============================================================
21. CURRENT VERIFICATION STATUS
============================================================

aes_sbox:

    PASS

sub_bytes:

    PASS

shift_rows:

    PASS

mix_columns:

    PASS

add_round_key:

    PASS

key_expansion:

    PASS
    Round 0 through Round 10 verified

aes_round:

    PASS

aes_final_round:

    PASS

round_controller:

    PASS

aes_core:

    PASS


Complete AES-128 test:

    PASS


Plaintext:

    00112233445566778899AABBCCDDEEFF

Key:

    000102030405060708090A0B0C0D0E0F

Ciphertext:

    69C4E0D86A7B0430D8CDB78070B4C55A


============================================================
22. SOFTWARE WORKFLOW
============================================================

Software should perform:

    1. Write plaintext_0
    2. Write plaintext_1
    3. Write plaintext_2
    4. Write plaintext_3

    5. Write key_0
    6. Write key_1
    7. Write key_2
    8. Write key_3

    9. Write CONTROL.START = 1

    10. Wait for STATUS.DONE

    11. Read ciphertext_0
    12. Read ciphertext_1
    13. Read ciphertext_2
    14. Read ciphertext_3

    15. Compare result against expected AES ciphertext.


============================================================
23. SOFTWARE PSEUDOCODE
============================================================

aes_write_plaintext(
    0x00112233,
    0x44556677,
    0x8899AABB,
    0xCCDDEEFF
);

aes_write_key(
    0x00010203,
    0x04050607,
    0x08090A0B,
    0x0C0D0E0F
);

aes_start();

while (!aes_done())
    ;

ciphertext_0 = aes_read(0x28);
ciphertext_1 = aes_read(0x2C);
ciphertext_2 = aes_read(0x30);
ciphertext_3 = aes_read(0x34);


Expected:

    ciphertext_0 = 0x69C4E0D8
    ciphertext_1 = 0x6A7B0430
    ciphertext_2 = 0xD8CDB780
    ciphertext_3 = 0x70B4C55A


============================================================
24. VLSI / PERFORMANCE WORK
============================================================

After X-HEEP integration, measure:

    1. Area
    2. Timing
    3. Maximum frequency
    4. Power
    5. Encryption latency
    6. Hardware cycles per AES block
    7. Software AES cycles
    8. Hardware/software speedup


Main architectural tradeoff:

    Iterative AES
        |
        +-- Lower area
        |
        +-- Higher latency
        |
        +-- Hardware reused across rounds


Potential future optimization:

    Parallel/unrolled AES rounds

but this is NOT the current architecture.


============================================================
25. PROJECT RESPONSIBILITY SPLIT
============================================================

HARDWARE:

    AES RTL
    X-HEEP peripheral wrapper
    Memory-mapped registers
    Integration
    RTL simulation
    Synthesis
    Timing
    Area
    Power


SOFTWARE:

    X-HEEP driver
    C firmware
    Register access
    AES test vectors
    Hardware verification from software
    Software AES reference
    Hardware vs software benchmark
    Cycle-count comparison


============================================================
26. IMPORTANT CURRENT STATUS
============================================================

STANDALONE AES CORE:

    COMPLETE AND VERIFIED.


NOT YET COMPLETE:

    X-HEEP peripheral wrapper
    X-HEEP SoC integration
    C driver
    Firmware
    Hardware/software benchmark
    VLSI synthesis
    PPA analysis


The X-HEEP wrapper should be the ONLY layer that needs
to know about X-HEEP-specific bus/peripheral signals.

The internal AES modules should remain independent of X-HEEP.


============================================================
END OF SPECIFICATION
============================================================