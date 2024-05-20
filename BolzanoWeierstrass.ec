require import AllCore.
require import RealSeq StdOrder.
import IntOrder.

(* crutch for recursive functions *)
type peano = [ Z | S of peano ].

op peano_to_int p =
with p = Z => 0
with p = S p' => 1 + peano_to_int p'.

op int_to_peano i = iter i S Z.

lemma peano_to_intK p :
  int_to_peano (peano_to_int p) = p.
proof. admitted.

lemma int_to_peanoK i :
  0 <= i =>
  peano_to_int (int_to_peano i) = i.
proof. admitted.

lemma int_to_peano0 :
  int_to_peano 0 = Z.
proof. admitted.

lemma int_to_peano_le0 i :
  i <= 0 =>
  int_to_peano i = Z.
proof. smt(iteri0). qed.

lemma int_to_peanoS i :
  0 < i =>
  int_to_peano i = S (int_to_peano (i - 1)).
proof. admitted.

op real_subseq (s1 s2 : int -> real) =
  exists m, forall i,
  s1 i = s2 (m i) /\ i <= m i.

op is_peak (x_ : int -> real) (p : int) = 0 <= p /\ forall m, p <= m => x_ m <= x_ p.
op no_peaks_after x_ (p : int) = 0 <= p /\ forall n, p <= n => !(is_peak x_ n).
op finite_peaks x_ = exists p, no_peaks_after x_ p.
op is_peak_after (x_ : int -> real) (p' : int) (p : int) = is_peak x_ p /\ p' < p.

op peaks_loc (x_ : int -> real) (i : peano) =
with i = Z => choiceb (is_peak x_) 0
with i = S i' => choiceb (is_peak_after x_ (peaks_loc x_ i')) 0.
op peaks_val x_ = x_ \o peaks_loc x_ \o int_to_peano.

lemma is_peak_after_gt x_ p :
  !(finite_peaks x_) =>
  p < choiceb (is_peak_after x_ p) 0.
proof.
move => infinite_peaks.
case (p < 0) => ?.
- smt(choicebP).
suff: (is_peak_after x_ p) (choiceb (is_peak_after x_ p) 0) by smt().
apply (choicebP (is_peak_after x_ p)).
have ?: exists n, (p + 1) <= n /\ is_peak x_ n by smt().
smt().
qed.

lemma is_peak_peaks x_ i :
  !(finite_peaks x_) =>
  is_peak x_ (peaks_loc x_ i).
proof.
move => infinite_peaks.
case i => /=.
- smt(choicebP).
move => i.
suff: (is_peak_after x_ (peaks_loc x_ i)) (choiceb (is_peak_after x_ (peaks_loc x_ i)) 0).
- smt().
apply (choicebP (is_peak_after x_ (peaks_loc x_ i))).
pose p := peaks_loc x_ i.
have ?: exists n, (p + 1) <= n /\ is_peak x_ n by smt().
smt().
qed.

lemma peaks_decreasing x_ i :
  !(finite_peaks x_) =>
  peaks_val x_ (i + 1) <= peaks_val x_ i.
proof.
move => infinite_peaks.
rewrite /peaks_val /(\o).
case (i < 0) => ?; first smt(int_to_peano_le0).
rewrite int_to_peanoS /=; first smt().
smt(is_peak_peaks is_peak_after_gt).
qed.

lemma peaks_subseq x_ :
  !(finite_peaks x_) =>
  real_subseq (peaks_val x_) x_.
proof.
move => infinite_peaks.
rewrite /peaks_val /(\o).
exists (peaks_loc x_ \o int_to_peano).
rewrite /(\o) => i /=.
case (i < 0) => [?|ge0_i].
- rewrite int_to_peano_le0; smt(choicebP).
apply (intind (fun i => i <= peaks_loc x_ (int_to_peano i))) => /=; last smt().
- rewrite int_to_peano0; smt(choicebP).
clear ge0_i i => i ge0_i ub_i.
rewrite int_to_peanoS /=; smt(is_peak_after_gt).
qed.

lemma peaks_lb x_ a :
  !(finite_peaks x_) =>
  (forall i, a <= x_ i) =>
  (forall i, a <= peaks_val x_ i).
proof. smt(peaks_subseq). qed.

