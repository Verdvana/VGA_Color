`include "vga_para.v"
//---------------------------------------------------------------------------

module vga_driver
(
						input    		 clk_25m,      //25M时钟
						input    		 rst_n,
						input   [23:0]  vga_data,
						
						output			 vga_dclk,   	//VGA 时钟
						output			 vga_blank,		//VGA 空白
						output			 vga_sync,		//VGA 显示同步
						output			 vga_hs,	    	//VGA 行同步
						output			 vga_vs,	    	//VGA 场同步
						output			 vga_en,			//VGA 显示使能
						output  [23:0]	 vga_rgb,		//VGA 显示数据

						output			 vga_request,	//VGA 图像数据请求（提前一个时钟）
						output  [11:0]  vga_xpos,		//VGA 水平座标   （提前一个时钟）
						output  [11:0]	 vga_ypos      //VGA 垂直座标   （提前一个时钟）
						 
						
						
);

//------------------------------------------
//行扫描计数
reg [11:0] hcnt; 
always @ (posedge clk_25m or negedge rst_n)
begin
	if (!rst_n)
		hcnt <= 12'd0;
	else
		begin
        if(hcnt < `H_TOTAL - 1'b1)		//line over			
            hcnt <= hcnt + 1'b1;
        else
            hcnt <= 12'd0;
		end
end 
assign	vga_hs = (hcnt <= `H_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
//列扫描计数
reg [11:0] vcnt;
always@(posedge clk_25m or negedge rst_n)
begin
	if (!rst_n)
		vcnt <= 12'b0;
	else if(hcnt == `H_TOTAL - 1'b1)		//line over
		begin
		if(vcnt < `V_TOTAL - 1'b1)		//frame over
			vcnt <= vcnt + 1'b1;
		else
			vcnt <= 12'd0;
		end
end
assign	vga_vs = (vcnt <= `V_SYNC - 1'b1) ? 1'b0 : 1'b1;

//------------------------------------------
//控制信号
assign	vga_dclk = ~clk_25m;
assign	vga_blank = vga_hs & vga_vs;		
assign	vga_sync = 1'b0;


//-----------------------------------------
assign	vga_en		=	(hcnt >= `H_SYNC + `H_BACK  && hcnt < `H_SYNC + `H_BACK + `H_DISP) && (vcnt >= `V_SYNC + `V_BACK  && vcnt < `V_SYNC + `V_BACK + `V_DISP) ? 1'b1 : 1'b0;
assign	vga_rgb 	= 	vga_en ? vga_data : 24'h000000;	//ffffff;



//------------------------------------------
//
localparam	H_AHEAD = 	12'd1;
assign	vga_request	=	(hcnt >= `H_SYNC + `H_BACK - H_AHEAD && hcnt < `H_SYNC + `H_BACK + `H_DISP - H_AHEAD) && (vcnt >= `V_SYNC + `V_BACK && vcnt < `V_SYNC + `V_BACK + `V_DISP)  ? 1'b1 : 1'b0;
//vga xpos & ypos
assign	vga_xpos	= 	vga_request ? (hcnt - (`H_SYNC + `H_BACK - H_AHEAD)) : 12'd0;
assign	vga_ypos	= 	vga_request ? (vcnt - (`V_SYNC + `V_BACK)) : 12'd0;
endmodule
