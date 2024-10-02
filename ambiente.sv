class ambiente #(parameter bits = 1, parameter devices = 4, parameter width = 16, parameter broadcast = {8{1'b1}});
    agente #(.devices(devices), .width(width), .broadcast(broadcast)) agente_inst;  // Instancia del agente
    driver #(.bits(bits), .drvrs(devices), .width(width)) driver_inst[devices];     // Instancias de los drivers
    checkr #(.width(width), .devices(devices), .broadcast(broadcast)) checkr_inst;  // Instancia del checker
    scoreboard #(.width(width), .devices(devices), .broadcast(broadcast)) scoreboard_inst;  // Instancia del scoreboard

    tipo_mbx_test_agnt #(.devices(devices), .width(width)) test_agnt_mbx;               // Mailbox test -> agente
    tipo_mbx_agnt_drv #(.width(width)) agnt_drv_mbx[devices];        // Mailboxes agente -> drivers
    tipo_mbx_drv_chkr #(.width(width)) drv_chkr_mbx[devices];        // Mailboxes drivers -> checker
    tipo_mbx_chkr_sb #(.width(width)) chkr_sb_mbx;                   // Mailbox checker -> scoreboard

    function new();

        test_agnt_mbx = new();           // Inicializar mbx test -> agente
        agente_inst = new();             // Inicializar instancia del agente
        

        for (int i = 0; i < devices; i++) begin // Ciclo para crear varios drivers con sus respectivos mailboxes
            driver_inst[i] = new(i);            // Inicializar instancias de los drivers
            agnt_drv_mbx[i] = new();            // Inicializar mailboxes agente -> drivers
            drv_chkr_mbx[i] = new();            // Inicializar mailboxes drivers -> checker
        end

        checkr_inst = new();             // Inicializar instancia del checker
        chkr_sb_mbx = new();             // Inicializar mbx checker -> scoreboard
        scoreboard_inst = new();         // Inicializar el scoreboard

        // Apuntar mailboxes
        
        for (int i = 0; i < devices; i++) begin             // Ciclo para apuntar los mailboxes
            driver_inst[i].agnt_drv_mbx = agnt_drv_mbx[i]; 
            agente_inst.agnt_drv_mbx[i] = agnt_drv_mbx[i];
            driver_inst[i].drv_chkr_mbx = drv_chkr_mbx[i];
            checkr_inst.drv_chkr_mbx[i] = drv_chkr_mbx[i];
            
        end

        agente_inst.test_agnt_mbx = test_agnt_mbx;   // Apuntar el mbx test -> agente al mbx correspondiente dentro del agente
        checkr_inst.chkr_sb_mbx = chkr_sb_mbx;       // Apuntar el mbx checker -> scoreboard al mbx correspondiente dentro del checker
        scoreboard_inst.chkr_sb_mbx = chkr_sb_mbx;   // Apuntar el mbx checker -> scoreboard al mbx correspondiente dentro del scoreboard
        
    endfunction

    // Correr el ambiente
    virtual task run();
        fork
            
            for (int i = 0; i < devices; i++) begin     // Ciclo para correr las instancias de los drivers
                automatic int j = i;
                fork
                    driver_inst[j].run();
                join_none
            end

            agente_inst.run();      // Correr el agente
            checkr_inst.run();      // Correr el checker
            scoreboard_inst.run();  // Correr el scoreboard     

        join_none
        $display("[%g] Ambiente inicializado", $time);
    endtask

endclass