`timescale 1ns/1ps
`include "paquetes.sv"
`include "driver.sv"
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
    end

    always @(posedge clk) begin
        if ($time > 1000) begin
            $display("Testbench: Tiempo limite alcanzado");
            $finish;
        end
    end
    
endmodule