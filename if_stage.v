

`include "defines.v"

module if_stage(
  input wire clk,
  input wire rst,
  input wire pc_ena_if,
  input wire[`REG_BUS]pc_if,
  
  output reg [63 : 0] pc,
  output reg [31 : 0] inst
  
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
    pc <= pc_if;
  end
  else begin
    pc <= pc + 4;
  end
end

//Access memory
reg [63:0] mem_r_addr,
           mem_r_data,
           mem_w_addr,
           mem_w_mask,
           mem_w_data,
           pc_r_data;
reg        wen;
           
RAMHelper RAMHelper(
  .clk              (clk),
  .en               (1),
  .rIdx_i           ((pc - `PC_START) >> 3),
  .rIdx_d           ((mem_r_addr - `PC_START) >> 3),
  .rdata_i          (pc_r_data),
  .rdata_d          (mem_r_data),
  .wIdx             ((mem_w_addr - `PC_START) >> 3),
  .wdata            (mem_w_data),
  .wmask            (mem_w_mask),
  .wen              (wen)
);
assign inst = pc[2] ? pc_r_data[63 : 32] : pc_r_data[31 : 0];

endmodule
