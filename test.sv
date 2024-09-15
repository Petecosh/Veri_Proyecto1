class test #(parameter devices = 4, parameter width = 16, parameter depth = 8);

    ambiente #(.devices(devices), .width(width)) ambiente_inst;

    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;

    tipo_mbx_test_agnt test_agnt_mbx; 


    function new();

        test_agnt_mbx = new();

        ambiente_inst = new();

        ambiente_inst.agente_inst.test_agnt_mbx = test_agnt_mbx;

    endfunction

    task run();
        $display("[%g] El test fue inicializado", $time);
        fork
            ambiente_inst.run();
        join_none

        // Pruebas
        instruccion_agente = new();
        instruccion_agente.tipo = escritura;
        instruccion_agente.dato = 'h6;
        instruccion_agente.print("Test: Paquete al agente creado")
        test_agnt_mbx.put(instruccion_agente);

        #10
        instruccion_agente = new();
        instruccion_agente.tipo = escritura;
        instruccion_agente.dato = 'h6;
        instruccion_agente.print("Test: Paquete al agente creado")
        test_agnt_mbx.put(instruccion_agente);

        #10
        instruccion_agente = new();
        instruccion_agente.tipo = lectura;
        instruccion_agente.print("Test: Paquete al agente creado")
        test_agnt_mbx.put(instruccion_agente);

        #10
        instruccion_agente = new();
        instruccion_agente.tipo = escritura;
        instruccion_agente.print("Test: Paquete al agente creado")
        test_agnt_mbx.put(instruccion_agente);

        #10
        $display("[%g] Test: Se alcanza el tiempo limite de la prueba", $time);
        $finish;

    endtask



endclass