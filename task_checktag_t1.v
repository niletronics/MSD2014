task checktag();
integer i; 
begin 
foundway = 1'b0;

for(i = 0 ; (i < `WAY_SIZE) &&( foundway == 1'b0 ); i = i + 1)
begin
	$display("Entered For loop");
	if (tag_array[index][i] == tag && mesif_array[index][i] != invalid) begin 
		cachehit = 1'b1; 
		foundway = 1'b1;
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
		misscount = misscount+1'b1;
	end
 end 
 endtask