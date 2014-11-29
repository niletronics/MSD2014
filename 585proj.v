`include "defines.v"


module l3cache(TraceAddress,operation, PC, out_bus, out_snoop, hitcount, misscount, ReadCount, WriteCount, debug_flag);
   

input [`ADDR_SIZE-1:0] TraceAddress;
input [`OPR_SIZE-1:0]operation;
output [2:0] out_bus;		
output [1:0] out_snoop;
input [99:0] PC;
output [31:0] ReadCount;
output [31:0] WriteCount;
output [31:0] hitcount;
output [31:0] misscount;
output [31:0] debug_flag;
reg [31:0] debug_flag;

reg [31:0] ReadCount=32'd0;
reg [31:0]WriteCount=32'd0;
reg [31:0]hitcount=32'd0;
reg [31:0]misscount=32'd0;	
reg [2:0] out_bus;	
reg [1:0] out_snoop;	
reg [`TAG_SIZE-1 : 0] tag;
reg [`INDEX_SIZE-1:0] index;
reg [`LRU_SIZE-1:0] LRU;	
//reg [`OPR_SIZE-1:0] operation;	
reg [2:0] state,next_state;
reg [1:0] in_snoop=2'b 11;
reg DEBUG=1'b1;
reg foundway;
reg found_invalid;
//cache structure 

reg [`TAG_SIZE-1:0] tag_array[2**`INDEX_SIZE-1:0][`WAY_SIZE-1:0];
reg [2:0] mesif_array[2**`INDEX_SIZE-1:0][`WAY_SIZE-1:0];

reg plrubit[((2**`INDEX_SIZE)-1):0][3:0][`WAY_SIZE-1:0];

integer way,level;
reg [`BYTESELECT_SIZE-1:0] byteSelect;
//integer i,j;	//Why are this global, can we make bits to local ? and if these are meant to be global, rename them
integer index_value=2**`INDEX_SIZE;
//$display("iiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiindex value= %d ", index_value);
reg cachehit;


// Input Operation
parameter cpu_write		= 4'd1;
parameter cpu_read 		= 4'd0;
parameter cpu_read_i		= 4'd2; // Really not sure if we should distinguish between code and operation. help
parameter s_invalidate		= 4'd3;
parameter s_read		= 4'd4;
parameter s_write		= 4'd5;
parameter s_rfo			= 4'd6;
parameter clear			= 4'd8;
parameter print			= 4'd9;
parameter FALSE       		= 1'b0;
parameter TRUE 	      		= 1'b1;
/*
0 read	request	from	L1	data	cache
1 write	request	from	L1	data	cache
2 read	request	from	L1	operation	cache
3 snooped	invalidate	command
4 snooped	read	request
5 snooped	write	request
6 snooped	read	with	intent	to	modify
8 clear	the	cache	and	reset	all	state
9 print	contents	and	state	of	each	valid	cache	line	(allow	subsequent	trace	activity) 
*/

//Bus Operation types
parameter READ 			= 3'd1; 		/* Bus Read */ 
parameter WRITE 		= 3'd2; 		/* Bus Write */ 
parameter INVALIDATE 	= 3'd3; 		/* Bus Invalidate */ 
parameter RFO 			= 3'd4; 		/* Bus Read With Intent to Modify */  
parameter NOP			= 3'd5;

// States 
parameter modified 	= 3'd0;
parameter exclusive = 3'd1;
parameter shared 	= 3'd2;
parameter invalid 	= 3'd3;
parameter forward 	= 3'd4;

// Snoop parameters
parameter hit 		= 2'd0;
parameter hitm		= 2'd1;
parameter nohit		= 2'd2;


initial
begin
clearcache();
end

always @(operation or TraceAddress or PC) 
begin
		calculateaddress();
		checktag();
		getsnoop();		
	case(operation)
		cpu_read: begin
			ReadCount=ReadCount+1'b1;
			if(cachehit==1'b1)	begin	
				hitupdatelru();
			end
			else begin
				missupdatelru();
				write_to_cache();
			end
			mesif_array[index][way]=exclusive;
		end
/*	
	cpu_write:	
	begin
	WriteCount=WriteCount+1'b1;
	calculateaddress();
	checktag();
	getsnoop();
	if(cachehit==1'b1)
	begin
	hitupdatelru();
	updatemesif();
	end
	else 
	begin
	write_to_cache();
	
	end
	end
	
	cpu_read_i:	
	begin
	ReadCount=ReadCount+1'b1;
	calculateaddress();
	checktag();
	debug_flag = 32'd1;
  	$display("debug flag = %d", debug_flag);
	getsnoop();
	if(cachehit==1'b1)
	begin
	hitupdatelru();
	updatemesif();
	end
	else
	begin
	write_to_cache();
	missupdatelru();
	updatemesif();
	end
	end
	
	s_invalidate:
	begin
	calculateaddress();
	checktag();
	if(cachehit==1'b1)
	begin
	updatemesif();
	end
	end
	
	s_read:
	begin
	calculateaddress();
	checktag();
	if(cachehit==1'b1)
	begin
		updatemesif();
	end
	end			

	s_write:
	begin
	calculateaddress();
	checktag();
	if(cachehit==1'b1)
	begin
		updatemesif();
	end
	end

	s_rfo:
	begin
	calculateaddress();
	checktag();
	if(cachehit==1'b1)
	begin
		updatemesif();
	end
end

	clear:
	begin
		clearcache();// it includes clearing of tag, lru and mesif
	end
	
	print:
	begin
		print_cache();
	end*/
	default: $display("Invalid Operation");
endcase

end


task write_to_cache();
begin
tag_array[index][way]=tag;
$display("tag array is at write_to_cache %b  	Index = %h Way = %d  ",tag_array[index][way], index, way);	
end
endtask

task clearcache();
integer i,j,k;
begin
	if(DEBUG) begin
		//debug_flag = 32'd1;
		$display(" TraceAddress = %h ", TraceAddress);
	end
		
	for(i=0; i<`INDEX_SIZE; i=i+1)
	begin
		for(j=0; j<`WAY_SIZE; j=j+1)
		begin
			tag_array[i][j]={`TAG_SIZE{FALSE}};
			$display("tag array is %b",tag_array[i][j]);
			mesif_array[i][j]= invalid;
			end
		end	
		
	for(i=0;i<((index_value));i=i+1) begin 
		for(j=0;j<`INDEX_SIZE;j=j+1) begin
			for(k=0;k<`WAY_SIZE;k=k+1) begin		 
				plrubit[i][j][k]=0;
			end
		end
	end
