class scoreboard #(parameter width = 16, parameter devices = 4, parameter broadcast = {8{1'b1}});
    pck_chkr_sb paquete_sb;         // Paquete checker -> scoreboard
    tipo_mbx_chkr_sb chkr_sb_mbx;   // Mailbox checker -> scoreboard
    pck_chkr_sb almacen[$];         // Guardar lo que sale del mbx checker -> scoreboard
    pck_test_sb instruccion_sb;     // Instruccion para el scoreboard
    tipo_mbx_test_sb test_sb_mbx;

    int file; // Archivo para CSV


    task run();

         $display("[%g] El scoreboard fue inicializado", $time);

        forever begin
            #5
            if (chkr_sb_mbx.num() != 0) begin
                chkr_sb_mbx.get(chkr_sb_mbx);
                $display("[%g] Scoreboard: Recibido paquete desde checker", $time);
                almacen.push_back(chkr_sb_mbx);

            end else begin
                if (test_sb_mbx != 0) begin
                    test_sb_mbx.get(instruccion_sb);

                    case(instruccion_sb.tipo)

                        Reporte: begin



                            $display("[%g] Scoreboard: Recibida instruccion reporte", );
                            tamano_sb = this.almacen.size();
                            $display("[%g] Dato       Origen       Tipo", $time);
                            for (int i = 0; i < tamano_sb; i++) begin
                                auxiliar = almacen[i];
                                auxiliar.print();
                            end

                            file = $fopen("output.csv", "w");
    
                            if (file) begin
                            // Write the header of the CSV file
                                $fdisplay(file, "Dato,Origen,Tipo");
                                
                                // Iterate over the queue and write each element to the CSV file
                                foreach (almacen[i]) begin
                                    $fdisplay(file, "%0d,%0d,%0d", almacen[i].dato, almacen[i].origen, almacen[i].tipo);
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