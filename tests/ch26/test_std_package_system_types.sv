/*
:name: test_std_package_system_types
:description: The std built-in package provides the semaphore, mailbox, randomize, process and weak_reference facilities, each with the semantics of its own clause, and its names are also visible without the std:: prefix (IEEE 1800-2023 Sections G.1, G.2 and 26.7)
:tags: ch26
:type: simulation
:lrm: 1800-2023 26.7 G.1 G.2
:oracle: spec
:spec_check: ai
:fourstate: no
:nondeterministic: no
:expected_stdout: @test_std_package_system_types.expected
*/
// IEEE 1800-2023 §G.1 and G.2: the standard built-in package contains the
// semaphore class, the mailbox class, the randomize function, the process
// class and the weak reference class, whose semantics the clauses those
// subclauses name define. §26.7: the package is implicitly wildcard imported
// into the compilation-unit scope, so its names are also usable without the
// std:: prefix.
//
// The test takes a key from a semaphore and puts it back, sends an int through
// a mailbox, reads the status of the current process, randomizes a variable
// with std::randomize, and follows an object through a weak reference until it
// is cleared. Then it uses a semaphore and the process class by their
// unqualified names, which reach them through the implicit wildcard import.

module test_std_package_system_types;
  class item;
    int id;
    function new(int id);
      this.id = id;
    endfunction
  endclass

  initial begin
    static std::semaphore keys = new(1);
    static std::mailbox #(int) box = new(1);
    static std::process here;
    static std::weak_reference #(item) reference;
    static item obj;
    static int got;
    static int value = 0;

    $display("semaphore takes one key %0d", keys.try_get(1) == 1);
    keys.put(1);
    $display("semaphore takes the key back %0d", keys.try_get(1) == 1);

    box.put(42);
    box.get(got);
    $display("mailbox carries an int %0d", got == 42);

    here = std::process::self();
    $display("process is running %0d",
             here.status() == std::process::RUNNING);

    $display("randomize returns 1 %0d",
             std::randomize(value) with { value == 9; } == 1 && value == 9);

    obj = new(5);
    reference = new(obj);
    $display("weak reference finds the object %0d", reference.get() == obj);
    reference.clear();
    $display("cleared weak reference is null %0d", reference.get() == null);

    begin
      static semaphore unqualified = new(1);
      static process mine = process::self();
      $display("unqualified names work %0d %0d",
               unqualified.try_get(1) == 1,
               mine.status() == process::RUNNING);
    end
    $finish;
  end
endmodule
