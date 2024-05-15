require import AllCore Real List StdBigop.
import RField.
import Bigreal Bigreal.BRA.
require import StdOrder.
import RealOrder.
require import RealLub RealFLub.

(* Extending RealFlub for closed intervals *)

op glb xs = - (lub (xs \o Real.([ - ]))).

op flub_in (f : real -> real) (x0 x1 : real) = flub (fun x =>
  if x0 <= x /\ x <= x1 then f x else minr (f x0) (f x1)).

op fglb_in f x0 x1 = - (flub_in (f \o Real.([ - ])) x0 x1).

lemma flub_in_upper_bound f (x0 x1 x : real) :
  x0 <= x =>
  x <= x1 =>
  f x <= flub_in f x0 x1.
proof. admitted.

lemma fglb_in_lower_bound f (x0 x1 x : real) :
  x0 <= x =>
  x <= x1 =>
  fglb_in f x0 x1 <= f x.
proof. admitted.

lemma flub_in_subset f (x0 x1 x0' x1' : real) :
  x0 <= x0' =>
  x1' <= x1 =>
  x0' <= x1' =>
  flub_in f x0' x1' <= flub_in f x0 x1.
proof. admitted.

lemma fglb_in_subset f (x0 x1 x0' x1' : real) :
  x0 <= x0' =>
  x1' <= x1 =>
  x0' <= x1' =>
  fglb_in f x0 x1 <= fglb_in f x0' x1'.
proof. admitted.

