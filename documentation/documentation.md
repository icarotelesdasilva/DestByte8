DestByte8 é uma arquitetura de processador de 8 bits desenvolvida do zero, com o objetivo de constituir uma arquitetura de propósito geral e evoluir tanto a sua ISA (Instruction Set Architecture) quanto sua implementação de hardware.

A implementação atual é descrita em Verilog RTL e é organizada em módulos independentes correspondentes às principais unidades do processador, incluindo:

* contador de programa;
* ROM de instruções;
* decodificador de instruções;
* banco de registradores;
* unidade lógica e aritmética (ALU);
* interconexão principal do processador.

A arquitetura não deve ser confundida com um simulador. O RTL constitui a descrição estrutural/comportamental do hardware digital da CPU. O diretório sim, quando existente no projeto, deve ser tratado separadamente como infraestrutura de verificação/desenvolvimento, e não como definição da CPU.

O repositório identifica explicitamente o DestByte8 como uma CPU de 8 bits construída inteiramente do zero. 

# características 

Característica

Estado atual

Largura de dados

8 bits

Largura das instruções

8 bits

Largura do PC

8 bits

Registradores gerais

8

Nome dos registradores

T0–T7

Largura dos registradores

8 bits

Endereço de registrador

3 bits

Operandos da ALU

2 × 8 bits

Resultado da ALU

8 bits

ALU atual

Soma e subtração

Memória de instruções

ROM

Endereço da ROM

8 bits

Espaço de endereçamento da ROM

256 posições

Reset

Assíncrono no PC

Incremento do PC

+1 por borda de subida

Flags

Não implementadas no RTL atual

Pipeline

Não implementado no RTL atual

Interrupções

Não implementadas no RTL atual

Stack pointer

Não implementado no RTL atual

