class checkr #(parameter width = 16, parameter devices = 4);
    
    tipo_mbx_drv_chkr drv_chkr_mbx[devices];
    pck_drv_chkr keys[$];
    int index[$];
    int contador0;

    
    function new();
    for (int q = 0; q < devices; q++) begin
            drv_chkr_mbx[q] = new();
        end
        this.keys = {};
        this.index = {};
        this.contador0 = 0;

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
                            if ((paquete_chkr.dato[width-1:width-8] < devices) || (paquete_chkr.dato[width-1:width-8] == 8'hffff))begin
                                index[contador0] = paquete_chkr.origen; 
                                keys[contador0] = paquete_chkr;
                                $display("[%g] Checker recive: org = %h, dato%h", $time,index[contador0],keys[j].contador0);
                                contador0++;
                            end
                            else begin
                                $display("[%g] dato con direccion erronea: org = %h, dato =%h", $time,paquete_chkr.origen,paquete_chkr.dato);
                                $finish;
                            end
                        end
                        1'b1: begin
                            
                            for (int j = 0; j < contador0; j++) begin
                                if (keys[j].dato == paquete_chkr.dato)begin
                                    $display("[%g] Dato checkaeado: org = %h, dato%h", $time,index[j],keys[j].dato);
                                    index.delete(j);
                                    keys.delete(j);
                                    contador0 = contador0-1;
                                end
                                else if (j >= contador0) begin
                                    $display("[%g] Nadie envio ese dato: dato =%h", $time,paquete_chkr.dato);
                                    $finish;
                                end
                            end
                        end
                    endcase
                end
            end
        end
    endtask
endclass