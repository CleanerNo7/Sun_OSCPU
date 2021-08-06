
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
`define INST_ADD    8'h11
`define INST_SUB    8'h12
`define INST_SLL    8'h13
`define INST_SLT    8'h14
`define INST_SLTU   8'h15
`define INST_XOR    8'h16
`define INST_SRL    8'h17
`define INST_SRA    8'h18
`define INST_OR     8'h19
`define INST_AND    8'h1A
`define INST_ADDW   8'h1B
`define INST_SUBW   8'h1C
`define INST_SLLW   8'h1D
`define INST_SRLW   8'h1E
`define INST_SRAW   8'h1F


//load & store
`define INST_LB     8'h21
`define INST_LH     8'h22
`define INST_LW     8'h23
`define INST_LBU    8'h24
`define INST_LHU    8'h25
`define INST_LWU    8'h26
`define INST_LD     8'h27

`define INST_SB     8'h2A
`define INST_SH     8'h2B
`define INST_SW     8'h2C
`define INST_SD     8'h2D


//ui
`define INST_LUI    8'h31
`define INST_AUIPC  8'h32

// j
`define INST_JAL    8'h3A
`define INST_JALR   8'h3B

//b
`define INST_BEQ    8'h41
`define INST_BNE    8'h42
`define INST_BLT    8'h43
`define INST_BGE    8'h44
`define INST_BLTU   8'h45
`define INST_BGEU   8'h46
