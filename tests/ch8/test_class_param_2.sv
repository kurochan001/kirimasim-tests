/*
:name: test_class_param_2
:description: Test: Parameterized class, instantiation with different types
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_param_2.expected
*/
// Test: Parameterized class, instantiation with different types
module test_class_param_2;

  class Pair #(type T = int);
    T first;
    T second;

    function new(T a, T b);
      first = a;
      second = b;
    endfunction

    function T sum();
      return first + second;
    endfunction

    function void swap();
      T tmp;
      tmp = first;
      first = second;
      second = tmp;
    endfunction
  endclass

  class Box #(int WIDTH = 8);
    bit [WIDTH-1:0] data;

    function new(bit [WIDTH-1:0] val);
      data = val;
    endfunction

    function int width();
      return WIDTH;
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    Pair #(int) ip;
    Pair #(real) rp;
    Box #(8) b8;
    Box #(16) b16;

    // Check 1: int pair sum
    ip = new(10, 20);
    if (ip.sum() == 30) begin pass_cnt++; $display("PASS: int pair sum == 30"); end
    else begin fail_cnt++; $display("FAIL: int pair sum = %0d", ip.sum()); end

    // Check 2: int pair swap
    ip.swap();
    if (ip.first == 20 && ip.second == 10) begin pass_cnt++; $display("PASS: int pair swap"); end
    else begin fail_cnt++; $display("FAIL: after swap first=%0d second=%0d", ip.first, ip.second); end

    // Check 3: real pair
    rp = new(1.5, 2.5);
    if (rp.sum() == 4.0) begin pass_cnt++; $display("PASS: real pair sum == 4.0"); end
    else begin fail_cnt++; $display("FAIL: real pair sum = %f", rp.sum()); end

    // Check 4: Box#(8) width
    b8 = new(8'hAB);
    if (b8.width() == 8) begin pass_cnt++; $display("PASS: Box#(8) width == 8"); end
    else begin fail_cnt++; $display("FAIL: Box#(8) width = %0d", b8.width()); end

    // Check 5: Box#(8) data
    if (b8.data == 8'hAB) begin pass_cnt++; $display("PASS: Box#(8) data == 0xAB"); end
    else begin fail_cnt++; $display("FAIL: Box#(8) data = 0x%0h", b8.data); end

    // Check 6: Box#(16) wider
    b16 = new(16'hCAFE);
    if (b16.data == 16'hCAFE && b16.width() == 16) begin pass_cnt++; $display("PASS: Box#(16) data and width"); end
    else begin fail_cnt++; $display("FAIL: Box#(16) data=0x%0h width=%0d", b16.data, b16.width()); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
