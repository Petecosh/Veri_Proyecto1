class checker_c;
    pck_drv_chkr #(.width(width)) paquete_drv_chkr;
    pck_drv_chkr #(.width(width)) auxiliar;
    pck_drv_sb   #(.width(width)) to_sb;
    pck_agnt_drv emul_fifo[$];
    tipo_mbx_drv_chkr drv_chkr_mbx;
    tipo_mbx_chkr_sb chkr_sb_mbx;
    int contador_auxiliar;

    function new();
        this.emul_fifo = {};
        this.contador_auxiliar = 0;
    endfunction

    task run;
        $display("[%g] El checker fue inicializado", $time);
        to_sb = new();

        forever begin
            to_sb = new();
            drv_chkr_mbx.get(paquete_drv_chkr);
            paquete_drv_chkr.print("Checker: Se recibe un paquete desde el driver");
            to_sb.clean();

            case (paquete_drv_chkr.tipo)

                lectura: begin
                    auxiliar = emul_fifo.pop_front();
                    if(auxiliar.dato[15:7] != 8'hff) begin                         
                        if(paquete_drv_chkr.dato == auxiliar.dato) begin
                            to_sb.dato_enviado = auxiliar.dato;
                            to_sb.tiempo_push = auxiliar.tiempo;
                            to_sb.tiempo_pop = paquete_drv_chkr.tiempo;
                            to_sb.completado = 1;
                            to_sb.calc_latencia();
                            to_sb.print("Checker: Transaccion Completada");
                            chkr_sb_mbx.put(to_sb);
                        end 
                        else begin
                            paquete_drv_chkr.print("Checker: ");
                            $display("Dato_leido= %h, Dato_Esperado %h",paquete_drv_chkr.dato, auxiliar.dato);
                            $finish;
                        end 
                    end 
                    else begin 
                        to_sb.tiempo_pop = paquete_drv_chkr.tiempo;
                        to_sb.Broadcast = 1;
                        to_sb.print("Checker: Broadcast");
                        chkr_sb_mbx.put(to_sb);
                    end
                end

                escritura: begin
                    if (emul_fifo.size() == depth) begin
                        auxiliar = emul_fifo.pop_front();
                        to_sb.dato_enviado = auxiliar.dato;
                        to_sb.tiempo_push = auxiliar.tiempo;
                        to_sb.overflow = 1;
                        to_sb.print("Checker: Overflow");
                        chkr_sb_mbx.put(to_sb);
                        emul_fifo.push_back(paquete_drv_chkr);
                    end 
                    else begin
                        paquete_drv_chkr.print("Checker: Escritura");
                        emul_fifo.push_back(paquete_drv_chkr);
                    end
                end

                reset: begin
                    contador_auxiliar = emul_fifo.size();
                    for (int i = 0; i < contador_auxiliar; i++) begin
                        auxiliar = emul_fifo.pop_front();
                        to_sb.clean();
                        to_sb.dato_enviado = auxiliar.dato;
                        to_sb.tiempo_push = auxiliar.tiempo;
                        to_sb.reset = 1;
                        to_sb.print("Checker: Reset");
                        chkr_sb_mbx.put(to_sb);
                    end

                end

                default: begin
                    $display("[%g] Checker Error: El paquiete recivido no tiene tipo valido", $time);
                    $finish;
                end
            endcase
        end
    endtask
endclass