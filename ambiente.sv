class ambiente #(parameter devices = 4, parameter width = 16);

    driver #(.width(width)) driver_inst[devices];
    agente #(.devices(devices), .width(width)) agente_inst;

    tipo_mbx_agnt_drv agnt_drv_mbx[devices];
    tipo_mbx_test_agnt test_agnt_mbx;

    function new();

        test_agnt_mbx = new();
        agente_inst = new();

        for (int i = 0; i < devices; i++) begin
            driver_inst[i] = new();
            agnt_drv_mbx[i] = new();
        end        

        // Apuntar mailboxes

        for (int i = 0; i < devices; i++) begin
            driver_inst[i].agnt_drv_mbx = agnt_drv_mbx[i];
            agente_inst.agnt_drv_mbx[i] = agnt_drv_mbx[i];
        end

        agente_inst.test_agnt_mbx = test_agnt_mbx;
        
    endfunction

    virtual task run();
        fork
            
            //for (int i = 0; i < devices; i++) begin
            //        driver_inst[i].run();
            //    join_none
            //end

            driver_inst[0].run();
            driver_inst[1].run();

            agente_inst.run();

        join_none
        $display("[%g] Ambiente inicializado", $time);
    endtask

endclass