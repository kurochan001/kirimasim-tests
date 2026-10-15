/*
:name: test_class_abstract_2
:description: Test: Abstract class usage
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.21 8.20 8.9
:oracle: spec verilator@5.052
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_class_abstract_2.expected
*/
// Test: Abstract class usage
// IEEE 1800-2023 Section 8.21 - Abstract classes and pure virtual methods

module test_class_abstract_2;

  // Abstract class with pure virtual methods
  virtual class Transaction;
    int id;
    static int next_id = 0;

    function new();
      id = next_id++;
    endfunction

    // Pure virtual methods - subclasses must implement
    pure virtual function bit validate();
    pure virtual function void execute();
    pure virtual function string to_string();
  endclass

  // Concrete implementation: Read transaction
  class ReadTransaction extends Transaction;
    int address;
    int data;

    function new(int addr);
      super.new();
      address = addr;
      data = 0;
    endfunction

    virtual function bit validate();
      return (address >= 0 && address < 1024);
    endfunction

    virtual function void execute();
      data = address * 2;  // Simulate read
    endfunction

    virtual function string to_string();
      return $sformatf("Read[%0d]: addr=%0d, data=%0d", id, address, data);
    endfunction
  endclass

  // Concrete implementation: Write transaction
  class WriteTransaction extends Transaction;
    int address;
    int data;

    function new(int addr, int d);
      super.new();
      address = addr;
      data = d;
    endfunction

    virtual function bit validate();
      return (address >= 0 && address < 1024 && data >= 0);
    endfunction

    virtual function void execute();
      // Simulate write - just validate data
    endfunction

    virtual function string to_string();
      return $sformatf("Write[%0d]: addr=%0d, data=%0d", id, address, data);
    endfunction
  endclass

  // Abstract class with mix of pure and non-pure virtual methods
  virtual class Codec;
    pure virtual function bit[7:0] encode(bit[7:0] data);
    pure virtual function bit[7:0] decode(bit[7:0] data);

    // Non-pure virtual with default implementation
    virtual function bit verify(bit[7:0] original, bit[7:0] encoded);
      return (decode(encoded) == original);
    endfunction
  endclass

  class XorCodec extends Codec;
    bit[7:0] key;

    function new(bit[7:0] k);
      key = k;
    endfunction

    virtual function bit[7:0] encode(bit[7:0] data);
      return data ^ key;
    endfunction

    virtual function bit[7:0] decode(bit[7:0] data);
      return data ^ key;  // XOR is symmetric
    endfunction
  endclass

  initial begin
    ReadTransaction rt;
    WriteTransaction wt;
    Transaction t;
    XorCodec codec;
    bit[7:0] original, encoded;
    static int pass_count = 0;
    static int fail_count = 0;

    // Test 1: Create concrete class with pure virtual methods
    rt = new(100);
    if (rt.validate()) begin
      $display("PASS: Test 1 - ReadTransaction validates correctly");
      pass_count++;
    end else begin
      $display("FAIL: Test 1 - ReadTransaction validation failed");
      fail_count++;
    end

    // Test 2: Execute pure virtual method
    rt.execute();
    if (rt.data == 200) begin
      $display("PASS: Test 2 - ReadTransaction execute() works");
      pass_count++;
    end else begin
      $display("FAIL: Test 2 - ReadTransaction execute() failed");
      fail_count++;
    end

    // Test 3: WriteTransaction implementation
    wt = new(50, 999);
    if (wt.validate() && wt.to_string() != "") begin
      $display("PASS: Test 3 - WriteTransaction implementation works");
      pass_count++;
    end else begin
      $display("FAIL: Test 3 - WriteTransaction failed");
      fail_count++;
    end

    // Test 4: Polymorphic array of abstract type
    t = rt;
    if (t.id == rt.id) begin
      $display("PASS: Test 4 - Polymorphic reference works");
      pass_count++;
    end else begin
      $display("FAIL: Test 4 - Polymorphic reference failed");
      fail_count++;
    end

    // Test 5: Abstract codec with verify using encode/decode
    codec = new(8'hAA);
    original = 8'h55;
    encoded = codec.encode(original);
    if (codec.verify(original, encoded)) begin
      $display("PASS: Test 5 - Codec verify() uses pure virtual methods");
      pass_count++;
    end else begin
      $display("FAIL: Test 5 - Codec verify failed");
      fail_count++;
    end

    // Summary
    $display("\n=== Summary: %0d PASS, %0d FAIL ===", pass_count, fail_count);
    if (fail_count == 0)
      $display("PASS: All abstract class tests passed");
    else
      $display("FAIL: Some tests failed");

    $finish;
  end

endmodule
