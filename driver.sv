class driver #(parameter bits = 1, parameter drvrs = 4, parameter width = 16);
    tipo_mbx_agnt_drv agnt_drv_mbx;                                    // Mailbox Agente -> Driver
    tipo_mbx_drv_chkr drv_chkr_mbx;                                    // Mailbox Driver -> Checker
    bit [width-1:0] emul_fifo_i[$];                                    // Emulación Fifo Driver -> DUT
    bit [width-1:0] emul_fifo_o[$];                                    // Emulación FIFO DUT -> Driver
    virtual bus_if #(.bits(bits), .drvrs(drvrs), .pckg_sz(width)) vif; // Interfaz
    int id;                                                            // Identificador
    pck_drv_chkr #(.width(width)) paquete_chkr;                        // Paquete hacia el checker

    function new(input int ident);
        id = ident;            // Crear una variable ident, viene de un ciclo for que saca número 0,1,2..
        this.emul_fifo_i = {}; // Inicializar FIFO in
        this.emul_fifo_o = {}; // Inicializar FIFO out
    endfunction

    // Se encarga de escribir
    task escribir();
        forever begin
            pck_agnt_drv #(.width(width)) paquete_drv; // Paquete que utilizar el driver

            $display("[%g] El driver espera por una transaccion", $time);
            // Sacar mensaje del mailbox
            agnt_drv_mbx.get(paquete_drv);
            paquete_drv.print("Driver: Transaccion recibida");
            $display("[%g] Transacciones pendientes en el mbx agnt_drv = %g", $time, agnt_drv_mbx.num());

            // Escribir en la FIFO in
            emul_fifo_i.push_back(paquete_drv.dato);
            paquete_drv.print("Driver Ejecución: Escritura");
        end 
    endtask

    // Se encarga de leer
    task leer();
        forever begin
            
            // Si la FIFO out tiene algo dentro...
            @(posedge vif.clk);
            if (emul_fifo_o.size() != 0) begin
                paquete_chkr = new();                        // Crear un paquete hacia el checker
                paquete_chkr.accion=1'b1;                    // Avisar que se trata es una lectura
                paquete_chkr.dato = emul_fifo_o.pop_front(); // Sacar el dato de FIFO out
                paquete_chkr.print("Monitor leyo un dato");
                drv_chkr_mbx.put(paquete_chkr);              // Se coloca lo que se leyo hacia checker
            end
        end
    endtask

    // Actualiza la FIFO in cada vez que el DUT pide pop
    task actualizar_FIFO_i();
        forever begin
            vif.D_pop[0][id] = emul_fifo_i[0]; // DUT siempre observa el top of FIFO
            
            // Si DUT pide pop...
            @(negedge vif.clk);
            if (vif.pop[0][id]) begin
                // Sale de FIFO in
                paquete_chkr = new();                        // Crear un paquete hacia el checker
                $display("[%g]  Driver FIFO in: Dato que sale hacia el DUT 0x%h", $time, vif.D_pop[0][id]);         
                paquete_chkr.accion=1'b0;                    // Avisar que se trata de una escritura
                paquete_chkr.dato = emul_fifo_i.pop_front(); // El dato enviado hacia el DUT se envia al checker tambien
                paquete_chkr.origen = id;                    // Asignar el origen de acuerdo al identificador
                drv_chkr_mbx.put(paquete_chkr);              // Se coloca lo que se escribio hacia el checker
                
            end
        end
    endtask

    // Actualiza la FIFO out cada vez que el DUT pide push
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

    // Revisar si hay algo pendiente en la FIFO entrada
    task revisar_FIFO_in();
        forever begin
            // Si la FIFO in tiene algo dentro...
            @(posedge vif.clk);
            if (emul_fifo_i.size() != 0) begin
                    vif.pndng[0][id] = 1; // Pending en 1
                        
            end else begin
                    vif.pndng[0][id] = 0; // Pending en 0
            end
        end
    endtask

    // Correr los otros tasks
    task run();
        vif.D_pop[0][id] = 0; // La primera vez que corre, los datos entrada DUT se ponen en 0
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