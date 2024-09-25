class checkr #(parameter width = 16, parameter devices = 4);
    pck_drv_chkr #(.width(width)) paquete_chkr;
    tipo_mbx_drv_chkr drv_chkr_mbx;
    pck_drv_chkr keys[$];
    int index[$];
    int contador1;
    int contador0;
    
    function new();
        this.keys = {};
        this.index = {};
        this.contador0 = 0;
        this.contador1 = 0;

    endfunction
    task run();

        $display("[%g] Chekcer inicializado", $time);

        forever begin
            /*
            #20
            drv_chkr_mbx[i].try_get(paquete_drv);
            if (i < devices) i++;
            else i = 0;
            */
            drv_chkr_mbx.get(paquete_chkr);
            case (paquete_chkr.accion)
                 
                1'b0: begin
                    
                    index[contador0] = paquete_chkr.origen; 
                    keys[contador0] = paquete_chkr;
                    contador0++;
                
                end
                1'b1: begin
                    
                    for (int j = 0; j =< contador0; j++) begin
                            if (keys[j] == paquete_chkr)begin
                                to_sc[contador]=index[j];
                                $display("[%g] dato checkaeado org = %h, dato%h", $time,index[j],keys[j]);
                                index.delete(j);
                                keys.delete(j);
                                contador0 = contador0-1;
                            end
                    end
                
                end

            endcase

        end

    endtask
endclass