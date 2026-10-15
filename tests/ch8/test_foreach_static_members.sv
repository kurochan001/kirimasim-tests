/*
:name: test_foreach_static_members
:description: Tests foreach iteration over static queue, dynamic array, and associative array members
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.9 8.10 12.7.3 7.10 7.8
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_foreach_static_members.expected
*/
// Tests foreach iteration over static queue, dynamic array, and associative array members
// Both from module scope (C::member) and inside static functions (bare name)
module t;
  class C;
    static int q[$];
    static int aa[string];
    static int da[];

    static function void init();
      q.push_back(10);
      q.push_back(20);
      q.push_back(30);
      aa["x"] = 1;
      aa["y"] = 2;
      aa["z"] = 3;
      da = new[3];
      da[0] = 100;
      da[1] = 200;
      da[2] = 300;
    endfunction

    // foreach inside static function (bare name)
    static function int sum_queue();
      int s = 0;
      foreach (q[i]) s += q[i];
      return s;
    endfunction

    static function int sum_aa();
      int s = 0;
      foreach (aa[key]) s += aa[key];
      return s;
    endfunction

    static function int sum_da();
      int s = 0;
      foreach (da[i]) s += da[i];
      return s;
    endfunction
  endclass

  int pass_count;
  initial begin
    pass_count = 0;

    C::init();

    begin
      static int count = 0;
      foreach (C::aa[key]) count++;
      if (count == 3) pass_count++;
      else $display("FAIL test1: foreach C::aa count=%0d expected=3", count);
    end

    // Test 2: foreach inside static function on queue
    if (C::sum_queue() == 60) pass_count++;
    else $display("FAIL test2: sum_queue=%0d expected=60", C::sum_queue());

    // Test 3: foreach inside static function on assoc array
    if (C::sum_aa() == 6) pass_count++;
    else $display("FAIL test3: sum_aa=%0d expected=6", C::sum_aa());

    // Test 4: foreach inside static function on dynamic array
    if (C::sum_da() == 600) pass_count++;
    else $display("FAIL test4: sum_da=%0d expected=600", C::sum_da());

    // Test 5: foreach on static queue from module scope
    begin
      static int sum = 0;
      foreach (C::q[i]) sum += C::q[i];
      if (sum == 60) pass_count++;
      else $display("FAIL test5: foreach C::q sum=%0d expected=60", sum);
    end

    // Test 6: Verify static members are properly shared
    C::q.push_back(40);
    if (C::sum_queue() == 100) pass_count++;
    else $display("FAIL test6: sum_queue after push=%0d expected=100", C::sum_queue());

    if (pass_count == 6)
      $display("PASS: all %0d tests passed", pass_count);
    else
      $display("FAIL: %0d/6 tests passed", pass_count);
  end
endmodule
