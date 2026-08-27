# DestByte8 CPU Architecture Specification

**Architecture:** DestByte8

**Class:** 8-bit CPU

**Instruction width:** 8 bits

**Data width:** 8 bits

**Register count:** 8

**Register width:** 8 bits

**Program Counter width:** 8 bits

**Instruction memory:** 256 × 8 bits

**ISA status:** Initial implementation

**Hardware description:** Verilog RTL

**Hardware license:** CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S)



## 1. Overview

DestByte8 is an 8-bit processor architecture designed and implemented from scratch.

The architecture uses fixed-width 8-bit instructions and 8-bit data.

The current instruction execution path consists of:

```text
PC
 ↓
Instruction ROM
 ↓
Decoder
 ↓
Register File
 ↓
ALU
 ↓
Register File
```

The current RTL implementation contains:

* Program Counter;
* PC-next logic;
* instruction ROM;
* instruction decoder;
* register file;
* arithmetic logic unit (ALU);
* top-level CPU interconnection.

The ISA defines the architectural behavior. The Verilog RTL is the current implementation of that behavior.

Features that are not defined by the ISA are considered implementation details unless explicitly specified.


# 2. Architectural Parameters

| Feature             | Current specification |
| ------------------- | --------------------- |
| Data width          | 8 bits                |
| Instruction width   | 8 bits                |
| Program Counter     | 8 bits                |
| Registers           | 8                     |
| Register names      | T0–T7                 |
| Register width      | 8 bits                |
| Register selector   | 3 bits                |
| ALU input width     | 8 bits                |
| ALU result width    | 8 bits                |
| ALU control         | 3 bits                |
| Instruction opcode  | 2 bits                |
| Instruction memory  | 256 × 8 bits          |
| Instruction address | 8 bits                |
| Flags               | Not implemented       |
| Stack pointer       | Not implemented       |
| Interrupts          | Not implemented       |
| Data RAM            | Not implemented       |
| Branch instructions | Not implemented       |


# 3. Register File

DestByte8 contains eight general-purpose registers:

```text
T0
T1
T2
T3
T4
T5
T6
T7
```

Each register stores one 8-bit value.

A register is selected using a 3-bit register selector.

| Selector | Register |
| -------- | -------- |
| `000`    | T0       |
| `001`    | T1       |
| `010`    | T2       |
| `011`    | T3       |
| `100`    | T4       |
| `101`    | T5       |
| `110`    | T6       |
| `111`    | T7       |

All eight registers are therefore directly addressable.

## 3.1 Register File Ports

The current register file provides:

* one synchronous write port;
* two combinational read ports.

Conceptually:

```text
r_addr1 → r_data1
r_addr2 → r_data2

w_addr  → destination register
w_data  → data written
we      → write enable
clk     → clock
reset   → reset
```

The two read addresses independently select two registers.

For an instruction using destination field `D` and source field `S`:

```text
r_addr1 = D
r_addr2 = S
w_addr  = D
```

The intended architectural write-back operation is therefore:

```text
T[D] ← ALU result
```

Writes occur on the active clock edge when write enable is asserted.

The current RTL also clears the register file during reset.


# 4. Instruction Format

Every DestByte8 instruction occupies exactly one byte.

```text
Bit:     7 6 | 5 4 3 | 2 1 0
        ─────┼───────┼───────
        OPC  │   D   │   S
```

The instruction is divided into three fields:

| Bits    | Field  |  Width | Purpose                         |
| ------- | ------ | -----: | ------------------------------- |
| `[7:6]` | OPCODE | 2 bits | Selects the operation           |
| `[5:3]` | D      | 3 bits | Destination / first ALU operand |
| `[2:0]` | S      | 3 bits | Second ALU operand              |

Total:

```text
2 + 3 + 3 = 8 bits
```

The current instruction format contains:

* no immediate field;
* no memory-address field;
* no operand-size field.


# 5. Instruction Encoding

The two most significant bits select the instruction group:

```text
OPCODE = instruction[7:6]
D      = instruction[5:3]
S      = instruction[2:0]
```

Current allocation:

| Opcode | Instruction | Status      |
| ------ | ----------- | ----------- |
| `00`   | ADD         | Implemented |
| `01`   | SUB         | Implemented |
| `10`   | —           | Reserved    |
| `11`   | —           | Reserved    |


# 6. ADD

## Encoding

```text
00 DDD SSS
```

## Semantics

```text
T[D] ← T[D] + T[S]
```

The `D` field has two roles:

1. selects the first ALU operand;
2. selects the destination register.

The `S` field selects the second ALU operand.

### Example

Given:

```text
T0 = 5
T1 = 3
```

Instruction:

```text
00 000 001
```

Fields:

```text
OPCODE = 00
D      = 000 → T0
S      = 001 → T1
```

Execution:

```text
T0 ← T0 + T1
T0 ← 5 + 3
T0 ← 8
```

Encoding:

```text
00000001 = 0x01
```

Therefore:

```text
0x01 = ADD T0,T1
```


# 7. SUB

## Encoding

```text
01 DDD SSS
```

## Semantics

```text
T[D] ← T[D] - T[S]
```

### Example

Given:

```text
T2 = 10
T3 = 4
```

Instruction:

```text
01 010 011
```

Fields:

```text
OPCODE = 01
D      = 010 → T2
S      = 011 → T3
```

Execution:

```text
T2 ← T2 - T3
T2 ← 10 - 4
T2 ← 6
```

Encoding:

```text
01010011 = 0x53
```

Therefore:

```text
0x53 = SUB T2,T3
```


# 8. Complete Opcode Space

Because the opcode contains two bits, there are four opcode groups.

Each group contains:

```text
8 × 8 = 64
```

possible register combinations.

Current allocation:

```text
0x00–0x3F = ADD
0x40–0x7F = SUB
0x80–0xBF = RESERVED
0xC0–0xFF = RESERVED
```

Therefore:

```text
64 ADD encodings
64 SUB encodings
128 reserved encodings
```


# 9. ADD Encoding Range

All instructions with opcode `00` are ADD instructions.

Range:

```text
0x00–0x3F
```

General encoding:

```text
00 DDD SSS
```

Examples:

| Byte   | Binary     | Instruction |
| ------ | ---------- | ----------- |
| `0x00` | `00000000` | `ADD T0,T0` |
| `0x01` | `00000001` | `ADD T0,T1` |
| `0x02` | `00000010` | `ADD T0,T2` |
| `0x07` | `00000111` | `ADD T0,T7` |
| `0x08` | `00001000` | `ADD T1,T0` |
| `0x10` | `00010000` | `ADD T2,T0` |
| `0x18` | `00011000` | `ADD T3,T0` |
| `0x20` | `00100000` | `ADD T4,T0` |
| `0x28` | `00101000` | `ADD T5,T0` |
| `0x30` | `00110000` | `ADD T6,T0` |
| `0x38` | `00111000` | `ADD T7,T0` |
| `0x3F` | `00111111` | `ADD T7,T7` |


# 10. SUB Encoding Range

All instructions with opcode `01` are SUB instructions.

Range:

```text
0x40–0x7F
```

General encoding:

```text
01 DDD SSS
```

Examples:

| Byte   | Binary     | Instruction |
| ------ | ---------- | ----------- |
| `0x40` | `01000000` | `SUB T0,T0` |
| `0x41` | `01000001` | `SUB T0,T1` |
| `0x42` | `01000010` | `SUB T0,T2` |
| `0x48` | `01001000` | `SUB T1,T0` |
| `0x50` | `01010000` | `SUB T2,T0` |
| `0x53` | `01010011` | `SUB T2,T3` |
| `0x60` | `01100000` | `SUB T4,T0` |
| `0x70` | `01110000` | `SUB T6,T0` |
| `0x78` | `01111000` | `SUB T7,T0` |
| `0x7F` | `01111111` | `SUB T7,T7` |


# 11. Reserved Opcode Space

The opcode values:

```text
10
11
```

are reserved.

Corresponding ranges:

```text
0x80–0xBF
0xC0–0xFF
```

These encodings currently do not define architectural instructions.

The current decoder disables register writes for these opcode values.

Software must not depend on the current internal behavior of reserved encodings.

Future ISA revisions may assign these opcode groups to new instructions.


# 12. Decoder

The decoder receives the complete instruction:

```text
instruction[7:0]
```

It produces:

```text
alu_control
w_addr
r_addr1
r_addr2
reg_we
```

Current field extraction:

