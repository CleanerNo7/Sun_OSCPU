
`include "defines.v"

module datamem (
    input wire            clk,
    input wire            rst,
    input wire            datamem_ena,
    input wire            memwb_ena,
    input wire  [`REG_BUS]mem_r_addr,
    input wire  [`REG_BUS]mem_w_addr,
    input wire  [`REG_BUS]mem_w_data,

    output wire [`REG_BUS]mem_r_data,
    output wire           wb_ena   //握手

);

reg [63 : 0]my_mem[63 : 0];

assign mem_r_data = ( rst == 1'b0) ? ( memwb_ena == 1'b1 ? my_mem[mem_r_addr] : `ZERO_WORD ) : `ZERO_WORD;
assign wb_ena     = memwb_ena;

always @(posedge clk) 
begin
  if (datamem_ena == 1'b1 && rst == 1'b0) 
  begin
    my_mem[mem_w_addr] <= mem_w_data; 
  end  
end

integer i;
initial 
begin
  for(i = 0 ; i < 64; i = i + 1)
  begin
    my_mem[i] = 0;
  end
end

endmodule


























