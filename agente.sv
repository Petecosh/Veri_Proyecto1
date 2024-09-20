class agente #(parameter devices = 4, parameter width = 16);
    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;
    pck_agnt_drv #(.width(width)) paquete_agnt_drv[devices];
    tipo_mbx_agnt_drv agnt_drv_mbx[devices];

    int num_transacciones;
    tipo_mbx_test_agnt test_agnt_mbx;
    int max_retardo;
    constrain ndatos_ran{

    }
    bit [3:0] origen;
    bit [3:0] receptor;
    bit [width-1:0]data_envio;

    function new;
        for (int i = 0; i < devices; i++) begin
            paquete_agnt_drv[i] = new();
        end
        num_transacciones = 2;
        max_retardo = 10;
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
                            paquete_agnt_drv = new;
                            //instruccion_agente.max_retardo = max_retardo;
                            origen = $urandom_range(devices, 0);
                            receptor = $urandom_range(devices, 0);
                            paquete_agnt_drv[origen].randomize();
                            paquete_agnt_drv[origen].origen = origen;
                            data_envio = {receptor, paquete_agnt_drv[origen].dato[width-9:0]}; 
                            paquete_agnt_drv[origen].dato = data_envio;             
                            paquete_agnt_drv[origen].print("Agente: Transaccion creada");

                            agnt_drv_mbx[origen].put(paquete_agnt_drv[origen]);

                        end
                    end

                    Especifica: begin

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