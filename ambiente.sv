class ambiente #(parameter devices = 4, parameter width = 16, parameter depth = 8);

    fifo #(.width(width), .depth(depth)) fifo_inst;


    function new();
        fifo_inst = new();
    endfunction

    virtual task run();
        fork
            fifo_inst.run();
        join_none
        $display("[%t] Ambiente inicializado", $time);
    endtask

endclass