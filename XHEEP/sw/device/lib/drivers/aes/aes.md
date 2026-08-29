## Summary

| Name                                | Offset   |   Length | Description                      |
|:------------------------------------|:---------|---------:|:---------------------------------|
| aes.[`PLAINTEXT_0`](#plaintext_0)   | 0x0      |        4 | Plaintext bits [127:96]          |
| aes.[`PLAINTEXT_1`](#plaintext_1)   | 0x4      |        4 | Plaintext bits [95:64]           |
| aes.[`PLAINTEXT_2`](#plaintext_2)   | 0x8      |        4 | Plaintext bits [63:32]           |
| aes.[`PLAINTEXT_3`](#plaintext_3)   | 0xc      |        4 | Plaintext bits [31:0]            |
| aes.[`KEY_0`](#key_0)               | 0x10     |        4 | AES key bits [127:96]            |
| aes.[`KEY_1`](#key_1)               | 0x14     |        4 | AES key bits [95:64]             |
| aes.[`KEY_2`](#key_2)               | 0x18     |        4 | AES key bits [63:32]             |
| aes.[`KEY_3`](#key_3)               | 0x1c     |        4 | AES key bits [31:0]              |
| aes.[`CONTROL`](#control)           | 0x20     |        4 | AES accelerator control register |
| aes.[`STATUS`](#status)             | 0x24     |        4 | AES accelerator status register  |
| aes.[`CIPHERTEXT_0`](#ciphertext_0) | 0x28     |        4 | Ciphertext bits [127:96]         |
| aes.[`CIPHERTEXT_1`](#ciphertext_1) | 0x2c     |        4 | Ciphertext bits [95:64]          |
| aes.[`CIPHERTEXT_2`](#ciphertext_2) | 0x30     |        4 | Ciphertext bits [63:32]          |
| aes.[`CIPHERTEXT_3`](#ciphertext_3) | 0x34     |        4 | Ciphertext bits [31:0]           |

## PLAINTEXT_0
Plaintext bits [127:96]
- Offset: `0x0`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description      |
|:------:|:------:|:-------:|:-------|:-----------------|
|  31:0  |   rw   |    x    | DATA   | Plaintext word 0 |

## PLAINTEXT_1
Plaintext bits [95:64]
- Offset: `0x4`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description      |
|:------:|:------:|:-------:|:-------|:-----------------|
|  31:0  |   rw   |    x    | DATA   | Plaintext word 1 |

## PLAINTEXT_2
Plaintext bits [63:32]
- Offset: `0x8`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description      |
|:------:|:------:|:-------:|:-------|:-----------------|
|  31:0  |   rw   |    x    | DATA   | Plaintext word 2 |

## PLAINTEXT_3
Plaintext bits [31:0]
- Offset: `0xc`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description      |
|:------:|:------:|:-------:|:-------|:-----------------|
|  31:0  |   rw   |    x    | DATA   | Plaintext word 3 |

## KEY_0
AES key bits [127:96]
- Offset: `0x10`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:0  |   rw   |    x    | DATA   | Key word 0    |

## KEY_1
AES key bits [95:64]
- Offset: `0x14`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:0  |   rw   |    x    | DATA   | Key word 1    |

## KEY_2
AES key bits [63:32]
- Offset: `0x18`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:0  |   rw   |    x    | DATA   | Key word 2    |

## KEY_3
AES key bits [31:0]
- Offset: `0x1c`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["rw"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description   |
|:------:|:------:|:-------:|:-------|:--------------|
|  31:0  |   rw   |    x    | DATA   | Key word 3    |

## CONTROL
AES accelerator control register
- Offset: `0x20`
- Reset default: `0x0`
- Reset mask: `0x1`

### Fields

```wavejson
{"reg": [{"name": "START", "bits": 1, "attr": ["rw"], "rotate": -90}, {"bits": 31}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description          |
|:------:|:------:|:-------:|:-------|:---------------------|
|  31:1  |        |         |        | Reserved             |
|   0    |   rw   |    x    | START  | Start AES encryption |

## STATUS
AES accelerator status register
- Offset: `0x24`
- Reset default: `0x0`
- Reset mask: `0x3`

### Fields

```wavejson
{"reg": [{"name": "BUSY", "bits": 1, "attr": ["ro"], "rotate": -90}, {"name": "DONE", "bits": 1, "attr": ["ro"], "rotate": -90}, {"bits": 30}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description                             |
|:------:|:------:|:-------:|:-------|:----------------------------------------|
|  31:2  |        |         |        | Reserved                                |
|   1    |   ro   |    x    | DONE   | AES encryption operation has completed  |
|   0    |   ro   |    x    | BUSY   | AES accelerator is currently processing |

## CIPHERTEXT_0
Ciphertext bits [127:96]
- Offset: `0x28`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description       |
|:------:|:------:|:-------:|:-------|:------------------|
|  31:0  |   ro   |    x    | DATA   | Ciphertext word 0 |

## CIPHERTEXT_1
Ciphertext bits [95:64]
- Offset: `0x2c`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description       |
|:------:|:------:|:-------:|:-------|:------------------|
|  31:0  |   ro   |    x    | DATA   | Ciphertext word 1 |

## CIPHERTEXT_2
Ciphertext bits [63:32]
- Offset: `0x30`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description       |
|:------:|:------:|:-------:|:-------|:------------------|
|  31:0  |   ro   |    x    | DATA   | Ciphertext word 2 |

## CIPHERTEXT_3
Ciphertext bits [31:0]
- Offset: `0x34`
- Reset default: `0x0`
- Reset mask: `0xffffffff`

### Fields

```wavejson
{"reg": [{"name": "DATA", "bits": 32, "attr": ["ro"], "rotate": 0}], "config": {"lanes": 1, "fontsize": 10, "vspace": 80}}
```

|  Bits  |  Type  |  Reset  | Name   | Description       |
|:------:|:------:|:-------:|:-------|:------------------|
|  31:0  |   ro   |    x    | DATA   | Ciphertext word 3 |

