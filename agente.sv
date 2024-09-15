class agente #(parameter devices = 4, parameter width = 16);
    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;
    pck_agnt_drv #(.width(width)) paquete_agnt_drv;
    tipo_mbx_agnt_drv agnt_drv_mbx;
    tipo_mbx_test_agnt test_agnt_mbx;

    task run();

        $display("[%g] El agente fue inicializado", $time);

        forever begin
            #1
            if (test_agnt_mbx.num() > 0) begin
                $display("[%g] Agente: Se recibe una instruccion", $time);
                test_agnt_mbx.get(instruccion_agente);
                case (instruccion_agente.tipo)

                    lectura: begin
                        pck_agnt_drv = new();
                        pck_agnt_drv.tipo = instruccion_agente.tipo;
                        pck_agnt_drv.print("Agente: Transaccion creada");
                        agnt_drv_mbx.put(pck_agnt_drv);
                    end

                    escritura: begin
                        pck_agnt_drv = new();
                        pck_agnt_drv.dato_i = instruccion_agente.dato;
                        pck_agnt_drv.tipo = instruccion_agente.tipo;
                        pck_agnt_drv.print("Agente: Transaccion creada");
                        agnt_drv_mbx.put(pck_agnt_drv);
                    end
                    
                    default: begin
                        $display("[%g] Error Agente: Instruccion con tipo no valido", $time);
                        $finish;
                    end

                endcase
                
            end

        end

    endtask

endclass