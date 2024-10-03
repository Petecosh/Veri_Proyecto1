`timescale 1ns/1ps
`include "paquetes.sv"
`include "driver.sv"
`include "agente.sv"
`include "checker.sv"
`include "scoreboard.sv"
`include "ambiente.sv"
`include "Library.sv"
`include "test.sv"

module test_bench;

    reg clk;
    int width;
    int devices;
    parameter bits = 1;
    parameter broadcast = {8'b1000_1111};
    class RandomParams;
        rand int width;
        rand int devices;

        // Restricciones para los valores randomizados (1 a 32)
        constraint c_width { width inside {[16:32]}; }
        constraint c_devices { devices inside {[1:32]}; }
    endclass

    // Instancia de la clase
    RandomParams params = new();

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
        $display("Randomized width: %0d, devices: %0d", width, devices);
        clk = 0;                                                     // Clock en 0
        test_inst = new();                                           // Inicializar la instancia del test
        $display("[%g] Test inicializado", $time);        
        $display("[%g] en testbench broad %h", $time, broadcast);           
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