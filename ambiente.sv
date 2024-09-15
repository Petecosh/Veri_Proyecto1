class ambiente #(parameter devices = 4, parameter width = 16);

    driver #(.width(width)) driver_inst;
    agente #(.devices(devices), .width(width)) agente_inst;

    tipo_mbx_agnt_drv agnt_drv_mbx;
    tipo_mbx_test_agnt test_agnt_mbx;

    function new();

        driver_inst = new();
        agente_inst = new();

        agnt_drv_mbx = new();
        test_agnt_mbx = new();

        // Apuntar mailboxes
        driver_inst.agnt_drv_mbx = agnt_drv_mbx;
        agente_inst.test_agnt_mbx = test_agnt_mbx;

    endfunction 

    virtual task run();
        fork
            driver_inst.run();
            agente_inst.run();
        join_none
        $display("[%g] Ambiente inicializado", $time);
    endtask

endclass