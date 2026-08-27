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
Reset	Asynchronous reset on the PC
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
* register file write enable.

The PC is set to:

0x00

In addition, top.v prevents register file writes while reset is active:

we = reg_we & ~reset

See the top-level implementation.

Values stored in T0–T7 are explicitly initialized or reset by the current logger file module during the reset to ensure a stable and proper boot.

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
