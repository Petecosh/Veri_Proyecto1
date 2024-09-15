
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

// Paquete Test -> Agente
class pck_test_agnt #(parameter devices = 4, parameter width = 16);
    bit [width-1:0] dato;
    tipo_trans tipo;

    function new(bit[width-1:0] dto = 0, tipo_trans tpo = lectura);
        this.dato = dto;
        this.tipo = tpo;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato = 0x%h" , $time, tag, this.tipo, this.dato);
    endfunction
endclass

// Mailboxes

typedef mailbox #(pck_agnt_drv) tipo_mbx_agnt_drv;

typedef mailbox #(pck_test_agnt) tipo_mbx_test_agnt;