```text
w_addr  = instruction[5:3]
r_addr1 = instruction[5:3]
r_addr2 = instruction[2:0]
```

Therefore:

```text
w_addr  = D
r_addr1 = D
r_addr2 = S
```

Current control mapping:

| Opcode | `alu_control` | `reg_we` |
| ------ | ------------- | -------: |
| `00`   | `000`         |      `1` |
| `01`   | `001`         |      `1` |
| `10`   | `000`         |      `0` |
| `11`   | `000`         |      `0` |

The decoder initializes its outputs to safe default values and disables register writes for unsupported opcode groups.


# 13. ALU

The ALU receives two 8-bit operands:

```text
A[7:0]
B[7:0]
```

and a 3-bit operation selector:

```text
alu_control[2:0]
```

It produces an 8-bit result:

```text
result[7:0]
```

Current operation mapping:

| `alu_control` | Operation |
| ------------- | --------- |
| `000`         | `A + B`   |
| `001`         | `A - B`   |
| Other         | `0x00`    |

The current ALU does not expose arithmetic flags.

There are currently no architectural:

* Zero flag;
* Carry flag;
* Borrow flag;
* Negative/Sign flag;
* Overflow flag.

Arithmetic results are limited to eight bits.

Therefore, the implemented arithmetic naturally retains the lower eight bits of the result.

Example:

```text
0xFF + 0x01 = 0x00
```

because the ninth carry bit is not part of the current ALU result.

---

# 14. Program Counter

The Program Counter is 8 bits wide.

Its address range is:

```text
0x00–0xFF
```

The current PC implementation provides:

```text
clk
reset
pc_next
pc_out
```

The PC receives the next value generated by the PC-next logic.

Current sequential execution uses:

```text
PC_next = PC + 1
```

Therefore, in the absence of another control-flow mechanism:

```text
PC ← PC + 1
```

The PC supplies the instruction ROM address:

```text
PC → ROM.addr
```

The current ISA contains no instruction that modifies the PC.

---

# 15. PC-Next Logic

The current PC-next module implements simple sequential advancement:

```text
pc_next = pc + 8'd1
```

The logic is combinational.

It does not currently implement:

* branches;
* jumps;
* calls;
* returns;
* conditional control flow.

A future control unit may replace or control this simple sequential path when additional control-flow instructions are introduced.


# 16. Instruction ROM

The instruction ROM contains:

```text
256 entries × 8 bits
```

Address width:

```text
8 bits
```

Data width:

```text
8 bits
```

Connection:

```text
PC → ROM address
ROM → instruction
```

The current ROM implementation explicitly initializes only selected addresses.

Current initialization:

```text
Address    Byte
0x00       0x00
0x01       0x20
```

These bytes decode according to the current ISA as:

```text
0x00 → ADD T0,T0
0x20 → ADD T4,T0
```

Only explicitly initialized ROM contents are defined by the current ROM source.

Uninitialized locations must not be treated as valid program instructions.


# 17. Current ROM Program

The current ROM program contains:

```text
Address   Byte
----------------
0x00      0x00
0x01      0x20
```

## Address `0x00`

```text
0x00
00000000
```

Fields:

```text
OPCODE = 00
D      = 000 → T0
S      = 000 → T0
```

Instruction:

```text
ADD T0,T0
```

Intended architectural operation:

```text
T0 ← T0 + T0
```

## Address `0x01`

```text
0x20
00100000
```

Fields:

```text
OPCODE = 00
D      = 100 → T4
S      = 000 → T0
```

Instruction:

```text
ADD T4,T0
```

Intended architectural operation:

```text
T4 ← T4 + T0
```

Therefore the intended two-instruction sequence is:

```text
T0 ← T0 + T0
T4 ← T4 + T0
```

The actual execution of this sequence must be verified by simulation.


# 18. Datapath

The current processor datapath is:

```text
             ┌────────────┐
             │     PC     │
             └─────┬──────┘
                   │
                   ▼
             ┌────────────┐
             │    ROM     │
             └─────┬──────┘
                   │
             instruction
                   │
                   ▼
             ┌────────────┐
             │  DECODER   │
             └──┬─────┬───┘
                │     │
          register   control
           fields
                │     │
                ▼     ▼
          ┌────────────────┐
          │ REGISTER FILE  │
          └──────┬───┬─────┘
                 │   │
                 A   B
                  \ /
                   ▼
              ┌─────────┐
              │   ALU   │
              └────┬────┘
                   │
              ALU result
                   │
                   ▼
          ┌────────────────┐
          │ REGISTER FILE  │
          └────────────────┘
```

The current top-level CPU also exposes the ALU result through:

```text
result[7:0]
```

The PC may additionally be exposed through a debug output in the RTL implementation.

A debug signal is not automatically part of the ISA.



# 19. Instruction Execution

The current intended execution process is divided into the following logical stages.

## 19.1 Fetch

The PC supplies the ROM address:

```text
PC → ROM
```

The ROM provides one instruction byte:

```text
ROM → instruction
```

## 19.2 Decode

The decoder extracts:

```text
opcode = instruction[7:6]
D      = instruction[5:3]
S      = instruction[2:0]
```

It then generates the register addresses and ALU control.

## 19.3 Register Read

The register file provides:

```text
A = T[D]
B = T[S]
```

## 19.4 Execute

The ALU performs the operation selected by the opcode:

```text
ADD:
A + B

SUB:
A - B
```

## 19.5 Write Back

For the currently implemented ADD and SUB instructions:

```text
T[D] ← ALU result
```

## 19.6 PC Update

The current sequential PC logic generates:

```text
PC_next = PC + 1
```

The PC therefore advances to the next instruction.



# 20. Reset

Reset behavior is part of the RTL implementation and must be distinguished from ISA semantics.

The current implementation resets the PC to:

```text
0x00
```

The register file is also reset to:

```text
T0 = 0x00
T1 = 0x00
T2 = 0x00
T3 = 0x00
T4 = 0x00
T5 = 0x00
T6 = 0x00
T7 = 0x00
```

Register writes are disabled while reset is asserted through the top-level write-enable condition:

```text
reg_we & ~reset
```

The exact synchronous/asynchronous timing semantics of reset are determined by the sequential RTL implementation.



# 21. CPU Interface

The current top-level CPU exposes:

```text
input  clk
input  reset
output [7:0] result
```

The RTL may also expose debug signals such as:

```text
pc_debug[7:0]
```

## `clk`

System clock.

## `reset`

Processor reset input.

## `result`

Current ALU result.

## `pc_debug`

Current PC value for simulation/debugging when present in the RTL.

`pc_debug` is an implementation/debug interface and is not an architectural register or ISA instruction field.



# 22. Architectural State

The current architectural register state consists of:

```text
T0
T1
T2
T3
T4
T5
T6
T7
```

The PC is also processor state used to determine the next instruction.

Each state element is 8 bits wide.

The architecture currently defines no:

* flag register;
* status register;
* stack pointer;
* general-purpose memory state.



# 23. Memory Model

The current implementation provides instruction ROM:

```text
256 × 8 bits
```

The current ISA does not define a separate data-memory address space.

There are currently no architectural instructions for:

* load;
* store;
* memory addressing;
* memory-mapped I/O.

Therefore the current ROM represents instruction storage rather than general-purpose data memory.



# 24. Control Flow

The current instruction set does not contain:

```text
JMP
CALL
RET
conditional branch
indirect jump
```

No current instruction directly modifies the PC.

Sequential execution is currently based on:

```text
PC_next = PC + 1
```

Future control-flow instructions will require both ISA definitions and corresponding hardware changes.



# 25. Flags

DestByte8 currently has no architectural flags.

The following are not implemented:

```text
Z = Zero
C = Carry
N = Negative
V = Overflow
B = Borrow
```

The ALU therefore produces only the 8-bit result.

If flags are introduced in a future revision, their encoding, update rules, and interaction with instructions must be explicitly defined by the ISA.



# 26. Reserved and Undefined Behavior

The following opcode groups are reserved:

```text
10
11
```

Corresponding ranges:

```text
0x80–0xBF
0xC0–0xFF
```

These encodings do not currently represent valid instructions.

Software must not rely on the internal behavior of reserved encodings.

Future ISA revisions may assign these opcode groups to new instructions.

ROM locations not explicitly initialized by the current ROM implementation are also not defined as program instructions.



# 27. Current Instruction Summary

