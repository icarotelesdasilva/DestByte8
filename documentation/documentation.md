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