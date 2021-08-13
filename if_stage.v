

`include "defines.v"

module if_stage(
  input wire clk,
  input wire rst,
  input wire pc_ena_if,
  input wire[`REG_BUS]pc_if,
  
  output reg [63 : 0] pc,
  output wire         inst_ena
  
);

parameter PC_START_RESET = `PC_START - 4 ;

// fetch an instruction
always@( posedge clk )
begin
  if( rst == 1'b1 )
  begin
    pc <= PC_START_RESET ;
  end
  else if( pc_ena_if == 1'b1 )
  begin
    pc <= pc_if ;
  end
  else begin
    pc <= pc + 4;
  end
end

assign inst_ena = ( rst == 1'b1 ) ? 0 : 1;

endmodule
