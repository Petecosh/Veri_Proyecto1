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
    reg reset;
    int width;
    int devices;
    parameter bits = 1;
    parameter broadcast = 8'b1000_1111;

    // Clase para randomizar los parámetros
    class RandomParams;
        rand int width;
        rand int devices;

        // Restricciones para los valores randomizados (1 a 32)
        constraint c_width { width inside {[1:32]}; }
        constraint c_devices { devices inside {[1:32]}; }
    endclass

    // Instancia de la clase
    RandomParams params = new();

    // Clock generation
    always #5 clk = ~clk;

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

    // Interfaz
    bus_if #(.bits(bits), .drvrs(devices), .pckg_sz(width), .broadcast(broadcast)) _if(.clk(clk));   

    initial begin
        // Inicialización
        clk = 0;
        reset = 1;

        // Randomizar los parámetros width y devices
        if (params.randomize()) begin
            width = params.width;
            devices = params.devices;
            $display("Randomized width: %0d, devices: %0d", width, devices);
        end else begin
            $display("Error al randomizar los parámetros.");
        end

        // Instancia del test (con los parámetros randomizados)
        test #(.bits(bits), .devices(devices), .width(width), .broadcast(broadcast)) test_inst;        

        // Asignación de la interfaz
        test_inst._if = _if;

        for (int i = 0; i < devices; i++) begin
            test_inst.ambiente_inst.driver_inst[i].vif = _if;
        end

        // Ejecutar el test
        fork
            test_inst.run();       // Correr el test
        join_none

        // Reset
        _if.reset = 1;
        #20 _if.reset = 0;

        // Tiempo límite para finalizar el test
        if ($time > 2000000) begin
            $display("[%g] Testbench: Tiempo límite alcanzado", $time);
            $finish;
        end
    end
    
    always @(posedge clk) begin
        if ($time > 2000000) begin
            $display("[%g] Testbench: Tiempo límite alcanzado", $time);
            $finish;
        end
    end

endmodule
