`timescale 1ns/1ps
`include "paquetes.sv"
`include "driver.sv"
`include "agente.sv"
`include "Library.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "ambiente.sv"
`include "test.sv"

module test_bench;

    reg clk;
    parameter width = 16;
    parameter devices = 5;
    parameter bits = 1;
    parameter broadcast = {8'b1111_1111};

    test #(.bits(bits), .devices(devices), .width(width), .broadcast(broadcast)) test_inst;          // Instancia del test

    bus_if #(.bits(bits), .drvrs(devices), .pckg_sz(width), .broadcast(broadcast)) _if(.clk(clk));   // Interfaz

    always #5 clk = ~clk;   // Clock

    // Instancia del DUT
    bs_gnrtr_n_rbtr #(.bits(bits), .drvrs(devices), .pckg_sz(width), .broadcast(broadcast)) uut(
        .clk(_if.clk),
        .reset(_if.reset),
        .pndng(_if.pndng),
        .push(_if.push),
        .pop(_if.pop),
        .D_pop(_if.D_pop),
        .D_push(_if.D_push)
    );


    initial begin
        clk = 0;                                                     // Clock en 0
        test_inst = new();                                           // Inicializar la instancia del test
        $display("[%g] Test inicializado", $time);                   
        test_inst._if = _if;                                         // Asociar la interfaz de afuera con la interfaz dentro del test
        for (int i = 0; i < devices; i++) begin                      // Ciclo para conectar las instancias de los drivers a la interfaz
            test_inst.ambiente_inst.driver_inst[i].vif = _if;
        end
        
        fork
            test_inst.run();       // Correr el test
        join_none


        // Reset
        _if.reset = 1;
        #20
        _if.reset = 0;
        
    end

    always @(posedge clk) begin

        if ($time > 2000000) begin
            $display("[%g] Testbench: Tiempo limite alcanzado", $time);
            $finish;
        end
    end
    
endmodule