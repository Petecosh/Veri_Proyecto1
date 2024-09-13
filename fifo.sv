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
        
            if (push_i == 1) begin
                emul_fifo.push_back(this.dato_i);
            end

            if (pop_i == 1) begin
                this.dato_o = emul_fifo.pop_front();
            end

        end
    endtask

endclass