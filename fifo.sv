class fifo #(parameter width = 16, parameter depth = 8);
    bit [width-1:0] emul_fifo[$];
    bit push_i;
    bit pop_i;
    bit [width-1:0] dato_i;
    bit [width-1:0] dato_o;

    function new();
        this.emul_fifo = {};
    endfunction

    task run();
        forever begin
        
            if (push == 1) begin
                emul_fifo.pushback(this.dato_i);
            end

            if (pop == 1) begin
                this.dato_o = emul_fifo.popfront();
            end

        end
    endtask

endclass