```text
┌────────┬──────────┬─────────────────────────────┐
│ Opcode │ Mnemonic │ Operation                   │
├────────┼──────────┼─────────────────────────────┤
│ 00     │ ADD      │ T[D] ← T[D] + T[S]         │
│ 01     │ SUB      │ T[D] ← T[D] - T[S]         │
│ 10     │ —        │ Reserved                    │
│ 11     │ —        │ Reserved                    │
└────────┴──────────┴─────────────────────────────┘
```



# 28. Complete Byte Layout

The complete instruction byte is:

```text
7       6 5       3 2       0
┌─────────┬─────────┬─────────┐
│  OPCODE │    D    │    S    │
│  2 bits │  3 bits │  3 bits │
└─────────┴─────────┴─────────┘
```

Interpretation:

```text
instruction[7:6] → operation
instruction[5:3] → destination / first operand
instruction[2:0] → second operand
```

Example:

```text
0x53 = 01010011
       ──┬─┬───
         │ │
         │ └── S = 011 = T3
         └──── D = 010 = T2
       opcode = 01 = SUB
```

Therefore:

```text
0x53 = SUB T2,T3
```


# 29. ISA Capacity

The current instruction format allocates:

```text
2 bits → opcode
3 bits → destination
3 bits → source
```

This provides:

```text
4 opcode groups
8 destination registers
8 source registers
```

Total possible byte encodings:

```text
4 × 8 × 8 = 256
```

Current allocation:

```text
64 ADD encodings
64 SUB encodings
128 reserved encodings
```

The two reserved opcode groups provide room for future ISA expansion while preserving the current 8-bit instruction width.

# 30. Current Limitations

The following features are not currently implemented as ISA instructions:

* immediate operands;
* load;
* store;
* logical operations;
* shifts;
* comparisons;
* branches;
* jumps;
* calls;
* returns;
* stack operations;
* flags;
* interrupts;
* exceptions;
* I/O instructions;
* privileged execution modes.

These features must not be considered part of DestByte8 until their encoding, semantics, hardware implementation, and verification are defined.



# 31. RTL Implementation Structure

The current repository separates the processor into hardware modules.

```text
alu/
    alu.v

memory/
    registers_memory.v

rom/
    rom.v

rtl/
    decoder.v
    pc.v
    pc_next.v
    top.v

control/
    control_unit.v

sim/
    simulation infrastructure
```

Current module responsibilities:

| Module               | Responsibility                       |
| -------------------- | ------------------------------------ |
| `alu.v`              | Arithmetic operations                |
| `registers_memory.v` | Register storage and register access |
| `rom.v`              | Instruction storage                  |
| `decoder.v`          | Instruction decoding                 |
| `pc.v`               | Program Counter register             |
| `pc_next.v`          | Sequential PC-next calculation       |
| `control_unit.v`     | Control logic under development      |
| `top.v`              | CPU integration                      |

The exact behavior of `control_unit.v` must be added to this specification once its interface and role in the datapath are finalized.



# 32. Verification Status

The current RTL has been successfully compiled with Verilator.

The current simulation has verified sequential PC advancement under the tested reset conditions:

```text
PC: 0
PC: 1
PC: 2
PC: 3
...
```

This verifies the tested PC progression.

It does **not**, by itself, verify:

* correct instruction decoding;
* correct register reads;
* correct ALU operation;
* correct register write-back;
* correct execution of ADD;
* correct execution of SUB;
* correct behavior of reserved opcodes.

Those behaviors require dedicated simulation tests.



# 33. Architectural Status

The current DestByte8 ISA consists of:

```text
8-bit data
8-bit instructions
8 registers
8-bit PC
256-byte instruction address space
ADD
SUB
```

Current opcode allocation:

```text
00 = ADD
01 = SUB
10 = RESERVED
11 = RESERVED
```

The architecture is intentionally minimal.

Future features should be added by explicitly defining:

1. instruction encoding;
2. instruction semantics;
3. architectural state changes;
4. RTL implementation;
5. verification tests;
6. documentation.

The ISA specification should describe behavior that has been intentionally defined and implemented, while implementation-specific details should remain identified as RTL behavior.



# Appendix A — Register Encoding

```text
000 = T0
001 = T1
010 = T2
011 = T3
100 = T4
101 = T5
110 = T6
111 = T7
```



# Appendix B — Opcode Encoding

```text
00 = ADD
01 = SUB
10 = RESERVED
11 = RESERVED
```



# Appendix C — Representative Encodings

```text
0x00 = ADD T0,T0
0x01 = ADD T0,T1
0x02 = ADD T0,T2
0x07 = ADD T0,T7

0x08 = ADD T1,T0
0x10 = ADD T2,T0
0x18 = ADD T3,T0
0x20 = ADD T4,T0
0x28 = ADD T5,T0
0x30 = ADD T6,T0
0x38 = ADD T7,T0
0x3F = ADD T7,T7

0x40 = SUB T0,T0
0x41 = SUB T0,T1
0x48 = SUB T1,T0
0x50 = SUB T2,T0
0x53 = SUB T2,T3
0x60 = SUB T4,T0
0x70 = SUB T6,T0
0x78 = SUB T7,T0
0x7F = SUB T7,T7

0x80–0xBF = RESERVED
0xC0–0xFF = RESERVED
```
DestByte8 CPU Architecture Specification

Document: Technical Architecture Specification
Architecture: DestByte8
Class: 8-bit CPU
Status: Initial implementation
Repository: icarotelesdasilva/DestByte8
Hardware License: CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S)

1. Overview

The DestByte8 is an 8-bit processor architecture developed from scratch. Its goal is to provide a general-purpose architecture that can evolve over time through the development of both its ISA (Instruction Set Architecture) and hardware implementation.

The current implementation is described in Verilog RTL and organized into independent modules corresponding to the processor’s main units:

* program counter;
* instruction ROM;
* instruction decoder;
* register file;
* arithmetic logic unit (ALU);
* main processor interconnection.

The architecture should not be confused with a simulator. The RTL is the structural and behavioral description of the CPU’s digital hardware. The sim directory, when present in the project, should be treated separately as verification and development infrastructure rather than as the definition of the CPU.

The repository explicitly identifies DestByte8 as an 8-bit CPU built entirely from scratch. See the GitHub repository.

2. Current Architectural Features

Feature	Current Status
Data width	8 bits
Instruction width	8 bits
Program counter width	8 bits
General-purpose registers	8
Register names	T0–T7
Register width	8 bits
Register address width	3 bits
ALU operands	2 × 8 bits
ALU result	8 bits
Current ALU operations	Addition and subtraction
Instruction memory	ROM
ROM address width	8 bits
ROM address space	256 positions
Reset	Asynchronous reset on the PC and register file
PC increment	+1 on each rising clock edge
Flags	Not implemented in the current RTL
Pipeline	Not implemented in the current RTL
Interrupts	Not implemented in the current RTL
Stack pointer	Not implemented in the current RTL

The features above are derived directly from the current implementation in the repository. See the PC implementation.

3. Register Model

DestByte8 provides eight general-purpose registers:

T0
T1
T2
T3
T4
T5
T6
T7

Each register is 8 bits wide.

A register is selected using a 3-bit field:

000 → T0
001 → T1
010 → T2
011 → T3
100 → T4
101 → T5
110 → T6
111 → T7

The register file is implemented as a memory containing eight 8-bit elements. It provides two combinational read ports and one synchronous write port. See the register file implementation.

3.1 Ports

              ┌─────────────────────┐
r_addr1 ─────►│                     │─────► r_data1
r_addr2 ─────►│   REGISTER FILE     │─────► r_data2
w_addr  ─────►│                     │
w_data  ─────►│                     │
we      ─────►│                     │
clk     ─────►│                     │
              └─────────────────────┘

3.2 Read Operation

Register reads are combinational:

r_data1 = T[r_addr1]
r_data2 = T[r_addr2]

Therefore, two operands can be read simultaneously.

3.3 Write Operation

A write occurs on the rising edge of the clock when we is active:

if (we)
    T[w_addr] <= w_data;

This behavior is implemented directly in the registers_memory module. See the register file implementation.

4. Program Counter

The Program Counter (PC) is 8 bits wide.

Its value is updated on the rising edge of the clock.

Under normal operation:

PC ← PC + 1

During reset:

PC ← 0x00

The module uses an asynchronous reset:

always @(posedge clk or posedge reset)

Therefore, the PC can be set to 0x00 when the reset signal is asserted, independently of the clock edge. See the PC implementation.

Since the PC is 8 bits wide, its representable range is:

