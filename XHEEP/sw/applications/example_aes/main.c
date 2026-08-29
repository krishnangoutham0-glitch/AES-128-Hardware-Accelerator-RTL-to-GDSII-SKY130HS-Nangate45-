// Copyright EPFL and Politecnico di Torino contributors.
// Licensed under the Apache License, Version 2.0, see LICENSE for details.
// SPDX-License-Identifier: Apache-2.0
//
// example_aes: exercises the AES-128 peripheral against the FIPS-197
// Appendix B known-answer test vector.
//
//   key        = 000102030405060708090a0b0c0d0e0f
//   plaintext  = 00112233445566778899aabbccddeeff
//   ciphertext = 69c4e0d86a7b0430d8cdb78070b4c55a   (expected)

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include "aes.h"                       // regtool-generated register offsets
#include "core_v_mini_mcu.h"           // provides AES_START_ADDRESS
#include "mmio.h"

int main(int argc, char *argv[]) {

    mmio_region_t aes_base = mmio_region_from_addr(AES_START_ADDRESS);

    // ------------------------------------------------------------------
    // FIPS-197 Appendix B test vector
    // ------------------------------------------------------------------
    const uint32_t plaintext[4] = {
        0x00112233, 0x44556677, 0x8899aabb, 0xccddeeff
    };
    const uint32_t key[4] = {
        0x00010203, 0x04050607, 0x08090a0b, 0x0c0d0e0f
    };
    const uint32_t expected_ciphertext[4] = {
        0x69c4e0d8, 0x6a7b0430, 0xd8cdb780, 0x70b4c55a
    };

    // ------------------------------------------------------------------
    // Load plaintext and key
    // ------------------------------------------------------------------
    mmio_region_write32(aes_base, AES_PLAINTEXT_0_REG_OFFSET, plaintext[0]);
    mmio_region_write32(aes_base, AES_PLAINTEXT_1_REG_OFFSET, plaintext[1]);
    mmio_region_write32(aes_base, AES_PLAINTEXT_2_REG_OFFSET, plaintext[2]);
    mmio_region_write32(aes_base, AES_PLAINTEXT_3_REG_OFFSET, plaintext[3]);

    mmio_region_write32(aes_base, AES_KEY_0_REG_OFFSET, key[0]);
    mmio_region_write32(aes_base, AES_KEY_1_REG_OFFSET, key[1]);
    mmio_region_write32(aes_base, AES_KEY_2_REG_OFFSET, key[2]);
    mmio_region_write32(aes_base, AES_KEY_3_REG_OFFSET, key[3]);

    // ------------------------------------------------------------------
    // Trigger encryption
    //
    // NOTE: CONTROL.START is currently a plain rw bit with no hwqe pulse
    // (see earlier review), so aes_start stays asserted for as long as
    // this bit reads 1. We must explicitly clear it after triggering,
    // or the round_controller will immediately restart encryption every
    // time it returns to idle.
    // ------------------------------------------------------------------
    mmio_region_write32(aes_base, AES_CONTROL_REG_OFFSET, 1u << AES_CONTROL_START_BIT);
    mmio_region_write32(aes_base, AES_CONTROL_REG_OFFSET, 0);

    // ------------------------------------------------------------------
    // Poll STATUS.DONE
    // ------------------------------------------------------------------
    uint32_t status;
    do {
    status = mmio_region_read32(aes_base, AES_STATUS_REG_OFFSET);
    } while (status & (1u << AES_STATUS_BUSY_BIT));

    // ------------------------------------------------------------------
    // Read back ciphertext
    // ------------------------------------------------------------------
    uint32_t ciphertext[4];
    ciphertext[0] = mmio_region_read32(aes_base, AES_CIPHERTEXT_0_REG_OFFSET);
    ciphertext[1] = mmio_region_read32(aes_base, AES_CIPHERTEXT_1_REG_OFFSET);
    ciphertext[2] = mmio_region_read32(aes_base, AES_CIPHERTEXT_2_REG_OFFSET);
    ciphertext[3] = mmio_region_read32(aes_base, AES_CIPHERTEXT_3_REG_OFFSET);

    printf("AES ciphertext: %08x%08x%08x%08x\n",
           ciphertext[0], ciphertext[1], ciphertext[2], ciphertext[3]);

    // ------------------------------------------------------------------
    // Compare against the known-answer vector
    // ------------------------------------------------------------------
    int pass = 1;
    for (int i = 0; i < 4; i++) {
        if (ciphertext[i] != expected_ciphertext[i]) {
            pass = 0;
        }
    }

    if (pass) {
        printf("AES test PASSED\n");
    } else {
        printf("AES test FAILED\n");
        printf("Expected:       %08x%08x%08x%08x\n",
               expected_ciphertext[0], expected_ciphertext[1],
               expected_ciphertext[2], expected_ciphertext[3]);
    }

    return pass ? EXIT_SUCCESS : EXIT_FAILURE;
}
