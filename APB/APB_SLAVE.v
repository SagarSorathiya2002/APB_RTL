module APB_SLAVE( PCLK,PRESETn,PSEL,PENABLE,READ_WRITE,paddr,apb_write_data,prdata,PREADY);

input PCLK,PRESETn,PSEL,PENABLE,READ_WRITE;

input [7:0] paddr,apb_write_data;

output reg [7:0] prdata;

output reg PREADY;

//memory 

reg [7:0] address ;
reg [7:0] data [255:0];

always@(posedge PCLK or posedge PRESETn)
begin

if(PRESETn)
begin

PREADY=1'd0;

end

else
begin

case({PSEL,PENABLE,READ_WRITE})

3'b110 : 
        begin
		  data[paddr]=apb_write_data;
		  PREADY=1'd1;
        end	
3'b111 : 
        begin
        prdata=data[paddr];
        PREADY=1'd1;
        end		  

default : PREADY=1'd0;		  
		  
endcase

end


end

endmodule 