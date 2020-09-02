`timescale 1 ns/1 ps

  module majority_tb;
	reg [31:0] x;
	reg [31:0] y;
	reg [31:0] z;
	wire [31:0] o;
  majority u1(
	.x(x),
	.y(y),
	.z(z),
	.o(o)
  );
   initial begin
        x = 32'b00000000111111110000000011111111;
        y = 32'b00000000000000000011111111111111;
        z = 32'b11111111111111110000000000000000;
   end
  endmodule