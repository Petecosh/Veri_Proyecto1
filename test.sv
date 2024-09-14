class test #(parameter devices = 4, parameter width = 16, parameter depth = 8);

    fifo #(.width(width), .depth(depth)) fifo_inst;

    function new();
        fifo_inst = new();
    endfunction

    task run();
        fork
            fifo_inst.run();
        join_none

        // Pruebas
        #5
        fifo_inst.dato_i = 'h6;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);

        #1
        fifo_inst.push_i = 1;
        #1
        fifo_inst.push_i = 0;

        #5
        fifo_inst.dato_i = 'hA;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);
        
        #1
        fifo_inst.push_i = 1;
        #1
        fifo_inst.push_i = 0;

        #5
        fifo_inst.pop_i = 1;
        #1
        fifo_inst.pop_i = 0;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);

        #5
        fifo_inst.pop_i = 1;
        #1
        fifo_inst.pop_i = 0;
        $display("[%t] Ultimo dato de la FIFO: %g", $time, fifo_inst.dato_o);

        #20
        $finish;

    endtask



endclass