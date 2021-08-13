

`include "defines.v"

module wb(

    input wire           rst,

    input wire           rd_data_mem_ena,
    input wire           rd_data_exe_ena,

    input wire [`REG_BUS]mem_r_data,
    input wire [`REG_BUS]rd_data_exe,


    output wire [`REG_BUS]rd_data,
    output wire           rd_data_wb

);

assign rd_data_wb = rd_data_mem_ena || rd_data_exe_ena;
assign rd_data    = ( rst == 1'b1) ? `ZERO_WORD : ( rd_data_exe_ena == 1'b1 ? rd_data_exe : ( rd_data_mem_ena == 1'b1 ? mem_r_data : `ZERO_WORD));


endmodule
