// Tipo Transaccion Agente (y Scoreboard)
typedef enum {Random, Especifica, Erronea, Broadcast, Reporte} tipo_agente;

// Interfaz
interface bus_if #(parameter bits = 1, parameter drvrs = 4, parameter pckg_sz = 16, parameter broadcast = {8{1'b1}})
(
    input clk
);
    
    logic reset;
    logic pndng[bits-1:0][drvrs-1:0];
    logic push[bits-1:0][drvrs-1:0]; 
    logic pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_pop[bits-1:0][drvrs-1:0];
    logic [pckg_sz-1:0] D_push[bits-1:0][drvrs-1:0];

endinterface

// Paquete Agente -> Driver
class pck_agnt_drv #(parameter devices = 4, parameter width = 16, parameter broadcast = {8{1'b1}});
    bit [width-1:0] dato;
    rand bit [devices-1:0] origen;   // Dispositivo origen
    rand bit [width-1:width-8] receptor;         // Dispositivo destino
    rand bit [width-9:0] payload;    // Mensaje
    rand bit [width-1:width-8] erronea;
    rand int retardo;               
    int max_retardo;

    constraint dir_erronea {erronea > devices; erronea != broadcast;}
    constraint const_retardo {retardo < max_retardo; retardo > 0;}
    constraint direccion {receptor < devices; receptor >=0; receptor != origen;}
    constraint dispositivo {origen < devices; origen >= 0;}

    function new(bit[width-1:0] dto = 0, int org = 0, bit rec = 1, bit pay = 0, int ret = 0, int max_ret = 0, bit dir_er = 0);
        this.dato = dto;
        this.origen = org;
        this.receptor = rec;
        this.payload = pay;
        this.retardo = ret;
        this.max_retardo = retardo;
        this.erronea=dir_er;
        
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Dato = 0x%h, origen = 0x%h, retardo = %0d" , $time, tag, this.dato, this.origen, this.retardo);
    endfunction

endclass


// Paquete Driver -> Checker
class pck_drv_chkr #(parameter width = 16);
    bit [width-1:0] dato;   // Dato enviado
    bit accion;             // Avisa si el dato es enviado hacia el DUT o recibido desde el DUT
    int origen;             // Dispositivo origen
    int tiempo;             // Tiempo para medir retardo

    function new(bit[width-1:0] dto = 0, bit ac = 0, int orig = 0, int tme = 0);
        this.dato = dto;
        this.accion = ac; 
        this.origen = orig;
        this.tiempo = tme;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Dato = 0x%h" , $time, tag, this.dato);
    endfunction

endclass


// Paquete Test -> Agente
class pck_test_agnt #(parameter devices = 4, parameter width = 16);
    bit [width-1:0] dato;   // Dato enviado
    tipo_agente tipo;       // Tipo de instruccion para el agente
    rand bit [4:0] origen;  // Dispositivo origen
    int retardo;            // Retardo especificado

    function new(bit[width-1:0] dto = 0, tipo_agente tpo = Random, int org = 0, int ret = 0);
        this.dato = dto;
        this.tipo = tpo;
        this.origen = org;
        this.retardo = ret;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato = 0x%h Origen = 0x%h" , $time, tag, this.tipo, this.dato, this.origen);
    endfunction
endclass


// Paquete Checker -> Scoreboard
class pck_chkr_sb #(parameter width = 16);
    bit [width-1:0] dato;   // Dato enviado
    int origen;             // Dispositivo origen
    string tipo;            // Tipo de la transaccion (correcta, erronea, broadcast)
    int tiempo_inicio;      // Tiempo inical para calcular retardo
    int tiempo_final;       // Tiempo final para calcular retardo
    int latencia;           // Valor final de retardo
    pck_drv_chkr #(.width(width)) keys[$];   // Estos 2 son para revisar que no sobro ningun paquete
    pck_drv_chkr #(.width(width)) index[$];  //

    task calc_latencia;
        this.latencia = this.tiempo_final - tiempo_inicio;
    endtask

    function new(bit[width-1:0] dto = 0, int org = 0, string tpo = Erronea, int t_i = 0, int t_f = 0, int lat = 0);
        this.dato = dto;
        this.origen = org;
        this.tipo = tpo;
        this.tiempo_inicio = t_i;
        this.tiempo_final = t_f;
        this.latencia = lat;
    endfunction

    function void print();
        $display("---------------------------");
        $display("[%g]   0x%h     0x%h     %s      %g" , $time, this.dato, this.origen, this.tipo, this.latencia);
    endfunction
    
endclass

// Paquete Test -> Scoreboard
class pck_test_sb;
    tipo_agente tipo;       // Tipo de instruccion para el scoreboard

    function new(tipo_agente tpo = Reporte);
        this.tipo = tpo;
    endfunction

endclass

// Mailboxes

typedef mailbox #(pck_agnt_drv #(.devices(6), .width(16), .broadcast ({8{1'b1}}))) tipo_mbx_agnt_drv;    // Mailbox agente -> driver
typedef mailbox #(pck_drv_chkr #(.width(6))) tipo_mbx_drv_chkr;    // Mailbox driver -> checker
typedef mailbox #(pck_chkr_sb #(.width(16))) tipo_mbx_chkr_sb;      // Mailbox checker -> scoreboard
typedef mailbox #(pck_test_agnt #(.devices(6), .width(16))) tipo_mbx_test_agnt;  // Mailbox test -> agente
typedef mailbox #(pck_test_sb) tipo_mbx_test_sb;      // Mailbox test -> scoreboard

