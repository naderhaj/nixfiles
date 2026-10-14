# Exercise 02: Functions
# Run: nix eval -f training/01-language/exercises/e02-functions.nix
#
# Replace `null` with working implementations.

let
  # ── Exercise 1: Write basic functions ─────────────────────────────────

  # TODO: Write a function that doubles its argument
  double = x: x * 2;
  # EXPECTED: double 5 == 10

  # TODO: Write a curried add function: add a b = a + b
  add = a: b: a + b;
  # EXPECTED: add 3 4 == 7

  # TODO: Use partial application: create `add10` from `add`
  # HINT: add10 = add ???;
  add10 = a: add a 10;
  # EXPECTED: add10 5 == 15

  # ── Exercise 2: Write compose ─────────────────────────────────────────

  # TODO: Write function composition: compose f g x = f(g(x))
  compose =
    f: g: x:
    f (g x);
  # EXPECTED: compose (x: x + 1) (x: x * 2) 3 == 7

  # ── Exercise 3: Destructuring ─────────────────────────────────────────

  # TODO: Write a function that takes { name, age } and returns a greeting string
  greet = { name, age }: "${name} is ${toString age}";
  # EXPECTED: greet { name = "Nader"; age = 30; } == "Nader is 30"
  # HINT: Use toString for the age

  # TODO: Write a function that takes { a, b, ... } and returns a + b,
  # ignoring any extra attributes
  addAB = { a, b, ... }: a + b;
  # EXPECTED: addAB { a = 1; b = 2; c = 3; } == 3

  # ── Exercise 4: Default values ────────────────────────────────────────

  # TODO: Write a function that takes { host, port ? 8080 } and returns "host:port"
  endpoint =
    {
      host,
      port ? 8080,
    }:
    "${host}:${toString port}";
  # EXPECTED: endpoint { host = "localhost"; } == "localhost:8080"
  # EXPECTED: endpoint { host = "localhost"; port = 3000; } == "localhost:3000"
  # HINT: toString for port

  # ── Exercise 5: @-pattern ─────────────────────────────────────────────

  # TODO: Write a function that takes { x, y, ... } @ args
  # and returns args // { sum = x + y; }
  addSum = { x, y, ... }@args: args // { sum = x + y; };
  # EXPECTED: addSum { x = 1; y = 2; z = 3; } == { x = 1; y = 2; z = 3; sum = 3; }

  # ── Exercise 6: foldl' ────────────────────────────────────────────────

  # TODO: Use builtins.foldl' to compute the product of [ 1 2 3 4 5 ]
  product = builtins.foldl' (acc: x: acc * x) 1 [
    1
    2
    3
    4
    5
  ];
  # EXPECTED: 120
  # HINT: builtins.foldl' (acc: x: ???) 1 [ 1 2 3 4 5 ]

in
{
  ex1_basic = double 5 == 10 && add 3 4 == 7 && add10 5 == 15;

  ex2_compose = compose (x: x + 1) (x: x * 2) 3 == 7;

  ex3_destructuring =
    greet {
      name = "Nader";
      age = 30;
    } == "Nader is 30"
    &&
      addAB {
        a = 1;
        b = 2;
        c = 3;
      } == 3;

  ex4_defaults =
    endpoint { host = "localhost"; } == "localhost:8080"
    &&
      endpoint {
        host = "localhost";
        port = 3000;
      } == "localhost:3000";

  ex5_at_pattern =
    addSum {
      x = 1;
      y = 2;
      z = 3;
    } == {
      x = 1;
      y = 2;
      z = 3;
      sum = 3;
    };

  ex6_foldl = product == 120;
}
