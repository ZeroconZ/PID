module UCC (
    input wire clk,          
    input wire reset,        
    input wire start_tick,   

    output reg load_PISO,
    output reg shift_SO,   
    output reg clear_acc,    
    output reg enable_acc,   
    output reg resta,      
    output reg update_out    
);

    localparam IDLE   = 2'b00; 
    localparam LOAD   = 2'b01; 
    localparam CALC   = 2'b10; 
    localparam UPDATE = 2'b11; 

    reg [1:0] estado_actual; 
    reg [3:0] bit_count;     

    //CAMBIO DE ESTADO
    always @(posedge clk) begin
        if (reset) begin
            estado_actual <= IDLE;
            bit_count     <= 0;
        end
        else begin
            case (estado_actual)
                IDLE: begin
                    if (start_tick) estado_actual <= LOAD; 
                end
                
                LOAD: begin
                    estado_actual <= CALC; 
                    bit_count     <= 0;    
                end
                
                CALC: begin
                    if (bit_count == 15) begin
                        estado_actual <= UPDATE; 
                    end else begin
                        bit_count <= bit_count + 1'b1; 
                    end
                end
                
                UPDATE: begin
                    estado_actual <= IDLE; 
                end
            endcase
        end
    end

	 //CONTROL DE MODULOS
    always @(*) begin
        load_PISO  = 0;
        shift_SO = 0;
        clear_acc  = 0;
        enable_acc = 0;
        resta    = 0;
        update_out = 0;

        case (estado_actual)
            IDLE: begin
				
            end
            
            LOAD: begin
                load_PISO = 1; 
                clear_acc = 1; 
            end
            
            CALC: begin
                shift_SO = 1; 
                enable_acc = 1; 
                
                if (bit_count == 15) begin
                    resta = 1; 
                end
            end
            
            UPDATE: begin
                update_out = 1; 
            end
        endcase
    end

endmodule