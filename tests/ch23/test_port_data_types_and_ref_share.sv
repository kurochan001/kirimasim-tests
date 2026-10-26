/*
:name: test_port_data_types_and_ref_share
:description: Values of all data types pass through assignment-compatible ports, and a ref port shares the variable connected to it (IEEE 1800-2023 Section 23.3.3)
:tags: ch23
:type: simulation
:lrm: 1800-2023 23.3.3 23.3.3.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_port_data_types_and_ref_share.expected
*/
// IEEE 1800-2023 §23.3.3: values of all data types on variables and nets can
// be passed through ports, both sides of a connection have assignment-
// compatible data types, and a ref port shares the connected variable through
// a hierarchical reference. The instance pdt_child receives a net, a real, a
// string, an unpacked structure, an unpacked array, a 4-bit value that is
// converted to its int port, and a ref int. It writes the ref variable and
// its output port, and the parent reads both after the child ran: a ref port
// writes the parent's variable itself, not a copy, while the output port
// carries a value.

typedef struct { int a; int b; } pdt_st;

// Icarus Verilog 13.0 cannot parse an unpacked structure, so the expected
// output is recorded with Verilator 5.052 alone.

module pdt_child(input wire [3:0] nw, input real rd, input string s,
                 input pdt_st st, input int arr[2], input int conv,
                 ref int shared, output int res);
  initial begin
    #1;
    shared += 10;
    res = arr[0] * 10;
    $display("child: r=%0.2f s=%s st=%0d,%0d arr=%0d,%0d conv=%0d net=%0d ref=%0d",
             rd, s, st.a, st.b, arr[0], arr[1], conv, nw, shared);
  end
endmodule

module test_port_data_types_and_ref_share;
  wire [3:0] nw = 4'h9;
  real rv = 1.5;
  string sv = "txt";
  pdt_st st = '{1, 2};
  int arr[2] = '{3, 4};
  logic [3:0] narrow = 4'hf;
  int shared = 7;
  int res;

  pdt_child u(.nw(nw), .rd(rv), .s(sv), .st(st), .arr(arr), .conv(narrow),
              .shared(shared), .res(res));

  initial #2 $display("parent: res=%0d shared=%0d", res, shared);
endmodule
