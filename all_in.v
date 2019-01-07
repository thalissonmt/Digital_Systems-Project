module all_in (infra,CLK,A0, A1, B0, B1, C0, C1, C2, signA, signB, signC);

input infra, CLK;
output [6:0] A1, A0, B1, B0, C1, C2, C0;
reg [6:0] A1, A0, B1, B0, C1, C2, C0;
output signA, signB, signC;
reg signA, signB, signC;

parameter [3:0] wait_for_command=4'b0000, preA=4'b0001, Aedit1=4'b0010, Aedit2=4'b0011, preB=4'b0100, Bedit1=4'b0101;
parameter [3:0] Bedit2=4'b0110, zerar_tudo=4'b0111, soma_sub=4'b1000;
parameter [6:0] desligado = 7'b1111111, zero = 7'b0000001, um = 7'b1001111, dois = 7'b0010010, tres = 7'b0000110, quatro = 7'b1001100; 
parameter [6:0] cinco = 7'b0100100, seis = 7'b0100000, sete = 7'b0001111, oito = 7'b0000000, nove = 7'b0000100;
parameter wait_until = 5000000;

reg [2:0] estado;
reg [2:0] prev_estado;
reg [1:0] pos;
reg [7:0] key;
reg [7:0] A, B;
integer result,result_temp, A_temp, B_temp;
reg [30:0] count;
wire [7:0] fio;
wire key_ok;
reg flag, flag_on, soma, from_a, from_b;

decoder hope(.clk(CLK), .infra_vr(infra), .done(key_ok), .key(fio));

initial estado = wait_for_command;
initial A0 = desligado;
initial A1 = desligado;
initial B0 = desligado;
initial B1 = desligado;
initial C0 = desligado;
initial C1 = desligado;
initial C2 = desligado;
initial flag_on = 0;
initial flag = 0;
initial soma = 1;
initial from_a =  0;
initial from_b = 0;

