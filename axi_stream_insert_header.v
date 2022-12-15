`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: axi_insert_header
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module axi_stream_insert_header #(
    parameter DATA_WD = 32,
    parameter DATA_BYTE_WD = DATA_WD / 8													
    ) (
    input clk,
    input rst_n,
    // AXI Stream input original data
    input valid_in,
    input [DATA_WD-1 : 0] data_in,
    input [DATA_BYTE_WD-1 : 0] keep_in,
    input last_in,
    output ready_in,
    // AXI Stream output with header inserted
    output valid_out,
    output [DATA_WD-1 : 0] data_out,
    output [DATA_BYTE_WD-1 : 0] keep_out,
    output last_out,
    input ready_out,
    // The header to be inserted to AXI Stream input
    input valid_insert,
    input [DATA_WD-1 : 0] header_insert,
    input [DATA_BYTE_WD-1 : 0] keep_insert,									
    output ready_insert
);
// Your code here
	
    //store data
    reg [DATA_WD*2-1:0] data_mem;													
	
    reg [DATA_WD-1 : 0]      data_out_reg;			
    reg [DATA_BYTE_WD-1 : 0] keep_out_reg;
    integer last_reg = 0; 
    
    assign data_out = data_out_reg;
    assign keep_out = keep_out_reg;
	assign last_out = last_reg;
	
	reg [DATA_WD:0] cnt_one = 'b0;
	//calculate 1's number utilizing loop
    function [DATA_WD:0] swar;
        input [DATA_WD:0] in_data;
        reg [DATA_WD:0] width;
        
        begin
            for( width=0; width<DATA_WD; width=width+1)
                begin
                    if(in_data[width])
                        cnt_one = cnt_one + 1'b1;
                    else
                        cnt_one = cnt_one;
                end
            swar = cnt_one;
        end
    endfunction
	
	// data_mem initial
	genvar j;
    generate for (j = 5'd0; j < DATA_WD; j=j+1) begin
        always @(posedge clk or negedge rst_n) begin
            data_out_reg[j] <= data_mem[j];
            if ( !last_in && valid_insert && ready_in && j < swar(keep_insert))
            begin
                data_mem[j] <= header_insert[j+swar(keep_insert)];
                keep_out_reg[j] <= 1;
                
            end
            else if (!last_in && valid_insert && ready_in && j >= swar(keep_insert))
            begin
                data_mem[j] <= data_in[j+keep_insert];
                keep_out_reg[j] <= 1;
            end		
            else if (last_in && valid_insert && ready_in && j < swar(keep_insert))                
            begin   
                data_mem[j] <= header_insert[j+swar(keep_insert)];
                keep_out_reg[j] <= 0;
                last_reg = 1;				
            end
            else if (last_in && valid_insert && ready_in && j >= swar(keep_insert))
            begin
                data_mem[j] <= data_in[j+keep_insert];
                keep_out_reg[j] <= 1;
                last_reg = 1;
            end
            else
                data_mem[j] <= data_mem[j];
        end
    end
    endgenerate

endmodule

