from utils import load_and_predict, load_and_predict_probabilities
import argparse

# Set up the argument parser
parser = argparse.ArgumentParser(description="Predict gestational age using a pre-trained model.")
parser.add_argument("--input", type=str, default="/input", help="Input directory [default=/input]")
parser.add_argument("--output", type=str, default="/output", help="Output directory [default=/output]")
parser.add_argument("--data", type=str, default="data", help="Data directory [default=data]")
parser.add_argument("--extdata", type=str, default="inst/extdata", help="Extension data directory [default=inst/extdata]")
parser.add_argument("--intermediate", type=str, default="intermediate", help="Intermediate data directory [default=intermediate]")
args = parser.parse_args()

extdata = args.extdata
intermediate = args.intermediate



prefix = 'ga_res_conds_fgr_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_pe_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_pe_onset_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_hellp_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_anencephaly_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_spina_bifida_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_diandric_triploid_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_miscarriage_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_preterm_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_gdm_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_lga_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_subfertility_est'
load_and_predict(prefix, extdata, intermediate)

prefix = 'ga_res_conds_chorioamnionitis_est'
load_and_predict(prefix, extdata, intermediate)



prefix = 'fgr_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'pe_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'pe_onset_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'hellp_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'anencephaly_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'spina_bifida_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'diandric_triploid_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'miscarriage_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'preterm_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'gdm_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'lga_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'subfertility_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)

prefix = 'chorioamnionitis_pred'
load_and_predict_probabilities(prefix, extdata, intermediate)
