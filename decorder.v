module decoder(clk, infra_vr, done, key);

parameter infinity_high_dur = 262143; // time_count - 262143*0.02us = 5.24ms, tempo do state 'read' para 'infinity'
parameter lead_low_dur = 230000; // lead_low_count - 230000*0.02us = 4.60ms, tempo do state 'infinity' para 'lead'
parameter lead_high_dur = 210000; // lead_high_count - 210000*0.02us = 4.20ms, 4.5-4.2 = 0.3ms < is_a_bit = 0.4ms, tempo do state 'lead' para 'read'
parameter read_high_dur = 41500; // time_count - 41500 *0.02us = 0.83ms, tempo no pos edge do infra_vr para saber se é 1
parameter is_a_bit = 20000; // time_count - 20000 *0.02us = 0.4ms, tempo para informar que está recebendo 1 bit;

parameter infinity = 2'b00;    //sempre em high
parameter lead = 2'b01;    //9ms em low e 4.5 ms em high
parameter read = 2'b10;    //0.6ms em low, 0.52ms em high é 0 e 1.66ms em high é 1, 32bit no total.

input clk; 
input infra_vr;     
output done;
output [7:0] key;

reg [7:0] key;                
reg [7:0] key_temp;             
reg [7:0] data; 
reg [7:0] data_inverse; 
reg [15:0] trash;                
reg [17:0] lead_low_count;           
reg [17:0] lead_high_count;          
reg [17:0] time_count;           
reg [5:0] pos;             
reg [1:0] state;                
reg lead_low_bool;
reg lead_high_bool;      
reg time_count_bool;  
reg done_bool;          
reg data_ready, done;          
	
//assign done = data_ready;
initial done = 0;
initial done_bool = 0;

always @(posedge clk) 
	case (state)
 	   	infinity: begin
 	   		if (lead_low_count > lead_low_dur) begin 
 	   			 state <= lead; 
 	   		end       
 	   	end 
		lead: begin
			if (lead_high_count > lead_high_dur) begin
				state <= read;
			end  	
		end 
		read: begin
			if ((time_count >= infinity_high_dur) || (pos >= 33)) begin
				state <= infinity;
			end  	
		end 
	    default: begin
	    	state <= infinity; 
	    end
	endcase

always @(posedge clk) begin
		if (lead_low_bool)   
			 lead_low_count <= lead_low_count + 1'b1;
		else  
			 lead_low_count <= 0;	      	      		 	

	  	if ((state == infinity) && !infra_vr)
			 lead_low_bool <= 1'b1;
		else                           
			 lead_low_bool <= 1'b0;		     		 	
      
	  	if (lead_high_bool)   
			 lead_high_count <= lead_high_count + 1'b1;
		else  
			 lead_high_count <= 0;	          		 	

	  	if ((state == lead) && infra_vr)
			 lead_high_bool <= 1'b1;
		else  
			 lead_high_bool <= 1'b0;     		 	

	 	if(time_count_bool)     
			 time_count <= time_count + 1'b1;
		else 
			 time_count <= 1'b0;   

	 	if ((state == read) && infra_vr)
			 time_count_bool <= 1'b1;  
		else
			 time_count_bool <= 1'b0; 

end

always @(posedge clk) begin
    	
	if (state == read) begin
		if (time_count == is_a_bit)
				pos <= pos + 1'b1;
	end else
     	pos <= 6'b0;

	if (state == read) begin
		 if (time_count >= read_high_dur && pos <= 16) begin
			trash[pos-1'b1] <= 1'b1; 

		 end else if (time_count >= read_high_dur && pos <= 24) begin
		 	data[pos-17] <= 1'b1; 

		 end else if (time_count >= read_high_dur) begin
		 	data_inverse[pos-25] <= 1'b1; 

		 end

	end else begin
		data <= 0;
		data_inverse <= 0;
		trash <= 0;
	end
end
	
always @(posedge clk) begin

	if (pos == 32) begin
		if (data_inverse[7:0] == ~data[7:0]) begin		
			key_temp <= data;     
			data_ready <= 1'b1;  
		end	else
			data_ready <= 1'b0 ; 
	end else
		data_ready <= 1'b0 ;

	if(done_bool==1) begin
		done <= 1;
		done_bool <= 0;
	end else
		done <= 0;
	if (data_ready) begin
	    key <= key_temp; 
	    done_bool <= 1;
	end
	
end
					
endmodule
