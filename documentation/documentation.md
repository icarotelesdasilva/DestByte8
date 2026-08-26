DestByte8 — Especificação da Arquitetura de CPU

Documento: Especificação Técnica da Arquitetura
Arquitetura: DestByte8
Classe: CPU de 8 bits
Estado: Implementação inicial
Repositório: icarotelesdasilva/DestByte8
Licença de hardware: CERN Open Hardware Licence Version 2 — Strongly Reciprocal (CERN-OHL-S)



1. Visão geral

O DestByte8 é uma arquitetura de processador de 8 bits desenvolvida do zero, com o objetivo de constituir uma arquitetura de propósito geral e evoluir tanto a sua ISA (Instruction Set Architecture) quanto sua implementação de hardware.

A implementação atual é descrita em Verilog RTL e é organizada em módulos independentes correspondentes às principais unidades do processador, incluindo:

* contador de programa;
* ROM de instruções;
* decodificador de instruções;
* banco de registradores;
* unidade lógica e aritmética (ALU);
* interconexão principal do processador.

A arquitetura não deve ser confundida com um simulador. O RTL constitui a descrição estrutural/comportamental do hardware digital da CPU. O diretório sim, quando existente no projeto, deve ser tratado separadamente como infraestrutura de verificação/desenvolvimento, e não como definição da CPU.

O repositório identifica explicitamente o DestByte8 como uma CPU de 8 bits construída inteiramente do zero. (GitHub)



2. Características arquiteturais atuais

Característica	Estado atual
Largura de dados	8 bits
Largura das instruções	8 bits
Largura do PC	8 bits
Registradores gerais	8
Nome dos registradores	T0–T7
Largura dos registradores	8 bits
Endereço de registrador	3 bits
Operandos da ALU	2 × 8 bits
Resultado da ALU	8 bits
ALU atual	Soma e subtração
Memória de instruções	ROM
Endereço da ROM	8 bits
Espaço de endereçamento da ROM	256 posições
Reset	Assíncrono no PC
Incremento do PC	+1 por borda de subida
Flags	Não implementadas no RTL atual
Pipeline	Não implementado no RTL atual
Interrupções	Não implementadas no RTL atual
Stack pointer	Não implementado no RTL atual

As características acima são derivadas diretamente da implementação atualmente presente no repositório. (GitHub)



3. Modelo de registradores

O DestByte8 possui oito registradores de propósito geral:

T0
T1
T2
T3
T4
T5
T6
T7

Todos possuem largura de 8 bits.

A seleção de um registrador é realizada por um campo de 3 bits:

000 → T0
001 → T1
010 → T2
011 → T3
100 → T4
101 → T5
110 → T6
111 → T7

O banco de registradores é implementado como uma memória de oito elementos de 8 bits. Ele possui duas portas de leitura combinacionais e uma porta de escrita síncrona. (GitHub)

3.1 Portas

              ┌─────────────────────┐
r_addr1 ─────►│                     │─────► r_data1
r_addr2 ─────►│   REGISTER FILE     │─────► r_data2
w_addr  ─────►│                     │
w_data  ─────►│                     │
we      ─────►│                     │
clk     ─────►│                     │
              └─────────────────────┘

3.2 Leitura

A leitura dos registradores é combinacional:

r_data1 = T[r_addr1]
r_data2 = T[r_addr2]

Portanto, os dois operandos podem ser obtidos simultaneamente.

3.3 Escrita

A escrita ocorre na borda positiva do clock quando we está ativo:

if (we)
    T[w_addr] <= w_data;

Esse comportamento está implementado diretamente no módulo registers_memory. (GitHub)



4. Contador de programa

O Program Counter (PC) possui largura de 8 bits.

Seu valor é atualizado na borda positiva do clock.

Em condição normal:

PC ← PC + 1

No reset:

PC ← 0x00

O reset utilizado pelo módulo é assíncrono:

always @(posedge clk or posedge reset)

Assim, o PC pode ser colocado em 0x00 pela ativação do sinal de reset independentemente da borda do clock. (GitHub)

Como o PC possui 8 bits, sua faixa de representação é:

0x00 – 0xFF

O comportamento atual é de incremento modular de 8 bits. Consequentemente, após 0xFF, o próximo valor representável do PC será 0x00.



5. Memória de instruções

A implementação atual utiliza uma ROM com:

256 posições
×
8 bits por posição