0x00 – 0xFF

The current behavior is an 8-bit modular increment. Consequently, after 0xFF, the next representable PC value is 0x00.

5. Instruction Memory

The current implementation uses a ROM with:

256 positions
×
8 bits per position

The ROM address is 8 bits wide and is provided directly by the PC:

PC → ROM.address

The ROM output is 8 bits wide:

ROM.data → instruction

The current implementation declares:

reg [7:0] memory [0:255];

and accesses the memory through:

assign data = memory[addr];

Therefore, the current implementation provides 256 instruction addresses, each containing 8 bits. See the ROM implementation.

6. Instruction Format

DestByte8 instructions are 8 bits wide:

 7       6 5       3 2       0
┌─────────┬─────────┬─────────┐
│ OPCODE  │   RD    │   RS    │
└─────────┴─────────┴─────────┘
    2 bits   3 bits   3 bits

Fields:

* instruction[7:6] = operation;
* instruction[5:3] = destination register and first operand;
* instruction[2:0] = second register or operand.

The current decoder uses these fields exactly as described. See the decoder implementation.

7. Current ISA Encoding

The current implementation uses the two most significant instruction bits to select the operation.

7.1 Addition

Opcode:
00

Format:

00 DDD SSS

Semantics:

T[DDD] ← T[DDD] + T[SSS]

The instruction enables register file write access.

The first ALU operand is T[DDD], and the second operand is T[SSS].

The operation is executed by the ALU with:

alu_control = 000

See the decoder implementation.

7.2 Subtraction

Opcode:
01

Format:

01 DDD SSS

Semantics:

T[DDD] ← T[DDD] - T[SSS]

As with addition, DDD simultaneously selects the destination register and the first operand.

The operation is executed by the ALU with:

alu_control = 001

See the decoder implementation.

8. Currently Implemented ISA Table

Bits 7:6	Operation	ALU Control	Write
00	ADD	000	Yes
01	SUB	001	Yes
10	Reserved	000	No
11	Reserved	000	No

The 10 and 11 opcodes do not currently correspond to architectural instructions defined by the decoder.

For these opcode values, the decoder keeps reg_we = 0. Therefore, they should not be documented as valid instructions in the current ISA version. See the decoder implementation.

9. Arithmetic Logic Unit

The ALU receives:

A        : 8 bits
B        : 8 bits
alu_ctrl : 3 bits

and produces:

result   : 8 bits

The current implementation supports two operations:

000 → A + B
001 → A - B

Any other alu_control value produces:

result = 8'h00

See the ALU implementation.

10. Flags

The current ALU implementation does not provide flag outputs.

The ALU currently has no architectural signals corresponding to:

* Zero;
* Carry;
* Borrow;
* Negative/Sign;
* Overflow.

Therefore, none of these flags should be considered part of the current ISA without an explicit architectural change.

11. Datapath

The current datapath can be represented as follows:

             ┌──────────┐
             │    PC    │
             └────┬─────┘
                  │
                  ▼
             ┌──────────┐
             │   ROM    │
             └────┬─────┘
                  │
             instruction
                  │
                  ▼
             ┌──────────┐
             │ DECODER  │
             └─┬──┬──┬──┘
               │  │  │
             addr addr control
               │  │  │
               ▼  ▼  ▼
             ┌───────────┐
             │ REGISTER  │
             │   FILE    │
             └──┬─────┬──┘
                │     │
                ▼     ▼
               A       B
                \     /
                 \   /
                  ▼ ▼
               ┌───────┐
               │  ALU  │
               └───┬───┘
                   │
                   ▼
               result
                   │
                   ├──────────► output
                   │
                   ▼
               REGISTER FILE

The integration of these modules is explicitly implemented in top.v. See the top-level implementation.

12. Basic Operation Cycle

The current implementation can be conceptually described in three stages.

12.1 Fetch

The PC provides the instruction address:

PC → ROM

The ROM returns an 8-bit word:

ROM → instruction

12.2 Decode

The decoder separates the instruction fields:

opcode = instruction[7:6]
destination = instruction[5:3]
source = instruction[2:0]

It then generates the control signals for the rest of the datapath. See the decoder implementation.

12.3 Execute

The selected registers provide operands to the ALU:

T[destination] → ALU.A
T[source]      → ALU.B

The ALU calculates the result.

When the instruction enables reg_we, the result is written back to the register selected by the DDD field. See the top-level implementation.

13. Execution Example

Assume:

T0 = 5
T1 = 3

The instruction:

00 000 001

corresponds to:

ADD T0, T1

The CPU selects:

A = T0 = 5
B = T1 = 3

The ALU calculates:

5 + 3 = 8

The result is written to:

T0 = 8

The hexadecimal representation of the instruction is:

0000 0001
= 0x01

14. Subtraction Example

Assume:

T2 = 10
T3 = 4

The instruction:

01 010 011

corresponds to:

SUB T2, T3

Result:

T2 ← 10 - 4
T2 ← 6

The hexadecimal representation of the instruction is:

0101 0011
= 0x53

15. Reset

The current reset behavior explicitly affects:

* the Program Counter;
* the register file;
* register file write enable.

The PC is set to:

0x00

During reset, T0–T7 are also explicitly reset to:

T0–T7 = 0x00

In addition, top.v prevents register file writes while reset is active:

we = reg_we & ~reset

See the top-level implementation.

The register file resets all eight registers to 0x00 when reset is asserted.

16. Current Core Interface

The top module provides:

input  clk
input  reset
output [7:0] result

The current interface is therefore:

             DestByte8
          ┌──────────────┐
clk ─────►│              │
reset ───►│     CPU      │────► result[7:0]
          │              │
          └──────────────┘

The result signal currently corresponds to the value produced by the ALU. See the top-level implementation.

17. Features Not Yet Defined

The following list should not be interpreted as a deficiency. It represents functionality that is not yet defined in the current RTL.

ISA

* load instructions;
* store instructions;
* logical operations;
* shifts;
* comparisons;
* jumps;
* conditional branches;
* function calls;
* function returns;
* I/O instructions;
* control instructions.

Architectural State

* flag register;
* stack pointer;
* status register;
* special-purpose registers;
* exception mechanism;
* interrupt mechanism.

Memory

* data RAM;
* external memory bus;
* memory-mapped I/O;
* memory map;
* external bus width and protocol.

Control Flow

The PC currently only increments:

PC ← PC + 1

There is currently no RTL logic that changes the PC to another address as the result of an instruction.

Timing

The final documentation should eventually specify:

* maximum frequency;
* clock period;
* instruction latencies;
* relationship between the clock and instruction execution;
* memory access timing;
* external signal behavior.

These parameters depend on the specific physical implementation and should not be inferred solely from the ISA width.

18. Architectural State vs. Implementation

It is important to distinguish between two levels of DestByte8.

ISA

The ISA defines the behavior observable by software.

Currently, this includes:

8-bit instructions
8-bit registers
T0–T7
ADD
SUB
PC

Implementation

The current implementation uses:

Verilog RTL
PC
ROM
decoder
register file
ALU

A future physical implementation may reorganize these internal blocks without necessarily changing the ISA, as long as it preserves the specified architectural behavior.

19. Specification Status

This version should be considered an initial specification derived from the current RTL, rather than a complete and final specification of the architecture.

Implemented

* 8-bit CPU/datapath
* 8-bit PC
* eight 8-bit general-purpose registers
* two read ports
* one write port
* 8-bit instructions
* instruction decoder
* ADD
* SUB
* 256 × 8-bit ROM
* PC reset
* automatic PC increment

Not Yet Specified or Implemented in the Current ISA

* flags
* branches
* jumps
* CALL/RET
* stack
* load/store
* data RAM
* interrupts
* peripherals
* I/O
* logical instructions
* shifts/rotates
* multiplication/division

20. Versioning Principle

The ISA specification should be versioned independently from the physical implementation.

Changes that modify the meaning of an existing instruction should result in a new ISA version.

Purely internal implementation changes may be introduced without changing the ISA version as long as they do not modify the observable behavior of programs.

21. Current Status Note

DestByte8 is in an early stage of development. The original project documentation also describes the T0–T7 registers as general-purpose registers and indicates that their functions may be redefined in future versions. See the original project documentation.

This specification should therefore be understood as a technical snapshot of the current implementation and as a foundation for the formal evolution of the architecture.

DestByte8 ISA/Architecture Draft 0.1.
# DestByte8 CPU Architecture Specification

