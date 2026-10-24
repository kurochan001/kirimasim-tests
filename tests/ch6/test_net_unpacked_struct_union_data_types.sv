/*
:name: test_net_unpacked_struct_union_data_types
:description: A net can have an unpacked structure or union type, or a structure that contains another unpacked structure and an unpacked array, as long as every element is a valid net type (IEEE 1800-2023 Section 6.7.1)
:tags: ch6
:type: simulation
:lrm: 1800-2023 6.7.1 7.2 7.3 10.3
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_net_unpacked_struct_union_data_types.expected
*/
// IEEE 1800-2023 §6.7.1: besides 4-state integral types, a valid data type for
// a net is a fixed-size unpacked array, unpacked structure or unpacked union
// whose elements all have valid net data types, so the rule applies again
// inside each element. The structure us_t (7.2), the union uu_t (7.3) and
// nest_t, a structure holding a us_t and an unpacked array of logic vectors,
// all qualify, and nets of these types are driven by continuous assignments
// (10.3), the union through one of its members.

module test_net_unpacked_struct_union_data_types;
  typedef struct { logic [3:0] a; logic b; } us_t;
  typedef union { logic [3:0] w; logic [3:0] v; } uu_t;
  typedef struct { us_t inner; logic [1:0] arr [2]; } nest_t;

  wire us_t n_s;
  wire nest_t n_n;
  wire uu_t n_u;

  assign n_s = '{a: 4'h9, b: 1'b1};
  assign n_n = '{inner: '{4'h3, 1'b0}, arr: '{2'b01, 2'b10}};
  assign n_u.w = 4'h6;

  initial
    #1 $display("struct: a=%h b=%b nested: a=%h b=%b arr=%b %b union: w=%h", n_s.a, n_s.b,
                n_n.inner.a, n_n.inner.b, n_n.arr[0], n_n.arr[1], n_u.w);
endmodule
