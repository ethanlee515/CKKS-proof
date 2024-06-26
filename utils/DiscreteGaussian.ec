require import AllCore Distr List.
require import RealExp.
require import RealSeries.
require import StdBigop.
import Bigreal Bigreal.BRA.

(* -- uninteresting helper lemma: geometric series converges -- *)

op geometric (r : real) (i : int) = if i < 0 then 0%r else r ^ i.

lemma ge0_geo r i : 0%r <= r => 0%r <= geometric r i.
proof.
move => ge0_r.
case (i < 0) => [|ge0_i]; first smt().
by rewrite /geometric ge0_i /= StdOrder.RealOrder.expr_ge0.
qed.

lemma ge0_big_geo F r S:
  0%r <= r =>
  0%r <= big F (geometric r) S.
proof.
move => ?.
apply (big_ind (fun x => 0%r <= x)); smt(ge0_geo).
qed.

lemma bigi_geoE r n :
  0 <= n =>
  r <> 1%r =>
  bigi predT (geometric r) 0 n = (1%r - r ^ n) / (1%r - r).
proof.
move => ge0_n ne1_r.
case (0 < n); last first => [eq0_n|gt0_n].
- have ->: n = 0 by smt().
  rewrite RField.expr0 /=.
  exact big_geq.
rewrite (RField.eqr_div (bigi predT (geometric r) 0 n) 1%r) => [//|/#|/=].
rewrite RField.mulrDr RField.mulrN /=.
rewrite mulr_suml /=.
rewrite (big_int_recl (n - 1)) /=; first smt().
have ->: geometric r 0 = 1%r.
- by rewrite /geometric /= RField.expr0.
rewrite (big_int_recr (n - 1)) /=; first smt().
have ->: geometric r (n - 1) * r = r ^ n by smt(RField.exprS).
smt(eq_big_int RField.exprS).
qed.

lemma filter_subset (xs ys: 'a list) :
  uniq xs => uniq ys =>
  mem xs <= mem ys =>
  perm_eq xs (filter (mem xs) ys).
proof.
move => uniq_xs uniq_ys is_subset.
apply uniq_perm_eq => // [|x].
- exact filter_uniq.
by rewrite mem_filter => /#.
qed.

(* complement of s in range(max(s)) *)
op compl (s: int list) = filter (predC (mem s)) (range 0 (listmax Int.(<=) 0 s + 1)).

lemma subset_range (xs : int list) (n : int) :
  uniq xs =>
  all (fun x => 0 <= x) xs =>
  all (fun x => x < n) xs =>
  mem xs <= mem (range 0 n).
proof. smt(mem_range allP). qed.

lemma split_range s :
  uniq s =>
  all (fun x => 0 <= x) s =>
  perm_eq (range 0 (listmax Int.(<=) 0 s + 1)) (s ++ compl s).
proof.
move => uniq_s ge0_s.
rewrite perm_eq_sym.
pose rg := range 0 (listmax Int.(<=) 0 s + 1).
pose p := mem s.
apply (perm_eq_trans (filter (mem s) rg ++ compl s)); last first.
- exact perm_filterC.
apply perm_cat2r.
apply filter_subset => //; first exact range_uniq.
apply subset_range => //.
apply allP => //= x mem_x.
suff: x <= listmax Int.(<=) 0 s.
- pose n := listmax Int.(<=) 0 s.
  smt().
apply listmax_gt_in => /#.
qed.

op geq0 x = (0 <= x).

(* It is possible to strengthen this and deal with -1 <= r < 0 too.
 * Too much headache involved however. *)
lemma summable_geometric r :
  (0%r <= r < 1%r) =>
  summable (geometric r).
proof.
move => [ge0_r lt1_r].
exists (1%r / (1%r - r)) => J uniq_J.
have ->: (fun i => `|geometric r i|) = (geometric r).
- apply fun_ext => i.
  smt(ge0_geo).
rewrite (eq_big_perm _ _ _ (filter geq0 J ++ filter (predC geq0) J)).
- by rewrite perm_eq_sym perm_filterC.
rewrite big_cat.
have -> /=: big predT (geometric r) (filter (predC geq0) J) = 0%r.
- clear uniq_J.
  elim J => [|head tail iH].
  + exact big_nil.
  rewrite filter_cons.
  case (predC geq0 head) => //= ?.
  by rewrite big_consT /#.
pose J_pos := filter geq0 J.
have uniq_J_pos : uniq J_pos.
- exact filter_uniq.
apply (StdOrder.RealOrder.ler_trans
  (bigi predT (fun i => geometric r i) 0 (listmax Int.(<=) 0 J_pos + 1))).
- rewrite (eq_big_perm _ _ (range _ _) (J_pos ++ compl J_pos)) /=.
  + apply split_range => //.
    apply allP => /= x mem_x.
    smt(mem_filter).
  rewrite big_cat.
  smt(ge0_big_geo).
rewrite bigi_geoE; 2: smt().
- suff: 0 <= listmax Int.(<=) 0 J_pos.
  + pose m := listmax Int.(<=) 0 J_pos.
    smt().
  case (J_pos = []) => [/#|?].
  apply (StdOrder.IntOrder.ler_trans (head 0 J_pos)).
  + have H: (head 0 J_pos) \in J_pos by smt().
    smt(mem_filter).
  by apply listmax_gt_in => /#.
pose x := r ^ (listmax Int.(<=) 0 J_pos + 1).
suff: 0%r <= x by smt().
exact StdOrder.RealOrder.expr_ge0.
qed.

(* Discrete Gaussian over integers with expected value 0 *)

(* un-normalized Gaussian *)
op gaussian s x : real = exp (- (x%r / s) ^ 2 / 2%r).

lemma even_gaussian s x :
  gaussian s x = gaussian s (-x).
proof. smt(RField.sqrrN). qed.

op gauss_geo s = exp (- (1%r / s) ^ 2 / 2%r).

lemma le_gaussian_geometric s x :
  0%r < s =>
  0 <= x =>
  gaussian s x <= geometric (gauss_geo s) x.
proof.
move => gt0_s ge0_x.
apply (intind (fun x => gaussian s x <= geometric (gauss_geo s) x)) => //=.
- rewrite /gaussian /geometric /gauss_geo /=.
  rewrite RField.expr0.
  smt(RField.expr2 exp0).
clear ge0_x x.
move => x ge0_x iH.
apply (StdOrder.RealOrder.ler_trans (gauss_geo s * gaussian s x)).
- rewrite /gaussian /gauss_geo.
  rewrite -expD.
  apply exp_mono.
  rewrite !RField.expr2 /#.
apply (StdOrder.RealOrder.ler_trans (gauss_geo s * geometric (gauss_geo s) x)).
- apply StdOrder.RealOrder.ler_pmul2l => //.
  exact exp_gt0.
smt(RField.exprS).
qed.

lemma summable_gaussian s :
  0%r < s =>
  summable (gaussian s).
proof.
move => gt0_s.
pose k := exp (- (1%r / s) ^ 2 / 2%r).
apply (summable_le (fun x => (geometric k x + geometric k (-x)))) => [|x /=].
- have ?: summable (geometric k).
  + apply summable_geometric.
    split => [|_]; first smt(exp_gt0).
    by rewrite -exp0 exp_mono_ltr RField.expr2 /#.
  apply summableD => //. 
  by apply (summable_inj (fun (x: int) => -x) (geometric k)) => /#.
case (0 < x) => [gt0_x|le0_x].
- have -> /=: geometric k (-x) = 0%r by smt().
  rewrite /"`|_|".
  have -> /=: 0%r <= gaussian s x by smt(exp_gt0).
  have -> /=: 0%r <= geometric k x by smt(ge0_geo exp_gt0).
  apply le_gaussian_geometric => /#.
case (x = 0) => [|lt0_x]; first smt(RField.expr2 RField.expr0 exp0).
have -> /=: geometric k x = 0%r by smt().
rewrite /"`|_|".
have -> /=: 0%r <= gaussian s x by smt(exp_gt0).
have -> /=: 0%r <= geometric k (-x) by smt(ge0_geo exp_gt0).
rewrite even_gaussian.
apply le_gaussian_geometric => /#.
qed.

lemma gt0_sum_gaussian s :
  0%r < s =>
  0%r < sum (gaussian s).
proof.
move => gt0_s.
rewrite (sumD1 (gaussian s) 0); first exact summable_gaussian.
suff: 0%r < gaussian s 0 /\ 0%r <= sum (fun x => if x <> 0 then gaussian s x else 0%r).
- smt().
split; first exact exp_gt0.
apply ge0_sum; smt(exp_gt0).
qed.

op discrete_gaussian_pdf s x = gaussian s x / sum (gaussian s).

lemma isdistr_discrete_gaussian s :
  0%r < s =>
  isdistr (discrete_gaussian_pdf s).
proof.
move => gt0_s.
split => [x|J uniq_J]; first smt(gt0_sum_gaussian exp_gt0).
rewrite /discrete_gaussian_pdf -mulr_suml.
have ->: (fun i => gaussian s i) = gaussian s by trivial.
suff: big predT (gaussian s) J <= sum (gaussian s).
- move => ?.
  apply StdOrder.RealOrder.ler_pdivr_mulr => //.
  exact gt0_sum_gaussian.
apply ler_big_sum; smt(exp_gt0 summable_gaussian).
qed.

op discrete_gaussian s = mk (discrete_gaussian_pdf s).

lemma discrete_gaussian1E s x :
  0%r < s =>
  mu1 (discrete_gaussian s) x = discrete_gaussian_pdf s x.
proof. smt(muK' isdistr_discrete_gaussian). qed.

lemma discrete_gaussian_ll s :
  0%r < s =>
  is_lossless (discrete_gaussian s).
proof.
move => gt0_s.
rewrite /is_lossless weightE.
have ->: mu1 (discrete_gaussian s) = discrete_gaussian_pdf s.
- apply fun_ext => ?.
  exact discrete_gaussian1E.
rewrite sumZr; smt(gt0_sum_gaussian).
qed.

lemma discrete_gaussian_fu s :
  0%r < s =>
  is_full (discrete_gaussian s).
proof.
move => gt0_s x.
apply supportP.
rewrite discrete_gaussian1E //.
smt(exp_gt0 gt0_sum_gaussian).
qed.
