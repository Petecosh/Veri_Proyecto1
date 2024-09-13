`timescale 1ns/1ps
`include "fifo.sv"


module testbench_fifo;

    reg clk;
    parameter width = 16;
    parameter depth = 8;
    fifo #(.width(width), .depth(depth)) fifo_inst;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        fifo_inst = new();
        fork
            fifo_inst.run();
        join_none

        #5
        fifo_inst.dato_i = 'h6;

        #1
        fifo_inst.push_i = 1;
        #1
        fifo_inst.push_i = 0;

        #5
        fifo_inst.dato_i = 'hA;
        
        #1
        fifo_inst.push_i = 1;
        #1
        fifo_inst.push_i = 0;

        #5
        fifo_inst.pop_i = 1;
        #1
        fifo_inst.pop_i = 0;

        #5
        fifo_inst.pop_i = 1;
        #1
        fifo_inst.pop_i = 0;

    end

    always @(posedge clk) begin
        if ($time > 1000) begin
            $display("Testbench: Tiempo limite alcanzado");
            $finish;
        end
    end
    
endmodule