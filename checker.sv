class checkr #(parameter width = 16, parameter devices = 4, parameter broadcast = {8{1'b1}});
    
    tipo_mbx_drv_chkr drv_chkr_mbx[devices];
    pck_drv_chkr keys[$];
    pck_drv_chkr index[$];
    int Procesos_erroneos[$];
    int con_index;
    int con_err;
    bit check_correcto;

    pck_chkr_sb #(width) paquete_sb;   // Paquete checker -> scoreboard
    tipo_mbx_chkr_sb chkr_sb_mbx;              // Mailbox checker -> scoreboard
    
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

        $display("[%g] Checker inicializado", $time);

        #5

        forever begin

            #10

            for (int h = 0; h < devices; h++)begin

                if (drv_chkr_mbx[h].num() > 0)begin

                    pck_drv_chkr #(.width(width)) paquete_chkr;
                    drv_chkr_mbx[h].get(paquete_chkr);

                    case (paquete_chkr.accion)
                            
                            1'b0: begin

                                $display("[%g] Checker recibe: org = %h, dato%h", $time, paquete_chkr.origen, paquete_chkr.dato);
                                
                                if (paquete_chkr.dato[width-1:width-8] == broadcast) begin
                                    for (int i = 0; i < devices-1; i++) begin
                                        index[con_index] = paquete_chkr;  
                                        keys[con_index] = paquete_chkr;
                                        con_index++;
                                    end
                                end

                                else if (paquete_chkr.dato[width-1:width-8] < devices) begin
                                    index[con_index] = paquete_chkr; 
                                    keys[con_index] = paquete_chkr;
                                    con_index++;
                                end

                                else begin
                                    $display("[%g] Dato con direccion erronea: org = %h, dato =%h", $time,paquete_chkr.origen,paquete_chkr.dato);
                                    Procesos_erroneos[con_err] = paquete_chkr.dato;
                                    
                                    paquete_sb = new();                       // Inicializo paquete checker -> scoreboard
                                    paquete_sb.tiempo_inicio = paquete_chkr.tiempo;
                                    paquete_sb.tiempo_final = paquete_chkr.tiempo;
                                    paquete_sb.dato = paquete_chkr.dato;      // Colocar el dato
                                    paquete_sb.origen = paquete_chkr.origen;  // Colocar origen
                                    paquete_sb.tipo = "Erroneo  ";            // Colocar tipo
                                    chkr_sb_mbx.put(paquete_sb);              // Colocar en el mbx checker -> scoreboard

                                    con_err++;
                                end
                                
                            end

                            1'b1: begin

                                if ((paquete_chkr.dato[width-1:width-8] == h) || (paquete_chkr.dato[width-1:width-8] == broadcast)) begin

                                    $display("[%g] Dato recibido en Driver correcto", $time);

                                    for (int j = 0; j < con_index; j++) begin  
                                        if (keys[j].dato == paquete_chkr.dato)begin
                                            $display("[%g] Dato checkaeado: org = %h, dato%h", $time,index[j].origen,keys[j].dato);

                                            paquete_sb = new();                       // Inicializo paquete checker -> scoreboard
                                            paquete_sb.tiempo_inicio = index[j].tiempo;
                                            paquete_sb.tiempo_final = paquete_chkr.tiempo;
                                            paquete_sb.dato = paquete_chkr.dato;      // Colocar el dato
                                            paquete_sb.origen = index[j].origen;             // Colocar origen
                                            if (paquete_chkr.dato[width-1:width-8] == broadcast) begin 
                                                paquete_sb.tipo = "Broadcast";        // Colocar tipo
                                            end else begin
                                                paquete_sb.tipo = "Correcto ";        // Colocar tipo
                                            end
                                            paquete_sb.keys = keys;                   // Para revisar que no queda nadie sobrando 
                                            paquete_sb.index = index;                 // 
                                            chkr_sb_mbx.put(paquete_sb);              // Colocar en el mbx checker -> scoreboard

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

                                end else begin
                                    $display("[%g] Dato en Driver INCORRECTO", $time);
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