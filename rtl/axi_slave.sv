module slave #(parameter ADDR_WIDTH=32,DATA_WIDTH=8)(axi_interface.slave intf);

    logic [DATA_WIDTH -1 : 0] mem [0:255];

    logic [ADDR_WIDTH - 1 : 0] wr_addr;
    logic [ADDR_WIDTH - 1 : 0] rd_addr;

    typedef enum bit [2:0] {widel,waddr_dec, wstart,wreadys,wlast_st}wstate_t;
    typedef enum bit [1:0] {bidle,bvalids,bwait}bstate_t;
    typedef enum bit [2:0] {ridel,raddr_dec,rvalids,rlast_st} rstate_t;

    wstate_t wstate, wnext_state;
    bstate_t bstate, bnext_state;
    rstate_t rstate, rnext_state;

    logic [ADDR_WIDTH - 1 :0] nextaddr, nextaddr_next;
    logic [ADDR_WIDTH - 1 :0] retaddr, retaddr_next;
    logic [3:0] wlen_count,wlen_count_next;
    logic       first, first_next;
    logic [7:0] boundary_wr, boundary_wr_next;

    logic [ADDR_WIDTH - 1 :0] rdnextaddr, rdnextaddr_next;
    logic [ADDR_WIDTH - 1 :0] rdretaddr, rdretaddr_next;
    logic [3:0] rdlen_count, rdlen_count_next;
    logic [7:0] boundary_rd,boundary_rd_next;

    function automatic [31:0] data_fixed_wr(input [31:0] addr,input [31:0] wdata_i,input [3:0] wstrb);
        begin
            for(int i=0;i<4;i++)begin
                if(wstrb[i])
                    mem[addr + i] = wdata_i[8*i +: 8];
            end
            return addr;
        end
    endfunction
        
    function automatic [31:0] data_incr_wr(input [31:0] addr,input [31:0] wdata_i,input [3:0] wstrb,input [2:0] wsize);
        begin
            for(int i=0;i<4;i++)begin
                if(wstrb[i])
                    mem[addr + i] = wdata_i[8*i +: 8];
            end
            return addr +(1 << wsize);
        end
    endfunction

    function automatic [31:0] data_wrap_wr(input [31:0] addr,input [31:0] wdata_i,input [3:0] wstrb,input [7:0] boundary,input [3:0] wsize);
        logic [31:0] next_addr;
        begin
            for(int i=0;i<4;i++) if(wstrb[i]) mem[addr + i] = wdata_i[8*i +: 8];
            next_addr = addr + (1 << wsize);
            if((next_addr & (boundary -1) ) == 0)
                next_addr = addr - boundary + (1 << wsize);
            return next_addr;
        end
    endfunction

    function automatic [31:0] data_fixed_rd (input addr);
        begin
            intf.rdata = {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
            return addr;
        end
    endfunction
        
    function automatic [31:0] data_incr_rd (input addr,input [2:0] rsize);
        begin
            intf.rdata = {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
            return addr + ( 1 << rsize);
        end
    endfunction

    function automatic [31:0] data_wrap_rd (input addr,input [7:0] boundary,input [2:0] rsize);
        logic [31:0] next_addr;
        begin
            intf.rdata = {mem[addr+3],mem[addr+2],mem[addr+1],mem[addr]};
            next_addr = addr + ( 1 << rsize);
            if ((next_addr & (boundary - 1))==0)
                next_addr = addr - boundary + (1 << rsize);
            return next_addr;
        end
    endfunction

    function automatic [7:0] wrap_boundary (input [7:0] len, input [2:0] size);
        case(len)
            4'd1 : wrap_boundary = 2 * ( 1 << size );
            4'd3 : wrap_boundary = 4 * ( 1 << size );
            4'd7 : wrap_boundary = 8 * ( 1 << size );
            4'd15: wrap_boundary = 16 * ( 1 << size );
            default : wrap_boundary = (len + 1) * (1 << size);
        endcase
    endfunction   

    always_ff @(posedge intf.clk or negedge intf.rst_n)begin
        if(!intf.rst_n)begin
            wstate      <= widel;
            nextaddr    <= 0;
            retaddr     <= 0;
            wlen_count  <= 0;
            first       <= 0;
            boundary_wr <= 0;
        end
        else begin
            wstate      <= wnext_state;
            nextaddr    <= nextaddr_next;
            retaddr     <= retaddr_next;
            wlen_count  <= wlen_count_next;
            first       <= first_next;
            boundary_wr <= boundary_wr_next;
        end
    end

    always_comb begin
        wnext_state      = wstate;
        intf.wready      = 0;
        nextaddr_next    = nextaddr;
        retaddr_next     = retaddr;
        wlen_count_next  = wlen_count;
        first_next       = first;
        boundary_wr_next = boundary_wr;

        case(wstate)
            widel : if(intf.awvalid) begin  
                first_next = 0;
                wlen_count_next = 0;
                wnext_state = waddr_dec;
            end

            waddr_dec : begin
                if(!first) begin
                    nextaddr_next = intf.awaddr;
                    first_next = 1;
                end
                intf.wready = 1;
                if(intf.wvalid) wnext_state = wstart;
                end
            wstart : if(intf.wvalid) begin
                case(intf.awburst)
                    2'b00 : retaddr_next = data_fixed_wr(nextaddr,intf.wdata,intf.wstrb);
                    2'b01 : retaddr_next = data_incr_wr(nextaddr,intf.wdata,intf.wstrb,intf.awsize);
                    2'b10 : begin
                        boundary_wr_next = wrap_boundary(intf.awlen,intf.awsize);
                        retaddr_next = data_wrap_wr(nextaddr,intf.wdata,intf.wstrb,boundary_wr_next,intf.awsize);
                    end
                endcase
                nextaddr_next = retaddr_next;
                wlen_count_next = wlen_count + 1;
                intf.wready = 1;
                wnext_state = (intf.wlast || (wlen_count_next == intf.awlen)) ? wlast_st : wreadys;
                end
            wreadys : if(intf.wvalid) begin
                intf.wready = 1;
                case(intf.awburst)
                     2'b00 : retaddr_next = data_fixed_wr(nextaddr,intf.wdata,intf.wstrb);
                    2'b01 : retaddr_next = data_incr_wr(nextaddr,intf.wdata,intf.wstrb,intf.awsize);
                    2'b10 : begin
                        boundary_wr_next = wrap_boundary(intf.awlen,intf.awsize);
                        retaddr_next = data_wrap_wr(nextaddr,intf.wdata,intf.wstrb,boundary_wr_next,intf.awsize);
                    end
                endcase
                nextaddr_next = retaddr_next;
                wlen_count_next = wlen_count + 1;
                if( intf.wlast || (wlen_count_next == intf.awlen)) wnext_state = wlast_st;
                end
            wlast_st : begin
                intf.wready     = 0;
                wlen_count_next = 0;
                first_next      = 0;
                wnext_state     = widel;
                end
        endcase
    end

    always_comb begin
        intf.awready = 1'b0;

        if(wstate == widel && intf.awvalid) begin
            intf.awready = 1'b1;
        end
        else if(wstate != widel)
        intf.awready = 1'b0;
    end

    always_ff @(posedge intf.clk or negedge intf.rst_n) begin
        if(!intf.rst_n)
            bstate <= bidle;
        else begin
            bstate <= bnext_state;
        end
    end

    always_comb begin
        bnext_state = bstate;
        intf.bvalid = 0;
        intf.bid    = intf.wid;
        intf.bresp  = 2'b00;
        case(bstate)
            bidle : if(wstate == wlast_st) bnext_state = bvalids;
            bvalids : begin
                intf.bvalid = 1;
                intf.bresp  = (intf.awsize > 3'b010) ? 2'b10 : 2'b00;
                if(intf.bready) bnext_state = bidle;
                else bnext_state = bvalids;
                end
            bwait : if(!intf.bready) bnext_state = bidle;
        endcase
    end


    always_ff @(posedge intf.clk or negedge intf.rst_n) begin
        if(!intf.rst_n) begin
            rstate      <= ridel;
            rdnextaddr  <= 0;
            rdretaddr   <= 0;
            rdlen_count <= 0;
            boundary_rd <= 0;
        end
        else begin
            rstate      <= rnext_state;
            rdnextaddr  <= rdnextaddr_next;
            rdretaddr   <= rdretaddr_next;
            rdlen_count <= rdlen_count_next;
            boundary_rd <= boundary_rd_next;
        end
    end

    always_comb begin
        rnext_state      = rstate;
        intf.rvalid      = 0;
        intf.rlast       = 0;
        intf.arready     = (rstate == ridel);
        intf.rid         = intf.arid;
        intf.rresp       = 2'b00;
        rdnextaddr_next    = rdnextaddr;
        rdretaddr_next     = rdretaddr;
        rdlen_count_next  = rdlen_count;
        boundary_rd_next = boundary_rd;

        case(rstate)
            ridel : if(intf.arvalid) begin  
                rdnextaddr_next = intf.araddr;
                rdlen_count_next = 0;
                rnext_state = raddr_dec;
            end
            raddr_dec : if(intf.rready) begin
                intf.rvalid = 1;
                case(intf.arburst)
                    2'b00 : rdretaddr_next = data_fixed_rd(rdnextaddr);
                    2'b01 : rdretaddr_next = data_incr_rd (rdnextaddr,intf.arsize);
                    2'b10 : begin
                        boundary_rd_next = wrap_boundary(intf.arlen,intf.arsize);
                        rdretaddr_next   = data_wrap_rd (rdnextaddr, boundary_rd_next, intf.arsize);
                    end
                endcase
                rdnextaddr_next  = rdretaddr_next;
                rdlen_count_next = rdlen_count + 1;
                rnext_state      = (rdlen_count == intf.arlen) ? rlast_st : rvalids;
            end
            rvalids : if(intf.rready) begin
                intf.rvalid = 1;
                case(intf.arburst)
                     2'b00 : rdretaddr_next = data_fixed_rd(rdnextaddr);
                    2'b01 : rdretaddr_next = data_incr_rd (rdnextaddr,intf.arsize);
                    2'b10 : begin
                        boundary_rd_next = wrap_boundary(intf.arlen,intf.arsize);
                        rdretaddr_next   = data_wrap_rd (rdnextaddr, boundary_rd_next, intf.arsize);
                    end
                endcase
                rdnextaddr_next  = rdretaddr_next;
                rdlen_count_next = rdlen_count + 1;
                if(rdlen_count_next == intf.arlen - 1) rnext_state = rlast_st;
            end
            rlast_st : begin
                intf.rvalid     = 1;
                intf.rlast      = 1;
                if(intf.rready)begin
                    rdlen_count_next = 0;
                    rnext_state      = ridel;
                end
            end
        endcase
    end
endmodule