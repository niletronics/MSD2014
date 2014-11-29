`define EOF 32'hFFFF_FFFF
`define NULL 0
`define MAX_LINE_LENGTH 1000

module TB;
  
  integer   file, c, r; //values for reading the file
  reg [99:0] PC;
  reg [3:0] operation;   //instruction to take from lines
  wire [2:0] out_bus;		
  wire [1:0] out_snoop;
  wire [31:0] ReadCount;
  wire [31:0] WriteCount;
  reg[31:0] TraceAddress;
  //`ifdef DEBUG
  wire [31:0] debug_flag;
  //`endif
  wire [31:0]hitcount,misscount;
  reg [31:0] Sum_Hit_Miss;
  real  hit_rate_percen, miss_rate_percen, hit_ratio;

     l3cache test_l3cache(TraceAddress,operation, PC, out_bus, out_snoop, hitcount, misscount, ReadCount, WriteCount, debug_flag);
						
//open up file
initial 
begin : file_block
	
    PC = 0;
	$display("************ECE 585 FINAL PROJECT**********");
	$display(" ");
	file = $fopen("cc1.din","r");

    if (file ==`NULL)   //in case of error opening file
        disable file_block; 
    c =$fgetc(file); //read in one line at a time
    while (c != `EOF)
    begin
        r = $ungetc(c,file);
		r = $fscanf(file,"%d %x\n",operation,TraceAddress);
		c = $fgetc(file);
	$display("address: %h     instr:  %h", TraceAddress, operation);	//address and instruction interchanged
	
	PC=PC+1'b1;
	#10;
	end // while not EOF

	$fclose(file); //close the file here

	Sum_Hit_Miss = hitcount + misscount;
	hit_rate_percen = ((hitcount/Sum_Hit_Miss)*100);
	miss_rate_percen = ((misscount/Sum_Hit_Miss)*100);
	hit_ratio = (hitcount/Sum_Hit_Miss);
	
	$display("Total Hit Count= %d " , hitcount);
	$display("Total Miss Count= %d " , misscount);
	$display("Total Read Count= %d " , ReadCount);
	$display("Total Write count= %d " , WriteCount);
	$display("Sum of total hit and miss count= %d " , Sum_Hit_Miss);
	$display("Hit rate percentage= %g " , hit_rate_percen );
	$display("Miss rate percentage= %g " , miss_rate_percen);
	$display("Hit ratio= %g " , hit_ratio);

end 
endmodule
