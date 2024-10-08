module MorraCinese (PRIMO, SECONDO, INIZIA, MANCHE, PARTITA, clk);
  input reg [1:0] PRIMO;
  input reg [1:0] SECONDO;
  input reg INIZIA;
  input clk;
  output reg [1:0] MANCHE; 
  output reg [1:0] PARTITA;
  
  	//registri interni
  reg [1:0] registro_1 = 2'b00; //mossa ultimo vincitore
  reg [1:0] registro_2 = 2'b00; //ultima manche vinta
  reg [4:0] registro_3 = 5'b00000; //setmax
  reg [4:0] registro_4 = 5'b00000; //contatore manche
  
  reg [2:0] stato = 3'b000;
  reg [2:0] stato_prossimo = 3'b000;

  
  reg min_manche = 1'b1;
  reg max_manche = 1'b1;
  reg fine = 1'b0;

  parameter min = 5'b00100;

  parameter INIZIO = 3'b000, G11 = 3'b001, G12 = 3'b010, G13 = 3'b011, G21 = 3'b100, G22 = 3'b101, G23 = 3'b110, FINE = 3'b111;

 
  always @(posedge clk)
	begin
      if(INIZIA)
      		stato = INIZIO;
    	else
    		stato = stato_prossimo;
	end
 
 
	//DATAPATH
  always @ (posedge clk,fine)
	begin
        if(INIZIA === 1'b0 && registro_3 === 5'b00000) //settaggio automatico del REGISTRO 3 al minimo di manche giocabili in caso di mancato settaggio da parte dell'utent
            begin
        	    registro_3 = 5'b00100;
            end
        else if(fine === 1'b1) //la partita successiva avrà lo stesso numero massimo di manche giocabili
            begin
          	    registro_1 = 2'b00;
      		    registro_2 = 2'b00;
          	    registro_4 = 5'b00000;
            end
     	else if(INIZIA === 1'b1) //RESET
			begin
				registro_3 = min + {PRIMO,SECONDO};
      			registro_4 = 5'b00000;
      			registro_1 = 2'b00;
      			registro_2 = 2'b00;
    	    end
           
      	//FASE DI GIOCO
            if (INIZIA || fine)
            begin
                MANCHE=2'b00;
            end
  			else if(PRIMO === 2'b00 || SECONDO === 2'b00)
   			begin
    			MANCHE = 2'b00; //manche non valida il registro_4 non aumenta
   			end
          	else if((registro_2 === 2'b01 && registro_1 === PRIMO) || (registro_2 === 2'b10 && registro_1 === SECONDO))
    		begin
				MANCHE = 2'b00; //manche non valida il registro_4 non aumenta
    		end
  			else if (PRIMO === SECONDO)
			begin
				MANCHE = 2'b11;//Parità
				registro_4 = registro_4 + 1'b1;
			end
          	else if((PRIMO === 2'b01 && SECONDO === 2'b11 ) || (PRIMO === 2'b10 && SECONDO === 2'b01) || (PRIMO === 2'b11 && SECONDO === 2'b10))
			begin
				MANCHE = 2'b01; //Vince il giocatore 1
				registro_4 = registro_4 + 1'b1;
              	registro_1 = PRIMO;
              	registro_2 = 2'b01;
			end
			else
  			begin
				MANCHE = 2'b10; //Vince il giocatore 2
				registro_4 = registro_4 + 1'b1;
              	registro_1 = SECONDO;
              	registro_2 = 2'b10;
			end
      
         	//comparatori
      if(registro_4 >= min)
    		min_manche = 1'b0;
      	else
          	min_manche = 1'b1;
      
      if(registro_4 === registro_3)
    		max_manche = 1'b0;
      	else
          	max_manche = 1'b1;
      
    end //end di always (DATAPATH)


	//FSM
  always @(stato, INIZIA, MANCHE, min_manche, max_manche)
	begin
        case(stato)
			INIZIO: 
			begin
                if(INIZIA || (MANCHE === 2'b11 && max_manche) || (MANCHE === 2'b00 && max_manche) )
                    begin

                        PARTITA = 2'b00;
                        fine = 1'b0;
                        stato_prossimo = INIZIO;
                    end 
                else if (!INIZIA && MANCHE === 2'b01 && max_manche)
                    begin
                        PARTITA = 2'b00;
                        fine = 1'b0;
                        stato_prossimo = G11;
                    end
                else if (!INIZIA && MANCHE === 2'b10 && max_manche)
                    begin
                        PARTITA = 2'b00;
                        fine = 1'b0;
                        stato_prossimo = G21;
                    end              	
                else 
                    begin
                        if(MANCHE === 2'b01 && !min_manche && !max_manche)
                            begin
                                PARTITA = 2'b01;
                                fine = 1'b0;
                                stato_prossimo = FINE;
                            end
                        else if (MANCHE === 2'b10 && !min_manche && !max_manche)
                            begin
                                PARTITA = 2'b10;
                                fine = 1'b0;
                                stato_prossimo = FINE;
                            end
                        else if (MANCHE === 2'b11 && !min_manche && !max_manche)
                            begin
                                PARTITA = 2'b11;
                                fine = 1'b0;
                                stato_prossimo = FINE;
                            end
                    end                	
        	end //end INIZIO

			G11: 
        	begin
              	if(INIZIA || (MANCHE === 2'b10 && max_manche))
                begin
                	PARTITA = 2'b00;
                  	fine = 1'b0;
                  	stato_prossimo = INIZIO;
                end
              	else if(MANCHE === 2'b01 && min_manche && max_manche)
                begin  	
                  	PARTITA = 2'b00;
                    fine = 1'b0;
                  	stato_prossimo = G12;
                end
              	else if((MANCHE === 2'b00 && max_manche) || (MANCHE === 2'b11 && max_manche))
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                    stato_prossimo = G11;
                end
                else
                begin
                  	if(MANCHE === 2'b01 && min_manche === 1'b0)
                    	PARTITA = 2'b01;
                  	else if(MANCHE === 2'b10 && min_manche === 1'b0 && max_manche === 1'b0)
                    	PARTITA = 2'b11;
                  	else if(MANCHE === 2'b11 && min_manche === 1'b0 && max_manche === 1'b0)
                    	PARTITA = 2'b01;
                  	fine=1'b0;
                    stato_prossimo = FINE;
                end
        	end //end G11


			G12: 
			begin   
			  	if(INIZIA)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = INIZIO;
                end
              	else if(MANCHE === 2'b01 && min_manche === 1'b1 && max_manche === 1'b1)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G13;
                end
              	else if((MANCHE === 2'b00 && max_manche === 1'b1) || (MANCHE === 2'b11 && max_manche === 1'b1 && min_manche === 1'b1))
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G12;
                end
              	else if(MANCHE === 2'b10 && max_manche === 1'b1 && min_manche === 1'b1)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G11;
                end
              	else if((MANCHE === 2'b11 && min_manche === 1'b0) || (MANCHE === 2'b01 && min_manche === 1'b0) || (MANCHE === 2'b10 && min_manche === 1'b0 && max_manche === 1'b0))
                begin
                    PARTITA = 2'b01;
                  	fine=1'b0;
                    stato_prossimo = FINE;
                end
			end //end G12
		
      
      		G13: 
			begin   
			  	if(INIZIA)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = INIZIO;
                end
              	else if(MANCHE === 2'b00 && max_manche === 1'b1)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G13;
                end
              	else if((MANCHE === 2'b01 || MANCHE === 2'b10 || MANCHE === 2'b11) && min_manche === 1'b0)
                begin
                  	PARTITA = 2'b01;
                  	fine=1'b0;
      				stato_prossimo = FINE;
                end
			end //end G13
      
      	
      		G21: 
			begin   
              	if(INIZIA ||(MANCHE === 2'b01 && max_manche === 1'b1))
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = INIZIO;
                end
              	else if((MANCHE === 2'b11 && max_manche === 1'b1) || (MANCHE === 2'b00 && max_manche === 1'b1))
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G21;
                end
              	else if(MANCHE === 2'b10 && min_manche === 1'b1 && max_manche === 1'b1)
              	begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G22;
              	end
              	else
                begin
                  	if(MANCHE === 2'b01 && min_manche === 1'b0 && max_manche === 1'b0)
                    begin
                    	PARTITA = 2'b11;
                    end
                  	else if(MANCHE === 2'b10 && min_manche === 1'b0)
                    begin
                    	PARTITA = 2'b10;
                    end
                  	else if(MANCHE === 2'b11 && min_manche === 1'b0 && max_manche === 1'b0)
                    begin
                    	PARTITA = 2'b10;
                    end
                  	fine=1'b0;
                  	stato_prossimo = FINE;
                end
			end //end G21
      
      
      		G22: 
			begin   
			  	if(INIZIA)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = INIZIO;
                end
              	else if((MANCHE === 2'b00 && max_manche === 1'b1) || (MANCHE === 2'b11 && max_manche === 1'b1 && min_manche === 1'b1))
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                  	stato_prossimo = G22;
                end
              	else if(MANCHE === 2'b01 && min_manche === 1'b1 && max_manche === 1'b1)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                  	stato_prossimo = G21;
                end
              	else if(MANCHE === 2'b10 && max_manche === 1'b1 && min_manche === 1'b1)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = G23;
                end
              	else if((MANCHE === 2'b11 && min_manche === 1'b0) || (MANCHE === 2'b01 && min_manche === 1'b0 && max_manche === 1'b0) || (MANCHE === 2'b10 && min_manche === 1'b0))
                begin
                  	PARTITA = 2'b10;
                  	fine = 1'b0;
                    stato_prossimo = FINE;
                end
			end //end G22
      
      
      		G23: 
			begin   
			  	if(INIZIA)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                	stato_prossimo = INIZIO;
                end
              	else if(MANCHE === 2'b00 && max_manche === 1'b1)
                begin
                  	PARTITA = 2'b00;
                  	fine = 1'b0;
                  	stato_prossimo = G23;
                end
              	else if((MANCHE === 2'b01 || MANCHE === 2'b10 || MANCHE === 2'b11) && min_manche === 1'b0)
                begin
                  	PARTITA = 2'b10;
                  	fine = 1'b0;
                  	stato_prossimo = FINE;
                end
			end //end G23
      
      
      		FINE: 
			begin   
			  	PARTITA = 2'b00;
              	fine=1'b1;
              	stato_prossimo = INIZIO;
			end //end END
  		
        
        endcase
    end //end always (FSM)

endmodule