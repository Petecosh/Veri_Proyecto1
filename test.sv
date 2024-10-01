class test #(parameter bits = 1, parameter devices = 4, parameter width = 16, parameter broadcast = {8{1'b1}});
    ambiente #(bits, devices, width, broadcast) ambiente_inst; // Instancia del ambiente
    pck_test_agnt #(devices, width) instruccion_agente;                           // Instruccion hacia el agente
    tipo_mbx_test_agnt test_agnt_mbx;                                                               // Mailbox test -> agente
    virtual bus_if #(bits, devices, width, broadcast) _if;     // Interfaz
    pck_test_sb instruccion_sb;
    tipo_mbx_test_sb test_sb_mbx;

    function new();

        test_agnt_mbx = new();                                      // Inicialziar el mbx test -> agente
        ambiente_inst = new();                                      // Inicializar la instancia del ambiente
        ambiente_inst.agente_inst.test_agnt_mbx = test_agnt_mbx;    // Apuntar el mbx test -> agente
        test_sb_mbx = new();                                        // Inicializar el mbx test -> scoreboard
        ambiente_inst.scoreboard_inst.test_sb_mbx = test_sb_mbx;    // Apuntar el mbx test -> scoreboard

    endfunction

    task run();
        $display("[%g] Test inicializado", $time);
        fork
            ambiente_inst.run();        // Correr el ambiente
        join_none

        // Pruebas
        #40
        instruccion_agente = new();
        instruccion_agente.tipo = Random;
        instruccion_agente.print("Test: Paquete al agente creado");
        test_agnt_mbx.put(instruccion_agente);
        
        #20
        instruccion_agente = new();
        instruccion_agente.tipo = Especifica;
        instruccion_agente.dato = 16'b0000_0010_0101_0111;
        instruccion_agente.origen = 1'b1;
        instruccion_agente.retardo = 4;
        instruccion_agente.print("Test: Paquete al agente creado");
        test_agnt_mbx.put(instruccion_agente);
        
        #20
        instruccion_agente = new();
        instruccion_agente.tipo = Erronea;
        instruccion_agente.print("Test: Paquete al agente creado");
        test_agnt_mbx.put(instruccion_agente);

        #20
        instruccion_agente = new();
        instruccion_agente.tipo = Broadcast;
        instruccion_agente.print("Test: Paquete al agente creado");
        test_agnt_mbx.put(instruccion_agente);
        
        #100000
        $display("[%g] Test: Se alcanza el tiempo limite de la prueba", $time);
        instruccion_sb = new();
        instruccion_sb.tipo = Reporte;
        test_sb_mbx.put(instruccion_sb);
        #100
        $finish;

    endtask



endclass