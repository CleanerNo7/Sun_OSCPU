
`timescale 1ns / 1ps

`define ZERO_WORD   64'h00000000_00000000  
`define PC_START    64'h00000000_80000000 
`define REG_BUS     63 : 0  
`define I_TYPE      7'b0010011
`define R_TYPE      7'b0110011
`define LD_TYPE     7'b0000011
`define ST_TYPE     7'b0100011
`define IW_TYPE     7'b0011011
`define RW_TYPE     7'b0111011
`define LUI         7'b0110111
`define AUIPC       7'b0010111
`define JAL         7'b1101111
`define JALR        7'b1100111
`define B_TYPE      7'b1100011
//default
`define INST_NOP    8'h10
//i-type & r-type
`define INST_ADD    8'h11//00010001
`define INST_SUB    8'h12//00010010
`define INST_SLL    8'h13//00010011      
`define INST_SLT    8'h14//00010100
`define INST_SLTU   8'h15//00010101
`define INST_XOR    8'h16//00010110
`define INST_SRL    8'h17//00010111
`define INST_SRA    8'h18//00011000
`define INST_OR     8'h19//00011001
`define INST_AND    8'h1A//00011010
`define INST_ADDW   8'h1B//00011011
`define INST_SUBW   8'h1C//00011100
`define INST_SLLW   8'h1D//00011101
`define INST_SRLW   8'h1E//00011110
`define INST_SRAW   8'h1F//00011111


//ui
`define INST_LUI    8'h20//00100000
`define INST_AUIPC  8'h21//00100001

// j
`define INST_JAL    8'h22//00100010
`define INST_JALR   8'h23//00100011

//b
`define INST_BEQ    8'h28//00101000
`define INST_BNE    8'h29//00101001
`define INST_BLT    8'h2A//00101010
`define INST_BGE    8'h2B//00101011
`define INST_BLTU   8'h2C//00101100
`define INST_BGEU   8'h2D//00101101
