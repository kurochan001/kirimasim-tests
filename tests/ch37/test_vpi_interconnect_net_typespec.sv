/*
:name: test_vpi_interconnect_net_typespec
:description: An interconnect net gives the typespec of the net it is connected to, iterates the elements that correspond to a packed array type with vpiElement, and iterates the members that correspond to a packed struct type with vpiMember (IEEE 1800-2023 Section 37.24)
:tags: ch37
:type: simulation
:lrm: 1800-2023 37.24 37.16 6.6.8
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:vpi_c: @test_vpi_interconnect_net_typespec.c
:expected_stdout: @test_vpi_interconnect_net_typespec.expected
*/
// IEEE 1800-2023 §37.24 detail 1: the typespec of an interconnect net is the
// typespec of the net it is connected to; when that type is a packed or
// unpacked array, vpiElement applied to the interconnect net gives the
// corresponding elements of the interconnect net, and when it is a packed or
// unpacked struct, vpiMember gives the corresponding struct members. The test
// connects one interconnect net to a 2-bit wire output and one to a packed
// struct wire output, compares the interconnect typespec handles with the
// typespecs of the connected nets found from the output ports, and prints the
// number and sizes of the elements and members.

typedef struct packed { logic [1:0] lo; logic [1:0] hi; } ic_pair;

module ic_vec_drv (output wire [1:0] o);
  assign o = 2'b10;
endmodule

module ic_pair_drv (output wire ic_pair o);
  assign o = '{2'b01, 2'b11};
endmodule

module test_vpi_interconnect_net_typespec;
  interconnect iv;
  interconnect is;

  ic_vec_drv uv (iv);
  ic_pair_drv us (is);

  initial #1 $vt_ic;
endmodule
