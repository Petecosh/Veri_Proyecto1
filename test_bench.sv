`timescale 1ns/1ps
`include "fifo.sv"
`include "ambiente.sv"
`include "test.sv"


module test_bench;

    reg clk;
    parameter width = 16;
    parameter depth = 8;
    parameter devices = 4;
    test #(.width(width), .depth(depth), .devices(devices)) test_inst;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        test_inst = new();
        fork
            test_inst.run();
        join_none

        #5
        fifo.dato_i = 'h6;

        #1
        fifo.push_i = 1;
        #1
        fifo.push_i = 0;

        #5
        fifo.dato_i = 'hA;
        
        #1
        fifo.push_i = 1;
        #1
        fifo.push_i = 0;

        #5
        fifo.pop_i = 1;
        #1
        fifo.pop_i = 0;

        #5
        fifo.pop_i = 1;
        #1
        fifo.pop_i = 0;

    end

    always @(posedge clk) begin
        if ($time > 1000) begin
            $display("Testbench: Tiempo limite alcanzado");
            $finish;
        end
    end
    
endmodule