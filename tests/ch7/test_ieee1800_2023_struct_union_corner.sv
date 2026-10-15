/*
:name: test_ieee1800_2023_struct_union_corner
:description: Struct/Union Corner Cases
:tags: ch7
:type: simulation
:lrm: 1800-2023 7.2 7.2.1 7.3 7.3.1 10.9.2
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_ieee1800_2023_struct_union_corner.expected
*/
// IEEE 1800-2023 Struct/Union Corner Cases
// Targets: struct and union handling paths
// Sections: 7.2 (struct), 7.3 (union), 7.2.1 (packed slicing)
// PASS_CRITERIA: All $display("PASS:*") messages must appear

module test_ieee1800_2023_struct_union_corner;

  // Basic packed struct
  typedef struct packed {
    logic [7:0] high;
    logic [7:0] low;
  } pair16_t;

  // Wider packed struct
  typedef struct packed {
    logic [7:0] a;
    logic [7:0] b;
    logic [7:0] c;
    logic [7:0] d;
  } quad32_t;

  // Nested packed struct
  typedef struct packed {
    pair16_t upper;
    pair16_t lower;
  } nested32_t;

  // Unpacked struct
  typedef struct {
    int x;
    int y;
    string name;
  } point_t;

  // Struct with array member
  typedef struct {
    int values[4];
    int count;
  } container_t;

  // Packed union
  typedef union packed {
    logic [15:0] word;
    pair16_t fields;
  } word_or_pair_t;

  initial begin
    static int pass_count = 0;
    static int total_tests = 20;

    // ===========================================
    // Packed Struct Operations (IEEE 1800-2023 Section 7.2)
    // ===========================================

    // Test 1: Packed struct member access
    begin
      static pair16_t s;
      // Assigned here so the result does not depend on the order of static initializers.
      s = '{high: 8'hAA, low: 8'h55};
      if (s.high == 8'hAA && s.low == 8'h55) begin
        $display("PASS: Test 1 - packed struct member access");
        pass_count++;
      end else $display("FAIL: Test 1 - struct member (h=%h,l=%h)", s.high, s.low);
    end

    // Test 2: Packed struct whole assignment from integer
    begin
      pair16_t s;
      s = 16'hAABB;
      if (s.high == 8'hAA && s.low == 8'hBB) begin
        $display("PASS: Test 2 - packed struct from integer 16'hAABB");
        pass_count++;
      end else $display("FAIL: Test 2 - struct int (h=%h, l=%h)", s.high, s.low);
    end

    // Test 3: Packed struct member modification
    begin
      static pair16_t s = 16'h0000;
      s.high = 8'hFF;
      if (s.high == 8'hFF && s.low == 8'h00) begin
        $display("PASS: Test 3 - packed struct member modification");
        pass_count++;
      end else $display("FAIL: Test 3 - struct modify");
    end

    // Test 4: Packed struct equality comparison
    begin
      static pair16_t s1;
      static pair16_t s2;
      static pair16_t s3;
      // Assigned here so the result does not depend on the order of static initializers.
      s1 = '{high: 8'h12, low: 8'h34};
      s2 = '{high: 8'h12, low: 8'h34};
      s3 = '{high: 8'h12, low: 8'h35};
      if (s1 == s2 && s1 != s3) begin
        $display("PASS: Test 4 - packed struct equality comparison");
        pass_count++;
      end else $display("FAIL: Test 4 - struct compare");
    end

    // Test 5: Packed struct to bit vector conversion
    begin
      static pair16_t s;
      static logic [15:0] vec;
      // Assigned here so the result does not depend on the order of static initializers.
      s = '{high: 8'hAB, low: 8'hCD};
      vec = s;
      if (vec == 16'hABCD) begin
        $display("PASS: Test 5 - packed struct -> bit vector");
        pass_count++;
      end else $display("FAIL: Test 5 - struct to vec (got %h)", vec);
    end

    // Test 6: Quad packed struct
    begin
      static quad32_t q;
      static logic [31:0] vec;
      // Assigned here so the result does not depend on the order of static initializers.
      q = '{a: 8'h12, b: 8'h34, c: 8'h56, d: 8'h78};
      vec = q;
      if (vec == 32'h12345678) begin
        $display("PASS: Test 6 - quad packed struct -> 32'h12345678");
        pass_count++;
      end else $display("FAIL: Test 6 - quad struct (got %h)", vec);
    end

    // Test 7: Nested packed struct member-by-member assignment via sub-struct (§7.2)
    begin
      nested32_t ns;
      ns.upper = '{high: 8'hDE, low: 8'hAD};
      ns.lower = '{high: 8'hBE, low: 8'hEF};
      if (ns.upper.high == 8'hDE && ns.lower.low == 8'hEF) begin
        $display("PASS: Test 7 - nested packed struct access");
        pass_count++;
      end else $display("FAIL: Test 7 - nested struct");
    end

    // Test 8: Nested packed struct as integer
    begin
      nested32_t ns;
      ns = 32'hDEADBEEF;
      if (ns.upper.high == 8'hDE && ns.upper.low == 8'hAD &&
          ns.lower.high == 8'hBE && ns.lower.low == 8'hEF) begin
        $display("PASS: Test 8 - nested struct from int 32'hDEADBEEF");
        pass_count++;
      end else $display("FAIL: Test 8 - nested from int");
    end

    // Test 9: $bits on packed struct
    begin
      pair16_t s;
      static int bits;
      // Assigned here so the result does not depend on the order of static initializers.
      bits = $bits(s);
      if (bits == 16) begin
        $display("PASS: Test 9 - $bits(packed struct) -> 16");
        pass_count++;
      end else $display("FAIL: Test 9 - $bits (got %0d)", bits);
    end

    // Test 10: $bits on quad packed struct
    begin
      quad32_t q;
      static int bits;
      // Assigned here so the result does not depend on the order of static initializers.
      bits = $bits(q);
      if (bits == 32) begin
        $display("PASS: Test 10 - $bits(quad struct) -> 32");
        pass_count++;
      end else $display("FAIL: Test 10 - $bits quad (got %0d)", bits);
    end

    // ===========================================
    // Unpacked Struct (IEEE 1800-2023 Section 7.2)
    // ===========================================

    // Test 11: Unpacked struct assignment
    begin
      point_t p;
      p.x = 10;
      p.y = 20;
      p.name = "origin";
      if (p.x == 10 && p.y == 20 && p.name == "origin") begin
        $display("PASS: Test 11 - unpacked struct assignment");
        pass_count++;
      end else $display("FAIL: Test 11 - unpacked struct");
    end

    // Test 12: Unpacked struct literal
    begin
      static point_t p;
      // Assigned here so the result does not depend on the order of static initializers.
      p = '{x: 5, y: 15, name: "test"};
      if (p.x == 5 && p.y == 15 && p.name == "test") begin
        $display("PASS: Test 12 - unpacked struct literal");
        pass_count++;
      end else $display("FAIL: Test 12 - struct literal");
    end

    // Test 13: Struct with array member
    begin
      container_t c;
      c.values[0] = 10;
      c.values[1] = 20;
      c.values[2] = 30;
      c.values[3] = 40;
      c.count = 4;
      if (c.values[2] == 30 && c.count == 4) begin
        $display("PASS: Test 13 - struct with array member");
        pass_count++;
      end else $display("FAIL: Test 13 - struct array member");
    end

    // Test 14: Struct copy
    begin
      static point_t p1;
      static point_t p2;
      // Assigned here so the result does not depend on the order of static initializers.
      p1 = '{x: 1, y: 2, name: "src"};
      p2 = p1;
      if (p2.x == 1 && p2.y == 2 && p2.name == "src") begin
        $display("PASS: Test 14 - struct copy");
        pass_count++;
      end else $display("FAIL: Test 14 - struct copy");
    end

    // ===========================================
    // Packed Union (IEEE 1800-2023 Section 7.3)
    // ===========================================

    // Test 15: Packed union word access
    begin
      word_or_pair_t u;
      u.word = 16'hABCD;
      if (u.word == 16'hABCD) begin
        $display("PASS: Test 15 - packed union word access");
        pass_count++;
      end else $display("FAIL: Test 15 - union word");
    end

    // Test 16: Packed union field overlay
    begin
      word_or_pair_t u;
      u.word = 16'hABCD;
      if (u.fields.high == 8'hAB && u.fields.low == 8'hCD) begin
        $display("PASS: Test 16 - packed union field overlay");
        pass_count++;
      end else $display("FAIL: Test 16 - union overlay (h=%h, l=%h)", u.fields.high, u.fields.low);
    end

    // Test 17: Packed union write through fields, read as word (§7.3)
    begin
      word_or_pair_t u;
      u.fields = '{high: 8'h12, low: 8'h34};
      if (u.word == 16'h1234) begin
        $display("PASS: Test 17 - union field write -> word read");
        pass_count++;
      end else $display("FAIL: Test 17 - union field->word (got %h)", u.word);
    end

    // ===========================================
    // Struct Array (IEEE 1800-2023 Section 7.2)
    // ===========================================

    // Test 18: Array of packed structs
    begin
      pair16_t arr[3];
      arr[0] = '{high: 8'h11, low: 8'h22};
      arr[1] = '{high: 8'h33, low: 8'h44};
      arr[2] = '{high: 8'h55, low: 8'h66};
      if (arr[0].high == 8'h11 && arr[1].low == 8'h44 && arr[2].high == 8'h55) begin
        $display("PASS: Test 18 - array of packed structs");
        pass_count++;
      end else $display("FAIL: Test 18 - struct array");
    end

    // Test 19: Struct literal '{default: val}
    begin
      static pair16_t s = '{default: 8'h00};
      if (s.high == 8'h00 && s.low == 8'h00) begin
        $display("PASS: Test 19 - struct literal '{default: 0}");
        pass_count++;
      end else $display("FAIL: Test 19 - struct default");
    end

    // Test 20: Dynamic array of structs
    begin
      point_t pts[];
      pts = new[2];
      pts[0] = '{x: 1, y: 2, name: "A"};
      pts[1] = '{x: 3, y: 4, name: "B"};
      if (pts[0].x == 1 && pts[1].name == "B" && pts.size() == 2) begin
        $display("PASS: Test 20 - dynamic array of structs");
        pass_count++;
      end else $display("FAIL: Test 20 - dyn array struct");
    end

    $display("\n=== Struct/Union Corner Cases Summary ===");
    $display("Tests passed: %0d/%0d", pass_count, total_tests);
    if (pass_count == total_tests) $display("ALL TESTS PASSED");
    else $display("SOME TESTS FAILED");
    $finish;
  end

endmodule
