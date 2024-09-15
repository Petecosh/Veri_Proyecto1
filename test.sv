class test #(parameter devices = 4, parameter width = 16, parameter depth = 8);

    driver #(.width(width), .depth(depth)) driver_inst;
    tipo_mbx_agnt_drv agnt_drv_mbx;

    pck_agnt_drv #(.width(width)) pck_test_inst;


    function new();
        driver_inst = new();
        agnt_drv_mbx = new();

        driver_inst.agnt_drv_mbx = agnt_drv_mbx;

    endfunction

    task run();
        $display("[%g] El test fue inicializado", $time);
        fork
            driver_inst.run();
        join_none

        // Pruebas
        pck_test_inst = new();
        pck_test_inst.tipo = escritura;
        pck_test_inst.dato_i = 'h6;
        pck_test_inst.print("Test: Paquete creado");
        agnt_drv_mbx.put(pck_test_inst);

        #10
        pck_test_inst = new();
        pck_test_inst.tipo = escritura;
        pck_test_inst.dato_i = 'h3;
        pck_test_inst.print("Test: Paquete creado");
        agnt_drv_mbx.put(pck_test_inst);

        #10
        pck_test_inst = new();
        pck_test_inst.tipo = lectura;
        pck_test_inst.dato_i = 'h1;
        pck_test_inst.print("Test: Paquete creado");
        agnt_drv_mbx.put(pck_test_inst);

        #10
        pck_test_inst = new();
        pck_test_inst.tipo = lectura;
        pck_test_inst.dato_i = 'h8;
        pck_test_inst.print("Test: Paquete creado");
        agnt_drv_mbx.put(pck_test_inst);

        #10
        $display("[%g] Test: Se alcanza el tiempo limite de la prueba", $time);
        $finish;

    endtask



endclass