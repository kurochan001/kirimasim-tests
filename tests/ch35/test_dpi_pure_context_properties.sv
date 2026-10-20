/*
:name: test_dpi_pure_context_properties
:description: A pure import depends only on its inputs, a context import may call exported subroutines that reach SystemVerilog data, and an import with neither property may still have side effects of its own in C (IEEE 1800-2023 Section 35.5.1.3)
:tags: ch35
:type: simulation
:lrm: 1800-2023 35.5.1.3 35.5.2 35.5.3 35.7
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:dpi_c: @test_dpi_pure_context_properties.c
:expected_stdout: @test_dpi_pure_context_properties.expected
*/
// IEEE 1800-2023 §35.5.1.3: an import whose result depends only on its
// inputs and that has no side effects can be declared pure (35.5.2). An
// import that calls exported subroutines, and so reaches SystemVerilog data
// other than its arguments, has to be declared context (35.5.3, 35.7). An
// import with neither property does not touch SystemVerilog data but may have
// side effects of its own, such as changing a C variable. c_feed calls the
// exported sv_add twice, which changes total; c_tick counts its calls in C.

module test_dpi_pure_context_properties;
  import "DPI-C" pure function int c_square(input int v);
  import "DPI-C" context function int c_feed(input int v);
  import "DPI-C" function int c_tick();
  export "DPI-C" function sv_add;

  int total = 0, fed, t1, t2;

  function int sv_add(input int v);
    total += v;
    return total;
  endfunction

  initial begin
    $display("square %0d", c_square(7));
    fed = c_feed(5);
    $display("feed returned %0d, total %0d", fed, total);
    t1 = c_tick();
    t2 = c_tick();
    $display("ticks %0d %0d", t1, t2);
  end
endmodule
