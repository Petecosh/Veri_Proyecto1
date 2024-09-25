class checkr #(parameter width = 16, parameter devices = 4);
    pck_drv_chkr #(.width(width), .devices(drvrs)) paquete_chkr;
    tipo_mbx_drv_chkr drv_chkr_mbx;
    pck_drv_chkr keys[$];
    int index[$];

    
    function new();
        this.keys = {};
        this.index = {};
        this.index = 0;

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
            case (paquete_chkr.origen)
                 
                1'b0: begin
                    
                    for (int i = 0; i =< index.size(); i++) begin
                            index[i] = paquete_chkr.origen; 
                            keys[i] = paquete_chkr;
                    end
                
                end
                1'b1: begin
                    
                    for (int j = 0; j =< keys.size(); j++) begin
                            if (keys[j] == paquete_chkr)begin
                                to_sc[contador]=index[j];
                                $display("[%g] dato checkaeado org = %h, dato%h", $time,index[j],keys[j]);
                                index.delete(j);
                                keys.delete(j);
                            end
                    end
                
                end

            endcase

        end

    endtask
endclass