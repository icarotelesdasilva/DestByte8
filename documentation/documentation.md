# DestByte16 CPU Architecture Specification

Architecture: DestByte16

Class: 16-bit CPU

Instruction width: 16 bits

Data width: 16 bits

Register count: 16

Register width: 16 bits

Program Counter width: 16 bits

Instruction memory: 65536 × 16 bits

Data memory: 65536 × 16 bits

ISA status: Initial architecture specification

Hardware description: Verilog RTL

Hardware license: CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S)

## 1. Overview

DestByte16 is a 16-bit processor architecture derived from the architectural philosophy of DestByte8.

The architecture uses fixed-width 16-bit instructions and 16-bit data.

The processor contains:

• Program Counter

• Instruction ROM

• Instruction Decoder

• Register File

• ALU

• Control Unit

• Data Memory

• Stack Pointer

• Flags Register

The main execution path is:

PC

↓

Instruction ROM

↓

Instruction Decoder

↓

Register File

↓

ALU

↓

Data Memory or Register File

The ISA defines the architectural behavior.

The Verilog RTL defines the hardware implementation of that architecture.

Features that are not explicitly defined by the ISA are considered implementation details.

## 2. Architectural Parameters

Data width: 16 bits

Instruction width: 16 bits

Program Counter: 16 bits

Registers: 16

Register names: T0–T15

Register width: 16 bits

Register selector: 4 bits

ALU input width: 16 bits

ALU result width: 16 bits

Instruction opcode: 4 bits

Instruction memory: 65536 × 16 bits

Instruction address: 16 bits

Data memory: 65536 × 16 bits

Data address: 16 bits

Flags: Implemented

Stack Pointer: Implemented

Interrupts: Not implemented

Exceptions: Not implemented

## 3. Register File

DestByte16 contains sixteen general-purpose registers:

T0

T1

T2

T3

T4

T5

T6

T7

T8

T9

T10

T11

T12

T13

T14

T15

Each register stores one 16-bit value.

A register is selected using a 4-bit register selector.

Selector `0000` selects T0.

Selector `0001` selects T1.

Selector `0010` selects T2.

Selector `0011` selects T3.

Selector `0100` selects T4.

Selector `0101` selects T5.

Selector `0110` selects T6.

Selector `0111` selects T7.

Selector `1000` selects T8.

Selector `1001` selects T9.

Selector `1010` selects T10.

Selector `1011` selects T11.

Selector `1100` selects T12.

Selector `1101` selects T13.

Selector `1110` selects T14.

Selector `1111` selects T15.

All sixteen registers are directly addressable.

## 3.1 Register File Ports

The register file provides:

• two combinational read ports

• one synchronous write port

Conceptually:

r_addr1 → r_data1

r_addr2 → r_data2

w_addr → destination register

w_data → data written

we → write enable

clk → clock

reset → reset

For a three-register instruction:

r_addr1 = RS1

r_addr2 = RS2

w_addr = RD

The architectural write operation is:

T[RD] ← result

## 4. Instruction Format

Every DestByte16 instruction occupies exactly 16 bits.

The standard register instruction format is:

Bits 15 to 12: OPCODE

Bits 11 to 8: RD

Bits 7 to 4: RS1

Bits 3 to 0: RS2

The instruction therefore contains:

4 bits for the opcode

4 bits for the destination register

4 bits for the first source register

4 bits for the second source register

Total:

4 + 4 + 4 + 4 = 16 bits

Instructions that require immediate values or addresses use alternative formats defined by their respective instructions.

## 5. Instruction Encoding

The four most significant bits select the primary instruction group.

OPCODE = instruction[15:12]

RD = instruction[11:8]

RS1 = instruction[7:4]

RS2 = instruction[3:0]

Current allocation:

`0000` = ADD

`0001` = SUB

`0010` = AND

`0011` = OR

`0100` = XOR

`0101` = NOT

`0110` = SHL

`0111` = SHR

`1000` = ADDI

`1001` = SUBI

`1010` = LD

`1011` = ST

`1100` = JMP

`1101` = BEQ

`1110` = BNE

`1111` = SYSTEM

## 6. ADD

Encoding:

`0000 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] + T[R]

The destination register is selected by D.

The first source register is selected by S.

The second source register is selected by R.

Example:

ADD T0,T1,T2

Operation:

T0 ← T1 + T2

## 7. SUB

Encoding:

`0001 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] - T[R]

Example:

SUB T0,T1,T2

Operation:

T0 ← T1 - T2

## 8. AND

Encoding:

`0010 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] AND T[R]

## 9. OR

Encoding:

`0011 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] OR T[R]

## 10. XOR

Encoding:

`0100 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] XOR T[R]

## 11. NOT

Encoding:

`0101 DDDD SSSS 0000`

Semantics:

T[D] ← NOT T[S]

## 12. Shift Left

Encoding:

`0110 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] << T[R]

The lower four bits of T[R] determine the shift amount.

## 13. Shift Right

Encoding:

