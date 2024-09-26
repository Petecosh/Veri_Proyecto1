class checkr #(parameter width = 16, parameter devices = 4);
    
    tipo_mbx_drv_chkr drv_chkr_mbx[devices];
    pck_drv_chkr keys[$];
    int index[$];
    int Procesos_erroneos[$];
    int con_index;
    int con_err;
    bit check_correcto;
    
    function new();
    for (int q = 0; q < devices; q++) begin
            drv_chkr_mbx[q] = new();
        end
        this.keys = {};
        this.index = {};
        this.Procesos_erroneos = {};
        this.con_index = 0;
        this.con_err = 0;
        this.check_correcto = 0;

    endfunction
    task run();

        $display("[%g] Chekcer inicializado", $time);

        forever begin
            for (int h=0; h<devices;h++)begin
                #20
                if (drv_chkr_mbx[h].num()>0)begin
                    pck_drv_chkr #(.width(width)) paquete_chkr;
                    drv_chkr_mbx[h].get(paquete_chkr);
                    case (paquete_chkr.accion)
                        
                        1'b0: begin
                            $display("[%g] Checker recive: org = %h, dato%h", $time,paquete_chkr.origen,paquete_chkr.dato);
                            
                            if (paquete_chkr.dato[width-1:width-8] == 8'hffff) begin
                                for (int i = 0; i < devices-1; i++) begin
                                    index[con_index] = paquete_chkr.origen; 
                                    keys[con_index] = paquete_chkr;
                                con_index++;
                                end
                            end
                            else if (paquete_chkr.dato[width-1:width-8] < devices) begin
                                index[con_index] = paquete_chkr.origen; 
                                keys[con_index] = paquete_chkr;
                                con_index++;
                            end
                            else begin
                                $display("[%g] dato con direccion erronea: org = %h, dato =%h", $time,paquete_chkr.origen,paquete_chkr.dato);
                                Procesos_erroneos[con_err] = paquete_chkr.dato;
                                con_err++;
                            end
                            
                        end
                        1'b1: begin
                           for (int j = 0; j < con_index; j++) begin  
                                if (keys[j].dato == paquete_chkr.dato)begin
                                    $display("[%g] Dato checkaeado: org = %h, dato%h", $time,index[j],keys[j].dato);
                                    index.delete(j);
                                    keys.delete(j);
                                    con_index = con_index-1;
                                    check_correcto = 1'b1;
                                end                                                               
                            end
                            if (check_correcto == 0)begin
                                $display("[%g] Nadie envio ese dato: dato =%h", $time,paquete_chkr.dato);
                                Procesos_erroneos[con_err] = paquete_chkr.dato;
                                con_err++;
                                check_correcto = 1'b0;
                            end
                        end
                        default: begin
                            $display("[%g] WHAT: org = %h, dato%h", $time,paquete_chkr.origen,paquete_chkr.dato);
                        end
                    endcase
                end
            end
        end
    endtask
endclass