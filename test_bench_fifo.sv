`timescale 1ns/1ps
`include "fifo.sv"


module test_bench_fifo;

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

    end

    always @(posedge clk) begin

        #5
        fifo_inst.dato_i = 'h6;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);

        #1
        fifo_inst.push_i = 1;
        #1
        fifo_inst.push_i = 0;

        #5
        fifo_inst.dato_i = 'hA;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);
        
        #1
        fifo_inst.push_i = 1;
        #1
        fifo_inst.push_i = 0;

        #5
        fifo_inst.pop_i = 1;
        #1
        fifo_inst.pop_i = 0;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);

        #5
        fifo_inst.pop_i = 1;
        #1
        fifo_inst.pop_i = 0;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);

        if ($time > 1000) begin
            $display("Testbench: Tiempo limite alcanzado");
            $finish;
        end
    end
    
endmodule