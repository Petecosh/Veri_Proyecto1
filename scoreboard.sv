class scoreboard #(parameter width = 16, parameter devices = 4, parameter broadcast = {8{1'b1}});
    pck_chkr_sb #(.width(width)) paquete_sb;         // Paquete checker -> scoreboard
    tipo_mbx_chkr_sb #(.width(width)) chkr_sb_mbx;   // Mailbox checker -> scoreboard
    pck_chkr_sb #(.width(width)) almacen[$];         // Guardar lo que sale del mbx checker -> scoreboard
    pck_test_sb instruccion_sb;                      // Instruccion para el scoreboard
    tipo_mbx_test_sb  test_sb_mbx;                   // Mailbox test -> scoreboard
    pck_drv_chkr #(.width(width)) keys[$];           // Estos 2 son para revisar que no sobro ningun paquete
    pck_drv_chkr #(.width(width)) index[$];          // 

    int tamano_sb;                                   // Tamano del almacen
    int file;                                        // Variable para crear el archivo CSV
    pck_chkr_sb #(.width(width)) auxiliar;           // Paquete para hacer prints

    task run();

         $display("[%g] El scoreboard fue inicializado", $time);

        forever begin
            #5
            if (chkr_sb_mbx.num() > 0) begin            // Si el mbx checker -> scoreboard tiene algo...
                chkr_sb_mbx.get(paquete_sb);            // Sacar paquete del mailbox checker -> scoreboard
                $display("[%g] Scoreboard: Recibido paquete desde checker", $time);
                almacen.push_back(paquete_sb);          // Poner el paquete en el array donde se guardan los paquetes procesados
                keys = paquete_sb.keys;                 // Estos 2 son para revisar que no sobro ningun paquete
                index = paquete_sb.index;               //

            end else begin
                if (test_sb_mbx.num() > 0) begin        // Si el mbx test -> scoreboard tiene algo...
                    test_sb_mbx.get(instruccion_sb);    // Sacar la instruccion del mailbox test -> scoreboard
                    case(instruccion_sb.tipo)           // Evaluar la instruccion recibida

                        Reporte: begin                  // Si la instruccion es de reporte...



                            $display("[%g] Scoreboard: Recibida instruccion reporte", $time);
                            tamano_sb = this.almacen.size();           // Obtener la cantidad de paquetes procesados
                            $display("[%g]   Dato       Origen         Tipo     Latencia", $time);
                            for (int i = 0; i < tamano_sb; i++) begin  // Ciclo para recorrer el array de paquetes guardados
                                almacen[i].calc_latencia();            // Se calcula la latencia
                                auxiliar = almacen[i];                 // Se asigna una variable auxiliar
                                auxiliar.print();                      // Se imprime el paquete procesado
                            end
                            $display("---------------------------");
                            $display("[%g] Se ejecutaron %0d mensajes", $time, almacen.size()); // Imprimir los paquetes procesados

                            if (keys.size() <= 1) begin                            // Si existe solo 1 paquete sin procesar (el paquete antes de ser eliminado y vaciar el array)
                                $display("[%g] No quedo ningun mensaje sobrando en el DUT", $time);
                            end else begin                                         // Si existe algun mensaje sin procesar...
                                $display("[%g] Sobraron los siguientes mensajes", $time);
                                for (int i = 0; i < keys.size(); i++) begin        // Ciclo para imprimir los paquetes sin procesar
                                    $display("[%g] Dato = 0x%h Origen = %0d", $time, keys[i], index[i]);
                                end
                            end

                            file = $fopen("output.csv", "w"); // Abrir un archivo CSV en escritura
    
                            if (file) begin                   // Si el archivo esta listo para escribirse...
                                
                                // Recorrer el array de paquetes guardados y guardar cada elemento en el archivo CSV
                                foreach (almacen[i]) begin
                                    $fdisplay(file, "%h,%0d,%s,%0d", almacen[i].dato, almacen[i].origen, almacen[i].tipo, almacen[i].latencia);
                                end
                                
                                $fclose(file);                // Cerrar el archivo CSV

                            end else begin

                            $display("Error CSV: No se pudo abrir el archivo para escribir");

                            end                         

                        end

                        default: begin   // Condicion default por si llega una instruccion no valida
                            $display("[%g] Scoreboard: Instruccion no valida", $time);
                        end

                    endcase

                end

            end

        end
        
    endtask

endclass