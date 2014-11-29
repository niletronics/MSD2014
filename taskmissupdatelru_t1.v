 
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
