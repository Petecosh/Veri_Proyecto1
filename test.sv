class test #(parameter devices = 4, parameter width = 16);

    ambiente #(.devices(devices), .width(width)) ambiente_inst;

    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;

    tipo_mbx_test_agnt test_agnt_mbx;


    function new();

        test_agnt_mbx = new();

        ambiente_inst = new();

        ambiente_inst.agente_inst.test_agnt_mbx = test_agnt_mbx;

    endfunction

    task run();
        $display("[%g] Test inicializado", $time);
        fork
            ambiente_inst.run();
        join_none

        // Pruebas
        #10
        instruccion_agente = new();
        instruccion_agente.tipo = Random;
        instruccion_agente.print("Test: Paquete al agente creado");
        test_agnt_mbx.put(instruccion_agente);

        #1000
        $display("[%g] Test: Se alcanza el tiempo limite de la prueba", $time);
        $finish;

    endtask



endclass