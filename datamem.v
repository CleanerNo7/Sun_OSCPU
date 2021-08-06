
`include "defines.v"



module datamem (
    input wire            clk,
    input wire            rst,
    input wire            mem_r_ena,
    input wire            mem_w_ena,
    input wire  [`REG_BUS]mem_r_addr,
    input wire  [`REG_BUS]mem_w_addr,
    input wire  [`REG_BUS]mem_w_data,

    output wire [`REG_BUS]mem_r_data,
    output wire           rd_data_mem_ena
);

wire en;
assign en         = ~rst;
assign mem_r_data = ram_read_helper(en, mem_r_addr);

assign rd_data_mem_ena = mem_r_ena;

always @(posedge clk) begin
  ram_write_helper(mem_w_addr,mem_w_data,mem_w_data,en);
end




endmodule


