O endereço da ROM possui 8 bits e é fornecido diretamente pelo PC:

PC → ROM.address

A saída da ROM possui 8 bits:

ROM.data → instruction

A implementação atual declara:

reg [7:0] memory [0:255];

e realiza acesso através de:

assign data = memory[addr];

Portanto, a implementação atual disponibiliza 256 endereços de instrução de 8 bits. (GitHub)



6. Formato da instrução

A instrução do DestByte8 possui 8 bits:

 7       6 5       3 2       0
┌─────────┬─────────┬─────────┐
│ OPCODE  │   RD    │   RS    │
└─────────┴─────────┴─────────┘
    2 bits   3 bits   3 bits

Onde:

* instruction[7:6] = operação;
* instruction[5:3] = registrador de destino e primeiro operando;
* instruction[2:0] = segundo registrador/operando.

O decodificador atual utiliza exatamente esses campos. (GitHub)



7. Codificação atual da ISA

A implementação atual utiliza os dois bits superiores da instrução para selecionar a operação.

7.1 Soma

Opcode:
00

Formato:

00 DDD SSS

Semântica:

T[DDD] ← T[DDD] + T[SSS]

A instrução habilita a escrita no banco de registradores.

O primeiro operando da ALU é T[DDD] e o segundo é T[SSS].

A operação é executada pela ALU com:

alu_control = 000

(GitHub)



7.2 Subtração

Opcode:
01

Formato:

01 DDD SSS

Semântica:

T[DDD] ← T[DDD] - T[SSS]

Assim como na soma, DDD seleciona simultaneamente o registrador de destino e o primeiro operando.

A operação é executada pela ALU com:

alu_control = 001

(GitHub)



8. Tabela da ISA atualmente implementada

Bits 7:6	Operação	ALU control	Escrita
00	ADD	000	Sim
01	SUB	001	Sim
10	Reservado	000	Não
11	Reservado	000	Não

Os códigos 10 e 11 não possuem atualmente uma instrução arquitetural definida pelo decoder.

Para esses valores, o decoder mantém reg_we = 0. Portanto, eles não devem ser documentados como instruções válidas nesta versão da ISA. (GitHub)



9. Unidade lógica e aritmética

A ALU recebe:

A        : 8 bits
B        : 8 bits
alu_ctrl : 3 bits

e produz:

result   : 8 bits

A implementação atual possui duas operações:

000 → A + B
001 → A - B

Qualquer outro valor de alu_control produz:

result = 8'h00

(GitHub)



10. Flags

A implementação atual da ALU não possui saída de flags.

Não há atualmente, no módulo da ALU, sinais arquiteturais correspondentes a:

* Zero;
* Carry;
* Borrow;
* Negative/Sign;
* Overflow.

Portanto, nenhuma dessas flags deve ser considerada parte da ISA atual sem uma alteração explícita da arquitetura.



11. Caminho de dados

O caminho de dados atual pode ser descrito como:

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
               resultado
                   │
                   ├──────────► saída
                   │
                   ▼
               REGISTER FILE

A integração desses módulos está explicitamente realizada em top.v. (GitHub)



12. Ciclo básico de operação

Na implementação atual, o funcionamento pode ser descrito conceitualmente em três etapas:

12.1 Busca

O PC fornece o endereço da instrução:

PC → ROM

A ROM retorna uma palavra de 8 bits:

ROM → instruction

12.2 Decodificação

O decoder separa:

opcode = instruction[7:6]
destino = instruction[5:3]
fonte = instruction[2:0]

e gera os sinais de controle para o restante do datapath. (GitHub)

12.3 Execução

Os registradores selecionados fornecem os operandos à ALU:

T[destino] → ALU.A
T[fonte]   → ALU.B

A ALU calcula o resultado.

Quando a instrução habilita reg_we, o resultado retorna ao registrador selecionado pelo campo DDD. (GitHub)

⸻

13. Exemplo de execução

Considere:

T0 = 5
T1 = 3

A instrução:

00 000 001

corresponde a:

ADD T0, T1

A CPU seleciona:

A = T0 = 5
B = T1 = 3

A ALU calcula:

5 + 3 = 8

e o resultado é escrito em:

T0 = 8

A representação hexadecimal da instrução é:

0000 0001
= 0x01



14. Exemplo de subtração

Considere:

T2 = 10
T3 = 4

A instrução:

01 010 011

