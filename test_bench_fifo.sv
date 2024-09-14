`timescale 1ns/1ps
`include "fifo.sv"
`include "ambiente.sv"
`include "test.sv"


module test_bench_fifo;

    reg clk;
    parameter width = 16;
    parameter depth = 8;
    parameter devices = 4;
    test #(.devices(devices), .width(width), .depth(depth)) test_inst;

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        test_inst = new();
        fork
            test_inst.run();
        join_none
    end

    always @(posedge clk) begin
        if ($time > 1000) begin
            $display("Testbench: Tiempo limite alcanzado");
            $finish;
        end
    end
    
endmodule