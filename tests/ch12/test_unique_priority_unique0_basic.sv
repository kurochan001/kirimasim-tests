/*
:name: test_unique_priority_unique0_basic
:description: unique / priority / unique0 case 最小テスト（IEEE 1800-2023）
:tags: ch12
:type: simulation
:lrm: 1800-2023 12.5.1 12.5.3
:oracle: spec iverilog@13.0
:fourstate: yes
:nondeterministic: no
:expected_stdout: @test_unique_priority_unique0_basic.expected
*/
// unique / priority / unique0 case 最小テスト（IEEE 1800-2023）
module test_unique_priority_unique0_basic;
  int pass = 0, tests = 0;

  task check(string name, bit cond);
    tests++;
    if (cond) pass++; else $display("check failed: %s", name);
  endtask

  // 1) unique case: 非重複アイテムで各入力に対して1本のみ実行
  task test_unique_non_overlap();
    int sel;
    static int hit0 = 0, hit1 = 0, hit2 = 0, hitd = 0;
    for (sel = 0; sel <= 2; sel++) begin
      unique case (sel)
        0: hit0++;
        1: hit1++;
        2: hit2++;
        default: hitd++;
      endcase
    end
    check("unique hits", hit0==1 && hit1==1 && hit2==1 && hitd==0);
  endtask

  // 2) unique0 case: 0本マッチ許容（default なしでもOK）
  task test_unique0_allows_zero_match();
    int sel;
    static int h = 0;
    sel = 3; // どのアイテムにも一致しない
    unique0 case (sel)
      0: h=1;
      1: h=2;
      2: h=3;
    endcase
    // ヒットしないことを確認（ランタイム違反は発生しない想定）
    check("unique0 zero-match allowed", h==0);

    // 一致する値では1本ヒット
    sel = 2;
    unique0 case (sel)
      0: h=10;
      2: h=20;
      default: h=99; // 一致するので default は走らない
    endcase
    check("unique0 single hit", h==20);
  endtask

  // 3) priority case: 重複マッチ時は最初の項目が選択される（通常の case 同様）
  task test_priority_first_match_taken();
    static int sel = 3; // 2'b11
    static int which = 0;
    priority casez (sel)
      2'b1?: which = 1; // sel==2 または 3 で真
      2'b?1: which = 2; // sel==1 または 3 で真（重複発生）
      default: which = 9;
    endcase
    // 先に書かれた 2'b1? が選ばれる
    check("priority case first match chosen", which==1);

    // どれも一致しない場合は default が選ばれる
    sel = 0;
    priority casez (sel)
      2'b1?: which = 3;
      2'b?1: which = 4;
      default: which = 5;
    endcase
    check("priority case default taken when none", which==5);
  endtask

  initial begin
    $display("=== unique/priority/unique0 basic tests ===");
    test_unique_non_overlap();
    test_unique0_allows_zero_match();
    test_priority_first_match_taken();
    $display("Summary: %0d/%0d passed", pass, tests);
    if (pass==tests) begin
      $display("TEST PASSED");
      $finish;
    end else begin
      $finish(1);
    end
  end
endmodule
