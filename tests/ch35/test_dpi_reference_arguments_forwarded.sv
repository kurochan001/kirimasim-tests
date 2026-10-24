/*
:name: test_dpi_reference_arguments_forwarded
:description: Arguments passed by reference are pointers to the data, int* for int and int arrays and svBitVecVal* or svLogicVecVal* for packed bit and logic vectors; C can call an export with storage it allocates itself or with the references it got as an import's own formals (IEEE 1800-2023 Section 35.5.4, H.8.4, H.8.8)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.4 H.8.4 H.8.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_reference_arguments_forwarded.c
:expected_stdout: @test_dpi_reference_arguments_forwarded.expected
*/
// IEEE 1800-2023 §35.5.4: an export can be called from C. H.8.4: an argument
// of type T passed by reference is a T*, a pointer to the actual data object,
// and a packed array is passed as a pointer to its canonical type,
// svBitVecVal* or svLogicVecVal*. The caller usually allocates the actual
// argument, but it can also pass a reference it already has, for example its
// own formal argument. H.8.8: output and inout arguments are passed by
// reference.
//
// c_own allocates an int, two svBitVecVal chunks, an svLogicVecVal and an int
// array in C and passes them to the export sv_fill, which writes 42, a 40-bit
// value, adds 1 to the logic vector and multiplies the array by 10; C prints
// what it gets back. c_forward is an import with the same four arguments: it
// passes its own formals, the references to the design's variables, on to
// sv_fill, prints what sv_fill wrote through them, and changes them again;
// the design then prints its variables.

module test_dpi_reference_arguments_forwarded;
  import "DPI-C" context function void c_own();
  import "DPI-C" context function void c_forward(output int n, output bit [39:0] w,
                                                 inout logic [7:0] l, inout int arr [3]);
  export "DPI-C" function sv_fill;

  function void sv_fill(output int n, output bit [39:0] w, inout logic [7:0] l,
                        inout int arr [3]);
    n = 42;
    w = 40'h12_3456_789a;
    l = l + 8'd1;
    foreach (arr[k]) arr[k] = arr[k] * 10;
  endfunction

  int n;
  bit [39:0] w;
  logic [7:0] l = 8'h0f;
  int arr [3] = '{1, 2, 3};

  initial begin
    c_own();
    c_forward(n, w, l, arr);
    $display("design: n %0d w %h l %h arr %0d %0d %0d", n, w, l, arr[0], arr[1], arr[2]);
  end
endmodule