always @(posedge CLK) begin
	key <= fio;

	if(flag)begin
		count <= count + 1;
		if(count == wait_until) begin
			count <= 0;
			flag <=0;
			estado <= prev_estado;
		end

	end else begin
		count<=0;
		flag <=0;

		if(key_ok==1) begin
	
			if(key==8'h12 && flag_on==0) begin
				flag_on <= ~flag_on;
				A0 <= zero;
				A1 <= zero;
				B0 <= zero;
				B1 <= zero;
				flag <= 1;
				prev_estado <= wait_for_command;

			end else if(key==8'h12 && flag_on==1) begin
				flag_on <= ~flag_on;
				A0 <= desligado;
				A1 <= desligado;
				B0 <= desligado;
				B1 <= desligado;
				A <= 0;
				B <= 0;
				signA <= 0;
				signB <= 0;
				flag <= 1;
				prev_estado <= wait_for_command;
			end

			if(flag_on==1) begin	

				case(estado)
					wait_for_command:begin
						
		            	if(key==8'hF)begin //editar A
		            		flag <= 1;
		            		A0 <= zero;
							A1 <= zero;
							signA <= 0;
							from_a <= 0;
							from_b <= 0;
							A <= 0;
							prev_estado <= Aedit1;
		            	end
		            	if(key==8'h13)begin //editar B
		            		flag <= 1;
		            		B <= 0;
							B0 <= zero;
							B1 <= zero;
							signB <= 0;
							from_a <= 0;
							from_b <= 0;
							prev_estado <= Bedit1;
		            	end
		            	if(key==8'h10)begin //zerar A B C
							flag <= 1;
							A0 <= zero;
							A1 <= zero;
							B0 <= zero;
							B1 <= zero;
							A <= 0;
							B <= 0;
							signB <= 0;
							signA <= 0;
							from_a <= 0;
							from_b <= 0; 
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'h1A)begin //sum
							flag <= 1;
							soma <= 1;
							from_a <= 0;
							from_b <= 0;
						end
						if(key==8'h1E)begin //sub
							flag <= 1;
							soma <= 0;
							from_a <= 0;
							from_b <= 0;
						end
						
						if(key==8'hC && from_a==1)begin //Inverter sinal A
							signA <= ~signA;
							flag <= 1;
							from_a <= 1;
							from_b <= 0;
							prev_estado <= wait_for_command;
						end
						
						if(key==8'hC && from_b)begin //Inverter B
							signB <= ~signB;
							flag <= 1;
							from_a <= 0;
							from_b <= 1;
							prev_estado <= wait_for_command;
						end
						
					end// do wait_for_command

					Aedit1:begin

						if(key==8'hC && signA==1'b0)begin //Inverter sinal A
							signA <= 1'b1;
							flag <= 1;
							prev_estado <= Aedit1;
						end else if(key==8'hC && signA==1'b1)begin //Inverter sinal A
							signA <= 1'b0;
							flag <= 1;
							prev_estado <= Aedit1;
						end
						
						if(key==8'd0)begin
							flag <= 1;
							A <= A + 8'd0;
							A0 <= zero;
							prev_estado <= Aedit2;
						end
						if(key==8'd1)begin
							flag <= 1;
							A <= A + 8'd10;
							prev_estado <= Aedit2;
							A0 <= um;
						end
						if(key==8'd2)begin
							flag <= 1;
							A <= A + 8'd20;
							prev_estado <= Aedit2;
							A0 <= dois;
						end
						if(key==8'd3)begin
							flag <= 1;
							A <= A + 8'd30;
							prev_estado <= Aedit2;
							A0 <= tres;
						end
						if(key==8'd4)begin
							flag <= 1;
							A <= A + 8'd40;
							prev_estado <= Aedit2;
							A0 <= quatro;
						end
						if(key==8'd5)begin
							flag <= 1;
							A <= A + 8'd50;
							prev_estado <= Aedit2;
							A0 <= cinco;
						end
						if(key==8'd6)begin
							flag <= 1;
							A <= A + 8'd60;
							prev_estado <= Aedit2;
							A0 <= seis;
						end
						if(key==8'd7)begin
							flag <= 1;
							A <= A + 8'd70;
							prev_estado <= Aedit2;
							A0 <= sete;
						end
						if(key==8'd8)begin
							flag <= 1;
							A <= A + 8'd80;
							prev_estado <= Aedit2;
							A0 <= oito;
						end
						if(key==8'd9)begin
							flag <= 1;
							A <= A + 8'd90;
							prev_estado <= Aedit2;
							A0 <= nove;
						end					

					end // do Adit1

					Aedit2: begin

						if(key==8'hC && signA==1'b0)begin //Inverter sinal A
							signA <= 1'b1;
							flag <= 1;
							prev_estado <= Aedit2;
						end else if(key==8'hC && signA==1'b1)begin //Inverter sinal A
							signA <= 1'b0;
							flag <= 1;
							prev_estado <= Aedit2;
						end
						
						if(key==8'd0)begin
							A1 <= zero;
							flag <= 1;
							A <= A + 8'd0;
							prev_estado <= wait_for_command;
						end
						if(key==8'd1)begin
							A1 <= um;
							flag <= 1;
							A <= A + 8'd1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd2)begin
							A1 <= dois;
							flag <= 1;
							A <= A + 8'd2;
							prev_estado <= wait_for_command;
						end
						if(key==8'd3)begin
							A1 <= tres;
							flag <= 1;
							A <= A + 8'd3;
							prev_estado <= wait_for_command;
						end
						if(key==8'd4)begin
							A1 <= quatro;
							flag <= 1;
							A <= A + 8'd4;
							prev_estado <= wait_for_command;
						end
						if(key==8'd5)begin
							A1 <= cinco;
							flag <= 1;
							A <= A + 8'd5;
							prev_estado <= wait_for_command;
						end
						if(key==8'd6)begin
							A1 <= seis;
							flag <= 1;
							A <= A + 8'd6;
							prev_estado <= wait_for_command;
						end
						if(key==8'd7)begin
							A1 <= sete;
							flag <= 1;
							A <= A + 8'd7;
							prev_estado <= wait_for_command;
						end
						if(key==8'd8)begin
							A1 <= oito;
							flag <= 1;
							A <= A + 8'd8;
							prev_estado <= wait_for_command;
						end
						if(key==8'd9)begin
							A1 <= nove;
							flag <= 1;
							A <= A + 8'd9;
							prev_estado <= wait_for_command;
						end
						
						from_a <= 1;
						from_b <= 0;
						
					end // do Aedit2
					
					Bedit1:begin
						if(key==8'hC && signB==1'b0)begin
							signB <= 1'b1;
							flag <= 1;
							prev_estado <= Bedit1;
						end else if(key==8'hC && signB==1'b1)begin
							signB <= 1'b0;
							flag <= 1;
							prev_estado <= Bedit1;
						end

						if(key==8'd0)begin
							B0 <= zero;
							B <= B + 8'd0;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd1)begin
							B0 <= um;
							B <= B + 8'd10;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd2)begin
							B0 <= dois;
							B <= B + 8'd20;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd3)begin
							B0 <= tres;
							B <= B + 8'd30;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd4)begin
							B0 <= quatro;
							B <= B + 8'd40;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd5)begin
							B0 <= cinco;
							B <= B + 8'd50;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd6)begin
							B0 <= seis;
							B <= B + 8'd60;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd7)begin
							B0 <= sete;
							B <= B + 8'd70;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd8)begin
							B0 <= oito;
							B <= B + 8'd80;
							flag <= 1;
							prev_estado <= Bedit2;
						end
						if(key==8'd9)begin
							B0 <= nove;
							B <= B + 8'd90;
							flag <= 1;
							prev_estado <= Bedit2;
						end	

					end // do Bedit1;			

					Bedit2: begin
						
						if(key==8'd0)begin
							B1 <= zero;
							B <= B + 8'd0;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd1)begin
							B1 <= um;
							B <= B + 8'd1;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd2)begin
							B1 <= dois;
							B <= B + 8'd2;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd3)begin
							B1 <= tres;
							B <= B + 8'd3;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd4)begin
							B1 <= quatro;
							B <= B + 8'd4;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd5)begin
							B1 <= cinco;
							B <= B + 8'd5;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd6)begin
							B1 <= seis;
							B <= B + 8'd6;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd7)begin
							B1 <= sete;
							B <= B + 8'd7;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd8)begin
							B1 <= oito;
							B <= B + 8'd8;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						if(key==8'd9)begin
							B1 <= nove;
							B <= B + 8'd9;
							flag <= 1;
							prev_estado <= wait_for_command;
						end
						
						from_a <= 0;
						from_b <= 1;
						
					end //do Bedit2
								
				endcase //do case(estado)

			end //if(flag_on==1)

		end // do if(key_ok==1)

	end // do else flag

end // do always

always @(posedge CLK) begin

	if(flag_on==1) begin
		

		if(signA==1) begin
			A_temp = -A;
		end else begin
			A_temp = A;
		end
		if(signB==1) begin
			B_temp = -B;
		end else begin
			B_temp = B;
		end

		if(soma) begin
			result = A_temp + B_temp;
		end else begin
			result = A_temp - B_temp;
		end

		if(result<0) begin
			result = -result;
			signC = 1;
		end else begin
			signC = 0;
		end

		result_temp = result;

		if((result_temp%10)==0) begin
			C2 <= zero;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==1) begin
			C2 <= um;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==2) begin
			C2 <= dois;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==3) begin
			C2 <= tres;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==4) begin
			C2 <= quatro;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==5) begin
			C2 <= cinco;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==6) begin
			C2 <= seis;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==7) begin
			C2 <= sete;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==8) begin
			C2 <= oito;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==9) begin
			C2 <= nove;
			result_temp = result_temp/10;
		end

		if((result_temp%10)==0) begin
			C1 <= zero;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==1) begin
			C1 <= um;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==2) begin
			C1 <= dois;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==3) begin
			C1 <= tres;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==4) begin
			C1 <= quatro;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==5) begin
			C1 <= cinco;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==6) begin
			C1 <= seis;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==7) begin
			C1 <= sete;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==8) begin
			C1 <= oito;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==9) begin
			C1 <= nove;
			result_temp = result_temp/10;
		end

		if((result_temp%10)==0) begin
			C0 <= zero;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==1) begin
			C0 <= um;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==2) begin
			C0 <= dois;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==3) begin
			C0 <= tres;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==4) begin
			C0 <= quatro;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==5) begin
			C0 <= cinco;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==6) begin
			C0 <= seis;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==7) begin
			C0 <= sete;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==8) begin
			C0 <= oito;
			result_temp = result_temp/10;
		end else if ((result_temp%10)==9) begin
			C0 <= nove;
			result_temp = result_temp/10;
		end

	end else begin
		C0 <= desligado;
		C1 <= desligado;
		C2 <= desligado;
		signC <= 0;
	end
end

endmodule