end
endtask	

task print_cache();
integer i,j;
		begin
			if(DEBUG)
				begin
				//debug_flag = 32'd1;
				$display("print_cache function is called");
				$display(" TraceAddress = %h ", TraceAddress);
				end
			
			$display("Contents of L3 cache ");
			$display(" ");
			for(j=0; j<`WAY_SIZE; j=j+1)
			begin
				$display("       ");
				$display("       ");
				$display("---------------------------------------------------------------------------------------------");
				$display("           			 WAY: %d , way size= %d ", j 	,`WAY_SIZE				         );
				$display("---------------------------------------------------------------------------------------------");
				$display("       ");
				$display("       ");
				$display("Starting Address			INDEX				TAG			MESIF State");
				
				for(i=0; i<4; i=i+1)
				begin
					if(mesif_array[i][j] != invalid)
						$display("%h			%h				%b			%h ",{ tag_array[i][j], i, 6'b000000}, i ,tag_array[i][j], mesif_array[i][j] );
						
					else if(mesif_array[j][i] == invalid)
						//$display("2222222222222222222222222222Invalid state at position: %h",{i, tag_array[j][i], 6'b000000} );
						$display("%h			%h				%b			%h",{tag_array[j][i],6'b000000} ,i ,tag_array[i][j], mesif_array[i][j] );
		
				end
			end	
		end	
endtask		

task checktag();
integer i; 
begin 
foundway = 1'b0;

for(i = 0 ; (i < `WAY_SIZE) &&( foundway == 1'b0 ); i = i + 1)
begin
	
	if (tag_array[index][i] == tag && mesif_array[index][i] != invalid) begin 
		cachehit = 1'b1; 
		foundway = 1'b1;
		$display("Found the way and way =i = %d ", i);
	end 
	else begin
		cachehit = 1'b0;
	end
end
	
	if(cachehit==1'b1) begin
		way = i;
		hitcount = hitcount+1'b1;
	end	
	else if(cachehit==1'b0) begin
		$display("It is a miss and %d should be max number of ways", i);
		misscount = misscount+1'b1;
	end
 end 
 endtask

task calculateaddress;
begin
	if(DEBUG)
		begin
		//debug_flag = 32'd1;
		$display("calculateaddress function is called");
		$display(" TraceAddress = %h ", TraceAddress);
		end

	
	byteSelect = TraceAddress[`BYTESELECT_SIZE-1:0];
	$display(" ***************************************************************************************************Trace address= %b ", TraceAddress);
	
	$display(" ***************************************************************************************************byte address= %b ", byteSelect);
	
	tag = TraceAddress[`ADDR_SIZE-1:`BYTESELECT_SIZE+`INDEX_SIZE];
	$display(" ***************************************************************************************************Tag address= %b ", tag);
	
	index = TraceAddress[`ADDR_SIZE-`TAG_SIZE-1:`BYTESELECT_SIZE];
	$display("***************************************************************************************************index address= %b ", index);
end	
endtask

task getsnoop();
begin

	if(DEBUG)
		begin
		//debug_flag = 32'd1;
		//$display("getsnoop function is called");
		//$display(" TraceAddress = %h ", TraceAddress);
		end
		
case({TraceAddress[1],TraceAddress[0]})

 00:
 begin
	in_snoop = hit;
end	
 01:
 begin
	in_snoop = hitm;
end	
 10:
 begin
	in_snoop = nohit;
	end
 11:
 begin
	in_snoop = hit;
end
endcase
end
endtask
 
task hitupdatelru;
integer i,j,k;
begin



if(DEBUG)
		begin
		//debug_flag = 32'd1;
		$display("hitupdatelru function is called");
		$display(" TraceAddress = %h ", TraceAddress);
		end

for(i=0;2**i<(`WAY_SIZE-1);i=i+1)

begin

level = i+1;

end

begin

for(i=level;i>=1;i=i-1)

begin

way = (way/2);

plrubit[index][level][way]=(!(plrubit[index][level][way]));


end

end

end
endtask
  
task missupdatelru;
integer flag,i,j;
begin
found_invalid = 1'b0;

	if(cachehit==1'b0) begin
		for (i=0; i<(`WAY_SIZE-1) && (found_invalid == 1'b0); i=i+1) begin		
			if(mesif_array[index][i] == invalid) begin
				way = i;
				$display("tag written to cache at %h  and index value=  %h", tag, index);
				found_invalid=1'b1;
			end
			else begin
				found_invalid=1'b0;
				
				for(i=0;2**i<(`WAY_SIZE-1);i=i+1) begin
					level = i+1'b1;
				end
	
				for(i=1; i<=level;i=i+1) begin
					if(plrubit[index][i][j]==0) begin
						j=(2*j);	
						flag =0;
					end
					else begin
					j = ((2*j)+1);
					flag = 1;
					end
				end
			
				if(flag==0) begin
					way=(2*j);
				end
				else begin
					way=((2*j)+1);
				end				
			end
		end
	end
end
endtask
 
task updatemesif();
begin
	if(DEBUG)
		begin
		//debug_flag = 32'd1;
		$display("updatemesif function is called");
		$display(" TraceAddress = %h ", TraceAddress);
		end
		
		
	case(mesif_array[index][way])	
	modified: begin
		if(operation == s_rfo) begin					
			out_snoop = hitm;
			out_bus = WRITE;					
			mesif_array[index][way] = invalid;
			
		end
		else if (operation == s_read) begin
			out_snoop = hitm;
			mesif_array[index][way] = shared;
			out_bus = WRITE;
		end			
		else if (operation == cpu_read || operation == cpu_read_i || operation == cpu_write) begin
			mesif_array[index][way] = modified;
			out_bus = NOP;
		end	
		else begin
			mesif_array[index][way] = modified;
		end
		end
			
	exclusive : begin
		if (operation == s_rfo) begin
			out_snoop = hit;
			out_bus = WRITE; // Forward
			mesif_array[index][way] = invalid;
		end
		else if(operation == s_read && in_snoop == hit) begin
			out_snoop = hit;
			out_bus = WRITE; // Forward
			mesif_array[index][way] = shared;
		end
		
		//else if(operation = cpu_read) begin
		//out_bus = NOP;
		//mesif_array[index][way] = exclusive;
		//end
		else if (operation == cpu_write) begin
			out_bus = NOP;
			mesif_array[index][way] = modified;
		end
		else begin
			mesif_array[index][way] = exclusive;
		end
	end
	
	shared : begin
	if (operation == s_rfo) begin
		out_bus = NOP;
		mesif_array[index][way] = invalid;
	end
	//else if (operation = s_read) begin
	//	out_bus = NOP;
	//	mesif_array[index][way] = shared;
	//end
	
	//else if(operation = cpu_read) begin
	//	out_bus = NOP;
	//	mesif_array[index][way] = shared;
	//end
	else if(operation == cpu_write) begin
		out_bus = RFO;
		mesif_array[index][way] = modified;
	end
	else begin
		mesif_array[index][way] = shared;
	end
	end
	
	invalid : begin
	if(operation == cpu_read && in_snoop == hit) begin
		out_bus = READ;
		mesif_array[index][way] = forward;
	end
	else if(operation == cpu_read && in_snoop == nohit) begin
		out_bus = READ;
		mesif_array[index][way] = exclusive;
	end
	else if(operation == cpu_write) begin
		out_bus = RFO;
		mesif_array[index][way] = modified;
	end
	else begin
		mesif_array[index][way] = invalid;
	end
	end
	
	forward : begin
		if(operation == s_rfo) begin
			out_snoop = hit;
			out_bus = WRITE;
			mesif_array[index][way] = invalid;
		end
		else if(operation == s_read) begin
			out_snoop = hit;
			out_bus = WRITE;
			mesif_array[index][way] = shared;
		end
	
		//else if(operation = cpu_read) begin
		//	out_bus = NOP;
		//	mesif_array[index][way] = forward;
		//end
		else if(operation == cpu_write) begin
			out_bus = RFO;
			mesif_array[index][way] = modified;
		end
		else begin
			mesif_array[index][way] = forward;
		end
		end

	endcase
end
endtask

endmodule



	
	