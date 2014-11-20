// -----------------------------------------------------------------------------
// File Name   : mesif.v 
// Version     : 0.1
// Status      : Design Progress
// Module Name : mesif 
// -----------------------------------------------------------------------------
// Author         : Nilesh Dattani
// E-mail         : nilesh.dattani@wipro.com
// Creation date  : 14th Nov 2014
// -----------------------------------------------------------------------------
// Last modified by : Nilesh 
// Last modified on : 19th Nov 2014
// -----------------------------------------------------------------------------
// Dependencies     : 
// Description      : MESIF state machine code for CACHE COHERENCE Protocol MESIF Implementation, This is the core module of the implementation
// ------------------Compiler Directives-----------------//
//
//
//---------------------Changes--------------------------------------------//
// Implementation of state machine
// Taking data from project description for type of operation n, 0 to 9 expect 7.



module mesif(tag,index, in_mesif, out_mesif, result, clk, LRU, operation, out_bus );

//--------Parameters---------------//
parameter tag_bits 		= 
parameter index_bits 	= 
parameter LRU_bits		= 
parameter opr_bits		= 

// Input Commands
parameter cpu_write		= 4'd1;
parameter cpu_read 		= 4'd0;
parameter cpu_read_l2	= 4'd2; // Really not sure if we should distinguish between code and instruction. help
parameter s_invalidate	= 4'd3;
parameter s_read		= 4'd4;
parameter s_write		= 4'd5;
parameter s_rfo			= 4'd6;
parameter clean			= 4'd8;
parameter print			= 4'd9;
/*
0 read	request	from	L1	data	cache
1 write	request	from	L1	data	cache
2 read	request	from	L1	instruction	cache
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

// States 
parameter modified 	= 3'd0;
parameter exclusive = 3'd1;
parameter shared 	= 3'd2;
parameter invalid 	= 3'd3;
parameter forward 	= 3'd4;



//----------- Input and Output declaration----------//

input [tag_bits-1 : 0] tag;			//Tag bits from Naveen's module
input [index_bits-1:0] index;		// index bits from Naveen's modules
input [4:0] in_mesif;				// input mesif bits from Rizwan's module
input [LRU_bits-1:0] LRU;			// Input LRU from Sai's module
input clk;							// Input clock from Naveen's module
input [opr_bits-1:0] operation;		// Operation type input from Naveen's module

output [4:0] out_mesif;				// Output mesif bits to Rizwan's module
output [2:0] out_bus;				// Output BUS Operation to Naveen's module





//----------Internal signals and variables declaration----------//


//--------------State Machine Implementation----------------//

always@(state)
begin
case(state)
	modified : begin
		out_mesif = modified;
	end

	shared : begin
		out_mesif = shared;
	end
	
	exclusive : begin
		out_mesif = exclusive;
	end
	
	invalid : begin
		out_mesif = invalid;
	end
		
	forward : begin
		out_mesif = forward;
	end
end
endcase

always@(state or index)
begin
	case(state)
	
		modified: begin
		if(operation = s_rfo && in_snoop = hitm) begin	// Snoop result generation pending
			out_bus = WRITE;					
			next_state = invalid;					
			end
		else if (operation = s_read && in_snoop = hitm) begin
			next_state = shared;
			out_bus = WRITE;
			end
		else if (operation = cpu_read || operation = cpu_read_l2 || operation = cpu_write) begin
			next_state = modified;
			out_bus = NOP;
			end	
		else begin
			next_state = modified
			end
		end
				
		exclusive : begin
			if(operation = cpu_read
		
		
		
		
		
			
