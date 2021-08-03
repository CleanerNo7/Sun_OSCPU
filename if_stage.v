

`include "defines.v"

module if_stage(
  input wire clk,
  input wire rst,
  
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
  else
  begin
    pc <= pc + 4;
  end
end

//Access memory
reg [63 : 0]pc_data;
reg [63 : 0]mem_r_data;
reg [63 : 0]mem_w_data;
reg [63 : 0]mem_w_mask;
reg [63 : 0]mem_r_addr;
reg [63 : 0]mem_w_addr;
reg         wen;
RAMHelper RAMHelper(
  .clk               (clk),
  .en                (1),
  .rIdx_i            ((pc - `PC_START) >> 3),
  .rdata_i           (pc_data),
  .rIdx_d            ((mem_r_addr - `PC_START) >> 3),
  .rdata_d           (mem_r_data),
  .wIdx              ((mem_w_addr - `PC_START) >> 3),
  .wdata             (mem_w_data),
  .wmask             (mem_w_mask),
  .wen               (wen)

);
assign inst = pc[2] ? pc_data[63 : 32] : pc_data[31 : 0];

endmodule
