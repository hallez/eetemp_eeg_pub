library(readxl)
library(dplyr)

file_path <- "/Users/hrzucker/Dropbox/work/ranganath_lab/data/eetemp/stimuli/BOSS-NORMS-formatted-for-R.xlsx"

file_path_out <- "/Users/hrzucker/workspace/eetemp/experiment-scripts"


name_brodeur <- readxl::read_excel(file_path, sheet = "Brodeur2010_2014a")
name_osulivan <- readxl::read_excel(file_path, sheet = "Osulivan_2013")
category1step <- readxl::read_excel(file_path, sheet = "Brodeur2010_Category1Step")
category2step <- readxl::read_excel(file_path, sheet = "Brodeur2014a_Category2Step")
familiarity <- readxl::read_excel(file_path, sheet = "Brodeur2010_2014a_Familiarity")
visual_complexity <- readxl::read_excel(file_path, sheet = "Brodeur2010_2014a_VisComplexity")
object_agreement <- readxl::read_excel(file_path, sheet = "Brodeur2012_2014a_ObjAgreement")
viewpoint_agreement <- readxl::read_excel(file_path, sheet = "Brodeur2010_2014a_ViewpointAgre")
manipulability <- readxl::read_excel(file_path, sheet = "Brodeur2010_2014a_Manipulabilit")

#' # Filter each dataframe
summary(name_brodeur)

filt_names_brodeur <- 
  name_brodeur %>%
  dplyr::filter(percent_NameAgreement_over_Fq_inputs > 0.29) 

summary(category2step)

filt_category_2step <-
  category2step %>%
  dplyr::filter(percent_Category_Agreement > 0.29)

# familiarity was on a 1-5 scale
summary(familiarity)

filt_familiarity <-
  familiarity %>%
  dplyr::filter(Mean > 2)

# visual complexity on a 1-5 scale
summary(visual_complexity)

filt_visual_complexity <-
  visual_complexity %>%
  dplyr::filter(Mean < 2)

summary(object_agreement)

filt_object_agreement <-
  object_agreement %>%
  dplyr::filter(Mean > 2)

summary(viewpoint_agreement)

filt_viewpoint_agreement <-
  viewpoint_agreement %>%
  dplyr::filter(Mean > 2)

#' # Merge common items
all_filt_merged <-
  dplyr::inner_join(filt_names_brodeur, filt_category_2step, by = c("FILENAME", "Dataset")) %>%
  dplyr::inner_join(., filt_familiarity, by = c("FILENAME", "Dataset"), suffix = c(".nc", ".familiarity")) %>%
  dplyr::inner_join(., filt_object_agreement, by = c("FILENAME", "Dataset"), suffix = c(".familiarity",".object_agreement")) %>%
  dplyr::inner_join(., filt_viewpoint_agreement, by = c("FILENAME", "Dataset"), suffix = c(".object_agreement",".viewpoint_agreement")) %>%
  # including `filt_visual_complexity` substantially limits the stimulus pool, 
  # but let's include complexity data for the stimuli where it exists
  dplyr::left_join(., visual_complexity, by = c("FILENAME", "Dataset"), suffix = c(".viewpoint_agreement",".visual_complexity"))

dim(all_filt_merged)

#' # Filter out other undesirded stimuli
final_stim_list <-
  all_filt_merged %>%
  # filter out unwanted categories
  dplyr::filter(!Modal_category %in% c("Crustacean", "Mammal", "Reptile", "Bird", "Insect", "Canine", "Feline", "Sea mammal", "Fish",
                                       "Bodypart", 
                                       "War related weapon & item")) %>%
  # filter out manually-identified stimuli
  dplyr::filter(!FILENAME %in% c("bowl01", "floortile01", "fork07b", "key01", "kiwi01a", "syringe01", "syringe02", "tambourine03","toyanimal03", "flugglehorn",
                                 "arrow02","harpoon", "americangoldfinch", "cedarwaxwing", "kingfisher", "tern", "car", "englishcucumber", "bassethound", "saintbernard",
                                 "asianelephant", "salmon", "fishskeleton", "daffodil", "cleaver01", "huntingknife", "knife03", "ladder", "highlighter02b", "macaque",
                                 "caribou02", "blackolive", "barnowl", "peach01", "mechanicalpencil02", "uprightpiano01", "pill", "bowrake", "highheelshoe01", "hikingshoe01",
                                 "crosscountryski", "daddylonglegs", "tarantula", "broadsword", "cutlass", "sword01", "stubbywrench01a",
                                 "elbow", "arm", "ear", "eye", "hand", "knee", "lip", "nose", "shoulder", "chefshat", "contactlens", "slug", "tank", "cannon",
                                 "bracelet04", "candle01", "clock04", "cork02", "giftbow04", "hairclip02", "icecube02", "lollipop04", "mailbox01", "mask04", "masquerademask01",
                                 "mirror01", "ribbon03a", "shirt01", "towel04a", "toyanimal04", "toyanimal05", "vase01", "waterbottle01b", "bag", "handbag02a", 
                                 "boat", "box01a", "metalbrush", "scrubbingbrush05b", "birthdaycandle", "officechair01", "chair", "patiochair", "clock01a", "coffeemachine",
                                 "condom", "drum01", "fan", "woodenfence", "filmnegative", "plasticflower01a", "craneflower", "flower01", "hibiscusflower02", "lily",
                                 "folder", "workglove02c", "gluestick", "hammer01", "sledgehammer", "hat03b", "skihelmet01", "ridinghelmet", "hotdogweiner", "lamp04a",
                                 "studiolight", "iceberglettuce", "fluorescentlightbulb", "lintbrush", "doorlock", "communitymailbox", "handmixer01d", "noparkingsign", 
                                 "redonion", "fountainpen", "needlenosepliers01", "pot02a", "kitchenscale01a", "screw02", "shelf", "sneaker03b", "swimsuit", 
                                 "snowshovel", "athleticsock", "spatula04", "statue", "sieve01b", "tampon", "tennisracket", "floortile02", "toytank", "treestump",
                                 "tulip02", "umbrella04", "wallet02a", "xylophone"))


#' # Manually check for duplicates
# For duplicate items, add to manual filter list above 
# filter by filenames that contain a 0 (based on BOSS naming conventions) to make this easier
numeric_filenames <- final_stim_list %>%
  dplyr::filter(grepl("0",FILENAME)) %>%
  dplyr::arrange(FILENAME)

# sort by modal name
modal_sorted <- final_stim_list %>%
  dplyr::arrange(Modal_name)

# find unique modal names
modal_unique <- final_stim_list %>%
  dplyr::distinct(., Modal_name, .keep_all = TRUE)

#' # Summarize stimulus set
dim(final_stim_list)
summary(final_stim_list)

# check that have enough stimuli
obj_per_list <- 36
lures_per_list <- 36
num_lists_eeg <- 5
num_lists_mri <- 0
total_stimuli <- ((obj_per_list + lures_per_list) * num_lists_eeg) + ((obj_per_list + lures_per_list) * num_lists_mri)

if(dim(final_stim_list)[1] < total_stimuli){
  stop("Not enough stimuli")
}

#' # Write out object list
write(final_stim_list$FILENAME, file = file.path(file_path_out, "boss-stim-list.txt"))

