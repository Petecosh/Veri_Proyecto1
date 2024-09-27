class scoreboard(parameter width = 16, parameter devices = 4, parameter broadcast = {8{1'b1}});
    pck_chkr_sb paquete_sb;         // Paquete checker -> scoreboard
    tipo_mbx_chkr_sb chkr_sb_mbx;   // Mailbox checker -> scoreboard
endclass