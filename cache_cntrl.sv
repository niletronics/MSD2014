module cache_cntrl();

int cache[8191:0];

function clear_cache (input a);
int rows, cols;
  
    for (rows = 0; rows<=16; rows=rows+1)
    begin
      for(cols = 0; cols<=15; cols=cols+1)
	  begin
	    cache[rows][cols] = 16'd0;
		$display("Clearing [%d][%d]", rows, cols);
	  end
    end
endfunction

initial
begin
clear_cache;
$display("Function complete");
end
endmodule