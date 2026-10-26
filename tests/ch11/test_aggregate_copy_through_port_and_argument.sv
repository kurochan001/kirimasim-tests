/*
:name: test_aggregate_copy_through_port_and_argument
:description: Unpacked structures and arrays are copied through a port and through subroutine arguments and compared with equality (IEEE 1800-2023 Section 11.2.2)
:tags: ch11
:type: simulation
:lrm: 1800-2023 11.2.2
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_aggregate_copy_through_port_and_argument.expected
*/
// IEEE 1800-2023 §11.2.2: unpacked structures and arrays can be copied in an
// assignment, through a port, or as an argument to a subroutine, and can be
// compared with equality or inequality. A pair_t value goes through the
// input and output ports of passthru, a pair_t is passed to a function and
// returned from it, an int array is passed by value to a function, and the
// structures are compared with == and !=.

typedef struct {
  int a;
  int b;
} pair_t;

module passthru(input pair_t i, output pair_t o);
  assign o = i;
endmodule

function automatic pair_t bump(input pair_t x);
  bump = '{x.a + 1, x.b + 1};
endfunction

function automatic int total(input int a[3]);
  total = a[0] + a[1] + a[2];
endfunction

module test_aggregate_copy_through_port_and_argument;
  pair_t p_in, p_out, r;
  int arr[3];

  passthru u(.i(p_in), .o(p_out));

  initial begin
    p_in.a = 1;
    p_in.b = 2;
    arr[0] = 3;
    arr[1] = 4;
    arr[2] = 5;
    #1;
    $display("port=%0d,%0d", p_out.a, p_out.b);
    r = bump(p_in);
    $display("arg=%0d,%0d", r.a, r.b);
    $display("arrayarg=%0d", total(arr));
    $display("eq=%0d ne=%0d", (p_in == p_in), (p_in != r));
  end
endmodule
