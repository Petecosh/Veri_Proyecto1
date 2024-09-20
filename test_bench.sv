`timescale 1ns/1ps
`include "paquetes.sv"
`include "driver.sv"
`include "agente.sv"
`include "Library.sv"
`include "ambiente.sv"
`include "test.sv"


module test_bench;

    reg clk;
    parameter width = 16;
    parameter devices = 4;
    parameter bits = 1;
    parameter broadcast = {8{1'b1}};
    test #(.bits(bits), .devices(devices), .width(width), .broadcast(broadcast)) test_inst;

    bus_if #(.bits(bits), .drvrs(devices), .pckg_sz(width), .broadcast(broadcast)) _if(.clk(clk));

    always #5 clk = ~clk;

    bs_gnrt #(.bits(bits), .drvrs(devices), .pckg_sz(width), .broadcast(broadcast)) uut (
        .clk(_if.clk),
        .reset(_if.reset),
        .pndng(_if.pndng),
        .push(_if.push),
        .pop(_if.pop),
        .D_pop(_if.D_pop),
        .D_push(_if.D_push)
    );


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