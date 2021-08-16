
`include "defines.v"



module mem_stage (
    input wire            rst,
    
    //cpu-side
    input wire     [2 : 0]load_type,
    input wire     [2 : 0]store_type,
    input wire            mem_r_ena,
    input wire            mem_w_ena,
    input wire  [`REG_BUS]mem_addr,
    input wire  [`REG_BUS]mem_w_data,
    output reg  [`REG_BUS]mem_r_data,
    output wire           rd_data_mem_ena,
    //ram-side
    output wire [`REG_BUS]ram_addr,
    output wire           ram_r_ena,
    output wire           ram_w_ena,
    output reg [`REG_BUS]ram_w_mask,
    output reg [`REG_BUS]ram_w_data,
    input wire  [`REG_BUS]ram_r_data
);

reg [`REG_BUS]sb_ram_w_mask;
reg [`REG_BUS]sb_ram_w_data;
reg [`REG_BUS]sh_ram_w_mask;
reg [`REG_BUS]sh_ram_w_data;
reg [`REG_BUS]sw_ram_w_mask;
reg [`REG_BUS]sw_ram_w_data;
reg [`REG_BUS]sd_ram_w_mask;
reg [`REG_BUS]sd_ram_w_data;

reg [`REG_BUS]lb_ram_r_data;
reg [`REG_BUS]lh_ram_r_data;
reg [`REG_BUS]lw_ram_r_data;
reg [`REG_BUS]lbu_ram_r_data;
reg [`REG_BUS]lhu_ram_r_data;
reg [`REG_BUS]lwu_ram_r_data;
reg [`REG_BUS]ld_ram_r_data;



assign ram_addr = mem_addr;
assign ram_r_ena  = rst ? 0 : mem_r_ena;
assign ram_w_ena  = rst ? 0 : mem_w_ena;
assign rd_data_mem_ena = mem_r_ena;

wire sb_signal = ~store_type[2] & ~store_type[1] & ~store_type[0];
wire sh_signal = ~store_type[2] & ~store_type[1] & store_type[0];
wire sw_signal = ~store_type[2] & store_type[1] & ~store_type[0];
wire sd_signal = ~store_type[2] & store_type[1] & store_type[0];

wire lb_signal  = ~load_type[2] & ~load_type[1] & ~load_type[0];
wire lh_signal  = ~load_type[2] & ~load_type[1] & load_type[0];
wire lw_signal  = ~load_type[2] & load_type[1] & ~load_type[0];
wire lbu_signal = load_type[2] & ~load_type[1] & ~load_type[0];
wire lhu_signal = load_type[2] & ~load_type[1] & load_type[0];
wire lwu_signal = load_type[2] & load_type[1] & ~load_type[0];
wire ld_signal  = ~load_type[2] & load_type[1] & load_type[0];

//ram_w mux
always @(*) 
begin
    if (rst) begin
        ram_w_mask = `ZERO_WORD;
        ram_w_data = `ZERO_WORD;
    end
    else if(sb_signal)begin
        ram_w_mask = sb_ram_w_mask;
        ram_w_data = sb_ram_w_data;
    end
    else if(sh_signal)begin
        ram_w_mask = sh_ram_w_mask;
        ram_w_data = sh_ram_w_data;
    end  
    else if(sw_signal)begin
        ram_w_mask = sw_ram_w_mask;
        ram_w_data = sw_ram_w_data;
    end    
    else if(sd_signal)begin
        ram_w_mask = sd_ram_w_mask;
        ram_w_data = sd_ram_w_data;
    end  
    else begin
        ram_w_mask = `ZERO_WORD;
        ram_w_data = `ZERO_WORD;
    end        
end
//ram_r mux
always @(*) 
begin
    if(rst)begin
        mem_r_data = `ZERO_WORD;
    end    
    else if (lb_signal) 
    begin
        mem_r_data = lb_ram_r_data;
    end
    else if (lh_signal) 
    begin
        mem_r_data = lh_ram_r_data;
    end
    else if (lw_signal) 
    begin
        mem_r_data = lw_ram_r_data;
    end
    else if (lbu_signal) 
    begin
        mem_r_data = lbu_ram_r_data;
    end
    else if (lhu_signal) 
    begin
        mem_r_data = lhu_ram_r_data;
    end
    else if (lwu_signal) 
    begin
        mem_r_data = lwu_ram_r_data;
    end
    else if (ld_signal) 
    begin
        mem_r_data = ld_ram_r_data;
    end
    else mem_r_data = `ZERO_WORD;
end

//ram_w_sb
always @( sb_signal or mem_addr[2 : 0] or mem_w_data[7 : 0] ) 
begin
    if(sb_signal)begin
        case(mem_addr[2 : 0])
        3'b000:begin
            sb_ram_w_mask = 64'h0000_0000_0000_00FF;
            sb_ram_w_data = {56'b0,mem_w_data[7 : 0]};
        end
        3'b001:begin
            sb_ram_w_mask = 64'h0000_0000_0000_FF00;
            sb_ram_w_data = {48'b0,mem_w_data[7 : 0],8'b0};
        end
        3'b010:begin
            sb_ram_w_mask = 64'h0000_0000_00FF_0000;
            sb_ram_w_data = {40'b0,mem_w_data[7 : 0],16'b0};
        end
        3'b011:begin
            sb_ram_w_mask = 64'h0000_0000_FF00_0000;
            sb_ram_w_data = {32'b0,mem_w_data[7 : 0],24'b0};
        end
        3'b100:begin
            sb_ram_w_mask = 64'h0000_00FF_0000_0000;
            sb_ram_w_data = {24'b0,mem_w_data[7 : 0],32'b0};
        end
        3'b101:begin
            sb_ram_w_mask = 64'h0000_FF00_0000_0000;
            sb_ram_w_data = {16'b0,mem_w_data[7 : 0],40'b0};
        end
        3'b110:begin
            sb_ram_w_mask = 64'h00FF_0000_0000_0000;
            sb_ram_w_data = {8'b0,mem_w_data[7 : 0],48'b0};
        end
        3'b111:begin
            sb_ram_w_mask = 64'hFF00_0000_0000_0000;
            sb_ram_w_data = {mem_w_data[7 : 0],56'b0};
        end
        endcase
    end
    else begin
        sb_ram_w_mask = `ZERO_WORD;
        sb_ram_w_data = `ZERO_WORD;
    end
end
//ram_w_sh
always @( sh_signal or mem_addr[2 : 1] or mem_w_data[15 : 0] ) 
begin
    if (sh_signal) begin
        case(mem_addr[2 : 1])
        2'd0:begin
            sh_ram_w_mask = 64'h0000_0000_0000_FFFF;
            sh_ram_w_data = {48'b0,mem_w_data[15 : 0]};
        end
        2'd1:begin
            sh_ram_w_mask = 64'h0000_0000_FFFF_0000;
            sh_ram_w_data = {32'b0,mem_w_data[15 : 0],16'b0};
        end
        2'd2:begin
            sh_ram_w_mask = 64'h0000_FFFF_0000_0000;
            sh_ram_w_data = {16'b0,mem_w_data[15 : 0],32'b0};
        end
        2'd3:begin
            sh_ram_w_mask = 64'hFFFF_0000_0000_0000;
            sh_ram_w_data = {mem_w_data[15 : 0],48'b0};
        end
    endcase
    end
    else begin
        sh_ram_w_mask = `ZERO_WORD;
        sh_ram_w_data   = `ZERO_WORD;
    end
end
//ram_w_sw
always @( sw_signal or mem_addr[2] or mem_w_data[31 : 0]) 
begin
    if(sw_signal)begin
        case(mem_addr[2])
        1'b0:begin
            sw_ram_w_mask = 64'h0000_0000_FFFF_FFFF;
            sw_ram_w_data   = {32'b0,mem_w_data[31 : 0]};
        end
        1'b1:begin
            sw_ram_w_mask = 64'hFFFF_FFFF_0000_0000;
            sw_ram_w_data   = {mem_w_data[31 : 0],32'b0};
        end
    endcase
    end
    else begin
        sw_ram_w_mask = `ZERO_WORD;
        sw_ram_w_data   = `ZERO_WORD;
    end   
end
//ram_w_sd
always @( sd_signal or mem_w_data) 
begin
    if(sd_signal)begin
        sd_ram_w_mask = 64'hFFFF_FFFF_FFFF_FFFF;
        sd_ram_w_data = mem_w_data;
    end
    else begin
        sd_ram_w_mask = `ZERO_WORD;
        sd_ram_w_data = `ZERO_WORD;
    end
end

//ram_r_lb
always @(lb_signal or mem_addr[2 : 0] or ram_r_data ) 
begin
    if (lb_signal) 
    begin
        case(mem_addr[2 : 0])
        3'd0: lb_ram_r_data = {{56{ram_r_data[7]}},ram_r_data[7 : 0]};
        3'd1: lb_ram_r_data = {{56{ram_r_data[15]}},ram_r_data[15 : 8]};
        3'd2: lb_ram_r_data = {{56{ram_r_data[23]}},ram_r_data[23 : 16]};
        3'd3: lb_ram_r_data = {{56{ram_r_data[31]}},ram_r_data[31 : 24]};
        3'd4: lb_ram_r_data = {{56{ram_r_data[39]}},ram_r_data[39 : 32]};
        3'd5: lb_ram_r_data = {{56{ram_r_data[47]}},ram_r_data[47 : 40]};
        3'd6: lb_ram_r_data = {{56{ram_r_data[55]}},ram_r_data[55 : 48]};
        3'd7: lb_ram_r_data = {{56{ram_r_data[63]}},ram_r_data[63 : 56]};
    endcase
    end    
    else begin 
        lb_ram_r_data = `ZERO_WORD; 
    end
end
//ram_r_lh
always @(lh_signal or mem_addr[2 : 1] or ram_r_data) 
begin
    if(lh_signal)
    begin
        case(mem_addr[2 : 1])
        2'd0: lh_ram_r_data = {{48{ram_r_data[15]}},ram_r_data[15 : 0]};    
        2'd1: lh_ram_r_data = {{48{ram_r_data[31]}},ram_r_data[31 : 16]};    
        2'd2: lh_ram_r_data = {{48{ram_r_data[47]}},ram_r_data[47 : 32]};    
        2'd3: lh_ram_r_data = {{48{ram_r_data[63]}},ram_r_data[63 : 48]};    
    endcase
    end    
    else begin
        lh_ram_r_data = `ZERO_WORD;
    end
end
//ram_r_lw
always @(lw_signal or mem_addr[2] or ram_r_data) 
begin
    if(lw_signal)
    begin
        case(mem_addr[2])
        1'd0: lw_ram_r_data = {{32{ram_r_data[31]}},ram_r_data[31 : 0]};
        1'd1: lw_ram_r_data = {{32{ram_r_data[63]}},ram_r_data[63 : 32]};
    endcase
    end    
    else begin
        lw_ram_r_data = `ZERO_WORD;
    end
end
//ram_r_lbu
always @(lbu_signal or mem_addr[2 : 0] or ram_r_data ) 
begin
    if (lbu_signal) 
    begin
        case(mem_addr[2 : 0])
        3'd0: lbu_ram_r_data = {56'b0,ram_r_data[7 : 0]};
        3'd1: lbu_ram_r_data = {56'b0,ram_r_data[15 : 8]};
        3'd2: lbu_ram_r_data = {56'b0,ram_r_data[23 : 16]};
        3'd3: lbu_ram_r_data = {56'b0,ram_r_data[31 : 24]};
        3'd4: lbu_ram_r_data = {56'b0,ram_r_data[39 : 32]};
        3'd5: lbu_ram_r_data = {56'b0,ram_r_data[47 : 40]};
        3'd6: lbu_ram_r_data = {56'b0,ram_r_data[55 : 48]};
        3'd7: lbu_ram_r_data = {56'b0,ram_r_data[63 : 56]};
    endcase
    end    
    else begin
        lbu_ram_r_data = `ZERO_WORD;
    end
end
//ram_r_lhu
always @(lhu_signal or mem_addr[2 : 1] or ram_r_data) 
begin
    if(lhu_signal)
    begin
        case(mem_addr[2 : 1])
        2'd0: lhu_ram_r_data = {48'b0,ram_r_data[15 : 0]};    
        2'd1: lhu_ram_r_data = {48'b0,ram_r_data[31 : 16]};    
        2'd2: lhu_ram_r_data = {48'b0,ram_r_data[47 : 32]};    
        2'd3: lhu_ram_r_data = {48'b0,ram_r_data[63 : 48]};    
    endcase
    end    
    else begin
        lhu_ram_r_data = `ZERO_WORD;
    end
end
//ram_r_lwu
always @(lwu_signal or mem_addr[2] or ram_r_data) 
begin
    if(lwu_signal)
    begin
        case(mem_addr[2])
        1'd0: lwu_ram_r_data = {32'b0,ram_r_data[31 : 0]};
        1'd1: lwu_ram_r_data = {32'b0,ram_r_data[63 : 32]};
    endcase
    end    
    else begin
        lwu_ram_r_data = `ZERO_WORD;
    end
end
//ram_r_ld
 always @(ld_signal or ram_r_data) begin
        if(ld_signal)
            ld_ram_r_data = ram_r_data;
        else
            ld_ram_r_data = `ZERO_WORD;
    end
endmodule
















