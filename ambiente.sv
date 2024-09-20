class ambiente #(parameter devices = 4, parameter width = 16);

    driver #(.width(width)) driver_inst[devices];
    agente #(.devices(devices), .width(width)) agente_inst;

    tipo_mbx_agnt_drv agnt_drv_mbx[devices];
    tipo_mbx_test_agnt test_agnt_mbx;
    //
    tipo_mbx_agnt_drv drv_test_mbx;

    function new();

        test_agnt_mbx = new();
        //
        drv_test_mbx=new();
        agente_inst = new();
        // Apuntar mailboxes
        for (int i = 0; i < devices; i++)begin
            driver_inst[i] = new();
            agnt_drv_mbx[i] = new();    
            driver_inst[i].agnt_drv_mbx = agnt_drv_mbx[i];
            agente_inst.agnt_drv_mbx[i] = agnt_drv_mbx[i];
            //
            driver_inst[i].drv_test_mbx = drv_test_mbx;
        end
        agente_inst.test_agnt_mbx = test_agnt_mbx;

        
        
    endfunction 

    virtual task run();
        fork
            for (int i = 0; i < devices; i++)begin
                driver_inst[i].run();
            end
            agente_inst.run();
        join_none
        $display("[%g] Ambiente inicializado", $time);
    endtask

endclass