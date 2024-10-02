class scoreboard #(parameter width = 16, parameter devices = 4, parameter broadcast = {8{1'b1}});
    pck_chkr_sb paquete_sb;         // Paquete checker -> scoreboard
    tipo_mbx_chkr_sb chkr_sb_mbx;   // Mailbox checker -> scoreboard
    pck_chkr_sb almacen[$];         // Guardar lo que sale del mbx checker -> scoreboard
    pck_test_sb instruccion_sb;     // Instruccion para el scoreboard
    tipo_mbx_test_sb test_sb_mbx;   // Mailbox test -> scoreboard
    pck_drv_chkr keys[$];           // Para revisar que no queda nadie sobrando
    pck_drv_chkr index[$];          // 

    int tamano_sb; // Tamano del almacen
    int file;      // Archivo para CSV
    pck_chkr_sb auxiliar; // Para hacer prints

    task run();

         $display("[%g] El scoreboard fue inicializado", $time);

        forever begin
            #5
            if (chkr_sb_mbx.num() > 0) begin            // Si el mbx checker -> scoreboard tiene algo...
                chkr_sb_mbx.get(paquete_sb);
                $display("[%g] Scoreboard: Recibido paquete desde checker", $time);
                almacen.push_back(paquete_sb);
                keys = paquete_sb.keys;
                index = paquete_sb.index;

            end else begin
                if (test_sb_mbx.num() > 0) begin
                    test_sb_mbx.get(instruccion_sb);
                    case(instruccion_sb.tipo)

                        Reporte: begin



                            $display("[%g] Scoreboard: Recibida instruccion reporte", $time);
                            tamano_sb = this.almacen.size();
                            $display("[%g]   Dato       Origen         Tipo     Latencia", $time);
                            for (int i = 0; i < tamano_sb; i++) begin
                                almacen[i].calc_latencia();
                                auxiliar = almacen[i];
                                auxiliar.print();
                            end
                            $display("---------------------------");
                            $display("[%g] Se ejecutaron %0d mensajes", $time, almacen.size());

                            if (keys.size() <= 1) begin
                                $display("[%g] No quedo ningun mensaje sobrando en el DUT", $time);
                            end else begin
                                $display("[%g] Sobraron los siguientes mensajes", $time);
                                for (int i = 0; i < keys.size(); i++) begin
                                    $display("[%g] Dato = 0x%h Origen = %0d", $time, keys[i], index[i]);
                                end
                            end

                            file = $fopen("output.csv", "w");
    
                            if (file) begin
                                
                                // Iterate over the queue and write each element to the CSV file
                                foreach (almacen[i]) begin
                                    $fdisplay(file, "%h,%0d,%s,%0d", almacen[i].dato, almacen[i].origen, almacen[i].tipo, almacen[i].latencia);
                                end
                                
                                // Close the file
                                $fclose(file);

                            end else begin

                            $display("Error: Could not open file for writing.");

                            end                         

                        end

                        default: begin
                            $display("[%g] Scoreboard: Instruccion no valida", $time);
                        end

                    endcase

                end

            end

        end
        
    endtask

endclass