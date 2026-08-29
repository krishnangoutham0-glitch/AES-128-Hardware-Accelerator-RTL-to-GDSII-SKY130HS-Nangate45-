// Generated register defines for aes

// Copyright information found in source file:
// Copyright EPFL and Politecnico di Torino contributors.

// Licensing information found in source file:
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0

#ifndef _AES_REG_DEFS_
#define _AES_REG_DEFS_

#ifdef __cplusplus
extern "C" {
#endif
// Register width
#define AES_PARAM_REG_WIDTH 32

// Plaintext bits [127:96]
#define AES_PLAINTEXT_0_REG_OFFSET 0x0

// Plaintext bits [95:64]
#define AES_PLAINTEXT_1_REG_OFFSET 0x4

// Plaintext bits [63:32]
#define AES_PLAINTEXT_2_REG_OFFSET 0x8

// Plaintext bits [31:0]
#define AES_PLAINTEXT_3_REG_OFFSET 0xc

// AES key bits [127:96]
#define AES_KEY_0_REG_OFFSET 0x10

// AES key bits [95:64]
#define AES_KEY_1_REG_OFFSET 0x14

// AES key bits [63:32]
#define AES_KEY_2_REG_OFFSET 0x18

// AES key bits [31:0]
#define AES_KEY_3_REG_OFFSET 0x1c

// AES accelerator control register
#define AES_CONTROL_REG_OFFSET 0x20
#define AES_CONTROL_START_BIT 0

// AES accelerator status register
#define AES_STATUS_REG_OFFSET 0x24
#define AES_STATUS_BUSY_BIT 0
#define AES_STATUS_DONE_BIT 1

// Ciphertext bits [127:96]
#define AES_CIPHERTEXT_0_REG_OFFSET 0x28

// Ciphertext bits [95:64]
#define AES_CIPHERTEXT_1_REG_OFFSET 0x2c

// Ciphertext bits [63:32]
#define AES_CIPHERTEXT_2_REG_OFFSET 0x30

// Ciphertext bits [31:0]
#define AES_CIPHERTEXT_3_REG_OFFSET 0x34

#ifdef __cplusplus
}  // extern "C"
#endif
#endif  // _AES_REG_DEFS_
// End generated register defines for aes