`timescale 1 ns/1 ps

  module sigma11_tb;
	reg [31:0] x;
	wire [31:0] y;
  sigma1 u1(
	.x(x),
	.y(y)
  );
   initial begin
        x = 32'b00000000000000000011111111111111;
   end
  endmodule