`0111 DDDD SSSS RRRR`

Semantics:

T[D] ← T[S] >> T[R]

The initial architecture defines this as a logical right shift.

## 14. ADDI

ADDI performs addition using an immediate value.

The immediate instruction format is:

`1000 DDDD SSSS IIII IIII`

The immediate field contains 8 bits.

The immediate value is sign-extended to 16 bits.

Semantics:

T[D] ← T[S] + sign_extend(I)

Example:

ADDI T0,T1,5

Operation:

T0 ← T1 + 5

## 15. SUBI

Encoding:

`1001 DDDD SSSS IIII IIII`

Semantics:

T[D] ← T[S] - sign_extend(I)

## 16. Load

LD reads a 16-bit value from data memory.

Encoding:

`1010 DDDD BBBB OOOOOOOO`

D selects the destination register.

B selects the base register.

O is an 8-bit signed offset.

Semantics:

address = T[B] + sign_extend(O)

T[D] ← MEM[address]

Example:

LD T0,[T1+4]

Operation:

T0 ← MEM[T1 + 4]

## 17. Store

ST writes a 16-bit value into data memory.

Encoding:

`1011 SSSS BBBB OOOOOOOO`

S selects the source register.

B selects the base register.

O is an 8-bit signed offset.

Semantics:

address = T[B] + sign_extend(O)

MEM[address] ← T[S]

## 18. Jump

JMP performs an unconditional control-flow transfer.

Encoding:

`1100 AAAAAAAAAAAA`

The lower 12 bits contain a signed PC-relative displacement.

Semantics:

PC ← PC + sign_extend(offset)

## 19. Branch Equal

BEQ performs a conditional branch.

Encoding:

`1101 AAAA BBBB OOOOOOOO`

A selects the first comparison register.

B selects the second comparison register.

O contains the signed branch displacement.

Semantics:

if T[A] == T[B]:

PC ← PC + sign_extend(O)

otherwise:

PC ← PC + 1

## 20. Branch Not Equal

Encoding:

`1110 AAAA BBBB OOOOOOOO`

Semantics:

if T[A] != T[B]:

PC ← PC + sign_extend(O)

otherwise:

PC ← PC + 1

## 21. SYSTEM

The opcode `1111` is reserved for system-level instructions.

The initial architecture does not define individual SYSTEM instructions.

Reserved functionality may later include:

NOP

HALT

CALL

RET

PUSH

POP

interrupt control

system calls

privileged operations

Software must not depend on undefined SYSTEM encodings.

## 22. Program Counter

The Program Counter is 16 bits wide.

Address range:

`0x0000–0xFFFF`

Sequential execution uses:

PC_next = PC + 1

The PC supplies the instruction memory address:

PC → Instruction ROM

The PC can also be modified by control-flow instructions.

## 23. Stack Pointer

DestByte16 contains a dedicated 16-bit Stack Pointer:

SP

The initial stack position is:

SP = 0xFFFF

The stack grows toward lower addresses.

Push:

SP ← SP - 1

MEM[SP] ← value

Pop:

value ← MEM[SP]

SP ← SP + 1

## 24. Flags

DestByte16 contains four architectural flags.

Z: Zero

N: Negative

C: Carry

V: Overflow

Zero flag:

Z = 1 when the operation result is zero.

Negative flag:

N = result[15]

Carry flag:

C indicates a carry out of bit 15 for unsigned arithmetic.

Overflow flag:

V indicates signed two's-complement overflow.

## 25. ALU

The ALU receives two 16-bit operands:

A[15:0]

B[15:0]

and produces:

result[15:0]

The ALU supports:

ADD

SUB

AND

OR

XOR

NOT

SHL

SHR

The ALU also generates the arithmetic flags.

## 26. Instruction Memory

The instruction memory contains:

65536 entries × 16 bits

Address width:

16 bits

Data width:

16 bits

Connection:

PC → ROM address

ROM → instruction

The maximum instruction address is:

`0xFFFF`

## 27. Data Memory

The data memory contains:

65536 entries × 16 bits

Address width:

16 bits

Data width:

16 bits

Address range:

`0x0000–0xFFFF`

Each memory location contains one 16-bit value.

## 28. Memory Model

Instruction memory and data memory are architecturally separated.

The processor therefore has independent instruction and data address spaces.

Instruction access:

PC → Instruction Memory

Data access:

ALU address → Data Memory

## 29. Decoder

The decoder receives:

instruction[15:0]

It extracts:

opcode

destination register

source register 1

source register 2

immediate

memory offset

branch displacement

The decoder generates the control signals required by the processor.

For undefined instructions, register and memory writes must remain disabled.

## 30. Control Unit

The control unit coordinates:

register reads

register writes

ALU operation

memory reads

memory writes

PC updates

branch decisions

immediate selection

flag updates

The control unit must guarantee that instructions cannot accidentally perform unrelated architectural writes.

## 31. Datapath

The primary datapath is:

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

The memory path is:

Register File

↓

ALU

↓

Data Memory

