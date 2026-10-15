/*
:name: test_class_basic_2
:description: Class constructor, properties and methods, and independent instances
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.4 8.7
:oracle: spec iverilog@13.0
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_basic_2.expected
*/
// Class constructor, properties and methods, and independent instances
module test_class_basic;

  class Packet;
    int id;
    string name;

    function new(int id_val, string name_val);
      id = id_val;
      name = name_val;
    endfunction

    function int get_id();
      return id;
    endfunction

    function string describe();
      return name;
    endfunction
  endclass

  initial begin
    static int pass_cnt = 0;
    static int fail_cnt = 0;
    Packet p1, p2;

    // Check 1: construct and read property
    p1 = new(42, "alpha");
    if (p1.id == 42) begin pass_cnt++; $display("PASS: p1.id == 42"); end
    else begin fail_cnt++; $display("FAIL: p1.id = %0d, expected 42", p1.id); end

    // Check 2: string property
    if (p1.name == "alpha") begin pass_cnt++; $display("PASS: p1.name == alpha"); end
    else begin fail_cnt++; $display("FAIL: p1.name = %s", p1.name); end

    // Check 3: method call
    if (p1.get_id() == 42) begin pass_cnt++; $display("PASS: get_id() == 42"); end
    else begin fail_cnt++; $display("FAIL: get_id() = %0d", p1.get_id()); end

    // Check 4: describe method
    if (p1.describe() == "alpha") begin pass_cnt++; $display("PASS: describe() == alpha"); end
    else begin fail_cnt++; $display("FAIL: describe() = %s", p1.describe()); end

    // Check 5: second instance is independent
    p2 = new(99, "beta");
    if (p2.id == 99 && p1.id == 42) begin pass_cnt++; $display("PASS: independent instances"); end
    else begin fail_cnt++; $display("FAIL: instances not independent"); end

    // Check 6: modify property directly
    p1.id = 100;
    if (p1.id == 100) begin pass_cnt++; $display("PASS: property write p1.id = 100"); end
    else begin fail_cnt++; $display("FAIL: p1.id = %0d after write", p1.id); end

    $display("Results: %0d passed, %0d failed", pass_cnt, fail_cnt);
    if (fail_cnt == 0) $display("TEST PASSED"); else $display("TEST FAILED");
    $finish;
  end

endmodule
