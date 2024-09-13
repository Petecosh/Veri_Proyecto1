class test #(parameter devices = 4, parameter width = 16, parameter depth = 8);

    ambiente #(.devices(devices), .width(width), .depth(depth)) ambiente_inst;

    function new();
        ambiente_inst = new();
    endfunction

    task run();
        fork
            ambiente_inst.run();
        join_none

        // Pruebas
        

    endtask



endclass