# Exercise 06: Laziness
# Run: nix eval -f training/01-language/exercises/e06-laziness.nix
#
# These exercises demonstrate lazy evaluation.
# Watch stderr for `trace:` output to understand evaluation order.

let
  # ── Exercise 1: Unused throw ──────────────────────────────────────────

  # TODO: What does this evaluate to? The throw is in an unused attribute.
  ex1 =
    let
      s = {
        safe = 42;
        dangerous = throw "this should not be reached";
      };
    in
    # TODO: Access only the safe value. Replace null.
    s.safe;
  # EXPECTED: 42

  # ── Exercise 2: Trace ordering ────────────────────────────────────────

  # Run this and observe the trace output on stderr.
  # TODO: Predict which trace messages will appear and in what order,
  # then replace the null with the final result value.
  ex2 =
    let
      a = builtins.trace "A evaluated" 10;
      b = builtins.trace "B evaluated" 20;
      c = builtins.trace "C evaluated" 30;
    in
    # Only a and c are used
    a + c;
  # TODO: What is the result? What traces appear?
  ex2_answer = 40;
  # EXPECTED: 40
  # TRACES: "A evaluated" and "C evaluated" (NOT "B evaluated")

  # ── Exercise 3: seq forces evaluation ─────────────────────────────────

  # TODO: Will this succeed or throw? Replace null with the result if it succeeds.
  ex3 =
    let
      x = {
        a = 1;
        b = throw "hidden error";
      };
    in
    builtins.seq x x.a;
  # HINT: seq forces x to WHNF (weak head normal form) — for attrsets,
  # this means "the attrset exists" but doesn't force individual values.
  ex3_answer = 1;
  # EXPECTED: 1 (seq only forces the attrset to exist, not its members)

  # ── Exercise 4: deepSeq forces everything ─────────────────────────────

  # TODO: Will `builtins.deepSeq { a = 1; b = throw "boom"; } "ok"` succeed?
  ex4_succeeds = false;
  # EXPECTED: false (deepSeq recursively forces everything, triggering the throw)

  # ── Exercise 5: Lazy attrset as infinite stream ───────────────────────

  # This defines an infinite stream using attrsets (which are lazily evaluated).
  nats = start: {
    head = start;
    tail = nats (start + 1);
  };

  take = n: s: if n == 0 then [ ] else [ s.head ] ++ take (n - 1) s.tail;

  # TODO: Use take to get the first 5 natural numbers starting from 0
  first_five = take 5 (nats 0);
  # EXPECTED: [ 0 1 2 3 4 ]

  # ── Exercise 6: Lazy config pattern ───────────────────────────────────

  # This pattern is common in NixOS modules — config values reference each other.
  # It works because of laziness.
  config = {
    hostname = "zeus";
    greeting = "Welcome to ${config.hostname}";
    banner = "${config.greeting}! Type 'help' for commands.";
  };

  # TODO: What is config.banner?
  banner_value = "Welcome to zeus! Type 'help' for commands.";
  # EXPECTED: "Welcome to zeus! Type 'help' for commands."

in
{
  ex1_unused_throw = ex1 == 42;
  ex2_trace_order = ex2 == 40 && ex2_answer == 40;
  ex3_seq = ex3 == 1 && ex3_answer == 1;
  ex4_deepseq = ex4_succeeds == false;
  ex5_infinite =
    first_five == [
      0
      1
      2
      3
      4
    ];
  ex6_lazy_config = banner_value == "Welcome to zeus! Type 'help' for commands.";
}
