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
// Last modified on : 14th Nov 2014
// -----------------------------------------------------------------------------
// Dependencies     : 
// Description      : MESIF state machine code for CACHE COHERENCE Protocol MESIF Implementation, This is the core module of the implementation
// ------------------Compiler Directives-----------------//
//
//
//-----------//

module mesif(tag,index, in_mesif, out_mesif, result, clk, LRU, operation );

//--------Parameters---------------//
parameter tag_bits 		= 
parameter index_bits 	= 
parameter LRU_bits		= 
parameter opr_bits		= 
parameter CPU_WRITE		=
parameter CPU_READ 		= 
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

// States 
parameter modified 	= 3'd0;
parameter exclusive = 3'd1;
parameter shared 	= 3'd2;
parameter invalid 	= 3'd3;
parameter forward 	= 3'd4;



//----------- Input and Output declaration----------//

input [tag_bits-1 : 0] tag;			//Tag bits from nmo module
input [index_bits-1:0] index;		// index bits from nmo modules
input [4:0] in_mesif;				// input mesif bits from rst module
output [4:0] out_mesif;				// Output mesif bits to rst module
input [LRU_bits-1:0] LRU;			// Input LRU from stu module
input clk;							// Input clock from top module
input [opr_bits-1:0] operation;		// Operation type input from nmo module





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
		if(operation = RFO && in_snoop = hitm) begin	// Need to get snoop result from snoop result generator and bus operation
			out_bus = writeback;					
			next_state = invalid;					// As per the state diagram
			end
		else if (operation = read && in_snoop = hitm) begin
			next_state = shared;
			out_bus = writeback;
			end
		else if (operation = read
			
			
