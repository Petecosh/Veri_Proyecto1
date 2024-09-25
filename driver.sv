class driver #(parameter bits = 1, parameter drvrs = 4, parameter width = 16);
    tipo_mbx_agnt_drv agnt_drv_mbx;
    tipo_mbx_drv_chkr drv_chkr_mbx;
    bit [width-1:0] emul_fifo_i[$];
    bit [width-1:0] emul_fifo_o[$];
    int identificador_drv;
    /*bit pending;
    bit pop_DUT;
    bit push_DUT;
    bit [width-1:0] dato_i_DUT;
    bit [width-1:0] dato_o_DUT;*/
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(width)) vif;
    pck_drv_chkr #(.width(width)) paquete_chkr;

    int id;

    function new(input int ident);
        
        id = ident;
        this.emul_fifo_i = {};
        this.emul_fifo_o = {};
        this.identificador_drv = 0;
    endfunction

    task escribir();
        forever begin
            pck_agnt_drv #(.width(width)) paquete_drv;

            $display("[%g] El driver espera por una transaccion", $time);

            // Sacar mensaje del mailbox
            agnt_drv_mbx.get(paquete_drv);
            identificador_drv = paquete_drv.origen;
            paquete_drv.print("Driver: Transaccion recibida");
            $display("[%g] Transacciones pendientes en el mbx agnt_drv = %g", $time, agnt_drv_mbx.num());


            // Escribir en la FIFO entrada
            emul_fifo_i.push_back(paquete_drv.dato);
            paquete_drv.print("Driver Ejecución: Escritura");
        end 
    endtask

    task leer();
        forever begin
            
            // Si la FIFO out tiene algo
            @(posedge vif.clk);
            if (emul_fifo_o.size() != 0) begin
                paquete_chkr = new();
                paquete_chkr.accion=1'b1;
                paquete_chkr.dato = emul_fifo_o.pop_front(); // Lo saco
                paquete_chkr.print("monitor lee");
                drv_chkr_mbx.put(paquete_chkr);
            end
        end
    endtask

    task actualizar_FIFO_i();
        forever begin
            // Si DUT pide pop 
            vif.D_pop[0][id] = emul_fifo_i[0];
            
            @(negedge vif.clk);
            if (vif.pop[0][id]) begin
                emul_fifo_i.pop_front();
                $display("[%g]  Driver FIFO in: Dato que sale hacia el DUT 0x%h", $time, vif.D_pop[0][id]);   
                paquete_chkr = new();      
                paquete_chkr.accion=1'b0;
                paquete_chkr.dato = vif.D_pop[0][id]; // Lo saco
                paquete_chkr.origen = id;
                drv_chkr_mbx.put(paquete_chkr);
                
            end
        end
    endtask

    task actualizar_FIFO_o();
        forever begin
            // Si DUT pide push
            @(posedge vif.clk);
            if (vif.push[0][id]) begin
                emul_fifo_o.push_back(vif.D_push[0][id]);
                $display("[%g] Driver FIFO out: DUT metio dato", $time);
            end
        end
    endtask

    task revisar_FIFO_in();
        // Revisar si hay algo pendiente en la FIFO entrada
        forever begin
            @(posedge vif.clk);
            if (emul_fifo_i.size() != 0) begin
                    vif.pndng[0][id] = 1;
                    //$display("[%g] Driver FIFO in: Pending en 1", $time);
                        
            end else begin
                    vif.pndng[0][id] = 0;
                    //$display("[%g] Driver FIFO in: Pending en 0", $time);
            end
        end
    endtask

    // Correr los otros tasks
    task run();
        vif.D_pop[0][id] =0;
        fork
            this.escribir();
            this.leer();
            this.actualizar_FIFO_i();
            this.actualizar_FIFO_o();
            this.revisar_FIFO_in();
        join_none
        $display("[%g] Driver inicializado", $time);
    endtask

endclass