**Architecture:** DestByte8
**Class:** 8-bit CPU
**Instruction width:** 8 bits
**Data width:** 8 bits
**Register count:** 8
**Register width:** 8 bits
**Program Counter width:** 8 bits
**Instruction memory:** 256 × 8 bits
**ISA status:** Initial implementation
**Hardware description:** Verilog RTL
**Hardware license:** CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S)

---

## 1. Overview

DestByte8 is an 8-bit processor architecture designed and implemented from scratch.

The architecture uses fixed-width 8-bit instructions and 8-bit data.

The current instruction execution path consists of:

```text
PC
 ↓
Instruction ROM
 ↓
Decoder
 ↓
Register File
 ↓
ALU
 ↓
Register File
```

The current RTL implementation contains:

* Program Counter;
* PC-next logic;
* instruction ROM;
* instruction decoder;
* register file;
* arithmetic logic unit (ALU);
* top-level CPU interconnection.

The ISA defines the architectural behavior. The Verilog RTL is the current implementation of that behavior.

Features that are not defined by the ISA are considered implementation details unless explicitly specified.

---

# 2. Architectural Parameters

| Feature             | Current specification |
| ------------------- | --------------------- |
| Data width          | 8 bits                |
| Instruction width   | 8 bits                |
| Program Counter     | 8 bits                |
| Registers           | 8                     |
| Register names      | T0–T7                 |
| Register width      | 8 bits                |
| Register selector   | 3 bits                |
| ALU input width     | 8 bits                |
| ALU result width    | 8 bits                |
| ALU control         | 3 bits                |
| Instruction opcode  | 2 bits                |
| Instruction memory  | 256 × 8 bits          |
| Instruction address | 8 bits                |
| Flags               | Not implemented       |
| Stack pointer       | Not implemented       |
| Interrupts          | Not implemented       |
| Data RAM            | Not implemented       |
| Branch instructions | Not implemented       |

---

# 3. Register File

DestByte8 contains eight general-purpose registers:

```text
T0
T1
T2
T3
T4
T5
T6
T7
```

Each register stores one 8-bit value.

A register is selected using a 3-bit register selector.

| Selector | Register |
| -------- | -------- |
| `000`    | T0       |
| `001`    | T1       |
| `010`    | T2       |
| `011`    | T3       |
| `100`    | T4       |
| `101`    | T5       |
| `110`    | T6       |
| `111`    | T7       |

All eight registers are therefore directly addressable.

## 3.1 Register File Ports

The current register file provides:

* one synchronous write port;
* two combinational read ports.

Conceptually:

```text
r_addr1 → r_data1
r_addr2 → r_data2

w_addr  → destination register
w_data  → data written
we      → write enable
clk     → clock
reset   → reset
```

The two read addresses independently select two registers.

For an instruction using destination field `D` and source field `S`:

```text
r_addr1 = D
r_addr2 = S
w_addr  = D
```

The intended architectural write-back operation is therefore:

```text
T[D] ← ALU result
```

Writes occur on the active clock edge when write enable is asserted.

The current RTL also clears the register file during reset.

---

# 4. Instruction Format

Every DestByte8 instruction occupies exactly one byte.

```text
Bit:     7 6 | 5 4 3 | 2 1 0
        ─────┼───────┼───────
        OPC  │   D   │   S
```

The instruction is divided into three fields:

| Bits    | Field  |  Width | Purpose                         |
| ------- | ------ | -----: | ------------------------------- |
| `[7:6]` | OPCODE | 2 bits | Selects the operation           |
| `[5:3]` | D      | 3 bits | Destination / first ALU operand |
| `[2:0]` | S      | 3 bits | Second ALU operand              |

Total:

```text
2 + 3 + 3 = 8 bits
```

The current instruction format contains:

* no immediate field;
* no memory-address field;
* no operand-size field.

---

# 5. Instruction Encoding

The two most significant bits select the instruction group:

```text
OPCODE = instruction[7:6]
D      = instruction[5:3]
S      = instruction[2:0]
```

Current allocation:

| Opcode | Instruction | Status      |
| ------ | ----------- | ----------- |
| `00`   | ADD         | Implemented |
| `01`   | SUB         | Implemented |
| `10`   | —           | Reserved    |
| `11`   | —           | Reserved    |

---

# 6. ADD

## Encoding

```text
00 DDD SSS
```

## Semantics

```text
T[D] ← T[D] + T[S]
```

The `D` field has two roles:

1. selects the first ALU operand;
2. selects the destination register.

The `S` field selects the second ALU operand.

### Example

Given:

```text
T0 = 5
T1 = 3
```

Instruction:

```text
00 000 001
```

Fields:

```text
OPCODE = 00
D      = 000 → T0
S      = 001 → T1
```

Execution:

```text
T0 ← T0 + T1
T0 ← 5 + 3
T0 ← 8
```

Encoding:

```text
00000001 = 0x01
```

Therefore:

```text
0x01 = ADD T0,T1
```

---

# 7. SUB

## Encoding

```text
01 DDD SSS
```

## Semantics

```text
T[D] ← T[D] - T[S]
```

### Example

Given:

```text
T2 = 10
T3 = 4
```

Instruction:

```text
01 010 011
```

Fields:

```text
OPCODE = 01
D      = 010 → T2
S      = 011 → T3
```

Execution:

```text
T2 ← T2 - T3
T2 ← 10 - 4
T2 ← 6
```

Encoding:

```text
01010011 = 0x53
```

Therefore:

```text
0x53 = SUB T2,T3
```

---

# 8. Complete Opcode Space

Because the opcode contains two bits, there are four opcode groups.

Each group contains:

```text
8 × 8 = 64
```

possible register combinations.

Current allocation:

```text
0x00–0x3F = ADD
0x40–0x7F = SUB
0x80–0xBF = RESERVED
0xC0–0xFF = RESERVED
```

Therefore:

```text
64 ADD encodings
64 SUB encodings
128 reserved encodings
```

---

# 9. ADD Encoding Range

All instructions with opcode `00` are ADD instructions.

Range:

```text
0x00–0x3F
```

General encoding:

```text
00 DDD SSS
```

Examples:

| Byte   | Binary     | Instruction |
| ------ | ---------- | ----------- |
| `0x00` | `00000000` | `ADD T0,T0` |
| `0x01` | `00000001` | `ADD T0,T1` |
| `0x02` | `00000010` | `ADD T0,T2` |
| `0x07` | `00000111` | `ADD T0,T7` |
| `0x08` | `00001000` | `ADD T1,T0` |
| `0x10` | `00010000` | `ADD T2,T0` |
| `0x18` | `00011000` | `ADD T3,T0` |
| `0x20` | `00100000` | `ADD T4,T0` |
| `0x28` | `00101000` | `ADD T5,T0` |
| `0x30` | `00110000` | `ADD T6,T0` |
| `0x38` | `00111000` | `ADD T7,T0` |
| `0x3F` | `00111111` | `ADD T7,T7` |

---

# 10. SUB Encoding Range

All instructions with opcode `01` are SUB instructions.

Range:

```text
0x40–0x7F
```

General encoding:

```text
01 DDD SSS
```

Examples:

| Byte   | Binary     | Instruction |
| ------ | ---------- | ----------- |
| `0x40` | `01000000` | `SUB T0,T0` |
| `0x41` | `01000001` | `SUB T0,T1` |
| `0x42` | `01000010` | `SUB T0,T2` |
| `0x48` | `01001000` | `SUB T1,T0` |
| `0x50` | `01010000` | `SUB T2,T0` |
| `0x53` | `01010011` | `SUB T2,T3` |
| `0x60` | `01100000` | `SUB T4,T0` |
| `0x70` | `01110000` | `SUB T6,T0` |
| `0x78` | `01111000` | `SUB T7,T0` |
| `0x7F` | `01111111` | `SUB T7,T7` |

---

# 11. Reserved Opcode Space

The opcode values:

```text
10
11
```

are reserved.

Corresponding ranges:

```text
0x80–0xBF
0xC0–0xFF
```

These encodings currently do not define architectural instructions.

The current decoder disables register writes for these opcode values.

Software must not depend on the current internal behavior of reserved encodings.

Future ISA revisions may assign these opcode groups to new instructions.

---

# 12. Decoder

The decoder receives the complete instruction:

```text
instruction[7:0]
```

It produces:

```text
alu_control
w_addr
r_addr1
r_addr2
reg_we
```

Current field extraction:

