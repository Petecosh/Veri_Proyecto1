class driver #(parameter width = 16);
    tipo_mbx_agnt_drv agnt_drv_mbx;
    tipo_mbx_drv_chkr drv_chkr_mbx;
    bit [width-1:0] emul_fifo_i[$];
    bit [width-1:0] emul_fifo_o[$];
    int identificador_drv;
    bit pending;
    bit pop_DUT;
    bit push_DUT;
    bit [width-1:0] dato_i_DUT;
    bit [width-1:0] dato_o_DUT;
    //virtual bus_if #() vif;

    int id;

    function new(input int ident);
        id = ident;
        this.emul_fifo_i = {};
        this.emul_fifo_o = {};
        this.identificador_drv = 0;
        this.pending = 0;
        this.pop_DUT = 0;
        this.push_DUT = 0;
        this.dato_i_DUT = 0;
        this.dato_o_DUT = 0;
        $display("sip driver");
    endfunction

    task escribir();
    $display("sip esc run");
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
    $display("sip leer run");
        forever begin
            // Si la FIFO out tiene algo
            if (emul_fifo_o.size() != 0) begin
                pck_drv_chkr #(.width(width)) paquete_chkr;
                paquete_chkr.dato = emul_fifo_o.pop_front(); // Lo saco
                paquete_chkr.print("Driver Ejecución: Lectura");
                //drv_chkr_mbx.put(paquete_chkr);
            end
        end
    endtask

    task actualizar_FIFO_i();
    $display("sip actufifoi run");
        forever begin
            // Si DUT pide pop 
            //@(posedge vif.clk);
            //if (vif.pop[0][id]) begin
            if (pop_DUT) begin
                //bit [width-1:0] auxiliar = emul_fifo_i.pop_front();
                //vif.D_pop[0][id] = auxiliar;
                //vif.D_pop = emul_fifo_i.pop_front();
                dato_i_DUT = emul_fifo_i.pop_front();
                $display("[%g] Driver FIFO in: DUT saco dato", $time);
            end
        end
    endtask

    task actualizar_FIFO_o();
    $display("sip fifoo run");
        forever begin
            // Si DUT pide push
            //@(posedge vif.clk);
            //if (vif.push[0][id]) begin
            if (push_DUT) begin
                //emul_fifo_o.push_back(vif.D_push[0][id]);
                emul_fifo_o.push_back(dato_o_DUT);
                $display("[%g] Driver FIFO out: DUT metio dato", $time);
            end
        end
    endtask

    task revisar_FIFO_in();
    $display("sip fifoi run");
        // Revisar si hay algo pendiente en la FIFO entrada
        forever begin
            //@(posedge vif.clk);
            if (emul_fifo_i.size() != 0) begin
                    //vif.pndng[0][id] = 1;
                    pending = 1;
                    //$display("[%g] Driver FIFO in: Pending en 1", $time);
                        
            end else begin
                    //vif.pndng[0][id] = 0;
                    pending = 0;
                    //$display("[%g] Driver FIFO in: Pending en 0", $time);
            end
        end
    endtask

    // Correr los otros tasks
    task run();
        $display("sip drv run");
        fork
            this.escribir();
            this.leer();
            //this.actualizar_FIFO_i();
            //this.actualizar_FIFO_o();
            //this.revisar_FIFO_in();
        join_none
        $display("[%g] Driver inicializado", $time);
    endtask

endclass