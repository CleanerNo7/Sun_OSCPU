
`include "defines.v"


module ram_1w2r(
    input clk,
    
    input reg [`REG_BUS]inst_addr,
    input wire         inst_ena,
    output wire  [31:0]inst,
    output wire        inst_ready,

    // DATA PORT
    input reg [`REG_BUS]ram_w_mask,
    input wire[`REG_BUS]ram_addr,
    input reg [`REG_BUS]ram_w_data,
    input wire      ram_r_ena,
    input wire      ram_w_ena,
    output wire [`REG_BUS]ram_r_data
);

    // INST PORT
    assign inst_ready = inst_ena;
    wire[`REG_BUS] inst_2 = ram_read_helper(inst_ena,{3'b000,(inst_addr-64'h0000_0000_8000_0000)>>3});

    assign inst = inst_addr[2] ? inst_2[63:32] : inst_2[31:0];

    // DATA PORT 
    assign ram_r_data = ram_read_helper(ram_r_ena, {3'b000,(ram_addr-64'h0000_0000_8000_0000)>>3});

    always @(posedge clk) begin
        ram_write_helper((ram_addr-64'h0000_0000_8000_0000)>>3, ram_w_data, ram_w_mask, ram_w_ena);
    end

endmodule