```text
w_addr  = instruction[5:3]
r_addr1 = instruction[5:3]
r_addr2 = instruction[2:0]
```

Therefore:

```text
w_addr  = D
r_addr1 = D
r_addr2 = S
```

Current control mapping:

| Opcode | `alu_control` | `reg_we` |
| ------ | ------------- | -------: |
| `00`   | `000`         |      `1` |
| `01`   | `001`         |      `1` |
| `10`   | `000`         |      `0` |
| `11`   | `000`         |      `0` |

The decoder initializes its outputs to safe default values and disables register writes for unsupported opcode groups.

---

# 13. ALU

The ALU receives two 8-bit operands:

```text
A[7:0]
B[7:0]
```

and a 3-bit operation selector:

```text
alu_control[2:0]
```

It produces an 8-bit result:

```text
result[7:0]
```

Current operation mapping:

| `alu_control` | Operation |
| ------------- | --------- |
| `000`         | `A + B`   |
| `001`         | `A - B`   |
| Other         | `0x00`    |

The current ALU does not expose arithmetic flags.

There are currently no architectural:

* Zero flag;
* Carry flag;
* Borrow flag;
* Negative/Sign flag;
* Overflow flag.

Arithmetic results are limited to eight bits.

Therefore, the implemented arithmetic naturally retains the lower eight bits of the result.

Example:

```text
0xFF + 0x01 = 0x00
```

because the ninth carry bit is not part of the current ALU result.

---

# 14. Program Counter

The Program Counter is 8 bits wide.

Its address range is:

```text
0x00–0xFF
```

The current PC implementation provides:

```text
clk
reset
pc_next
pc_out
```

The PC receives the next value generated by the PC-next logic.

Current sequential execution uses:

```text
PC_next = PC + 1
```

Therefore, in the absence of another control-flow mechanism:

```text
PC ← PC + 1
```

The PC supplies the instruction ROM address:

```text
PC → ROM.addr
```

The current ISA contains no instruction that modifies the PC.

---

# 15. PC-Next Logic

The current PC-next module implements simple sequential advancement:

```text
pc_next = pc + 8'd1
```

The logic is combinational.

It does not currently implement:

* branches;
* jumps;
* calls;
* returns;
* conditional control flow.

A future control unit may replace or control this simple sequential path when additional control-flow instructions are introduced.

---

# 16. Instruction ROM

The instruction ROM contains:

```text
256 entries × 8 bits
```

Address width:

```text
8 bits
```

Data width:

```text
8 bits
```

Connection:

```text
PC → ROM address
ROM → instruction
```

The current ROM implementation explicitly initializes only selected addresses.

Current initialization:

```text
Address    Byte
0x00       0x00
0x01       0x20
```

These bytes decode according to the current ISA as:

```text
0x00 → ADD T0,T0
0x20 → ADD T4,T0
```

Only explicitly initialized ROM contents are defined by the current ROM source.

Uninitialized locations must not be treated as valid program instructions.

---

# 17. Current ROM Program

The current ROM program contains:

```text
Address   Byte
----------------
0x00      0x00
0x01      0x20
```

## Address `0x00`

```text
0x00
00000000
```

Fields:

```text
OPCODE = 00
D      = 000 → T0
S      = 000 → T0
```

Instruction:

```text
ADD T0,T0
```

Intended architectural operation:

```text
T0 ← T0 + T0
```

## Address `0x01`

```text
0x20
00100000
```

Fields:

```text
OPCODE = 00
D      = 100 → T4
S      = 000 → T0
```

Instruction:

```text
ADD T4,T0
```

Intended architectural operation:

```text
T4 ← T4 + T0
```

Therefore the intended two-instruction sequence is:

```text
T0 ← T0 + T0
T4 ← T4 + T0
```

The actual execution of this sequence must be verified by simulation.

---

# 18. Datapath

The current processor datapath is:

```text
             ┌────────────┐
             │     PC     │
             └─────┬──────┘
                   │
                   ▼
             ┌────────────┐
             │    ROM     │
             └─────┬──────┘
                   │
             instruction
                   │
                   ▼
             ┌────────────┐
             │  DECODER   │
             └──┬─────┬───┘
                │     │
          register   control
           fields
                │     │
                ▼     ▼
          ┌────────────────┐
          │ REGISTER FILE  │
          └──────┬───┬─────┘
                 │   │
                 A   B
                  \ /
                   ▼
              ┌─────────┐
              │   ALU   │
              └────┬────┘
                   │
              ALU result
                   │
                   ▼
          ┌────────────────┐
          │ REGISTER FILE  │
          └────────────────┘
```

The current top-level CPU also exposes the ALU result through:

```text
result[7:0]
```

The PC may additionally be exposed through a debug output in the RTL implementation.

A debug signal is not automatically part of the ISA.



# 19. Instruction Execution

The current intended execution process is divided into the following logical stages.

## 19.1 Fetch

The PC supplies the ROM address:

```text
PC → ROM
```

The ROM provides one instruction byte:

```text
ROM → instruction
```

## 19.2 Decode

The decoder extracts:

```text
opcode = instruction[7:6]
D      = instruction[5:3]
S      = instruction[2:0]
```

It then generates the register addresses and ALU control.

## 19.3 Register Read

The register file provides:

```text
A = T[D]
B = T[S]
```

## 19.4 Execute

The ALU performs the operation selected by the opcode:

```text
ADD:
A + B

SUB:
A - B
```

## 19.5 Write Back

For the currently implemented ADD and SUB instructions:

```text
T[D] ← ALU result
```

## 19.6 PC Update

The current sequential PC logic generates:

```text
PC_next = PC + 1
```

The PC therefore advances to the next instruction.



# 20. Reset

Reset behavior is part of the RTL implementation and must be distinguished from ISA semantics.

The current implementation resets the PC to:

```text
0x00
```

The register file is also reset to:

```text
T0 = 0x00
T1 = 0x00
T2 = 0x00
T3 = 0x00
T4 = 0x00
T5 = 0x00
T6 = 0x00
T7 = 0x00
```

Register writes are disabled while reset is asserted through the top-level write-enable condition:

```text
reg_we & ~reset
```

The exact synchronous/asynchronous timing semantics of reset are determined by the sequential RTL implementation.



# 21. CPU Interface

The current top-level CPU exposes:

```text
input  clk
input  reset
output [7:0] result
```

The RTL may also expose debug signals such as:

```text
pc_debug[7:0]
```

## `clk`

System clock.

## `reset`

Processor reset input.

## `result`

Current ALU result.

## `pc_debug`

Current PC value for simulation/debugging when present in the RTL.

`pc_debug` is an implementation/debug interface and is not an architectural register or ISA instruction field.



# 22. Architectural State

The current architectural register state consists of:

```text
T0
T1
T2
T3
T4
T5
T6
T7
```

The PC is also processor state used to determine the next instruction.

Each state element is 8 bits wide.

The architecture currently defines no:

* flag register;
* status register;
* stack pointer;
* general-purpose memory state.



# 23. Memory Model

The current implementation provides instruction ROM:

```text
256 × 8 bits
```

The current ISA does not define a separate data-memory address space.

There are currently no architectural instructions for:

* load;
* store;
* memory addressing;
* memory-mapped I/O.

Therefore the current ROM represents instruction storage rather than general-purpose data memory.



# 24. Control Flow

The current instruction set does not contain:

```text
JMP
CALL
RET
conditional branch
indirect jump
```

No current instruction directly modifies the PC.

Sequential execution is currently based on:

```text
PC_next = PC + 1
```

Future control-flow instructions will require both ISA definitions and corresponding hardware changes.



# 25. Flags

DestByte8 currently has no architectural flags.

The following are not implemented:

```text
Z = Zero
C = Carry
N = Negative
V = Overflow
B = Borrow
```

The ALU therefore produces only the 8-bit result.

If flags are introduced in a future revision, their encoding, update rules, and interaction with instructions must be explicitly defined by the ISA.



# 26. Reserved and Undefined Behavior

The following opcode groups are reserved:

```text
10
11
```

Corresponding ranges:

```text
0x80–0xBF
0xC0–0xFF
```

These encodings do not currently represent valid instructions.

Software must not rely on the internal behavior of reserved encodings.

Future ISA revisions may assign these opcode groups to new instructions.

ROM locations not explicitly initialized by the current ROM implementation are also not defined as program instructions.



# 27. Current Instruction Summary

