`ifndef CORE_ARITHMETIC_ADDERS_BRENT_KUNG_ADDER
`define CORE_ARITHMETIC_ADDERS_BRENT_KUNG_ADDER

// https://gist.github.com/ouwenshi/606ef1c0e53f63cf343617093f4c0e5e
module brent_kung_adder #(
  parameter INPUT_SIZE = 32,
  parameter GROUP_SIZE = 8 // This can be 1, 2, 4, 8
)(
  input  logic [INPUT_SIZE-1:0] A,
  input  logic [INPUT_SIZE-1:0] B,
  output logic [INPUT_SIZE  :0] S
);

	wire	[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]	r_temp;
	wire	[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]	r;
	wire	[INPUT_SIZE / GROUP_SIZE        :0]	cin;
	wire	[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]	q;
	
	assign cin[0] = 1'b0;
	
	generate
	for( genvar i = 0; i < INPUT_SIZE / GROUP_SIZE; i = i + 1) begin: parallel_FA_CLA_prefix
		group_q_generation #(.GROUP_SIZE(GROUP_SIZE))
		f(.a(A[GROUP_SIZE * (i + 1) - 1:GROUP_SIZE * i]),
		  .b(B[GROUP_SIZE * (i + 1) - 1:GROUP_SIZE * i]),
		  .cin(cin[i]),
		  .s(S[GROUP_SIZE * (i + 1) - 1:GROUP_SIZE * i]),
		  .qg(q[i * 2 + 1:i * 2]));
	end

	parallel_prefix_tree_first_half #(.TREE_SIZE(INPUT_SIZE / GROUP_SIZE))
	t1(.q(q[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]),
	   .r(r_temp[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]));
	parallel_prefix_tree_second_half #(.TREE_SIZE(INPUT_SIZE / GROUP_SIZE))
	t2(.q(r_temp[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]),
	   .r(r[INPUT_SIZE / GROUP_SIZE * 2 - 1:0]));
	
	for(genvar i = 0;i < INPUT_SIZE / GROUP_SIZE;i = i + 1) begin: cin_generation
		cin_generation_logic f(.r(r[2 * i + 1:2 * i]), .c0(1'b0), .cin(cin[i + 1]));
	end
	
	assign S[INPUT_SIZE] = cin[INPUT_SIZE / GROUP_SIZE];
	
	endgenerate
	
endmodule

module parallel_prefix_tree_first_half #(
  parameter TREE_SIZE = 4
)(
  input  logic [TREE_SIZE*2-1:0] q,
  output logic [TREE_SIZE*2-1:0] r
);
	
	generate
	if(TREE_SIZE == 2) begin: trival_case
		assign r[1:0] = q[1:0];
		prefix_logic f(.ql(q[1:0]),
                   .qh(q[3:2]),
                   .r(r[3:2]));
	end
	else begin: recursive_case
		wire	[TREE_SIZE * 2 - 1:0]	r_temp;
		parallel_prefix_tree_first_half #(.TREE_SIZE(TREE_SIZE / 2))
		recursion_lsbh(.q(q[TREE_SIZE - 1:0]),
					   .r(r_temp[TREE_SIZE - 1:0]));
		parallel_prefix_tree_first_half #(.TREE_SIZE(TREE_SIZE / 2))
		recursion_msbh(.q(q[TREE_SIZE * 2 - 1:TREE_SIZE]),
					   .r(r_temp[TREE_SIZE * 2 - 1:TREE_SIZE]));
		for(genvar i = 0;i < TREE_SIZE * 2;i = i + 2) begin: parallel_stitch_up
			if(i != TREE_SIZE * 2 - 2) begin: parallel_stitch_up_pass
				assign r[i + 1:i] = r_temp[i + 1:i];
			end
			else begin: parallel_stitch_up_produce
				prefix_logic f(.ql(r_temp[TREE_SIZE - 1:TREE_SIZE - 2]),
							   .qh(r_temp[TREE_SIZE * 2 - 1:TREE_SIZE * 2 - 2]),
							   .r(r[TREE_SIZE * 2 - 1:TREE_SIZE * 2 - 2]));
			end
		end
	end
	endgenerate
	
endmodule

module parallel_prefix_tree_second_half #(
  parameter TREE_SIZE = 4
)(
  input  logic [TREE_SIZE*2-1:0] q,
  output logic [TREE_SIZE*2-1:0] r
);
	
  wire	[TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 1) - 1:0]	r_temp;
	
	assign r_temp[TREE_SIZE * 2 - 1:0] = q[TREE_SIZE * 2 - 1:0];
	
	generate
	for(genvar i = 0;i < $clog2(TREE_SIZE) - 2;i = i + 1) begin: second_half_level
		assign r_temp[TREE_SIZE * 2 * (i + 1) + ((TREE_SIZE / (2 ** i)) - 1 - 2 ** ($clog2(TREE_SIZE / 4) - i)) * 2 - 1:TREE_SIZE * 2 * (i + 1)] = r_temp[TREE_SIZE * 2 * i + ((TREE_SIZE / (2 ** i)) - 1 - 2 ** ($clog2(TREE_SIZE / 4) - i)) * 2 - 1:TREE_SIZE * 2 * i];
		for(genvar j = (TREE_SIZE / (2 ** i)) - 1 - 2 ** ($clog2(TREE_SIZE / 4) - i);j < TREE_SIZE;j = j + 2 ** ($clog2(TREE_SIZE / 2) - i)) begin: second_half_level_logic
			prefix_logic f(.ql(r_temp[TREE_SIZE * 2 * i + (j - 2 ** ($clog2(TREE_SIZE / 4) - i)) * 2 + 1:TREE_SIZE * 2 * i + (j - 2 ** ($clog2(TREE_SIZE / 4) - i)) * 2]),
						   .qh(r_temp[TREE_SIZE * 2 * i + j * 2 + 1:TREE_SIZE * 2 * i + j * 2]),
						   .r(r_temp[TREE_SIZE * 2 * (i + 1) + j * 2 + 1:TREE_SIZE * 2 * (i + 1) + j * 2]));
			if(j != TREE_SIZE - 1 - 2 ** ($clog2(TREE_SIZE / 4) - i)) begin: second_half_level_direct_connect
				assign r_temp[TREE_SIZE * 2 * (i + 1) + (j + 2 ** ($clog2(TREE_SIZE / 2) - i)) * 2 - 1:TREE_SIZE * 2 * (i + 1) + j * 2 + 2] = r_temp[TREE_SIZE * 2 * i + (j + 2 ** ($clog2(TREE_SIZE / 2) - i)) * 2 - 1:TREE_SIZE * 2 * i + j * 2 + 2];
			end
		end
		assign r_temp[TREE_SIZE * 2 * (i + 2) - 1:TREE_SIZE * 2 * (i + 2) - (2 ** ($clog2(TREE_SIZE / 4) - i)) * 2] = r_temp[TREE_SIZE * 2 * (i + 1) - 1:TREE_SIZE * 2 * (i + 1) - (2 ** ($clog2(TREE_SIZE / 4) - i)) * 2];
	end
	assign r[1:0] = r_temp[TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + 1:TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2)];
	for(genvar i = 1;i < TREE_SIZE;i = i + 2) begin: final_r_odd
		assign r[i * 2 + 1:i * 2] = r_temp[TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + i * 2 + 1:TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + i * 2];
	end
	for(genvar i = 2;i < TREE_SIZE;i = i + 2) begin: final_r_even
		prefix_logic f(.ql(r_temp[TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + i * 2 - 1:TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + i * 2 - 2]),
					   .qh(r_temp[TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + i * 2 + 1:TREE_SIZE * 2 * ($clog2(TREE_SIZE) - 2) + i * 2]),
					   .r(r[i * 2 + 1:i * 2]));
	end
	endgenerate
	
