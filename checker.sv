class checkr #(parameter width = 16, parameter devices = 4);
    
    tipo_mbx_drv_chkr drv_chkr_mbx[devices];
    pck_drv_chkr keys[$];
    int index[$];
    int contador1;

    
    function new();
        this.keys = {};
        this.index = {};
        this.contador0 = 0;

    endfunction
    task run();

        $display("[%g] Chekcer inicializado", $time);

        forever begin
            for (int h; h<=devices;++)begin
                if (drv_chkr_mbx[h].num()>0)begin
                    pck_drv_chkr #(.width(width)) paquete_chkr;
                    drv_chkr_mbx[h].get(paquete_chkr);
                    case (paquete_chkr.accion)
                        
                        1'b0: begin
                            
                            index[contador0] = paquete_chkr.origen; 
                            keys[contador0] = paquete_chkr;
                            $display("[%g]  = %h, dato%h", $time,index[contador0],keys[contador0]);
                            contador0++;
                            
                        end
                        1'b1: begin
                            
                            for (int j = 0; j <= contador0; j++) begin
                                if (keys[j] == paquete_chkr)begin
                                    $display("[%g] dato checkaeado org = %h, dato%h", $time,index[j],keys[j]);
                                    index.delete(j);
                                    keys.delete(j);
                                    contador0 = contador0-1;
                                end
                            end
                        end
                    endcase
                end
            end
        end
    endtask
endclass