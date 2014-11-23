mesif_tb;

reg [tag_bits-1 : 0] tag;
reg [index_bits-1:0] index;
reg [4:0] in_mesif;	
reg [LRU_bits-1:0] LRU;
reg clk;		
reg [opr_bits-1:0] operation;
reg [1:0] in_snoop;	

wire [4:0] out_mesif;
wire [2:0] out_bus;			
wire [1:0] out_snoop;

module mesif(tag, index, in_mesif, clk, LRU, operation, out_snoop, out_bus, out_mesif, tag_bits, index_bits, LRU_bits, opr_bits);