```text
┌────────┬──────────┬─────────────────────────────┐
│ Opcode │ Mnemonic │ Operation                   │
├────────┼──────────┼─────────────────────────────┤
│ 00     │ ADD      │ T[D] ← T[D] + T[S]         │
│ 01     │ SUB      │ T[D] ← T[D] - T[S]         │
│ 10     │ —        │ Reserved                    │
│ 11     │ —        │ Reserved                    │
└────────┴──────────┴─────────────────────────────┘
```



# 28. Complete Byte Layout

The complete instruction byte is:

```text
7       6 5       3 2       0
┌─────────┬─────────┬─────────┐
│  OPCODE │    D    │    S    │
│  2 bits │  3 bits │  3 bits │
└─────────┴─────────┴─────────┘
```

Interpretation:

```text
instruction[7:6] → operation
instruction[5:3] → destination / first operand
instruction[2:0] → second operand
```

Example:

```text
0x53 = 01010011
       ──┬─┬───
         │ │
         │ └── S = 011 = T3
         └──── D = 010 = T2
       opcode = 01 = SUB
```

Therefore:

```text
0x53 = SUB T2,T3
```


# 29. ISA Capacity

The current instruction format allocates:

```text
2 bits → opcode
3 bits → destination
3 bits → source
```

This provides:

```text
4 opcode groups
8 destination registers
8 source registers
```

Total possible byte encodings:

```text
4 × 8 × 8 = 256
```

Current allocation:

```text
64 ADD encodings
64 SUB encodings
128 reserved encodings
```

The two reserved opcode groups provide room for future ISA expansion while preserving the current 8-bit instruction width.

# 30. Current Limitations

The following features are not currently implemented as ISA instructions:

* immediate operands;
* load;
* store;
* logical operations;
* shifts;
* comparisons;
* branches;
* jumps;
* calls;
* returns;
* stack operations;
* flags;
* interrupts;
* exceptions;
* I/O instructions;
* privileged execution modes.

These features must not be considered part of DestByte8 until their encoding, semantics, hardware implementation, and verification are defined.



# 31. RTL Implementation Structure

The current repository separates the processor into hardware modules.

```text
alu/
    alu.v

memory/
    registers_memory.v

rom/
    rom.v

rtl/
    decoder.v
    pc.v
    pc_next.v
    top.v

control/
    control_unit.v

sim/
    simulation infrastructure
```

Current module responsibilities:

| Module               | Responsibility                       |
| -------------------- | ------------------------------------ |
| `alu.v`              | Arithmetic operations                |
| `registers_memory.v` | Register storage and register access |
| `rom.v`              | Instruction storage                  |
| `decoder.v`          | Instruction decoding                 |
| `pc.v`               | Program Counter register             |
| `pc_next.v`          | Sequential PC-next calculation       |
| `control_unit.v`     | Control logic under development      |
| `top.v`              | CPU integration                      |

The exact behavior of `control_unit.v` must be added to this specification once its interface and role in the datapath are finalized.

---

# 32. Verification Status

The current RTL has been successfully compiled with Verilator.

The current simulation has verified sequential PC advancement under the tested reset conditions:

```text
PC: 0
PC: 1
PC: 2
PC: 3
...
```

This verifies the tested PC progression.

It does **not**, by itself, verify:

* correct instruction decoding;
* correct register reads;
* correct ALU operation;
* correct register write-back;
* correct execution of ADD;
* correct execution of SUB;
* correct behavior of reserved opcodes.

Those behaviors require dedicated simulation tests.

---

# 33. Architectural Status

The current DestByte8 ISA consists of:

```text
8-bit data
8-bit instructions
8 registers
8-bit PC
256-byte instruction address space
ADD
SUB
```

Current opcode allocation:

```text
00 = ADD
01 = SUB
10 = RESERVED
11 = RESERVED
```

The architecture is intentionally minimal.

Future features should be added by explicitly defining:

1. instruction encoding;
2. instruction semantics;
3. architectural state changes;
4. RTL implementation;
5. verification tests;
6. documentation.

The ISA specification should describe behavior that has been intentionally defined and implemented, while implementation-specific details should remain identified as RTL behavior.

---

# Appendix A — Register Encoding

```text
000 = T0
001 = T1
010 = T2
011 = T3
100 = T4
101 = T5
110 = T6
111 = T7
```

---

# Appendix B — Opcode Encoding

```text
00 = ADD
01 = SUB
10 = RESERVED
11 = RESERVED
```

---

# Appendix C — Representative Encodings

```text
0x00 = ADD T0,T0
0x01 = ADD T0,T1
0x02 = ADD T0,T2
0x07 = ADD T0,T7

0x08 = ADD T1,T0
0x10 = ADD T2,T0
0x18 = ADD T3,T0
0x20 = ADD T4,T0
0x28 = ADD T5,T0
0x30 = ADD T6,T0
0x38 = ADD T7,T0
0x3F = ADD T7,T7

0x40 = SUB T0,T0
0x41 = SUB T0,T1
0x48 = SUB T1,T0
0x50 = SUB T2,T0
0x53 = SUB T2,T3
0x60 = SUB T4,T0
0x70 = SUB T6,T0
0x78 = SUB T7,T0
0x7F = SUB T7,T7

0x80–0xBF = RESERVED
0xC0–0xFF = RESERVED
```
DestByte8 CPU Architecture Specification

Document: Technical Architecture Specification
Architecture: DestByte8
Class: 8-bit CPU
Status: Initial implementation
Repository: icarotelesdasilva/DestByte8
Hardware License: CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S)

1. Overview

The DestByte8 is an 8-bit processor architecture developed from scratch. Its goal is to provide a general-purpose architecture that can evolve over time through the development of both its ISA (Instruction Set Architecture) and hardware implementation.

The current implementation is described in Verilog RTL and organized into independent modules corresponding to the processor’s main units:

* program counter;
* instruction ROM;
* instruction decoder;
* register file;
* arithmetic logic unit (ALU);
* main processor interconnection.

The architecture should not be confused with a simulator. The RTL is the structural and behavioral description of the CPU’s digital hardware. The sim directory, when present in the project, should be treated separately as verification and development infrastructure rather than as the definition of the CPU.

The repository explicitly identifies DestByte8 as an 8-bit CPU built entirely from scratch. See the GitHub repository.

2. Current Architectural Features

Feature	Current Status
Data width	8 bits
Instruction width	8 bits
Program counter width	8 bits
General-purpose registers	8
Register names	T0–T7
Register width	8 bits
Register address width	3 bits
ALU operands	2 × 8 bits
ALU result	8 bits
Current ALU operations	Addition and subtraction
Instruction memory	ROM
ROM address width	8 bits
ROM address space	256 positions
Reset	Asynchronous reset on the PC and register file
PC increment	+1 on each rising clock edge
Flags	Not implemented in the current RTL
Pipeline	Not implemented in the current RTL
Interrupts	Not implemented in the current RTL
Stack pointer	Not implemented in the current RTL

The features above are derived directly from the current implementation in the repository. See the PC implementation.

3. Register Model

DestByte8 provides eight general-purpose registers:

T0
T1
T2
T3
T4
T5
T6
T7

Each register is 8 bits wide.

A register is selected using a 3-bit field:

000 → T0
001 → T1
010 → T2
011 → T3
100 → T4
101 → T5
110 → T6
111 → T7

The register file is implemented as a memory containing eight 8-bit elements. It provides two combinational read ports and one synchronous write port. See the register file implementation.

3.1 Ports

              ┌─────────────────────┐
r_addr1 ─────►│                     │─────► r_data1
r_addr2 ─────►│   REGISTER FILE     │─────► r_data2
w_addr  ─────►│                     │
w_data  ─────►│                     │
we      ─────►│                     │
clk     ─────►│                     │
              └─────────────────────┘

3.2 Read Operation

Register reads are combinational:

r_data1 = T[r_addr1]
r_data2 = T[r_addr2]

Therefore, two operands can be read simultaneously.

3.3 Write Operation

A write occurs on the rising edge of the clock when we is active:

if (we)
    T[w_addr] <= w_data;

This behavior is implemented directly in the registers_memory module. See the register file implementation.

4. Program Counter

The Program Counter (PC) is 8 bits wide.

Its value is updated on the rising edge of the clock.

Under normal operation:

PC ← PC + 1

During reset:

PC ← 0x00

The module uses an asynchronous reset:

always @(posedge clk or posedge reset)

Therefore, the PC can be set to 0x00 when the reset signal is asserted, independently of the clock edge. See the PC implementation.

