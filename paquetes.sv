
// Tipo Transaccion Fifo
typedef enum {lectura, escritura} tipo_trans;


// Paquete Agente -> Driver
class pck_agnt_drv #(parameter width = 16);
    rand bit [width-1:0] dato_i;
    rand bit [width-1:0] dato_o;
    rand tipo_trans tipo;

    function new(bit[width-1:0] dto_i = 0, bit[width-1:0] dto_o = 0, tipo_trans tpo = lectura);
        this.dato_i = dto_i;
        this.dato_o = dto_o;
        this.tipo = tpo;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato_i = 0x%h Dato_o = 0x%h" , $time, tag, this.tipo, this.dato_i, this.dato_o);
    endfunction

endclass


// Paquete Driver -> Checker
class pck_drv_chkr #(parameter width = 16);
    rand bit [width-1:0] dato_i;
    rand bit [width-1:0] dato_o;
    rand bit [7:0] receptor;
    rand tipo_trans tipo;

    function new(bit[width-1:0] dto_i = 0, bit[width-1:0] dto_o = 0, tipo_trans tpo = lectura);
        this.dato_i = dto_i;
        this.dato_o = dto_o;
        this.tipo = tpo;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato_i = 0x%h Dato_o = 0x%h" , $time, tag, this.tipo, this.dato_i, this.dato_o);
    endfunction

endclass


// Paquete Test -> Agente
class pck_test_agnt #(parameter devices = 4, parameter width = 16);
    bit [width-1:0] dato;
    tipo_trans tipo;
    rand int origen;

    function new(bit[width-1:0] dto = 0, tipo_trans tpo = lectura, int org = 0);
        this.dato = dto;
        this.tipo = tpo;
        this.origen = org;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato = 0x%h Origen = 0x%h" , $time, tag, this.tipo, this.dato, this.origen);
    endfunction
endclass


//Paquete chercker scoreboard
class pck_drv_sb #(parameter width = 16);
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

// Mailboxes

typedef mailbox #(pck_agnt_drv) tipo_mbx_agnt_drv;

typedef mailbox #(pck_agnt_drv) tipo_mbx_drv_chkr;

typedef mailbox #(pck_drv_sb) tipo_mbx_chkr_sb;

typedef mailbox #(pck_test_agnt) tipo_mbx_test_agnt;

