module VGA_adaptive
(
				input 	    clk_50m,
				input 		 rst_n,
				
  				output 		 vga_sync_n,
  				output 		 vga_blank_n,
				output 		 vga_clk,
				output 		 vga_hsync,
				output 		 vga_vsync,
				output [7:0] vga_r,
				output [7:0] vga_g,
				output [7:0] vga_b
);	
	
	
	wire clk_ref;
	wire sys_rst_n;
	
	
	
	
	
	PLL_0002 uo (
		.refclk   (clk_50m),   //  refclk.clk
		.rst      (!rst_n),      //   reset.reset
		.outclk_0 (clk_ref), // outclk0.clk
		.locked   ()          // (terminated)
	);
	
	wire	clk_vga = clk_ref;


	wire	[11:0]	vga_xpos;	
	wire	[11:0]	vga_ypos;		
	wire	[23:0]	vga_data;	


	vga_driver  u1
	(
		.clk_25m      (clk_vga),
		.rst_n        (rst_n),
		.vga_data     (vga_data),
						
		.vga_dclk     (vga_clk),
		.vga_sync     (vga_sync_n),
		.vga_blank    (vga_blank_n),
		.vga_hs       (vga_hsync),
		.vga_vs       (vga_vsync),	
		.vga_en       (), 
		.vga_rgb      ({vga_r,vga_g,vga_b}),
		.vga_request  (),
		.vga_xpos     (vga_xpos),  
      .vga_ypos     (vga_ypos)
	);
	
	vga_display u2
	(
		.clk_25m      (vga_clk),
		.rst_n        (rst_n),
		.vga_xpos     (vga_xpos),
		.vga_ypos     (vga_ypos),
							
		.vga_data     (vga_data) 
							
	);
	
	
	

endmodule