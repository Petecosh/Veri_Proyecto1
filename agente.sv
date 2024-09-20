class agente #(parameter devices = 4, parameter width = 16);
    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;
    pck_agnt_drv #(.width(width)) paquete_agnt_drv[devices];
    tipo_mbx_agnt_drv agnt_drv_mbx[devices];
    tipo_mbx_test_agnt test_agnt_mbx;
    //
    tipo_mbx_agnt_drv drv_test_mbx;
    task run();

        $display("[%g] Agente inicializado", $time);
        fork
        forever begin
            #1
            if (test_agnt_mbx.num() > 0) begin
                test_agnt_mbx.get(instruccion_agente);
                $display("[%g] Agente,%d: Se recibe una instruccion", $time,instruccion_agente.origen);
                case (instruccion_agente.tipo)

                    lectura: begin
                        paquete_agnt_drv[instruccion_agente.origen] = new();
                        paquete_agnt_drv[instruccion_agente.origen].tipo = instruccion_agente.tipo;
                        paquete_agnt_drv[instruccion_agente.origen].print("Agente: Transaccion creada");
                        agnt_drv_mbx[instruccion_agente.origen].put(paquete_agnt_drv[instruccion_agente.origen]);
                    end

                    escritura: begin
                        paquete_agnt_drv[instruccion_agente.origen] = new();
                        paquete_agnt_drv[instruccion_agente.origen].dato_i = instruccion_agente.dato;
                        paquete_agnt_drv[instruccion_agente.origen].tipo = instruccion_agente.tipo;
                        paquete_agnt_drv[instruccion_agente.origen].print("Agente: Transaccion creada");
                        agnt_drv_mbx[instruccion_agente.origen].put(paquete_agnt_drv[instruccion_agente.origen]);
                    end
                    
                    default: begin
                        $display("[%g] Error Agente: Instruccion con tipo no valido", $time);
                        $finish;
                    end

                endcase
                
            end

        end

        begin
            //drivers
            pck_agnt_drv #(.width(width)) paquete1;
            drv_test_mbx.get(paquete1);
            $display("[%g] test,%d: ", $time,paquete1);
            drv_test_mbx.get(paquete1);
        end

        join_any

        

    endtask

endclass