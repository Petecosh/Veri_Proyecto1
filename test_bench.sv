`timescale 1ns/1ps
`include "paquetes.sv"
`include "driver.sv"
`include "agente.sv"
`include "ambiente.sv"
`include "test.sv"


module test_bench;

    reg clk;
    parameter width = 16;
    parameter devices = 4;
    test #(.devices(devices), .width(width)) test_inst;
    int x [3];

    always #5 clk = ~clk;

    initial begin
        x[0]=1;
        x[1]=5;
        $display("[%d] Test:", x[1]);
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