(* standard delta-epsilon definition of a limit *)
op is_lim (f : real -> real) (x y : real) =
  forall dy, 0%r < dy =>
  (exists dx, 0%r < dx /\ forall x', x' <> x => `|x' - x| < dx => `|f x' - y| < dy).

lemma lim_unique f x y0 y1 :
  is_lim f x y0 => is_lim f x y1 => y0 = y1.
proof.
move => is_lim_y0 is_lim_y1.
apply (absurd true) => [ne_ys /=|//].
pose eps := `|y0 - y1| / 4%r.
have is_lim_y0': exists dx, 0%r < dx /\ forall x', x' <> x => `|x' - x| < dx => `|f x' - y0| < eps.
- by apply is_lim_y0 => /#.
have is_lim_y1': exists dx, 0%r < dx /\ forall x', x' <> x => `|x' - x| < dx => `|f x' - y1| < eps.
- by apply is_lim_y1 => /#.
clear is_lim_y0 is_lim_y1.
case is_lim_y0' => [dx0 [gt0_dx0 is_lim_y0]].
case is_lim_y1' => [dx1 [gt0_dx1 is_lim_y1]].
pose x0 := x + minr dx0 dx1 / 2%r.
have ?: `|f x0 - y0| < eps by smt().
have ?: `|f x0 - y1| < eps by smt().
smt().
qed.

op lim_exists f x = exists y, is_lim f x y.
op lim f x = choiceb (is_lim f x) 0%r.
op continuous_at f x = (lim_exists f x /\ lim f x = f x).
op continuous f = forall x, continuous_at f x.

lemma continuous_flub_fglb (f : real -> real) (x eps : real) :
  continuous_at f x =>
  exists dx,
  0%r < dx /\
  flub_in f (x - dx) (x + dx) < (f x + eps) /\
  fglb_in f (x - dx) (x + dx) > f x - eps.
proof. admitted.

op lower_sum f xs =
  bigi predT
  (fun i =>
    let x0 = nth 0%r xs i in
    let x1 = nth 0%r xs (i + 1) in
    fglb_in f x0 x1 * (x1 - x0))
  0 (size xs - 1).

op is_partition xs x0 x1 =
  sorted Real.(<=) xs /\
  xs <> [] /\
  head 0%r xs = x0 /\
  last 0%r xs = x1.

op split_partition_to (xs : real list) (x : real) =
  filter (fun a => a <= x) xs ++ [x].

lemma sorted_split_partition_to xs x :
  xs <> [] =>
  x >= head 0%r xs =>
  sorted Real.(<=) xs =>
  sorted Real.(<=) (split_partition_to xs x).
proof. admitted.

lemma head_split_partition_to xs x :
  xs <> [] =>
  x >= head 0%r xs =>
  head 0%r (split_partition_to xs x) = head 0%r xs.
proof. admitted.

lemma last_split_partition_to xs x :
  last 0%r (split_partition_to xs x) = x.
proof. smt(last_cat). qed.

lemma is_partition_split_to xs (x0 x1 x2 : real) :
  x0 <= x1 =>
  x1 <= x2 =>
  is_partition xs x0 x2 =>
  is_partition (split_partition_to xs x1) x0 x1.
proof. admitted.

op split_partition_from (xs : real list) (x : real) =
  x :: filter (fun a => a >= x) xs.

lemma sorted_split_partition_from xs x :
  xs <> [] =>
  x >= head 0%r xs =>
  sorted Real.(<=) xs =>
  sorted Real.(<=) (split_partition_from xs x).
proof.
admitted.

lemma head_split_partition_from xs x :
  head 0%r (split_partition_from xs x) = x.
proof. smt(). qed.

lemma last_split_partition_from xs x :
  xs <> [] =>
  x <= last 0%r xs =>
  last 0%r (split_partition_from xs x) = last 0%r xs.
proof. admitted.

lemma is_partition_split_from xs (x0 x1 x2 : real) :
  x0 <= x1 =>
  x1 <= x2 =>
  is_partition xs x0 x2 =>
  is_partition (split_partition_from xs x1) x1 x2.
proof. admitted.

lemma split_lower_sum x f xs :
  xs <> [] =>
  x >= head 0%r xs =>
  x <= last 0%r xs =>
  lower_sum f xs = lower_sum f (split_partition_to xs x) + lower_sum f (split_partition_from xs x).
proof. admitted.

op is_lower_sum f x0 x1 y =
  exists xs,
  is_partition xs x0 x1 /\
  lower_sum f xs = y.

lemma has_lub_lower_sum f x0 x1 :
  has_lub (is_lower_sum f x0 x1).
proof.
print has_lub.
admitted.

op integral f x0 x1 = lub (is_lower_sum f x0 x1).

lemma lower_sum_le_integral f x0 x1 y :
  is_lower_sum f x0 x1 y =>
  y <= integral f x0 x1.
proof.
print integral.
admitted.

lemma is_lower_sum_cat f (x1 x0 x2 aL aR : real) :
  x0 <= x1 =>
  x1 <= x2 =>
  is_lower_sum f x0 x1 aL =>
  is_lower_sum f x1 x2 aR =>
  is_lower_sum f x0 x2 (aL + aR).
proof. admitted.

lemma integral_const (c x0 x1 : real) :
  x0 <= x1 =>
  integral (fun x => c) x0 x1 = c * (x1 - x0).
proof.
admitted.

lemma integral_le (f1 f2 : real -> real) (x0 x1 : real) :
  (forall x, x0 <= x => x <= x1 => f1 x <= f2 x) =>
  integral f1 x0 x1 <= integral f2 x0 x1.
proof. admitted.

lemma integral_lb f (x0 x1 : real) :
  x0 <= x1 =>
  fglb_in f x0 x1 * (x1 - x0) <= integral f x0 x1.
proof.
move => le_x0_x1.
rewrite -(integral_const (fglb_in f x0 x1) x0 x1) //=.
apply integral_le => x lb_x ub_x /=.
exact fglb_in_lower_bound.
qed.

lemma integral_ub f (x0 x1 : real) :
  x0 <= x1 =>
  integral f x0 x1 <= flub_in f x0 x1 * (x1 - x0).
proof.
move => ?.
rewrite -(integral_const (flub_in f x0 x1) x0 x1) //=.
apply integral_le => ??? /=.
exact flub_in_upper_bound.
qed.

(* Consider define in terms of lower sum instead? *)
op upper_sum f xs =
  bigi predT
  (fun i =>
    let x0 = nth 0%r xs i in
    let x1 = nth 0%r xs (i + 1) in
    flub_in f x0 x1 * (x1 - x0))
  0 (size xs - 1).

op is_upper_sum f x0 x1 y =
  exists xs,
  is_partition xs x0 x1 /\
  upper_sum f xs = y.

op upper_integral f x0 x1 = glb (is_upper_sum f x0 x1).

(* This is a bit coarse.
 * Might be useful to define this on intevals instead. *)
op integrable f = forall x0 x1, (integral f x0 x1 = upper_integral f x0 x1).

op differential (f : real -> real) (x dx : real) = (f (x + dx) - f x) / dx.

op derive f x = lim (differential f x) 0%r.

op differentiable_at f x = lim_exists (differential f x) 0%r.

(*
lemma integral_xx f x :
  integral f x x = 0%r.
proof. admitted.
*)

lemma integral_split_le f (x1 x0 x2 : real) :
  x0 <= x1 => x1 <= x2 =>
  integral f x0 x2 <= integral f x0 x1 + integral f x1 x2.
proof.
move => le_x0_x1 le_x1_x2.
apply lub_le_ub; first exact has_lub_lower_sum.
move => s is_lower_sum_s.
case is_lower_sum_s => xs [is_partition_xs is_sum_xs].
rewrite (split_lower_sum x1) //= in is_sum_xs; 1,2,3:smt().
subst.
suff: lower_sum f (split_partition_to xs x1) <= integral f x0 x1 /\
  lower_sum f (split_partition_from xs x1) <= integral f x1 x2 by smt().
split.
- apply lower_sum_le_integral.
  exists (split_partition_to xs x1) => /=.
  exact (is_partition_split_to xs x0 x1 x2).
- apply lower_sum_le_integral.
  exists (split_partition_from xs x1) => /=.
  exact (is_partition_split_from xs x0 x1 x2).
qed.

lemma ler_sum_lub (E1 E2 E3 : real -> bool) :
  nonempty E1 => has_lub E2 => has_lub E3 =>
  (forall x1 x2, E1 x1 => E2 x2 => exists x3, E3 x3 /\ x1 + x2 <= x3) =>
  lub E1 + lub E2 <= lub E3.
proof.
move => ?? lub2 lub3.
have lub1: has_lub E1.
- split; first smt().
  exists (lub E3 - lub E2).
  move => x1 E1x1.
  suff: forall eps, 0%r < eps => x1 + (lub E2 - eps) <= lub E3.
  + move => ?.
    pose eps' := (lub E3 - lub E2 - x1) / 2%r.
    have ?: x1 + (lub E2 - eps') <= lub E3 by smt().
    smt().
  move => eps gt0_eps.
  have [x2 ?] : exists x2, E2 x2 /\ lub E2 - eps < x2.
  + exact lub_adherent.
  smt(lub_upper_bound).
suff: forall eps, 0%r < eps => (lub E1 - eps) + (lub E2 - eps) <= lub E3.
- move => ?.
  pose eps' := (lub E1 + lub E2 - lub E3) / 4%r.
  have ?: lub E1 - eps' + (lub E2 - eps') <= lub E3 by smt().
  smt().
move => eps gt0_eps.
have [x1 ?]: exists x1, E1 x1 /\ lub E1 - eps < x1.
- exact lub_adherent.
have [x2 ?]: exists x2, E2 x2 /\ lub E2 - eps < x2.
- exact lub_adherent.
apply (ler_trans (x1 + x2)); first smt().
have [x3 ?] : exists x3, E3 x3 /\ x1 + x2 <= x3 by smt().
smt(lub_upper_bound).
qed.

lemma integral_split_ge f (x1 x0 x2 : real) :
  x0 <= x1 => x1 <= x2 =>
  integral f x0 x2 >= integral f x0 x1 + integral f x1 x2.
proof.
move => le_x0_x1 le_x1_x2.
apply ler_sum_lub; 1,2,3: smt(has_lub_lower_sum).
smt(is_lower_sum_cat).
qed.

lemma integral_split f (x1 x0 x2 : real) :
  x0 <= x1 => x1 <= x2 =>
  integral f x0 x2 = integral f x0 x1 + integral f x1 x2.
proof. smt(integral_split_le integral_split_ge). qed.

lemma fundamental_theorem_of_calculus (f : real -> real) (x x0 : real) :
  x0 < x =>
  continuous_at f x =>
  integrable f =>
  differentiable_at (integral f x0) x /\
  derive (integral f x0) x = f x.
proof.
move => order_xs continuous_f integrable_f.
suff: is_lim (differential (integral f x0) x) 0%r (f x).
- smt(lim_unique choicebP).
move => dy gt0_dy /=.
pose dy' := minr dy 0.5.
apply (continuous_flub_fglb f x dy') in continuous_f.
case continuous_f => [dx0 [gt0_dx0 [ub_f lb_f]]].
pose dx1 := dy' / (2%r * `|f x| + dy').
pose dx2 := x - x0.
exists (minr dx0 (minr dx1 dx2)).
split => [/#| h ne0_h small_h].
rewrite /differential.
case (0%r < h) => [gt0_h|le0_h].
- rewrite (integral_split f x); 1,2:smt().
  have ->: integral f x0 x + integral f x (x + h) - integral f x0 x = integral f x (x + h) by smt().
  case (0%r <= integral f x (x + h) / h - f x).
  + smt(ler_pdivr_mulr integral_ub flub_in_subset).
  + smt(ler_pdivl_mulr integral_lb fglb_in_subset).
- rewrite (integral_split f (x + h) x0 x); 1,2:smt().
  have -> /=: integral f x0 (x + h) - (integral f x0 (x + h) + integral f (x + h) x) = - integral f (x + h) x by smt().
  case (0%r <= (- integral f (x + h) x) / h - f x).
  + suff: (- integral f (x + h) x) / h - f x < dy by smt().
    apply (ler_lt_trans (flub_in f (x + h) x - f x)); last smt(flub_in_subset).
    suff: (- integral f (x + h) x) / h <= (flub_in f (x + h) x) by smt().
    by apply ler_ndivr_mulr; smt(integral_ub).
  + suff: integral f (x + h) x / h + f x < dy by smt().
    apply (ler_lt_trans (- fglb_in f (x + h) x + f x)); last smt(fglb_in_subset).
    suff: integral f (x + h) x / h <= - fglb_in f (x + h) x by smt().
    apply ler_ndivr_mulr; smt(integral_lb).
qed.
