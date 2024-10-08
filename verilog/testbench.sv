`timescale 1ns/1ns
module testbench;


  reg [1:0] PRIMO;
  reg [1:0] SECONDO;
  reg INIZIA;
  reg clk=1'b1;
  wire [1:0] MANCHE;
  wire [1:0] PARTITA;


  MorraCinese dut (
    .PRIMO(PRIMO),
    .SECONDO(SECONDO),
    .INIZIA(INIZIA),
    .clk(clk),
    .MANCHE(MANCHE),
    .PARTITA(PARTITA)
    );


  
  integer tbf, outf;
 
  always #50 clk = ~clk;
  
  
  
  always @(negedge clk)
  begin
    $display("Outputs: MANCHE[%b] MANCHE[%b] PARTITA[%b] PARTITA[%b]", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
    $fdisplay( tbf, "simulate %b %b %b %b %b", PRIMO[1], PRIMO[0], SECONDO[1], SECONDO[0], INIZIA);
    $fdisplay( outf, "Outputs: %b %b %b %b", MANCHE[1], MANCHE[0], PARTITA[1], PARTITA[0]);
  end
    

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(1);    
    
    tbf = $fopen("testbench.script", "w");
    outf = $fopen("output_verilog.txt", "w");
    // funzione $fdisplay per stampare sul file tbf
    $fdisplay(tbf,"read_blif FSMD.blif");
    
    
    PRIMO = 2'b00; 
    SECONDO=2'b10;
    INIZIA= 1'b1; //4 manche massime
    
    #90
    PRIMO = 2'b00; 
    SECONDO=2'b11;
    INIZIA= 1'b0; //mossa invalida
    
    #100
    PRIMO = 2'b10; 
    SECONDO=2'b11;
    INIZIA= 1'b0; //0-1
    
    #100
    PRIMO = 2'b11; 
    SECONDO=2'b11;
    INIZIA= 1'b0; //mossa non valida g2
    
    #100
    PRIMO = 2'b01; 
    SECONDO=2'b11;
    INIZIA= 1'b0; //mossa non valida g2
    
    #100
    PRIMO = 2'b11; 
    SECONDO=2'b01;
    INIZIA= 1'b0; //0-2 con 2 manche valide giocate
    
    #100
    PRIMO = 2'b10; 
    SECONDO=2'b10;
    INIZIA= 1'b0; //0-2 con 3 m.v giocate
    
    #100
    PRIMO = 2'b11; 
    SECONDO=2'b11;
   	INIZIA= 1'b0; //0-2 con 4 manche giocate. 
    //FINE PARTITA
   
	#100 // PER TORNARE ALLO STATO INIZIALE
    PRIMO = 2'b11; 
    SECONDO=2'b10;
   	INIZIA= 1'b0; //PASSAGGIO DA FINE A INIZIO
    
    #100
    PRIMO = 2'b00; 
    SECONDO=2'b00;
   	INIZIA= 1'b1; //MAX PARTITE=4 
    
     #100
    PRIMO = 2'b01; 
    SECONDO=2'b11;
   	INIZIA= 1'b0; //1-0
    
     #100
    PRIMO = 2'b11; 
    SECONDO=2'b10;
   	INIZIA= 1'b0; //2-0
    
     #100
    PRIMO = 2'b01; 
    SECONDO=2'b11;
   	INIZIA= 1'b0; //3-0
    
     #100
    PRIMO = 2'b11; 
    SECONDO=2'b11;
   	INIZIA= 1'b0; //3-0, VINCE g1
    
    
     #100
    PRIMO = 2'b00; 
    SECONDO=2'b01;
   	INIZIA= 1'b1; //PER TORNARE ALLO STATO INIZIALE.
    
    
    #100 
    PRIMO = 2'b00; 
    SECONDO=2'b00;
   	INIZIA= 1'b1; //4 partite max
    
    #100 
    PRIMO = 2'b01; 
    SECONDO=2'b01;
   	INIZIA= 1'b0; // 0-0, 1 manche PAREGGIO
    
    #100 
    PRIMO = 2'b10; 
    SECONDO=2'b10;
   	INIZIA= 1'b0; // 0-0, 2 manche PAREGGIO
    
    #100 
    PRIMO = 2'b10; 
    SECONDO=2'b11;
   	INIZIA= 1'b0; // 0-1, 3 manche VG2
    
    #100 
    PRIMO = 2'b11; 
    SECONDO=2'b01;
   	INIZIA= 1'b0; //0-2, 4 manche VINCE IL G2 
    
    #100 //DA FINE A INIZIO, setto il massimo a 5
    PRIMO=2'b00;
    SECONDO=2'b01;
    INIZIA=1'b1;
    
    #100 //MANCHE INVALIDA
    PRIMO=2'b00;
    SECONDO=2'b00;
    INIZIA=1'b0;
    
    #100 //0-0, 1 manche giocata
    PRIMO=2'b10;
    SECONDO=2'b10;
    INIZIA=1'b0;
    
    #100 //0-0 due mg
    PRIMO=2'b10;
    SECONDO=2'b10;
    INIZIA=1'b0;
    
    #100 //0-0 3 mg
    PRIMO=2'b10;
    SECONDO=2'b10;
    INIZIA=1'b0;
    
    #100 //0-0 4 mg
    PRIMO=2'b10;
    SECONDO=2'b10;
    INIZIA=1'b0;
    
     #100 //0-0 5 mg, PAREGGIO
    PRIMO=2'b10;
    SECONDO=2'b10;
    INIZIA=1'b0;
    
     #100 //DA FINE A INIZIO, IN QUESTO MODO IL MAX DI MANCHE RIMANE 5 PERCHE INIZIA=0
    PRIMO=2'b10;
    SECONDO=2'b10;
    INIZIA=1'b0;
    
    
      #100
    PRIMO=2'b10; // 0-1 , 1 manche giocata
    SECONDO=2'b11;
    INIZIA=1'b0;
    
      #100
    PRIMO=2'b10; // 1-1, 2 manche giocate
    SECONDO=2'b01;
    INIZIA=1'b0;
    
      #100
    PRIMO=2'b01; //2-1, 3 manche giocate
    SECONDO=2'b11; 
    INIZIA=1'b0;
    
      #100
    PRIMO=2'b11; //2-2, 4 manche giocate
    SECONDO=2'b01;
    INIZIA=1'b0;
    
      #100
    PRIMO=2'b01; // 3-2, 5 manche giocate, massimo raggiunto, vince g1
    SECONDO=2'b11;
    INIZIA=1'b0;
    
    
    
    #100
    
    
    
   	$fclose(outf);
    $fclose(tbf);
    // Termine simulazione
    $finish;

  end

endmodule