endmodule

module group_q_generation #(
  parameter GROUP_SIZE = 8
)(
  input  logic [GROUP_SIZE-1:0] a,
  input  logic [GROUP_SIZE-1:0] b,
  input  logic                  cin,
  output logic [GROUP_SIZE-1:0] s,
  output logic [1:0]            qg
);
	
	wire	[2 * GROUP_SIZE - 1:0]	q;
	wire	[GROUP_SIZE - 1:0]	c;
	
	assign c[0] = cin;
	
	generate
	for(genvar i = 0;i < GROUP_SIZE;i = i + 1) begin: parallel_FA_CLA_prefix
		FA_CLA_prefix f(.a(a[i]),
						.b(b[i]),
						.cin(c[i]),
						.s(s[i]),
						.q(q[i * 2 + 1:i * 2]));
		if(i != GROUP_SIZE - 1)begin: special_case
			assign c[i + 1] = q[i * 2 + 1] | q[i * 2] & c[i];
		end
	end
	
	//group q generation based on the GROUP_SIZE
	if(GROUP_SIZE == 1) begin: case_gs1
		assign qg[1] = q[1];
		assign qg[0] = q[0];
	end
	else if(GROUP_SIZE == 2) begin: case_gs2
		assign qg[1] = q[3] | (q[1] & q[2]);
		assign qg[0] = q[2] & q[0];
	end
	else if(GROUP_SIZE == 4) begin: case_gs4
		assign qg[1] = q[7] | (q[5] & q[6]) | (q[3] & q[6] & q[4]) | (q[1] & q[6] & q[4] & q[2]);
		assign qg[0] = q[6] & q[4] & q[2] & q[0];
	end
	else if(GROUP_SIZE == 8) begin: case_gs8
		assign qg[1] = q[15] | (q[13] & q[14]) | (q[11] & q[14] & q[12]) | (q[9] & q[14] & q[12] & q[10]) | (q[7] & q[14] & q[12] & q[10] & q[8]) | (q[5] & q[14] & q[12] & q[10] & q[8] & q[6]) | (q[3] & q[14] & q[12] & q[10] & q[8] & q[6] & q[4]) | (q[1] & q[14] & q[12] & q[10] & q[8] & q[6] & q[4] & q[2]);
		assign qg[0] = q[14] & q[12] & q[10] & q[8] & q[6] & q[4] & q[2] & q[0];
	end
	endgenerate
	
endmodule

module cin_generation_logic(
  input logic [1:0] r,
  input logic       c0,
  output logic      cin
);
	assign cin = (r[0] & c0) | r[1];
endmodule


module prefix_logic(
  input  logic [1:0] ql,
  input  logic [1:0] qh,
  output logic [1:0] r
);
	assign r[0] = qh[0] & ql[0];
	assign r[1] = (qh[0] & ql[1]) | qh[1];	
endmodule

module FA_CLA_prefix(
  input  logic       a,
  input  logic       b,
  input  logic       cin,
  output logic       s,
  output logic [1:0] q
);	
	assign q[0] = a ^ b;
	assign s = q[0] ^ cin;
	assign q[1] = a & b;
endmodule

`endif