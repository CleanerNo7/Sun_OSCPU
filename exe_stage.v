
`include "defines.v"

module exe_stage(
  input wire rst,

  input reg     [4 : 0]inst_type_i,
  input reg     [7 : 0]inst_opcode,
  input wire    [`REG_BUS]op1,
  input wire    [`REG_BUS]op2,
  input wire    pc_ena_exe,
  input reg     [`REG_BUS]pc,
  input wire    [`REG_BUS]offset,
  
  output wire   [4 : 0]inst_type_o, 
  output wire   pc_ena_if,

  output wire   [2 : 0]mem,          //  指令
  output wire[`REG_BUS]mem_w_data,   
  output wire[`REG_BUS]rd_data_exe,
  output wire          rd_data_exe_ena,
  output wire[`REG_BUS]pc_if
);


wire         w;
wire [63 : 0]rd_addw,
             rd_subw,
             rd_sllw,
             rd_srlw,
             rd_sraw,
             pc_exe,
             pc_j,
             pc_b;

assign inst_type_o = inst_type_i;
assign pc_ena_if   = pc_ena_exe;

assign w = ~inst_opcode[5] & inst_opcode[4] & inst_opcode[3];
assign rd_addw = w ? ($signed( op1 ) + $signed( op2 )) : `ZERO_WORD;
assign rd_subw = w ? ($signed( op1 ) - $signed( op2 )) : `ZERO_WORD;
assign rd_sllw = w ? (op1 << op2[4 : 0]) : `ZERO_WORD;
assign rd_srlw = w ? (op1[31 : 0] >> op2[4 : 0]) : `ZERO_WORD;
assign rd_sraw = w ? (op1[31 : 0] >> $signed( op2[4 : 0] )) : `ZERO_WORD;

assign pc_exe  = ( pc_ena_exe == 1'b1 ) ? pc : `ZERO_WORD;



reg [`REG_BUS]opop;

always@( * )
begin
  if( rst == 1'b1 )
  begin
    opop = `ZERO_WORD;
  end
  else
  begin
    case( inst_opcode )
    //i-type & r-type inst_type = 5'b10000 or 5'b01000
    `INST_ADD:   begin opop = $signed( op1 ) + $signed( op2 );              end        //rd_data
    `INST_SUB:   begin opop = $signed( op1 ) - $signed( op2 );              end
    `INST_SLL:   begin opop = op1 << op2[4 : 0];                            end   
    `INST_SLT:   begin opop = ( $signed( op1 ) < $signed( op2 ) ) ? 1 : 0;  end
    `INST_SLTU:  begin opop = ( op1 < op2 ) ? 1 : 0;                        end
    `INST_XOR:   begin opop = op1 ^ op2;                                    end
    `INST_SRL:   begin opop = op1 >> op2[4 : 0];                            end
    `INST_SRA:   begin opop = op1 >> $signed( op2[4 : 0] );                 end
    `INST_OR:    begin opop = op1 | op2;                                    end
    `INST_AND:   begin opop = op1 & op2;                                    end
    `INST_ADDW:  begin opop = { {32{rd_addw[31]}}, rd_addw };               end 
    `INST_SUBW:  begin opop = { {32{rd_subw[31]}}, rd_subw };               end
    `INST_SLLW:  begin opop = { {32{rd_sllw[31]}}, rd_sllw };               end
    `INST_SRLW:  begin opop = { {32{rd_srlw[31]}}, rd_srlw };               end                 
    `INST_SRAW:  begin opop = { {32{rd_sraw[31]}}, rd_sraw };               end
    
    //load-type inst_type = 5'b00100
    `INST_LB:    begin opop = 64'b001;     end      //mem
    `INST_LH:    begin opop = 64'b010;     end
    `INST_LW:    begin opop = 64'b011;     end
    `INST_LBU:   begin opop = 64'b100;     end
    `INST_LHU:   begin opop = 64'b101;     end
    `INST_LWU:   begin opop = 64'b110;     end
    `INST_LD:    begin opop = 64'b111;     end
    //store-type inst_type = 5'b00010
    `INST_SB:    begin opop = { {56{1'b0}}, op2[7 : 0] }  ;   end   //mem_w_Data
    `INST_SH:    begin opop = { {48{1'b0}}, op2[15 : 0] } ;   end
    `INST_SW:    begin opop = { {32{1'b0}}, op2[31 : 0] } ;   end
    `INST_SD:    begin opop = op2;                            end
    //LUI & AUIPC inst_type = 5'b00001
    `INST_LUI:   begin opop = op1;             end
    `INST_AUIPC: begin opop = op1 + pc_exe;    end
    //j           inst_type = 5'b00011
    `INST_JAL:   begin opop = pc_exe + 4;      end
    `INST_JALR:  begin opop = pc_exe + 4;      end
    //b           inst_type = 5'b00110
    `INST_BEQ:   begin opop = ( op1 == op2 ) ? ( pc_exe + offset ) : ( pc_exe + 4 );                     end
    `INST_BNE:   begin opop = ( op1 != op2 ) ? ( pc_exe + offset ) : ( pc_exe + 4 );                     end
    `INST_BLT:   begin opop = ( $signed( op1 ) < $signed( op2 )) ? ( pc_exe + offset) : ( pc_exe + 4 );  end
    `INST_BGE:   begin opop = ( $signed( op1 ) >= $signed( op2 )) ? ( pc_exe + offset) : ( pc_exe + 4 ); end 
    `INST_BLTU:  begin opop = ( op1 < op2 ) ? ( pc_exe +offset ) : ( pc_exe + 4 );                       end
    `INST_BGEU:  begin opop = ( op1 >= op2 ) ? ( pc_exe +offset ) : ( pc_exe + 4 );                      end
    //default
    `INST_NOP:   begin opop = `ZERO_WORD;  end
	  default:     begin opop = `ZERO_WORD;  end
	endcase
  end
end

assign pc_j    = ( inst_type_i[1] && inst_type_i[0] == 1'b1 ) ? ( inst_opcode[1] && inst_opcode[0] == 1'b1 ? offset : ( pc_exe + offset )) : ( pc_exe + 4 );
assign pc_b    = ( inst_type_i[2] && inst_type_i[1] == 1'b1 ) ? opop : ( pc_exe + 4 );

assign pc_if   = ( inst_type_i[1] && inst_type_i[0] == 1'b1 ) ? pc_j : ( inst_type_i[2] && inst_type_i[1] == 1'b1 ? pc_b : ( pc_exe + 4 ));
assign rd_data_exe= (rst == 1'b1) ? `ZERO_WORD : (inst_type_i[4] || inst_type_i[3] || inst_type_i[0] ? opop : `ZERO_WORD);
assign mem        = (rst == 1'b1) ? 3'b000 : (inst_type_i[2] ? opop[2 : 0] : 3'b000);
assign mem_w_data = (rst == 1'b1) ? `ZERO_WORD : (inst_type_i[1] ? opop : `ZERO_WORD);

assign rd_data_exe_ena = inst_type_i[4] || inst_type_i[3] || inst_type_i[0];

endmodule
