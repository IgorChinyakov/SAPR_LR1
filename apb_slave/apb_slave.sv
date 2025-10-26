module apb_slave (
    input         pclk,           // синхросигнал
    input         presetn,        // сигнал сброса (инверсный)
    input  [31:0] paddr,          // адрес обращения
    input  [31:0] pwdata,         // данные для записи
    input         psel,           // признак выбора устройства
    input         penable,        // признак активной транзакции
    input         pwrite,         // признак операции записи

    output logic        pready,   // признак готовности от устройства
    output logic        pslverr,  // опциональный сигнал: ошибка при обращении
    output logic [31:0] prdata    // прочитанные данные
);

    logic [31:0] register_with_some_name;

    // APB FSM
    enum logic [1:0] {
        APB_SETUP,
        APB_W_ENABLE,
        APB_R_ENABLE
    } apb_st;

    always @(posedge pclk) begin
        if (!presetn) begin
            prdata                  <= '0;
            pslverr                 <= 1'b0;
            pready                  <= 1'b0;
            register_with_some_name <= 32'h0;
            apb_st                  <= APB_SETUP;
        end else begin
            case (apb_st)
                APB_SETUP: begin : apb_setup_st
                    // Очистка данных и ошибок
                    prdata <= '0;
                    pready <= 1'b0;

                    // Переход в ENABLE, когда psel активен
                    if (psel && !penable) begin
                        if (pwrite)
                            apb_st <= APB_W_ENABLE;
                        else
                            apb_st <= APB_R_ENABLE;
                    end
                end : apb_setup_st

                APB_W_ENABLE: begin : apb_w_en_st
                    // Декодирование адреса и запись
                    if (psel && penable && pwrite) begin
                        pready <= 1'b1;
                        case (paddr[7:0])
                            8'h0: begin
                                // Запись в регистр со смещением 0
                                register_with_some_name <= pwdata;

                                // Пример условной логики обработки записи
                                // if (pwdata[.....] == ..... )
                                //     ...
                            end

                            8'h4: begin
                                // Запись в регистр со смещением 4
                            end

                            8'h8: begin
                                // Запись в регистр со смещением 8
                            end

                            default: begin
                                pslverr <= 1'b1;
                            end
                        endcase

                        apb_st <= APB_SETUP;
                    end
                end : apb_w_en_st

                APB_R_ENABLE: begin : apb_r_en_st
                    if (psel && penable && !pwrite) begin
                        pready <= 1'b1;
                        case (paddr[7:0])
                            8'h0: begin
                                // Чтение из регистра со смещением 0
                                prdata <= register_with_some_name;
                            end

                            8'h4: begin
                                // Чтение из регистра со смещением 4
                            end

                            8'h8: begin
                                // Чтение из регистра со смещением 8
                            end

                            default: begin
                                pslverr <= 1'b1;
                            end
                        endcase

                        apb_st <= APB_SETUP;
                    end
                end : apb_r_en_st

                default: begin
                    pslverr <= 1'b1;
                end
            endcase

            // Пример фонового действия
            if (register_with_some_name[0] == 1'b0)
                register_with_some_name <= 32'hAAAA_AAAA;
            else
                register_with_some_name <= 32'h5555_5555;
        end
    end

endmodule