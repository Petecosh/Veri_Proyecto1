class driver #(parameter width = 16, parameter depth = 8);
    tipo_mbx_agnt_drv agnt_drv_mbx;
    bit [width-1:0] emul_fifo_i[$];
    bit [width-1:0] emul_fifo_o[$];
    bit pending;

    function new();
        this.emul_fifo_i = {};
        this.emul_fifo_o = {};
        pending = 0;
    endfunction

    task run();
        forever begin

            pck_agnt_drv #(.width(width)) paquete;

            $display("[%g] El driver espera por una transaccion", $time);

            agnt_drv_mbx.get(paquete);
            paquete.print("Driver: Transaccion recibida");
            $display("[%g] Transacciones pendientes en el mbx agnt_drv = %g", $time, agnt_drv_mbx.num());

            case (paquete.tipo)

                lectura: begin
                    paquete.dato_o = emul_fifo_i.pop_front();
                    paquete.print("Driver: Lectura");
                end

                escritura: begin
                    emul_fifo_i.push_back(paquete.dato_i);
                    paquete.print("Driver: Escritura");
                    pending = 1;
                end
                
                default: begin
                    $display("[%g] Error Driver: Paquete con tipo no valido", $time);
                    $finish;
                end

            endcase

            if (emul_fifo_i.size() != 0) begin
                    pending = 1;
                    $display("[%g] Driver: Pending en 1", $time);
                    
            end else begin
                    pending = 0;
                    $display("[%g] Driver: Pending en 0", $time);
            end

        end 

    endtask

endclass