


`include "defines.v"

module id_stage(
  input wire  rst,
  input wire  [31 : 0]inst,
  input wire  [`REG_BUS]rs1_data,
  input wire  [`REG_BUS]rs2_data,
  
  
  output wire rs1_r_ena,
  output wire rs2_r_ena,
  output wire mem_r_ena,
  output wire mem_w_ena,
  output wire rd_w_ena,

  output wire [4 : 0]rs1_r_addr,
  output wire [4 : 0]rs2_r_addr,
  output wire [4 : 0]rd_addr,
  output wire [`REG_BUS]mem_r_addr,
  output wire [`REG_BUS]mem_w_addr,
  
  output reg  [4 : 0]inst_type,
  output reg  [7 : 0]inst_opcode,
  output wire [`REG_BUS]op1,
  output wire [`REG_BUS]op2
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

//中间变量
wire           op2_ena;
wire [`REG_BUS]op2_i;


//拆解
assign opcode = ( rst == 1'b0 ) ? inst[6 : 0] : 7'b0;
assign rd     = inst[11 : 7];
assign func3  = inst[14 : 12];
assign func7  = inst[31 : 25]; 
assign rs1    = inst[19 : 15];
assign rs2    = inst[24 : 20];
assign shamt  = inst[24 : 20];   //shamt = imm[4 : 0]
assign imm    = inst[31 : 20];

//sort inst-type
wire inst_i, inst_r, inst_load, inst_store;
assign inst_i     = ( opcode == `I_TYPE ) || ( opcode == `IW_TYPE );
assign inst_r     = ( opcode == `R_TYPE ) || ( opcode == `RW_TYPE ) ;
assign inst_load  = opcode == `LD_TYPE;
assign inst_store = opcode == `ST_TYPE;

//ctrl signal
assign rs1_r_ena = inst_i || inst_r || inst_load || inst_store;
assign rs2_r_ena = inst_r || inst_store;
assign rd_w_ena  = inst_i || inst_r || inst_load;
assign mem_r_ena = inst_load;
assign mem_w_ena = inst_store;

// I-type       opcode = 0010011
// R-type       opcode = 0110011
//load-type     opcode = 0000011
//store-type    opcode = 0100011
//rv64i-IW type opcode = 0011011
//rv64i-RW type opcode = 0111011
always @(*) 
begin
  case( opcode )
    //i-type
    `I_TYPE:  
    begin
      inst_type  = 5'b10000;
      case( func3 )
      000 :      begin inst_opcode = `INST_ADD;  end    //rd = rs1 + ( sign-extended )imm
      010 :      begin inst_opcode = `INST_SLT;  end    //if ( rs1 < ( sign-extended )imm ) rd = 1
      011 :      begin inst_opcode = `INST_SLTU; end    //if ( unsigned rs1 < unsigned imm ) rd = 1
      100 :      begin inst_opcode = `INST_XOR;  end    //rd = rs1 ^ ( sign-extended )imm
      110 :      begin inst_opcode = `INST_OR;   end    //rd = rs1 | ( sign-extended )imm
      111 :      begin inst_opcode = `INST_AND;  end    //rd = rs1 & ( sign-extended )imm
      001 :      begin inst_opcode = `INST_SLL;  end    //rd = rs1 << shamt = rs1 << imm[4 : 0]
      101 :      begin if ( imm[10] == 1 ) 
                       begin
                         inst_opcode = `INST_SRA;       //rd = $signed ( rs1 ) >> shamt  = >> imm[4 : 0]      
                       end
                       else begin
                         inst_opcode = `INST_SRL;       //rd = rs1 >> shamt = rs1 >> imm[4 : 0]
                       end  
                 end
      default:   begin inst_opcode = `INST_NOP;  end
      endcase
    end 
    `IW_TYPE:
    begin
      inst_type = 5'b10000;
      case ( func3 )
      000  :     begin inst_opcode = `INST_ADDW; end
      001  :     begin inst_opcode = `INST_SLLW; end
      101  :     begin if ( imm[10] == 1 ) 
                       begin
                         inst_opcode = `INST_SRAW;
                       end
                       else begin
                         inst_opcode = `INST_SRLW;
                       end
                 end
      default:   begin inst_opcode = `INST_NOP;   end 
      endcase
    end
    //r-type 
    `R_TYPE:  
    begin
      inst_type  = 5'b01000;
      case( func3 )
      000 :      begin if ( imm[10] == 1 )            //rd
                       begin
                         inst_opcode = `INST_SUB;       //rd = $signed( rs1 ) - $signed( rs2 )
                       end
                       else begin
                         inst_opcode = `INST_ADD;       //rd = $signed( rs1 ) + $signed( rs2 )
                       end
                 end
      001:       begin inst_opcode = `INST_SLL; end     //rd = rs1 >> rs2[4 : 0] 
      010:       begin inst_opcode = `INST_SLT; end     //rd = ( $signed( rs1 ) < $signed( rs2 ) ) ? 1 : 0
      011:       begin inst_opcode = `INST_SLTU; end    //rd = ( rs1 < rs2 ) ? 1 : 0
      100:       begin inst_opcode = `INST_XOR; end
      101:       begin if ( imm[10] == 1 ) 
                       begin
                         inst_opcode = `INST_SRA; end   //rd = $signed( rs1 ) >> rs2[4 : 0]
                       else begin
                         inst_opcode = `INST_SRL; end   //rd = rs1 >> rs2[4 : 0]
                 end  
      110:       begin inst_opcode = `INST_OR;  end
      111:       begin inst_opcode = `INST_AND; end
      default    begin inst_opcode = `INST_NOP; end
      endcase
    end
    `RW_TYPE:
    begin
      inst_type = 5'b01000;
      case ( func3 )
      000  :     begin if ( imm[10] == 1 )            
                       begin
                         inst_opcode = `INST_SUBW;       
                       end
                       else begin
                         inst_opcode = `INST_ADDW;       
                       end
                 end 
      001  :     begin inst_opcode = `INST_SLLW; end
      101  :     begin if ( imm[10] == 1 ) 
                       begin
                         inst_opcode = `INST_SRA; end  
                       else begin
                         inst_opcode = `INST_SRL; end   
                 end  
      default:   begin inst_opcode = `INST_NOP; end 
      endcase 
    end
    //load-type
    `LD_TYPE: 
    begin
      inst_type  = 5'b00100;
      case( func3)
      000 :      begin inst_opcode = `INST_LB;  end
      001 :      begin inst_opcode = `INST_LH;  end
      010 :      begin inst_opcode = `INST_LW;  end
      100 :      begin inst_opcode = `INST_LBU; end
      101 :      begin inst_opcode = `INST_LHU; end
      110 :      begin inst_opcode = `INST_LWU; end
      011 :      begin inst_opcode = `INST_LD;  end 
      default:   begin inst_opcode = `INST_NOP; end
      endcase
    end
    //store-type
    `ST_TYPE:
    begin
      inst_type  = 5'b00010;
      case ( func3 )
      000:       begin inst_opcode = `INST_SB;  end
      001:       begin inst_opcode = `INST_SH;  end
      010:       begin inst_opcode = `INST_SW;  end
      011:       begin inst_opcode = `INST_SD;  end
      default:   begin inst_opcode = `INST_NOP; end
      endcase
    end
    //rst
    0000000: 
    begin
      inst_type   = 5'b0;
      inst_opcode = 8'b0;
    end
    default: begin inst_opcode = `INST_NOP; end
  endcase
end  

//中间变量
assign op2_ena    = inst_type[4] || inst_type[3] || inst_type[1];
assign op2_i      = ( ~func3[2] & func3[1] & func3[0]) ? { {52{1'b0}}, imm } : { {52{imm[11]}}, imm };



//输出变量
assign rs1_r_addr = ( rs1_r_ena == 1'b1) ? rs1 : 0;
assign rs2_r_addr = ( rs2_r_ena == 1'b1) ? rs2 : 0;
assign rd_addr    = ( rd_w_ena == 1'b1 ) ? rd : 0;
assign op1        = ( rst == 1'b1 ) ? rs1_data : 0;
assign op2        = ( op2_ena == 1'b1 ) ? (inst_type[4] == 1'b1 ? op2_i : rs2_data ) : 0;
assign mem_r_addr = rs1_data + { {52{imm[11]}}, imm };
assign mem_w_addr = rs1_data + { {52{imm[11]}}, imm[11 : 5] , rd };



endmodule
