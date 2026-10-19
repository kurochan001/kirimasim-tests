/*
:name: test_class_in_generate_block
:description: A class declared in a loop generate block is a different class in each block, which sees that block's genvar and localparam (IEEE 1800-2023 Section 27.4)
:tags: ch27
:type: simulation
:lrm: 1800-2023 27.4 8.9 3.13
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_in_generate_block.expected
*/
// IEEE 1800-2023 §27.4: each iteration of a loop generate construct creates
// a block of its own, with its own copy of the declarations in it, and the
// genvar is a localparam of that block. A class declared in the block is
// therefore a separate class in each block (3.13): its methods see the
// block's genvar and localparam, and each has its own static property
// (8.9).

module test_class_in_generate_block;
  for (genvar i = 0; i < 3; i++) begin : h
    localparam int LP = i * 100;
    class W;
      static int cnt = 0;
      function int idx();
        return i;
      endfunction
      function int lp();
        return LP;
      endfunction
    endclass
    W w = new;
  end

  initial begin
    $display("idx: %0d %0d %0d", h[0].w.idx(), h[1].w.idx(), h[2].w.idx());
    $display("lp: %0d %0d %0d", h[0].w.lp(), h[1].w.lp(), h[2].w.lp());
    h[0].w.cnt = 7;
    $display("cnt after h[0].w.cnt = 7: %0d %0d %0d", h[0].w.cnt, h[1].w.cnt, h[2].w.cnt);
  end
endmodule
