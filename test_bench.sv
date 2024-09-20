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

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        test_inst = new();
        $display("[%g] Test inicializado", $time);
        fork
            test_inst.run();
        join_none
        
    end

    always @(posedge clk) begin
        if ($time > 1000) begin
            $display("[%g] Testbench: Tiempo limite alcanzado", $time);
            $finish;
        end
    end
    
endmodule