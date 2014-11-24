// -----------------------------------------------------------------------------
// File Name   : mesif.v 
// Version     : 0.1
// Status      : Design Progress
// Module Name : mesif 
// -----------------------------------------------------------------------------
// Author         : Nilesh Dattani
// E-mail         : nilesh.dattani@pdx.edu
// Creation date  : 14th Nov 2014
// -----------------------------------------------------------------------------
// Last modified by : Nilesh 
// Last modified on : 21th Nov 2014
// -----------------------------------------------------------------------------
// Dependencies     : 
// Description      : MESIF state machine code for CACHE COHERENCE Protocol MESIF Implementation, This is the core module of the implementation
// ------------------Compiler Directives-----------------//
//
//
//---------------------Changes--------------------------------------------//
// Implementation of state machine
// Taking data from project description for type of operation n, 0 to 9 expect 7.

`include "defines.v"

module mesif(tag, index, in_mesif, in_snoop, clk, LRU, operation, out_snoop, out_bus, out_mesif);

 

//----------- Input and Output declaration----------//

input [`TAG_BITS-1 : 0] tag;			//Tag bits from Naveen's module
input [`INDEX_BITS-1:0] index;		// index bits from Naveen's modules
input [4:0] in_mesif;				// input mesif bits from Rizwan's module
input [`LRU_BITS-1:0] LRU;			// Input LRU from Sai's module
input clk;							// Input clock from Naveen's module
input [`OPR_BITS-1:0] operation;		// Operation type input from Naveen's module
input [1:0] in_snoop;			// Snoop result from my module.


output [4:0] out_mesif;				// Output mesif bits to Rizwan's module
output [2:0] out_bus;				// Output BUS Operation to Naveen's module
output [1:0] out_snoop;				// Output Snoop Result to Naveen's module

reg [4:0] out_mesif;	
reg [2:0] out_bus;	
reg [1:0] out_snoop;	

reg [3:0] state, next_state;

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




//----------Internal signals and variables declaration----------//


//--------------State Machine Implementation----------------//

/*always@(state)
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
endcase
end
*/

/*always@(state or index) // review
begin
	case(state)	
		modified: begin
		if(operation == s_rfo) begin					// Snoop result generation pending
			out_snoop = hitm;
			out_bus = WRITE;					
			next_state = invalid;					
			end
		else if (operation == s_read) begin
			out_snoop = hitm;
			next_state = shared;
			out_bus = WRITE;
			end
			
		else if (operation == cpu_read || operation == cpu_read_l2 || operation == cpu_write) begin
			next_state = modified;
			out_bus = NOP;
			end	
		else begin
			next_state = modified;
			end
		end
				
		exclusive : begin
			if (operation == s_rfo) begin
			out_snoop = hit;
			out_bus = WRITE; // Forward
			next_state = invalid;
			end
			else if(operation == s_read && in_snoop == hit) begin
			out_snoop = hit;
			out_bus = WRITE; // Forward
			next_state = shared;
			end
			
			//else if(operation = cpu_read) begin
			//out_bus = NOP;
			//next_state = exclusive;
			//end
			else if (operation == cpu_write) begin
			out_bus = NOP;
			next_state = modified;
			end
			else begin
			next_state = exclusive;
			end
		end
		
		shared : begin
		if (operation == s_rfo) begin
		out_bus = NOP;
		next_state = invalid;
		end
		//else if (operation = s_read) begin
		//out_bus = NOP;
		//next_state = shared;
		//end
		
		//else if(operation = cpu_read) begin
		//out_bus = NOP;
		//next_state = shared;
		//end
		else if(operation == cpu_write) begin
		out_bus = RFO;
		next_state = modified;
		end
		else begin
		next_state = shared;
		end
	end
	
		invalid : begin
		if(operation == cpu_read && in_snoop == hit) begin
		out_bus = READ;
		next_state = forward;
		end
		else if(operation == cpu_read && in_snoop == nohit) begin
		out_bus = READ;
		next_state = exclusive;
		end
		else if(operation == cpu_write) begin
		out_bus = RFO;
		next_state = modified;
		end
		else begin
		next_state = invalid;
		end
	end
	
		forward : begin
		if(operation == s_rfo) begin
		out_snoop = hit;
		out_bus = WRITE;
		next_state = invalid;
		end
		else if(operation == s_read) begin
		out_snoop = hit;
		out_bus = WRITE;
		next_state = shared;
		end
		
		//else if(operation = cpu_read) begin
		//out_bus = NOP;
		//next_state = forward;
		//end
		else if(operation == cpu_write) begin
		out_bus = RFO;
		next_state = modified;
		end
		else begin
		next_state = forward;
		end
	end
	
	endcase
	end
endmodule
*/

initial
begin
	case(state)	
		modified: begin
		if(operation == s_rfo) begin					// Snoop result generation pending
			out_snoop = hitm;
			out_bus = WRITE;					
			next_state = invalid;					
			end
		else if (operation == s_read) begin
			out_snoop = hitm;
			next_state = shared;
			out_bus = WRITE;
			end
			
		else if (operation == cpu_read || operation == cpu_read_l2 || operation == cpu_write) begin
			next_state = modified;
			out_bus = NOP;
			end	
		else begin
			next_state = modified;
			end
		end
				
		exclusive : begin
			if (operation == s_rfo) begin
			out_snoop = hit;
			out_bus = WRITE; // Forward
			next_state = invalid;
			end
			else if(operation == s_read && in_snoop == hit) begin
			out_snoop = hit;
			out_bus = WRITE; // Forward
			next_state = shared;
			end
			
			//else if(operation = cpu_read) begin
			//out_bus = NOP;
			//next_state = exclusive;
			//end
			else if (operation == cpu_write) begin
			out_bus = NOP;
			next_state = modified;
			end
			else begin
			next_state = exclusive;
			end
		end
		
		shared : begin
		if (operation == s_rfo) begin
		out_bus = NOP;
		next_state = invalid;
		end
		//else if (operation = s_read) begin
		//out_bus = NOP;
		//next_state = shared;
		//end
		
		//else if(operation = cpu_read) begin
		//out_bus = NOP;
		//next_state = shared;
		//end
		else if(operation == cpu_write) begin
		out_bus = RFO;
		next_state = modified;
		end
		else begin
		next_state = shared;
		end
	end
	
		invalid : begin
		if(operation == cpu_read && in_snoop == hit) begin
		out_bus = READ;
		next_state = forward;
		end
		else if(operation == cpu_read && in_snoop == nohit) begin
		out_bus = READ;
		next_state = exclusive;
		end
		else if(operation == cpu_write) begin
		out_bus = RFO;
		next_state = modified;
		end
		else begin
		next_state = invalid;
		end
	end
	
		forward : begin
		if(operation == s_rfo) begin
		out_snoop = hit;
		out_bus = WRITE;
		next_state = invalid;
		end
		else if(operation == s_read) begin
		out_snoop = hit;
		out_bus = WRITE;
		next_state = shared;
		end
		
		//else if(operation = cpu_read) begin
		//out_bus = NOP;
		//next_state = forward;
		//end
		else if(operation == cpu_write) begin
		out_bus = RFO;
		next_state = modified;
		end
		else begin
		next_state = forward;
		end
	end
	end
	
	endcase
	end