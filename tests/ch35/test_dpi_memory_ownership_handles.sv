/*
:name: test_dpi_memory_ownership_handles
:description: Memory allocated by C stays allocated until C frees it, also when the design drops its chandles, and C frees blocks whose pointers the design passes back to it; C copies a string it got instead of keeping or freeing SystemVerilog's storage, and SystemVerilog copies the strings C returns, which C frees later (IEEE 1800-2023 Section 35.5.1.4, H.6.6)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.4 H.6.6 6.14
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_memory_ownership_handles.c
:expected_stdout: @test_dpi_memory_ownership_handles.expected
*/
// IEEE 1800-2023 §35.5.1.4, H.6.6: the memory that C allocates and the memory
// that SystemVerilog allocates are separate, and each side frees only its
// own: C does not free SystemVerilog's memory, and SystemVerilog does not free
// C's. C may still give SystemVerilog a pointer to a block, in a chandle
// (6.14), and SystemVerilog may pass it back to a C function that frees it,
// since the block is then both allocated and freed by C.
//
// c_alloc allocates a block, marks it and counts it as live; c_free checks
// the mark and frees the block; c_live gives the count. The design keeps a
// copy of one chandle, sets the original to null, which frees nothing, and
// then passes the copy and the other chandle to c_free. c_keep copies the
// string it gets into memory of its own; the design then changes its
// variable, and c_kept returns the copy. c_label returns a string in a block
// it allocates and frees, after overwriting it, at its next call; the design
// keeps both results.

module test_dpi_memory_ownership_handles;
  import "DPI-C" function chandle c_alloc(input int n);
  import "DPI-C" function int c_free(input chandle h);
  import "DPI-C" function int c_live();
  import "DPI-C" function void c_keep(input string s);
  import "DPI-C" function string c_kept();
  import "DPI-C" function string c_label(input int n);

  chandle a, b, copy;
  string note = "first", s1, s2;

  initial begin
    a = c_alloc(1);
    b = c_alloc(2);
    copy = a;
    $display("live after two allocations: %0d", c_live());
    a = null;
    $display("live after the design set its chandle to null: %0d", c_live());
    $display("c_free of the copy: %0d, of b: %0d", c_free(copy), c_free(b));
    $display("live after c_free: %0d", c_live());
    c_keep(note);
    note = "second";
    $display("C kept \"%s\", the design has \"%s\"", c_kept(), note);
    s1 = c_label(1);
    s2 = c_label(2);
    void'(c_label(3));
    $display("labels kept by the design: \"%s\" \"%s\"", s1, s2);
  end
endmodule
