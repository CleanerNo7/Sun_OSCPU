


`include "defines.v"

module id_stage(
  input wire  rst,
  input wire  [31 : 0]inst,
  input wire          inst_ready,
  input wire  [`REG_BUS]rs1_data,
  input wire  [`REG_BUS]rs2_data,

  
  output wire pc_ena_exe,
  output wire rs1_r_ena,
  output wire rs2_r_ena,
  output wire mem_r_ena,
  output wire mem_w_ena,
  output wire rd_w_ena,

  output wire [4 : 0]rs1_r_addr,
  output wire [4 : 0]rs2_r_addr,
  output wire [4 : 0]rd_addr,
  output wire [`REG_BUS]mem_addr,
  
  output wire [4 : 0]inst_type,
  output wire [7 : 0]inst_opcode,
  output wire        inst_w,
  output wire [2 : 0]load_type,
  output wire [2 : 0]store_type,

  output wire [`REG_BUS]mem_w_data,
  output wire [`REG_BUS]op1,
  output wire [`REG_BUS]op2,
  output wire [`REG_BUS]offset,

  output wire custom_ena

);

//inst拆解
wire    [6 : 0]opcode,
               func7;
wire    [2 : 0]func3;
wire    [4 : 0]rs1,
               rs2,
               rd,
               shamt;
wire   [11 : 0]imm;
wire   [19 : 0]imm_20;     //lui,高位立即数加载

wire           j_20,
               j_11;
wire    [9 : 0]j_10_1;
wire    [7 : 0]j_19_12;
wire    [`REG_BUS]offset_j,
                  offset_jal,
                  offset_jalr;

wire           b_12,
               b_11;
wire    [5 : 0]b_10_5;
wire    [3 : 0]b_4_1;
wire    [`REG_BUS]offset_b;