↓

Register File

The control unit determines which path is active for each instruction.

## 32. Instruction Execution

The logical execution process is:

FETCH

DECODE

REGISTER READ

EXECUTE

MEMORY ACCESS

WRITE BACK

PC UPDATE

Not every instruction requires every stage.

Arithmetic instructions use the ALU and register file.

Load and store instructions additionally access data memory.

Control-flow instructions modify the Program Counter.

## 33. Reset

Reset places the processor into a deterministic initial state.

After reset:

PC = 0x0000

SP = 0xFFFF

T0 = 0x0000

T1 = 0x0000

T2 = 0x0000

T3 = 0x0000

T4 = 0x0000

T5 = 0x0000

T6 = 0x0000

T7 = 0x0000

T8 = 0x0000

T9 = 0x0000

T10 = 0x0000

T11 = 0x0000

T12 = 0x0000

T13 = 0x0000

T14 = 0x0000

T15 = 0x0000

Z = 0

N = 0

C = 0

V = 0

## 34. CPU Interface

The initial top-level hardware interface is:

clk

reset

result

pc_debug

The clock controls sequential state.

Reset initializes architectural state.

Result exposes the current ALU result for hardware observation.

pc_debug exposes the current Program Counter.

Debug outputs are not part of the ISA.

## 35. RTL Structure

The recommended hardware organization is:

DestByte16

alu

memory

registers_memory

data_memory

rom

rtl

decoder

pc

pc_next

immediate_generator

control

control_unit

top

The modules should remain independent and have clearly defined interfaces.

## 36. Hardware Responsibilities

alu.v

Responsible for arithmetic and logical operations.

registers_memory.v

Responsible for the sixteen general-purpose registers.

data_memory.v

Responsible for data storage.

rom.v

Responsible for instruction storage.

decoder.v

Responsible for instruction decoding.

pc.v

Responsible for the Program Counter.

pc_next.v

Responsible for determining the next Program Counter value.

immediate_generator.v

Responsible for extracting and extending immediate values.

control_unit.v

Responsible for processor control.

top.v

Responsible for integrating the complete processor.

## 37. Arithmetic Representation

DestByte16 uses 16-bit binary arithmetic.

Unsigned range:

0 to 65535

Signed two's-complement range:

−32768 to +32767

Arithmetic results are stored in 16 bits.

Example:

0xFFFF + 0x0001 = 0x0000

The carry is represented by the C flag.

## 38. Illegal Instructions

Undefined instructions must not modify architectural state except for the behavior explicitly defined for illegal instructions in a future ISA revision.

At minimum:

reg_we = 0

mem_write = 0

Reserved instructions must therefore not accidentally modify registers or memory.

## 39. Architectural Limitations

The initial DestByte16 architecture does not define:

interrupts

exceptions

privilege levels

virtual memory

cache memory

floating-point operations

SIMD operations

multiplication

division

DMA

memory-mapped I/O

hardware timers

byte-addressable memory

These features may be introduced in future revisions.

## 40. Future ISA Expansion

Possible future instructions include:

MUL

DIV

MOD

CMP

CALL

RET

PUSH

POP

BLT

BGT

BLE

BGE

NOP

HALT

IN

OUT

CSR

IRET

The ISA may also be expanded with:

interrupt vectors

exception handling

privileged execution

memory-mapped I/O

byte access

half-word access

pipeline execution


## 41. Design Philosophy

DestByte16 follows the same fundamental philosophy as DestByte8:

simple hardware

modular architecture

fixed-width instructions

explicit instruction encoding

deterministic behavior

clear separation between ISA and RTL

The architecture should remain small enough to understand while providing substantially more functionality than the original DestByte8 architecture.


## 42. ISA and RTL

The following are architectural:

register definitions

instruction encodings

instruction semantics

Program Counter behavior

Stack Pointer behavior

memory behavior

flags

control-flow behavior

The following are implementation details unless explicitly specified:

internal wires

internal registers

pipeline organization

FPGA primitives

synthesis optimizations

debug signals

internal control signals

physical memory technology

## 43. Relationship with DestByte8

DestByte16 is a new architecture based on the design philosophy of DestByte8.

DestByte8 uses:

8-bit data

8-bit instructions

8 registers

8-bit Program Counter

2-bit opcode

ADD

SUB

DestByte16 expands the architecture to:

16-bit data

16-bit instructions

16 registers

16-bit Program Counter

4-bit opcode

arithmetic instructions

logical instructions

immediate instructions

memory instructions

control-flow instructions

flags

stack support

DestByte16 is not binary compatible with DestByte8.

The two architectures should therefore be treated as separate processor architectures.

## 44. Core Hardware Goal

The primary goal of DestByte16 is to provide a compact and complete 16-bit processor architecture while preserving the simplicity of the original DestByte8 design.

Every architectural feature must define:

instruction encoding

instruction semantics

architectural state changes

hardware requirements

RTL behavior

A feature is considered part of the ISA only when its architectural behavior has been explicitly defined.