Since the PC is 8 bits wide, its representable range is:

0x00 – 0xFF

The current behavior is an 8-bit modular increment. Consequently, after 0xFF, the next representable PC value is 0x00.

5. Instruction Memory

The current implementation uses a ROM with:

256 positions
×
8 bits per position

The ROM address is 8 bits wide and is provided directly by the PC:

PC → ROM.address

The ROM output is 8 bits wide:

ROM.data → instruction

The current implementation declares:

reg [7:0] memory [0:255];

and accesses the memory through:

assign data = memory[addr];

Therefore, the current implementation provides 256 instruction addresses, each containing 8 bits. See the ROM implementation.

6. Instruction Format

DestByte8 instructions are 8 bits wide:

 7       6 5       3 2       0
┌─────────┬─────────┬─────────┐
│ OPCODE  │   RD    │   RS    │
└─────────┴─────────┴─────────┘
    2 bits   3 bits   3 bits

Fields:

* instruction[7:6] = operation;
* instruction[5:3] = destination register and first operand;
* instruction[2:0] = second register or operand.

The current decoder uses these fields exactly as described. See the decoder implementation.

7. Current ISA Encoding

The current implementation uses the two most significant instruction bits to select the operation.

7.1 Addition

Opcode:
00

Format:

00 DDD SSS

Semantics:

T[DDD] ← T[DDD] + T[SSS]

The instruction enables register file write access.

The first ALU operand is T[DDD], and the second operand is T[SSS].

The operation is executed by the ALU with:

alu_control = 000

See the decoder implementation.

7.2 Subtraction

Opcode:
01

Format:

01 DDD SSS

Semantics:

T[DDD] ← T[DDD] - T[SSS]

As with addition, DDD simultaneously selects the destination register and the first operand.

The operation is executed by the ALU with:

alu_control = 001

See the decoder implementation.

8. Currently Implemented ISA Table

Bits 7:6	Operation	ALU Control	Write
00	ADD	000	Yes
01	SUB	001	Yes
10	Reserved	000	No
11	Reserved	000	No

The 10 and 11 opcodes do not currently correspond to architectural instructions defined by the decoder.

For these opcode values, the decoder keeps reg_we = 0. Therefore, they should not be documented as valid instructions in the current ISA version. See the decoder implementation.

9. Arithmetic Logic Unit

The ALU receives:

A        : 8 bits
B        : 8 bits
alu_ctrl : 3 bits

and produces:

result   : 8 bits

The current implementation supports two operations:

000 → A + B
001 → A - B

Any other alu_control value produces:

result = 8'h00

See the ALU implementation.

10. Flags

The current ALU implementation does not provide flag outputs.

The ALU currently has no architectural signals corresponding to:

* Zero;
* Carry;
* Borrow;
* Negative/Sign;
* Overflow.

Therefore, none of these flags should be considered part of the current ISA without an explicit architectural change.

11. Datapath

The current datapath can be represented as follows:

             ┌──────────┐
             │    PC    │
             └────┬─────┘
                  │
                  ▼
             ┌──────────┐
             │   ROM    │
             └────┬─────┘
                  │
             instruction
                  │
                  ▼
             ┌──────────┐
             │ DECODER  │
             └─┬──┬──┬──┘
               │  │  │
             addr addr control
               │  │  │
               ▼  ▼  ▼
             ┌───────────┐
             │ REGISTER  │
             │   FILE    │
             └──┬─────┬──┘
                │     │
                ▼     ▼
               A       B
                \     /
                 \   /
                  ▼ ▼
               ┌───────┐
               │  ALU  │
               └───┬───┘
                   │
                   ▼
               result
                   │
                   ├──────────► output
                   │
                   ▼
               REGISTER FILE

The integration of these modules is explicitly implemented in top.v. See the top-level implementation.

12. Basic Operation Cycle

The current implementation can be conceptually described in three stages.

12.1 Fetch

The PC provides the instruction address:

PC → ROM

The ROM returns an 8-bit word:

ROM → instruction

12.2 Decode

The decoder separates the instruction fields:

opcode = instruction[7:6]
destination = instruction[5:3]
source = instruction[2:0]

It then generates the control signals for the rest of the datapath. See the decoder implementation.

12.3 Execute

The selected registers provide operands to the ALU:

T[destination] → ALU.A
T[source]      → ALU.B

The ALU calculates the result.

When the instruction enables reg_we, the result is written back to the register selected by the DDD field. See the top-level implementation.

13. Execution Example

Assume:

T0 = 5
T1 = 3

The instruction:

00 000 001

corresponds to:

ADD T0, T1

The CPU selects:

A = T0 = 5
B = T1 = 3

The ALU calculates:

5 + 3 = 8

The result is written to:

T0 = 8

The hexadecimal representation of the instruction is:

0000 0001
= 0x01

14. Subtraction Example

Assume:

T2 = 10
T3 = 4

The instruction:

01 010 011

corresponds to:

SUB T2, T3

Result:

T2 ← 10 - 4
T2 ← 6

The hexadecimal representation of the instruction is:

0101 0011
= 0x53

15. Reset

The current reset behavior explicitly affects:

* the Program Counter;
* the register file;
* register file write enable.

The PC is set to:

0x00

During reset, T0–T7 are also explicitly reset to:

T0–T7 = 0x00

In addition, top.v prevents register file writes while reset is active:

we = reg_we & ~reset

See the top-level implementation.

The register file resets all eight registers to 0x00 when reset is asserted.

16. Current Core Interface

The top module provides:

input  clk
input  reset
output [7:0] result

The current interface is therefore:

             DestByte8
          ┌──────────────┐
clk ─────►│              │
reset ───►│     CPU      │────► result[7:0]
          │              │
          └──────────────┘

The result signal currently corresponds to the value produced by the ALU. See the top-level implementation.

17. Features Not Yet Defined

The following list should not be interpreted as a deficiency. It represents functionality that is not yet defined in the current RTL.

ISA

* load instructions;
* store instructions;
* logical operations;
* shifts;
* comparisons;
* jumps;
* conditional branches;
* function calls;
* function returns;
* I/O instructions;
* control instructions.

Architectural State

* flag register;
* stack pointer;
* status register;
* special-purpose registers;
* exception mechanism;
* interrupt mechanism.

Memory

* data RAM;
* external memory bus;
* memory-mapped I/O;
* memory map;
* external bus width and protocol.

Control Flow

The PC currently only increments:

PC ← PC + 1

There is currently no RTL logic that changes the PC to another address as the result of an instruction.

Timing

The final documentation should eventually specify:

* maximum frequency;
* clock period;
* instruction latencies;
* relationship between the clock and instruction execution;
* memory access timing;
* external signal behavior.

These parameters depend on the specific physical implementation and should not be inferred solely from the ISA width.

18. Architectural State vs. Implementation

It is important to distinguish between two levels of DestByte8.

ISA

The ISA defines the behavior observable by software.

Currently, this includes:

8-bit instructions
8-bit registers
T0–T7
ADD
SUB
PC

Implementation

The current implementation uses:

Verilog RTL
PC
ROM
decoder
register file
ALU

A future physical implementation may reorganize these internal blocks without necessarily changing the ISA, as long as it preserves the specified architectural behavior.

19. Specification Status

This version should be considered an initial specification derived from the current RTL, rather than a complete and final specification of the architecture.

Implemented

* 8-bit CPU/datapath
* 8-bit PC
* eight 8-bit general-purpose registers
* two read ports
* one write port
* 8-bit instructions
* instruction decoder
* ADD
* SUB
* 256 × 8-bit ROM
* PC reset
* automatic PC increment

Not Yet Specified or Implemented in the Current ISA

* flags
* branches
* jumps
* CALL/RET
* stack
* load/store
* data RAM
* interrupts
* peripherals
* I/O
* logical instructions
* shifts/rotates
* multiplication/division

20. Versioning Principle

The ISA specification should be versioned independently from the physical implementation.

Changes that modify the meaning of an existing instruction should result in a new ISA version.

Purely internal implementation changes may be introduced without changing the ISA version as long as they do not modify the observable behavior of programs.

21. Current Status Note

DestByte8 is in an early stage of development. The original project documentation also describes the T0–T7 registers as general-purpose registers and indicates that their functions may be redefined in future versions. See the original project documentation.

This specification should therefore be understood as a technical snapshot of the current implementation and as a foundation for the formal evolution of the architecture.

DestByte8 ISA/Architecture Draft 0.2.