op incr_loc x_ (i : peano) =
with i = Z => choiceb (no_peaks_after x_) 0
with i = S i' => choiceb (fun n => incr_loc x_ i' < n /\ x_ (incr_loc x_ i') <= x_ n) 0.
op incr_val x_ = x_ \o incr_loc x_ \o int_to_peano.

lemma ge0_incr_loc_SZ x_ :
  finite_peaks x_ =>
  0 <= incr_loc x_ Z.
proof. smt(choicebP). qed.

lemma ge0_incr_loc x_ :
  finite_peaks x_ =>
  0 <= incr_loc x_ (int_to_peano 0).
proof.
move => ?.
rewrite int_to_peano0.
exact ge0_incr_loc_SZ.
qed.

lemma ge0_incr_loc_le0 x_ i :
  i <= 0 =>
  finite_peaks x_ =>
  0 <= incr_loc x_ (int_to_peano i).
proof.
move => ?.
rewrite int_to_peano_le0 //=.
exact ge0_incr_loc_SZ.
qed.

lemma incr_subseq x_ :
  finite_peaks x_ =>
  real_subseq (incr_val x_) x_.
proof. admitted.

(*
lemma y_subseq x_ i :
  (exists p, no_peaks_after x_ p) =>
  i <= y_ x_ (int_to_peano i).
proof.
move => [p [ge0_p H]].
case (0 < i) => ?; last first.
- apply (StdOrder.IntOrder.ler_trans 0).
  + smt().
  by apply ge0_y_le0 => /#.
apply (intind (fun i => i <= y_ x_ (int_to_peano i))); last smt().
- move => //=.
  by apply ge0_y_le0 => /#.
move => //= j ge0_j.
rewrite (int_to_peanoS (j + 1)) /=; first smt().
move => ?.
pose P := (fun (n : int) =>
  y_ x_ (int_to_peano j) < n /\ x_ (y_ x_ (int_to_peano j)) <= x_ n).
suff: exists n, P n.
+ move => ?.
  have [??]: P (choiceb P 0).
  * exact choicebP.
  suff: j < choiceb P 0.
  * admit.
  exact (StdOrder.IntOrder.ler_lt_trans (y_ x_ (int_to_peano j))).
print is_peak.
print no_peaks_after.
admit.
qed.
*)

lemma incr_increasing x_ i :
  finite_peaks x_ =>
  incr_val x_ i <= incr_val x_ (i + 1).
proof. admitted.

(*
lemma fi_diverge : !(converge (%r)).
proof.
suff: converge (%r) => false by smt().
move => [y ?].
have [N ?]: exists (N : int), forall n, N <= n => `|n%r - y| < 0.5 by smt().
pose n := max N (ceil y) + 1.
have ?: `|n%r - y| < 1%r / 2%r by smt().
smt().
qed.
*)

lemma incr_ub x_ (b : real) :
  finite_peaks x_ =>
  (forall i, x_ i <= b) =>
  (forall i, incr_val x_ i <= b).
proof.
move => ? ub_x i.
have [m is_subseq]: real_subseq (incr_val x_) x_.
- exact incr_subseq.
(* smt gives error here.
 * something wrong with pattern-matching in ops I guess.
 * Filling in the proof manually for now. *)
have [H _]: incr_val x_ i = x_ (m i) /\ i <= m i by exact is_subseq.
by rewrite H ub_x.
qed.

lemma diverge_superlinear (f : int -> real) :
  (forall i, i%r <= f i) => !(converge f).
proof.
move => f_superlinear.
suff: converge f => false by smt().
move => [y ?].
have [N ?]: exists (N : int), forall n, N <= n => `|f n - y| < 0.5 by smt().
pose n := max N (ceil y) + 1.
have ?: `|f n - y| < 1%r / 2%r by smt().
smt(ceil_ge).
qed.

lemma subseq_superlinear s' s :
  real_subseq s' s =>
  (forall i, i%r <= s i) =>
  forall i, i%r <= s' i.
proof. smt(). qed.

lemma cnv_bmono_from_decr (s : int -> real) (M : real) (N : int) :
  (forall n p, N <= n && n <= p => s p <= s n) =>
  (forall n, N <= n => M <= s n) => converge s.
proof.
move => ??.
suff: converge (fun x => - s x).
- move => [l ?].
  exists (-l).
  have ->: s = fun x => - (- s x) by exact fun_ext.
  exact cnvtoN.
by apply (cnv_bmono_from _ (-M) N); smt().
qed.

lemma iter_incr (f : int -> real) (a b : int) :
  (forall i, a <= i => i < b => f i <= f (i + 1)) =>
  f a <= f b.
proof. admitted.

lemma iter_decr (f : int -> real) (a b : int) :
  (forall i, a <= i => i < b => f (i + 1) <= f i) =>
  f b <= f a.
proof. admitted.

lemma Bolzano_Weierstrass x_ (a b : real) :
  (forall i, a <= x_ i) =>
  (forall i, x_ i <= b) =>
  (exists x_', real_subseq x_' x_ /\ converge x_').
proof.
move => lb_x ub_x.
case (exists p, no_peaks_after x_ p) => ?.
- exists (incr_val x_).
  (* this should be increasing *)
  split; first exact incr_subseq.
  apply (cnv_bmono_from _ b 0).
  + move => n p ?.
    apply (iter_incr (incr_val x_)) => i lb_i ub_i.
    exact incr_increasing.
  move => n ?.
  exact incr_ub.
- exists (peaks_val x_).
  (* this should be decreasing *)
  split; first exact peaks_subseq.
  apply (cnv_bmono_from_decr _ a 0).
  + move => n p ?.
    apply (iter_decr (peaks_val x_)) => i lb_i ub_i.
    exact peaks_decreasing.
  move => n? .
  exact peaks_lb.
qed.
