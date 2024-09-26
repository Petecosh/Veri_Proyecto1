// Tipo Transaccion Agente
typedef enum {Random, Especifica, Erronea} tipo_agente;

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
class pck_agnt_drv #(parameter devices = 4,parameter width = 16);
    bit [width-1:0] dato;
    rand bit [devices-1:0] origen;   // Dispositivo origen
    rand bit [7:0] receptor;         // Dispositivo destino
    rand bit [width-9:0] payload;    // Mensaje

    constraint direccion {receptor < devices; receptor >=0; receptor != origen;}
    constraint dispositivo {origen < devices; origen >= 0;}
    //constraint retardo {retardo < max_retardo; retardo>0;}

    function new(bit[width-1:0] dto = 0, int org = 0, bit rec = 1, bit pay = 0);
        this.dato = dto;
        this.origen = org;
        this.receptor = rec;
        this.payload = pay;
        
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Dato = 0x%h, origen = 0x%h" , $time, tag, this.dato,this.origen);
    endfunction

endclass


// Paquete Driver -> Checker
class pck_drv_chkr #(parameter width = 16);
    bit [width-1:0] dato;   // Dato enviado
    bit accion;             // Avisa si el dato es enviado hacia el DUT o recibido desde el DUT
    int origen;             // Dispositivo origen
    
    function new(bit[width-1:0] dto = 0, bit ac = 0, int orig = 0);
        this.dato = dto;
        this.accion = ac; 
        this.origen = orig;
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

    function new(bit[width-1:0] dto = 0, tipo_agente tpo = Random, int org = 0);
        this.dato = dto;
        this.tipo = tpo;
        this.origen = org;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato = 0x%h Origen = 0x%h" , $time, tag, this.tipo, this.dato, this.origen);
    endfunction
endclass


// Paquete Checker -> Scoreboard
class pck_chkr_sb #(parameter width = 16);
    bit [width-1:0] dato_enviado;
    int tiempo_push;
    int tiempo_pop;
    bit completado;
    bit Broadcast;
    bit reset;
    int latencia;

    function clean();
        this.dato_enviado = 0;
        this.tiempo_push = 0;
        this.tiempo_pop = 0;
        this.completado = 0;
        this.Broadcast = 0;
        this.reset = 0;
        this.latencia = 0;
    endfunction

    task calc_latencia;
        this.latencia = this.tiempo_pop - tiempo_push;
    endtask

    function print (string tag);
        $display("[%g] %s dato = %h, t_push = %g, t_pop = %g, cmplt = %g, Brdcst = %g, rst = %g, ltncy = %g",
                 $time,
                 tag,
                 this.dato_enviado,
                 this.tiempo_push,
                 this.tiempo_pop,
                 this.completado,
                 this.Broadcast,
                 this.reset,
                 this.latencia);
    endfunction
endclass

// Paquete Test -> Scoreboard

// Mailboxes

typedef mailbox #(pck_agnt_drv) tipo_mbx_agnt_drv;    // Mailbox agente -> driver
typedef mailbox #(pck_drv_chkr) tipo_mbx_drv_chkr;    // Mailbox driver -> checker
typedef mailbox #(pck_chkr_sb) tipo_mbx_chkr_sb;       // Mailbox checker -> scoreboard
typedef mailbox #(pck_test_agnt) tipo_mbx_test_agnt;  // Mailbox test -> agente

