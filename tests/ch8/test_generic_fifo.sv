/*
:name: test_generic_fifo
:description: Parameterized class basic test (IEEE 1800-2023 8.25)
:tags: ch8
:type: simulation
:lrm: 1800-2023 8.25 7.10
:oracle: spec verilator@5.052
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_generic_fifo.expected
*/
// Parameterized class basic test (IEEE 1800-2023 8.25)
class generic_fifo #(type T = int, int DEPTH = 8);
  T queue[$];

  function void push(T item);
    if (queue.size() < DEPTH)
      queue.push_back(item);
    else
      $fatal(1, "FIFO full");
  endfunction

  function T pop();
    if (queue.size() > 0)
      return queue.pop_front();
    else
      $fatal(1, "FIFO empty");
  endfunction

  function int size();
    return queue.size();
  endfunction
endclass

typedef generic_fifo#(bit[7:0], 16) byte_fifo_t;
typedef generic_fifo#(int, 32) int_fifo_t;

module test_generic_fifo;
  initial begin
    static byte_fifo_t bf = new();
    static int_fifo_t  ifq = new();

    // Byte FIFO
    bf.push(8'hAA);
    bf.push(8'hBB);
    assert(bf.size() == 2);
    assert(bf.pop() == 8'hAA);

    // Int FIFO
    ifq.push(123);
    ifq.push(456);
    assert(ifq.size() == 2);
    assert(ifq.pop() == 123);

    $display("Parameterized class test PASSED");
    $finish;
  end
endmodule
