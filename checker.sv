class checkr #(parameter width = 16, parameter devices = 4, parameter broadcast = {8{1'b1}});
    
    tipo_mbx_drv_chkr #(.width(width)) drv_chkr_mbx[devices];  // Mailboxes driver -> checker
    pck_drv_chkr #(.width(width)) keys[$];                     // Array para guardar los origenes de los paquetes escritos al DUT
    pck_drv_chkr #(.width(width)) index[$];                    // Array para guardar los paquetes escritos al DUT
    int Procesos_erroneos[$];                                  // Array para guardar los paquetes con direccion invalida
    int con_index;                                             // Variable contador para array index
    int con_err;                                               // Variable contador para array de erroneos
    bit check_correcto;                                        // Bit para indicar que se reviso correctamente

    pck_chkr_sb #(.width(width)) paquete_sb;                   // Paquete checker -> scoreboard
    tipo_mbx_chkr_sb #(.width(width)) chkr_sb_mbx;             // Mailbox checker -> scoreboard
    
    function new();
    for (int q = 0; q < devices; q++) begin                    // Ciclo para inicializar los mailboxes driver -> checker
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

            for (int h = 0; h < devices; h++)begin               // Ciclo para ir revisando cada uno de los mailboxes driver -> checker

                if (drv_chkr_mbx[h].num() > 0) begin             // Si el mailbox driver -> checker tiene algo

                    pck_drv_chkr #(.width(width)) paquete_chkr;  // Paquete que utiliza el checker
                    drv_chkr_mbx[h].get(paquete_chkr);           // Saca el paquete del mailbox driver -> checker

                    case (paquete_chkr.accion)                   // Evaluar si se trata de una escritura hacia el DUT o una lectura del DUT
                            
                            1'b0: begin                          // Si se trata de una escritura hacia el DUT...

                                $display("[%g] Checker recibe: org = %h, dato%h", $time, paquete_chkr.origen, paquete_chkr.dato);
                                if (paquete_chkr.dato[width-1:width-8] == broadcast) begin   // Reviso si el identificador es broadcast
                                    for (int i = 0; i < devices-1; i++) begin                // Ciclo para guardar el paquete dentro de los array diccionario
                                        index[con_index] = paquete_chkr;
                                        keys[con_index] = paquete_chkr;
                                        con_index++;
                                    end
                                end

                                else if (paquete_chkr.dato[width-1:width-8] < devices) begin // Si el identificador es una direccion valida...
                                    index[con_index] = paquete_chkr;                         // Guardo el paquete dentro de los array diccionario
                                    keys[con_index] = paquete_chkr;
                                    con_index++;
                                end

                                else begin                                                   // Si el identificador es un direccion invalida...
                                    $display("[%g] Dato con direccion erronea: org = %h, dato =%h", $time, paquete_chkr.origen, paquete_chkr.dato);
                                    Procesos_erroneos[con_err] = paquete_chkr.dato;          // Guardo el paquete dentro de los array diccionario
                                    
                                    paquete_sb = new();                                      // Inicializo paquete checker -> scoreboard
                                    paquete_sb.tiempo_inicio = paquete_chkr.tiempo;          // Colocar el tiempo inicial
                                    paquete_sb.tiempo_final = paquete_chkr.tiempo;           // Colocar el tiempo final
                                    paquete_sb.dato = paquete_chkr.dato;                     // Colocar el dato
                                    paquete_sb.origen = paquete_chkr.origen;                 // Colocar origen
                                    paquete_sb.tipo = "Erroneo  ";                           // Colocar tipo erroneo
                                    chkr_sb_mbx.put(paquete_sb);                             // Colocar en el mbx checker -> scoreboard

                                    con_err++;
                                end
                                
                            end

                            1'b1: begin                    // Si se trata de una lectura del DUT...

                                if ((paquete_chkr.dato[width-1:width-8] == h) || (paquete_chkr.dato[width-1:width-8] == broadcast)) begin // Si el direccion es igual al id del driver o es broadcast..

                                    $display("[%g] Dato recibido en Driver correcto", $time);

                                    for (int j = 0; j < con_index; j++) begin              // Ciclo para recorrer el array diccionario
                                        if (keys[j].dato == paquete_chkr.dato) begin       // Si el paquete leido se encontro dentro del diccionario
                                            $display("[%g] Dato checkeado: org = %h, dato%h", $time, index[j].origen, keys[j].dato);

                                            paquete_sb = new();                             // Inicializo paquete checker -> scoreboard
                                            paquete_sb.tiempo_inicio = index[j].tiempo;     // Colocar el tiempo inicial
                                            paquete_sb.tiempo_final = paquete_chkr.tiempo;  // Colocar el tiempo final
                                            paquete_sb.dato = paquete_chkr.dato;            // Colocar el dato
                                            paquete_sb.origen = index[j].origen;            // Colocar origen
                                            if (paquete_chkr.dato[width-1:width-8] == broadcast) begin  // Si el identificador es broadcast... 
                                                paquete_sb.tipo = "Broadcast";              // Colocar tipo broadcast
                                            end else begin                                  // Si el identificador es una direccion valida
                                                paquete_sb.tipo = "Correcto ";              // Colocar tipo valido
                                            end
                                            paquete_sb.keys = keys;                         // Estos 2 son para revisar que no queda ningun paquete sobrando 
                                            paquete_sb.index = index;                       // 
                                            chkr_sb_mbx.put(paquete_sb);                    // Colocar en el mbx checker -> scoreboard

                                            index.delete(j);                                // Eliminar el paquete leido del diccionario
                                            keys.delete(j);                                 // Eliminar el paquete leido del diccionario
                                            con_index = con_index-1;                        // Reducir el indice del array, porque se elimino un elemento dentro del array
                                            check_correcto = 1'b1;                          // Indicar que se encontro el paquete leido dentro del diccionario
                                        end                                                               
                                    end

                                    if (check_correcto == 0)begin                           // Si no se encontro el paquete leido dentro del diccionario...
                                        $display("[%g] Nadie envio ese dato: dato =%h", $time,paquete_chkr.dato);
                                        Procesos_erroneos[con_err] = paquete_chkr.dato;     // Guardar el paquete erroneo dentro del array de elementos erroneos
                                        con_err++;                                          // Aumentar el contador de elementos erroneos
                                        check_correcto = 1'b0;                              // Indicar que no se encontro el paquete dentro del diccionario
                                    end

                                end else begin                                              // Si la direccion no corresponde con el identificador del driver...
                                    $display("[%g] Dato en Driver INCORRECTO", $time);      // Indicar que llego un paquete a un driver que no le correspondia
                                end
                               
                            end

                            default: begin                                                 // Condicion default por si sucede algo raro
                                $display("[%g] WHAT: org = %h, dato%h", $time,paquete_chkr.origen,paquete_chkr.dato); // Imprimir el dato
                            end
                        endcase
                end
            end
        end
    endtask
endclass