corresponde a:

SUB T2, T3

Resultado:

T2 ← 10 - 4
T2 ← 6

A instrução possui representação hexadecimal:

0101 0011
= 0x53



15. Reset

O reset atualmente possui efeito explícito sobre:

* Program Counter;
* habilitação de escrita do register file.

O PC é colocado em:

0x00

Além disso, top.v impede a escrita do banco de registradores enquanto reset estiver ativo:

we = reg_we & ~reset

(GitHub)

O comportamento dos valores armazenados em T0–T7 após o reset não é explicitamente inicializado pelo módulo atual de registradores. Portanto, esse comportamento deve ser considerado não especificado na revisão atual da arquitetura.



16. Interface externa atual do núcleo

O módulo superior top possui:

input  clk
input  reset
output [7:0] result

A interface atual é, portanto:

             DestByte8
          ┌──────────────┐
clk ─────►│              │
reset ───►│     CPU      │────► result[7:0]
          │              │
          └──────────────┘

O sinal result corresponde atualmente ao resultado produzido pela ALU. (GitHub)



17. Características ainda não definidas

A seguinte lista não deve ser interpretada como deficiência; ela representa simplesmente funcionalidades que ainda não estão definidas no RTL atual.

ISA

* instruções de carga;
* instruções de armazenamento;
* operações lógicas;
* deslocamentos;
* comparação;
* saltos;
* branches condicionais;
* chamadas de função;
* retorno de função;
* instruções de I/O;
* instruções de controle.

Estado arquitetural

* registrador de flags;
* stack pointer;
* registrador de status;
* registradores especiais;
* mecanismo de exceções;
* mecanismo de interrupções.

Memória

* RAM de dados;
* barramento externo de memória;
* MMIO;
* mapa de memória;
* largura e protocolo do barramento externo.

Controle de fluxo

O PC atualmente apenas incrementa:

PC ← PC + 1

Não existe atualmente lógica RTL para alterar o PC para outro endereço em decorrência de uma instrução.

Temporização

A documentação definitiva deverá especificar futuramente:

* frequência máxima;
* período de clock;
* latências;
* relação entre clock e execução da instrução;
* tempos de acesso da memória;
* comportamento de sinais externos.

Esses parâmetros dependem da implementação física específica e não devem ser inferidos apenas a partir da largura da ISA.



18. Estado arquitetural versus implementação

É importante distinguir dois níveis do DestByte8.

ISA

A ISA define o comportamento que um programa pode observar.

Atualmente, isso inclui:

8-bit instructions
8-bit registers
T0–T7
ADD
SUB
PC

Implementação

A implementação atual utiliza:

Verilog RTL
PC
ROM
decoder
register file
ALU

Uma futura implementação física pode reorganizar internamente esses blocos sem necessariamente alterar a ISA, desde que preserve o comportamento arquitetural especificado.



19. Estado da especificação

Esta versão deve ser considerada uma especificação inicial derivada do RTL atual, e não ainda uma especificação definitiva da arquitetura completa.

Implementado

* CPU/datapath de 8 bits
* PC de 8 bits
* oito registradores gerais de 8 bits
* duas portas de leitura
* uma porta de escrita
* instruções de 8 bits
* decoder
* ADD
* SUB
* ROM de 256 × 8 bits
* reset do PC
* incremento automático do PC

Ainda não especificado/implementado na ISA atual

* flags
* branches
* jumps
* CALL/RET
* stack
* load/store
* RAM de dados
* interrupções
* periféricos
* I/O
* instruções lógicas
* shifts/rotates
* multiplicação/divisão


20. Princípio de versionamento

A especificação da ISA deve ser versionada independentemente da implementação física.

Alterações que modificam o significado de uma instrução existente devem resultar em uma nova versão da ISA.

Alterações puramente internas de implementação podem ocorrer sem alterar a versão da ISA quando não modificarem o comportamento observável dos programas.

21. Observação sobre o estado atual

O DestByte8 encontra-se em fase inicial de desenvolvimento. O documento original do projeto também descreve os registradores T0–T7 como registradores de uso geral e indica que suas funções podem ser redefinidas em versões futuras. (GitHub)

Esta especificação, portanto, deve ser entendida como uma fotografia técnica da implementação atual, servindo como base para a evolução formal da arquitetura.

⸻

Fim da especificação — DestByte8 ISA/Architecture Draft 0.1