//
//  Curried.swift
//  Prelude
//
//  Created by Kristofer Hanes on 6/16/17.
//  Copyright © 2017 Kristofer Hanes. All rights reserved.
//

func curried<A, B, Return>(_ fn: @escaping (A, B) -> Return) -> (A) -> (B) -> Return {
  return { a in { b in fn(a, b) } }
}

func curried<A, B, C, Return>(_ fn: @escaping (A, B, C) -> Return) -> (A) -> (B) -> (C) -> Return {
  return { a in { b in { c in fn(a, b, c) } } }
}

func curried<A, B, C, D, Return>(_ fn: @escaping (A, B, C, D) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> Return {
    return { a in { b in { c in { d in fn(a, b, c, d) } } } }
}

func curried<A, B, C, D, E, Return>(_ fn: @escaping (A, B, C, D, E) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> Return {
    return { a in { b in { c in { d in { e in fn(a, b, c, d, e) } } } } }
}

func curried<A, B, C, D, E, F, Return>(_ fn: @escaping (A, B, C, D, E, F) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> Return {
    return { a in { b in { c in { d in { e in { f in fn(a, b, c, d, e, f) } } } } } }
}

func curried<A, B, C, D, E, F, G, Return>(_ fn: @escaping (A, B, C, D, E, F, G) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in fn(a, b, c, d, e, f, g) } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in fn(a, b, c, d, e, f, g, h) } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in fn(a, b, c, d, e, f, g, h, i) } } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, J, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I, J) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (J) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in { j in fn(a, b, c, d, e, f, g, h, i, j) } } } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, J, K, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I, J, K) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (J) -> (K) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in { j in { k in fn(a, b, c, d, e, f, g, h, i, j, k) } } } } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, J, K, L, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I, J, K, L) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (J) -> (K) -> (L) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in { j in { k in { l in fn(a, b, c, d, e, f, g, h, i, j, k, l) } } } } } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, J, K, L, M, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I, J, K, L, M) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (J) -> (K) -> (L) -> (M) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in { j in { k in { l in { m in fn(a, b, c, d, e, f, g, h, i, j, k, l, m) } } } } } } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, J, K, L, M, N, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I, J, K, L, M, N) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (J) -> (K) -> (L) -> (M) -> (N) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in { j in { k in { l in { m in { n in fn(a, b, c, d, e, f, g, h, i, j, k, l, m, n) } } } } } } } } } } } } } }
}

func curried<A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, Return>(_ fn: @escaping (A, B, C, D, E, F, G, H, I, J, K, L, M, N, O) -> Return)
  -> (A) -> (B) -> (C) -> (D) -> (E) -> (F) -> (G) -> (H) -> (I) -> (J) -> (K) -> (L) -> (M) -> (N) -> (O) -> Return {
    return { a in { b in { c in { d in { e in { f in { g in { h in { i in { j in { k in { l in { m in { n in { o in fn(a, b, c, d, e, f, g, h, i, j, k, l, m, n, o) } } } } } } } } } } } } } } }
}