//中间变量
wire           op2_ena;
wire [`REG_BUS]op2_i;
wire [`REG_BUS]op1_ui;
wire [`REG_BUS]mem_r_addr,
               mem_w_addr;


//拆解
assign opcode = ( rst == 1'b1 ) ? 7'b0 : ( inst_ready == 1'b1 ? inst[6 : 0] : 7'b0 );
assign rd     = inst[11 : 7];
assign func3  = inst[14 : 12];
assign func7  = inst[31 : 25]; 
assign rs1    = inst[19 : 15];
assign rs2    = inst[24 : 20];
assign shamt  = inst[24 : 20];   //shamt = imm[4 : 0]
assign imm    = inst[31 : 20];
assign imm_20 = inst[31 : 12];

assign j_20    = inst[31];
assign j_19_12 = inst[19 : 12];
assign j_11    = inst[20];
assign j_10_1  = inst[30 : 21];

assign b_12    = inst[31];
assign b_11    = inst[7];
assign b_10_5  = inst[30 : 25];
assign b_4_1   = inst[11 : 8];

//sort inst-type
wire inst_i, inst_iw, inst_r, inst_rw, inst_load, inst_store, inst_ui, inst_j, inst_jalr, inst_b, inst_custom;
assign inst_i     = ~opcode[6] & ~opcode[5] & opcode[4] & ~opcode[3] & ~opcode[2];
assign inst_iw    = ~opcode[6] & ~opcode[5] & opcode[4] & opcode[3] & ~opcode[2];
assign inst_r     = ~opcode[6] & opcode[5] & opcode[4] & ~opcode[3] & ~opcode[2];
assign inst_rw    = ~opcode[6] & opcode[5] & opcode[4] & opcode[3] & ~opcode[2];
assign inst_load  = ~opcode[6] & ~opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2];
assign inst_store = ~opcode[6] & opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2];
assign inst_ui    = ~opcode[6] & opcode[4] & ~opcode[3] & opcode[2];
assign inst_j     = opcode[6] & opcode[5] & ~opcode[4] & opcode[2];
assign inst_jalr  = opcode[6] & opcode[5] & ~opcode[4] & ~opcode[3] & opcode[2];
assign inst_b     = opcode[6] & opcode[5] & ~opcode[4] & ~opcode[3] & ~opcode[2];

assign inst_custom= opcode[6] & opcode[5] & opcode[4] & opcode[3] & ~opcode[2];
//sort inst_type
assign inst_type[4] = inst_i || inst_iw || inst_custom;
assign inst_type[3] = inst_r || inst_rw || inst_custom;
assign inst_type[2] = inst_load || inst_b;
assign inst_type[1] = inst_store || inst_j || inst_b;
assign inst_type[0] = inst_ui || inst_j ;
assign inst_w = inst_iw || inst_rw;

//ctrl signal
assign rs1_r_ena = inst_i || inst_iw || inst_r || inst_rw || inst_load || inst_store || inst_jalr || inst_b || inst_custom;
assign rs2_r_ena = inst_r || inst_rw || inst_store || inst_b;
assign rd_w_ena  = inst_i || inst_iw || inst_r || inst_rw || inst_load || inst_custom;
assign mem_r_ena = inst_load || inst_custom;
assign mem_w_ena = inst_store;


wire inst_auipc;
assign inst_auipc = ~opcode[6] & ~opcode[5] & opcode[4] & ~opcode[3] & opcode[2];
assign pc_ena_exe = inst_auipc || inst_j || inst_b;


//load & store 
assign load_type  = ( inst_load == 1'b1 ) ? func3 : ( inst_custom == 1'b1 ? 3'b011 : 3'b111);
assign store_type = ( inst_store == 1'b1 ) ? func3 : 3'b111;
assign mem_w_data = ( mem_w_ena == 1'b1 ) ? rs2_data : `ZERO_WORD;

// I-type       opcode = 0010011
// R-type       opcode = 0110011
//load-type     opcode = 0000011
//store-type    opcode = 0100011
//rv64i-IW type opcode = 0011011
//rv64i-RW type opcode = 0111011
//lui           opcode = 0110111
//AUIPC         opcode = 0010111
//Jal           opcode = 1101111
//jalr          opcode = 1100111
//b             opcode = 1100011

//customize     opcode = 1111011
//              inst_type = 5'b11000

//I-type & IW-type inst_type = 5'b10000
//R-type & RW-type inst_type = 5'b01000
//load-type        inst_type = 5'b00100
//store-type       inst_type = 5'b00010
//lui    & auipc   inst_type = 5'b00001
//J-type           inst_type = 5'b00011
//B-type           inst_type = 5'b00110

wire add_signal,  sub_signal,  sll_signal, slt_signal, sltu_signal, xor_signal,srl_signal, sra_signal, or_signal, and_signal, 
     addw_signal, subw_signal, sllw_signal, srlw_signal, sraw_signal,
     lui_signal,  auipc_signal,
     jal_signal,  jalr_signal,
     beq_signal,  bne_signal,  blt_signal, bge_signal, bltu_signal, bgeu_signal;

wire addi_signal, addr_signal;
assign addi_signal = inst_i & ~func3[2] & ~func3[1] & ~func3[0];
assign addr_signal = inst_r & ~imm[10] & ~func3[2] & ~func3[1] & ~func3[0];

assign add_signal = addi_signal || addr_signal;
assign sub_signal = inst_r & imm[10] & ~func3[2] & ~func3[1] & ~func3[0];
assign sll_signal = ( inst_i || inst_r ) & ~func3[2] & ~func3[1] & func3[0];
assign slt_signal = ( inst_i || inst_r ) & ~func3[2] & func3[1] & ~func3[0];
assign sltu_signal= ( inst_i || inst_r ) & ~func3[2] & func3[1] & func3[0];
assign xor_signal = ( inst_i || inst_r ) & func3[2] & ~func3[1] & ~func3[0];
assign srl_signal = ( inst_i || inst_r ) & ~imm[10] & func3[2] & ~func3[1] & func3[0];
assign sra_signal = ( inst_i || inst_r ) & imm[10] & func3[2] & ~func3[1] & func3[0];
assign or_signal  = ( inst_i || inst_r ) & func3[2] & func3[1] & ~func3[0];
assign and_signal = ( inst_i || inst_r ) & func3[2] & func3[1] & func3[0];

wire addwi_signal, addwr_signal;
assign addwi_signal = inst_iw & ~func3[2] & ~func3[1] & ~func3[0];
assign addwr_signal = inst_rw & ~imm[10] & ~func3[2] & ~func3[1] & ~func3[0];

assign addw_signal = addwi_signal || addwr_signal;
assign subw_signal = inst_rw & imm[10] & ~func3[2] & ~func3[1] & ~func3[0];
assign sllw_signal = ( inst_iw || inst_rw ) & ~func3[2] & ~func3[1] & func3[0];
assign srlw_signal = ( inst_iw || inst_rw ) & ~imm[10] & func3[2] & ~func3[1] & func3[0];
assign sraw_signal = ( inst_iw || inst_rw ) & imm[10] & func3[2] & ~func3[1] & func3[0];

assign lui_signal   = inst_ui & opcode[5];
assign auipc_signal = inst_auipc;

assign jal_signal  = inst_j & opcode[3];
assign jalr_signal = inst_jalr;

assign beq_signal = inst_b & ~func3[2] & ~func3[1] & ~func3[0];
assign bne_signal = inst_b & ~func3[2] & ~func3[1] & func3[0];
assign blt_signal = inst_b & func3[2] & ~func3[1] & ~func3[0];
assign bge_signal = inst_b & func3[2] & ~func3[1] & func3[0];
assign bltu_signal= inst_b & func3[2] & func3[1] & ~func3[0];
assign bgeu_signal= inst_b & func3[2] & func3[1] & func3[0];

assign inst_opcode[6] = inst_custom;
assign inst_opcode[5] = inst_ui || inst_j || inst_b;
assign inst_opcode[4] = inst_i || inst_iw || inst_r || inst_rw;
assign inst_opcode[3] = sra_signal || or_signal || and_signal || addw_signal || subw_signal || sllw_signal || srlw_signal || sraw_signal || inst_b;
assign inst_opcode[2] = slt_signal || sltu_signal || xor_signal || srl_signal || subw_signal || sllw_signal || srlw_signal || sraw_signal || bltu_signal || bgeu_signal;
assign inst_opcode[1] = sub_signal || sll_signal || xor_signal || srl_signal || and_signal || addw_signal || srlw_signal || sraw_signal || inst_j || blt_signal || bge_signal;
assign inst_opcode[0] = add_signal || sll_signal || sltu_signal || srl_signal || or_signal || addw_signal || sllw_signal || sraw_signal || auipc_signal || inst_jalr || bne_signal || bge_signal || bgeu_signal;



//中间变量
assign op2_ena    = inst_type[4] || inst_type[3] || inst_type[1];
assign op2_i      =  { {52{imm[11]}}, imm };
assign op1_ui     = { {32{imm_20[19]}}, imm_20, 12'b0 };
assign offset_jal = { {44{j_20}}, j_19_12, j_11, j_10_1,1'b0 };
assign offset_jalr= ( { {52{imm[11]}}, imm } + rs1_data ) & -1 ;
assign offset_j   = ( inst_j == 1'b1 ) ? (inst_jalr == 1'b1 ? offset_jalr :offset_jal ) : 0; 
assign offset_b   = { {52{b_12}}, b_11, b_10_5, b_4_1,1'b0};
assign mem_r_addr = ( inst_custom == 1'b1 ) ? rs1 : ( rs1_data + { {52{imm[11]}}, imm });
assign mem_w_addr = rs1_data + { {52{imm[11]}}, func7 , rd };

//输出变量
assign rs1_r_addr = ( rs1_r_ena == 1'b1) ? rs1 : 0;
assign rs2_r_addr = ( rs2_r_ena == 1'b1) ? rs2 : 0;
assign rd_addr    = rd;
assign op1        = ( rs1_r_ena == 1'b1 ) ? rs1_data : ( inst_ui == 1'b1 ? op1_ui : 0 );
assign op2        = ( op2_ena == 1'b1 ) ? (inst_type[4] == 1'b1 ? op2_i : rs2_data ) : 0;
assign mem_addr   = ( inst_load | inst_custom == 1'b1 ) ? mem_r_addr : ( inst_store == 1'b1 ? mem_w_addr : `ZERO_WORD );
assign offset     = ( inst_j == 1'b1 ) ? offset_j : ( inst_b == 1'b1 ? offset_b : 0);

assign custom_ena = inst_custom;

endmodule
