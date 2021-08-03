

`include "defines.v"

module memwb(
    input wire           clk,
    input wire           rst,
    input wire           wb_ena,
    input wire [`REG_BUS]mem_r_data,
    input wire    [2 : 0]mem,

    output wire [`REG_BUS]rd_data

);

reg [`REG_BUS]rdd;

always @( posedge clk ) 
begin
    if (wb_ena == 1'b1 && rst == 1'b0)
    begin
       case ( mem )
        3'b001:   begin rdd = { {56{mem_r_data[7]}}, mem_r_data[7 : 0] };    end
        3'b010:   begin rdd = { {48{mem_r_data[15]}}, mem_r_data[15 : 0] };  end
        3'b011:   begin rdd = { {32{mem_r_data[31]}}, mem_r_data[31 : 0] };  end
        3'b100:   begin rdd = { {56{1'b0}}, mem_r_data[7 : 0] };             end
        3'b101:   begin rdd = { {48{1'b0}}, mem_r_data[15 : 0] };            end
        3'b110:   begin rdd = { {32{1'b0}}, mem_r_data[31 : 0] };            end
        3'b111:   begin rdd = mem_r_data;                                    end  
        default:  begin rdd = `ZERO_WORD;                                    end
       endcase     
    end    
end

assign rd_data = rdd;



endmodule
