
// Tipos de transaccion para el bus
typedef enum {lectura, escritura} tipo_trans;


// Paquete que recibe el driver desde el agente
class pck_agnt_drv #(parameter width = 16);
    rand bit [width-1:0] dato_i;
    rand bit [width-1:0] dato_o;
    rand tipo_trans tipo;

    function new(bit[width-1:0] dto_i = 0, bit[width-1:0] dto_o = 0, tipo_trans tpo = lectura);
        this.dato_i = dto;
        this.dato_o = dto;
        this.tipo = tpo;
    endfunction

    function void print(string tag = "");
        $display("[%g] %s Tipo = %s Dato_i = 0x%h Dato_o = 0x%h" , $time, tag, this.tipo, this.dato_i, this.dato_o);
    endfunction

endclass

// Mailboxes

typedef mailbox #(pck_agnt_drv) agnt_drv_mbx;

