class ambiente #(parameter bits = 1, parameter devices = 4, parameter width = 16);
    checkr #(.width(width), .devices(devices)) checkr_inst;
    driver #(.bits(bits), .drvrs(devices), .width(width)) driver_inst[devices];
    agente #(.devices(devices), .width(width)) agente_inst;
    

    tipo_mbx_agnt_drv agnt_drv_mbx[devices];
    tipo_mbx_test_agnt test_agnt_mbx;
    tipo_mbx_drv_chkr drv_chkr_mbx;

    function new();

        test_agnt_mbx = new();
        agente_inst = new();
        checkr_inst = new();

        for (int i = 0; i < devices; i++) begin
            driver_inst[i] = new(i);
            agnt_drv_mbx[i] = new();
            
        end        
        drv_chkr_mbx = new();
        // Apuntar mailboxes
        
        for (int i = 0; i < devices; i++) begin
            driver_inst[i].agnt_drv_mbx = agnt_drv_mbx[i];
            agente_inst.agnt_drv_mbx[i] = agnt_drv_mbx[i];
            driver_inst[i].drv_chkr_mbx = drv_chkr_mbx;
            
        end
        
        checkr_inst.drv_chkr_mbx = drv_chkr_mbx;

        agente_inst.test_agnt_mbx = test_agnt_mbx;
        $display("sip ambiente");
        
    endfunction

    virtual task run();
        $display("sip ambiente runnig");
        fork
            
            for (int i = 0; i < devices; i++) begin
                automatic int j = i;
                fork
                    driver_inst[j].run();
                join_none
            end

            //driver_inst[0].run();
            //driver_inst[1].run();

            agente_inst.run();
            checkr_inst.run();

        join_none
        $display("[%g] Ambiente inicializado", $time);
    endtask

endclass