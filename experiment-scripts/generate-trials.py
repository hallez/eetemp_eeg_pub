import csv, numpy, os, random, sys, yaml

subj_id = 's' + raw_input("Enter the subject number (e.g., 101): ")

list_length = 36
list_count = 5
lure_list_length = 15
num_eeg_blocks = 6
num_lures = (lure_list_length * num_eeg_blocks)
required_stim_count = (list_length * list_count) + num_lures

encoding_scale_options = ["1-yes       2-no", "1-no        2-yes"]

remember_response_options = [1,3]

questions = ['bathtub', 'convenience store', 'fridge', 'supermarket']

practice_stim_numbers = range(3,15)
practice_list_length = 4
practice_lure_list_length = 2

config = yaml.load(open('config.yml', 'r'))
directories = config['directories']

stimlist_path = os.path.join(directories['base-dir'], directories['scripts'], 'boss-stim-list.txt')
outdir = os.path.join(directories['base-dir'], directories['raw-behavioral-dir'], subj_id)

if not os.path.exists(outdir):
    os.makedirs(outdir)

# function definitions
def write_file(filename, items, format_str, header_str):
  filepath = os.path.join(outdir, filename)

  with open(filepath, 'wb') as f:
      # write a headerline to meet psychopy expectations
      # NB: headerline cannot include spaces
      f.write(header_str)
      numpy.savetxt(f, items, fmt = format_str, delimiter =",")

def write_lbls_file(filename, items, format_str, header_str):
  filepath = os.path.join(directories['base-dir'], directories['scripts'], filename)

  with open(filepath, 'wb') as f:
      # write a headerline to meet psychopy expectations
      # NB: headerline cannot include spaces
      f.write(header_str)
      numpy.savetxt(f, items, fmt=format_str, delimiter=",")

# save out encoding block labels file
write_lbls_file("list-ids.csv", range(1, list_count+1), '%s', 'listNum\n')

# randomly generate encoding response scale
encoding_scale = random.choice(encoding_scale_options)

# randomly generate response scale order for object recognition
remember_response = random.choice(remember_response_options)
if remember_response == 1:
    objrec_scale = "1-remember   2-familiar   3-new"
    familiar_response = 2
    new_response = 3
elif remember_response == 3:
    objrec_scale = "1-new   2-familiar   3-remember"
    familiar_response = 2
    new_response = 1

# randomly generate response scale order for question source recognition
# so that don't overwrite questions set new variable as a list
# based on https://www.safaribooksonline.com/library/view/python-cookbook/0596001673/ch02s09.html
questions_shuffled = list(questions)
numpy.random.shuffle(questions_shuffled)
q1 = questions_shuffled[0]
q2 = questions_shuffled[1]
q3 = questions_shuffled[2]
q4 = questions_shuffled[3]

stimpaths = [line.rstrip('\n') for line in open(stimlist_path)]

numstim = len(stimpaths)
if numstim < required_stim_count:
  msg = "not enough stimuli - have {}, need {}!".format(
    numstim, required_stim_count)
  sys.exit(msg)

numpy.random.shuffle(stimpaths)

if list_length % len(questions) != 0:
    msg = "list_length {} is not evenly divisible by the number of questions {}".format(list_length, len(questions))
    sys.exit(msg)

list_questions = numpy.repeat(questions, list_length/len(questions))

# remove any unnecessary stimuli
stimpaths = stimpaths[0:required_stim_count]

# select to-be-studied items
for i in range(list_count):
  stim_start_index = i * list_length
  stim_end_index = stim_start_index + list_length

  # select to-be-studied list
  stimlist = stimpaths[stim_start_index:stim_end_index]

  numpy.random.shuffle(list_questions)

  enc_list_id = numpy.repeat(str(i+1), len(stimlist))

  # use double parenthesis because numpy.column_stack takes a single input
  stimlist_rows = numpy.column_stack((stimlist, list_questions, enc_list_id, numpy.repeat(1,len(stimlist)), numpy.repeat(encoding_scale, len(stimlist))))

  filename = "enc_{}.csv".format(i+1)
  write_file(filename, stimlist_rows, ['%s', '%s', '%s', '%s','%s'], 'stim,encQuest,encList,oldStatus,encRatingScale\n')

  # append current stimlist to growing objrec list
  if i==0:
      objrec_old_items = stimlist_rows
  else:
      objrec_old_items = numpy.concatenate((objrec_old_items, stimlist_rows), axis = 0)

