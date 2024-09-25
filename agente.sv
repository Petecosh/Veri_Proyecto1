class agente #(parameter devices = 4, parameter width = 16);
    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;
    pck_agnt_drv #(.width(width)) paquete_agnt_drv[devices];
    pck_agnt_drv #(.width(width)) ori;
    tipo_mbx_agnt_drv agnt_drv_mbx[devices];

    int num_transacciones;
    tipo_mbx_test_agnt test_agnt_mbx;
    int max_retardo;
    bit [width-1:0]data_envio;
    int origen;
    function new();
        for (int i = 0; i < devices; i++) begin
            paquete_agnt_drv[i] = new();
        end
        num_transacciones = 3;
        max_retardo = 10;
        $display("sip agente");
    endfunction

    task run();

        $display("[%g] Agente inicializado", $time);

        forever begin
            #1
            if (test_agnt_mbx.num() > 0) begin
                $display("[%g] Agente: Se recibe una instruccion", $time);
                test_agnt_mbx.get(instruccion_agente);

                
                case (instruccion_agente.tipo)

                    Random: begin
                        for (int i = 0; i < num_transacciones; i++) begin
                            ori = new();
                            ori.randomize();
                            ori.dato = {ori.recpetor, ori.payload};
                            //instruccion_agente.max_retardo = max_retardo;
                            paquete_agnt_drv[ori.origen] = new();
                            paquete_agnt_drv[ori.origen] = ori;
                            paquete_agnt_drv[ori.origen].print("Agente: Random Transaccion creada");
                            agnt_drv_mbx[ori.origen].put(paquete_agnt_drv[ori.origen]);

                        end
                    end

                    Especifica: begin
                        for (int i = 0; i < num_transacciones; i++) begin
                            //instruccion_agente.max_retardo = max_retardo;
                            paquete_agnt_drv[instruccion_agente.origen] = new();
                            paquete_agnt_drv[instruccion_agente.origen].dato = instruccion_agente.dato;
                            paquete_agnt_drv[instruccion_agente.origen].origen = instruccion_agente.origen; 
                            paquete_agnt_drv[instruccion_agente.origen].print("Agente: Especifica Transaccion creada");
                            agnt_drv_mbx[instruccion_agente.origen].put(paquete_agnt_drv[instruccion_agente.origen]);

                        end
                    end

                    

                    Erronea: begin

                    end
                    
                    default: begin
                        $display("[%g] Error Agente: Instruccion con tipo no valido", $time);
                        $finish;
                    end

                endcase
                //conecxion a los distintos drivers
                
                
                
            end

        end

    endtask

endclass