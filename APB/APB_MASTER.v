 module APB_MASTER(PCLK,PRESETn,transfer,READ_WRITE,apb_write_paddr,apb_write_data,apb_read_paddr,apb_read_data_out,paddr,pwdata,prdata,PENABLE,PWRITE,PREADY,psel1,psel2,PSLVRR);
// defaults  READ-> READ_WRITE=1 , WRITE -> READ_WRITE=0;

input PCLK,PRESETn,READ_WRITE,PREADY,transfer;

input [7:0] apb_write_data,prdata;

input [8:0] apb_write_paddr,apb_read_paddr;

output psel1,psel2;

output reg [7:0] apb_read_data_out,pwdata;

output reg [8:0] paddr;

output PSLVRR,PWRITE,PENABLE;

parameter IDEAL  = 2'd0,
          SETUP  = 2'd1,
          ACCESS = 2'd2;

reg [1:0] current_state=IDEAL,next_state;

// error_flags

reg setup_error,
    apb_read_add_error,
    apb_write_add_error,
	 apb_rw_error,
    apb_write_data_error;


// assignment 

assign PWRITE=READ_WRITE;

assign PENABLE=current_state==ACCESS?1:0;

assign {psel1,psel2}=(current_state!=IDEAL)?(paddr[8]?2'b10:2'b01):2'b0;

assign PSLVRR = setup_error||apb_read_add_error||apb_write_add_error||apb_write_data_error||apb_rw_error;

always@(posedge PCLK or posedge PRESETn)
begin

if(PRESETn)
begin

current_state=IDEAL;

end

else
begin

current_state=next_state;

end
end

always@(current_state or transfer or PREADY or PSLVRR)
begin

case(current_state)

IDEAL :
       begin
if(transfer)
  next_state=SETUP;
else
  next_state=IDEAL;

end

SETUP :
       begin

		 
if(READ_WRITE)
begin

paddr=apb_read_paddr;

end

else
begin

paddr=apb_write_paddr;
pwdata=apb_write_data;
end
		 
		 
if(!PSLVRR)
next_state=ACCESS;
else
next_state=SETUP;

end

ACCESS :
       begin

if(!transfer&&PREADY&&!PSLVRR)
begin

next_state=IDEAL;

if(READ_WRITE)
begin

apb_read_data_out=prdata;

end

end

else if((transfer)&(PREADY)&(!PSLVRR))
begin

next_state=SETUP;

if(READ_WRITE)
begin

apb_read_data_out=prdata;

end

end

else

next_state=ACCESS;

       end

default :
       begin

next_state=IDEAL;
end

endcase

end

// Logic Design for PSLVVR

always@(posedge PCLK or posedge PRESETn)
begin

if(PRESETn)
begin


    {setup_error,
    apb_read_add_error,
    apb_write_add_error,
	 apb_rw_error,
    apb_write_data_error}=5'd0;


end

else
begin

if(current_state==IDEAL&&next_state==ACCESS)
      setup_error=1'd1;
else  setup_error=1'd0;

if(READ_WRITE===1'dz||READ_WRITE===1'dx)
      apb_rw_error=1'd1;
else  apb_rw_error=1'd0;		

if(READ_WRITE&&(apb_read_paddr===9'dx||apb_read_paddr===9'dz))
       apb_read_add_error=1'b1;
else	 apb_read_add_error=1'd0;

if(!READ_WRITE&&(apb_write_paddr===9'dx||apb_write_paddr===9'dz)&&(current_state==ACCESS||current_state==SETUP))
     apb_write_add_error=1'b1;
else apb_write_add_error=1'd0;

if(!READ_WRITE&&(apb_write_data===8'dx||apb_write_data===8'dz))
     apb_write_data_error=1'd1;
else apb_write_data_error=1'd0;


if(current_state==SETUP)
begin

if(READ_WRITE&&(paddr!=apb_read_paddr))
setup_error=1'd1;
else if((!READ_WRITE)&&(paddr!=apb_write_paddr)&&(pwdata!=apb_write_data))
setup_error=1'd1;
else
setup_error=1'd0;

end

end



end


endmodule 