numpy.random.shuffle(objrec_old_items)
write_file("list_recog.csv", objrec_old_items, ['%s', '%s', '%s', '%s','%s'], 'stim,encQuest,encList,oldStatus,encRatingScale\n')

# select new (lure) items
lure_start_index = stim_end_index
lure_end_index = lure_start_index + num_lures
lurelist = stimpaths[lure_start_index:lure_end_index]
lurelist_rows = numpy.column_stack((lurelist, numpy.repeat("new", len(lurelist)), numpy.repeat(0, len(lurelist)), numpy.repeat(0, len(lurelist)), numpy.repeat(encoding_scale, len(lurelist))))

# chunk item recognition into mini-lists for eeg
# ensure each block has the same number of new (lure) items
if required_stim_count % num_eeg_blocks == 0:
    length_eeg_block = required_stim_count / num_eeg_blocks
    num_old_per_block = (list_length * list_count) / num_eeg_blocks

    # write out block labels file
    write_lbls_file("eeg-block-ids.csv", range(1, num_eeg_blocks+1), '%s', 'blockNum\n')

    for i in range(num_eeg_blocks):
        start_idx = i * num_old_per_block
        end_idx = start_idx + num_old_per_block
        lure_start_idx = i * lure_list_length
        lure_end_idx = lure_start_idx + lure_list_length
        cur_old = objrec_old_items[numpy.array(range(start_idx,end_idx)), :]
        cur_new = lurelist_rows[numpy.array(range(lure_start_idx, lure_end_idx)),:] # select from `lurelist` to ensure items only ever in new or old list

        cur_old_new = numpy.concatenate((cur_old, cur_new), axis = 0)
        cur_eeg_block = numpy.column_stack((cur_old_new, numpy.repeat(objrec_scale, len(cur_old_new)), numpy.repeat(remember_response, len(cur_old_new)), numpy.repeat(familiar_response, len(cur_old_new)), numpy.repeat(new_response, len(cur_old_new)), numpy.repeat(q1, len(cur_old_new)), numpy.repeat(q2, len(cur_old_new)), numpy.repeat(q3, len(cur_old_new)), numpy.repeat(q4, len(cur_old_new))))

        numpy.random.shuffle(cur_eeg_block)
        write_file("eeg_recog_{}.csv".format(i+1), cur_eeg_block, ['%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s'], 'stim,encQuest,encList,oldStatus,encRatingScale,objRecScale,rememberResp,familiarResp,newResp,q1,q2,q3,q4\n')
else:
    msg= "ERROR: The number of objrec trials is not evenly divisible by the number of eeg blocks."
    sys.exit(msg)

# save out subject-unique practice files so that can use same response scale ordering
numpy.random.shuffle(practice_stim_numbers)
practice_stimlist = practice_stim_numbers[0:practice_list_length]

practice_lure_stimlist = numpy.column_stack((practice_stim_numbers[practice_list_length:practice_list_length + practice_lure_list_length], numpy.repeat("lure", practice_lure_list_length), numpy.repeat(encoding_scale, practice_lure_list_length)))

practice_questions = numpy.repeat(questions, practice_list_length/len(questions))

numpy.random.shuffle(practice_questions) # shuffle so in a random order

practice_enc = numpy.column_stack((practice_stimlist, practice_questions, numpy.repeat(encoding_scale, len(practice_stimlist))))
write_file("practice_enc.csv", practice_enc, ['%s', '%s', '%s'], 'stim,encQuest,encRatingScale\n')

practice_objrec_items = numpy.concatenate((practice_enc, practice_lure_stimlist), axis = 0)
practice_objrec = numpy.column_stack((practice_objrec_items,
                                      numpy.repeat(objrec_scale, len(practice_objrec_items)), numpy.repeat(remember_response, len(practice_objrec_items)),numpy.repeat(familiar_response, len(practice_objrec_items)),numpy.repeat(new_response, len(practice_objrec_items)),
                                      numpy.repeat(q1, len(practice_objrec_items)),numpy.repeat(q2, len(practice_objrec_items)),numpy.repeat(q3, len(practice_objrec_items)),numpy.repeat(q4, len(practice_objrec_items))))

numpy.random.shuffle(practice_objrec)
write_file("practice_objrec.csv", practice_objrec, ['%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s', '%s'], 'stim,encQuest,encRatingScale,objRecScale,rememberResp,familiarResp,newResp,q1,q2,q3,q4\n')
