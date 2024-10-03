class agente #(parameter devices = 4, parameter width = 16, parameter broadcast = {8{1'b1}});
    pck_test_agnt #(.devices(devices), .width(width)) instruccion_agente;                              // Instruccion que recibe el agente
    pck_agnt_drv #(.devices(devices), .width(width),.broadcast(broadcast)) paquete_agnt_drv[devices];  // Paquete que se envia hacia los mbx de los drivers
    pck_agnt_drv #(.devices(devices), .width(width),.broadcast(broadcast)) paquete_rand;               // Paquete para randomizar
    tipo_mbx_agnt_drv #(.devices(devices), .width(width),.broadcast(broadcast)) agnt_drv_mbx[devices]; // Mailboxes del agente a los drivers

    int num_transacciones;                                                                             // Numero de transacciones
    tipo_mbx_test_agnt #(.devices(devices), .width(width)) test_agnt_mbx;                              // Mailbox del test al agente
    int max_retardo;                                                                                   // Retardo maximo

    function new();
        num_transacciones = 500;  // Se define la cantidad de transacciones
        max_retardo = 10;         // Se define 10 como el retardo maximo
    endfunction

    task run();

        $display("[%g] Agente inicializado", $time);

        forever begin
            #1
            if (test_agnt_mbx.num() > 0) begin                             // Si el mbx del agente no esta vacio
                $display("[%g] Agente: Se recibe una instruccion", $time);
                test_agnt_mbx.get(instruccion_agente);                     // El agente saca la instruccion

                
                case (instruccion_agente.tipo)

                    Random: begin                                                              // Si la instruccion es de tipo random...
                        for (int i = 0; i < num_transacciones; i++) begin                      // Se generan un numero de transacciones random 
                            paquete_rand = new();                                              // Se inicializa el paquete random
                            paquete_rand.max_retardo = max_retardo;
                            paquete_rand.randomize();                                          // se randomiza el contenido del paquete
                            paquete_rand.dato = {paquete_rand.receptor, paquete_rand.payload}; // Se concatena el identificador y el payload
                            paquete_agnt_drv[paquete_rand.origen] = new();                     // Se inicializa un paquete agente -> driver
                            paquete_agnt_drv[paquete_rand.origen] = paquete_rand;              // El contenido del paquete agente -> driver es el mismo que el randomizado
                            paquete_agnt_drv[paquete_rand.origen].print("Agente: Random Transaccion creada");
                            agnt_drv_mbx[paquete_rand.origen].put(paquete_agnt_drv[paquete_rand.origen]); // Se coloca en el mbx agente -> driver
                        end
                    end

                    Especifica: begin                                                                   // Si la instruccion es de tipo especifica...
                        paquete_agnt_drv[instruccion_agente.origen] = new();                            // Se inicializa el paquete agente -> driver
                        paquete_agnt_drv[instruccion_agente.origen].retardo = instruccion_agente.retardo;
                        paquete_agnt_drv[instruccion_agente.origen].dato = instruccion_agente.dato;     // El dato a enviar es especificado por la instruccion
                        paquete_agnt_drv[instruccion_agente.origen].origen = instruccion_agente.origen; // El dispositivo origen es especificado por la instruccion
                        paquete_agnt_drv[instruccion_agente.origen].print("Agente: Especifica Transaccion creada");
                        agnt_drv_mbx[instruccion_agente.origen].put(paquete_agnt_drv[instruccion_agente.origen]); // Se coloca en el mbx agente -> driver
                    end

                    

                    Erronea: begin                                                              // Si la instruccion es erronea a proposito
                        for (int j = 0; j < max_retardo; j++) begin
                            paquete_rand = new();
                            paquete_rand.max_retardo = max_retardo;                             // Inicializar un paquete random
                            paquete_rand.randomize();                                           // El paquete se randomiza
                            paquete_rand.dato = { paquete_rand.erronea, paquete_rand.payload};  // El identificador erroneo se concatena con el payload
                            paquete_agnt_drv[paquete_rand.origen] = new();                      // Inicializar el paquete agente -> driver
                            paquete_agnt_drv[paquete_rand.origen] = paquete_rand;               // Asociar el contenido random al paquete agente -> driver
                            paquete_agnt_drv[paquete_rand.origen].print("Agente: Erronea Transaccion creada");
                            agnt_drv_mbx[paquete_rand.origen].put(paquete_agnt_drv[paquete_rand.origen]); // Se coloca en el mbx agente -> driver
                        end
                    end

                    Broadcast: begin                                                           // Si la instruccion es de tipo broadcast...
                        for (int i = 0; i < devices; i++) begin                                // Se generan un broadcast por cada device 
                            paquete_rand = new();                                              // Se inicializa el paquete random
                            paquete_rand.randomize();                                          // se randomiza el contenido del paquete
                            paquete_rand.dato = {broadcast, paquete_rand.payload};             // Se concatena el broadcast y el payload
                            paquete_agnt_drv[i] = new();                                       // Se inicializa un paquete agente -> driver
                            paquete_agnt_drv[i].dato = paquete_rand.dato;                      // El dato del paquete agente -> driver
                            paquete_agnt_drv[i].origen = i;                                    // Agregar el origen
                            paquete_agnt_drv[i].print("Agente: Broadcast Transaccion creada");
                            agnt_drv_mbx[i].put(paquete_agnt_drv[i]);                          // Se coloca en el mbx agente -> driver
                        end
                    end
                    
                    default: begin                                                             // Condicion default por si llega instruccion no valida
                        $display("[%g] Error Agente: Instruccion con tipo no valido", $time);
                        $finish;
                    end

                endcase
                
            end

        end

    endtask

endclass