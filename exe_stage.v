
`include "defines.v"

module exe_stage(
  input wire rst,

  input wire    [4 : 0]inst_type_i,
  input wire    [7 : 0]inst_opcode,
  input wire    [`REG_BUS]op1,
  input wire    [`REG_BUS]op2,
  input wire    pc_ena_exe,
  input reg     [`REG_BUS]pc,
  input wire    [`REG_BUS]offset,
  input wire              w,
  
  output wire   [4 : 0]inst_type_o, 
  output wire   pc_ena_if,

  
  output wire[`REG_BUS]rd_data_exe,
  output wire          rd_data_exe_ena,
  output wire[`REG_BUS]pc_if
);


wire [63 : 0]rd_addw1,
             rd_addw,
             rd_subw1,
             rd_subw,
             rd_sllw,
             rd_srlw,
             rd_sraw,
             pc_exe,
             pc_j,
             pc_b;
wire [5 : 0]shamt;

assign shamt = op2[5 : 0];
assign inst_type_o = inst_type_i;
assign pc_ena_if   = ( inst_type_i[1] && inst_type_i[0] ) || ( inst_type_i[2] && inst_type_i[1] );

assign rd_addw1 = w ? ($signed( op1 ) + $signed( op2 )) : `ZERO_WORD;
assign rd_addw  = {{32{rd_addw1[31]}},rd_addw1[31 : 0]};
assign rd_subw1 = w ? ($signed( op1 ) - $signed( op2 )) : `ZERO_WORD;
assign rd_subw  = {{32{rd_subw1[31]}},rd_subw1[31 : 0]};
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
    `INST_SUB:   begin opop = $signed( op2 ) - $signed( op1 );              end
    `INST_SLL:   begin opop = op1 << shamt     ;                            end   
    `INST_SLT:   begin opop = ( $signed( op1 ) < $signed( op2 ) ) ? 1 : 0;  end
    `INST_SLTU:  begin opop = ( op1 < op2 ) ? 1 : 0;                        end
    `INST_XOR:   begin opop = op1 ^ op2;                                    end
    `INST_SRL:   begin opop = op1 >> shamt;                                 end
    `INST_SRA:   begin opop = op1 >> $signed( shamt );                      end
    `INST_OR:    begin opop = op1 | op2;                                    end
    `INST_AND:   begin opop = op1 & op2;                                    end
    `INST_ADDW:  begin opop = rd_addw;                                      end 
    `INST_SUBW:  begin opop = rd_subw;                                      end
    `INST_SLLW:  begin opop = { {32{rd_sllw[31]}}, rd_sllw };               end
    `INST_SRLW:  begin opop = { {32{rd_srlw[31]}}, rd_srlw };               end                 
    `INST_SRAW:  begin opop = { {32{rd_sraw[31]}}, rd_sraw };               end
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


assign rd_data_exe_ena = inst_type_i[4] || inst_type_i[3] || inst_type_i[0];

endmodule
