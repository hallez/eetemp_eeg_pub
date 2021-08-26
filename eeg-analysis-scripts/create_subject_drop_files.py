import numpy
import pandas
import os.path
import shutil
import yaml

# define functions 
def extract_and_save_cols(out_dir, subj_str_value, row_value, analysis_type, column_to_extract):
    fname_out = "%s_b%d_%s%s.csv" % (subj_str_value, row_value['BLOCK'], analysis_type, column_to_extract)
    fpath_out = os.path.join(out_dir, subj_str_value, fname_out)
    col_name = "%s%s" % (analysis_type, column_to_extract)
    extracted_col = row_value[col_name]

    # overwrite 'nan' float values with a string
    if isinstance(extracted_col, float):
        extracted_col = str('NaN')
        print('%s block %d column %s is %s of type %s' % (subj_str_value, row_value['BLOCK'], col_name, extracted_col, type(extracted_col)))

    # based on: https://stackoverflow.com/questions/5214578/python-print-string-to-text-file
    text_file = open(fpath_out, "w")
    text_file.write(extracted_col)
    text_file.close()

if __name__ == '__main__':
    config = yaml.load(open('config.yml', 'r'))
    directories = config['directories']
    base_dir = directories['base-dir']
    analyzed_eeg_dir = os.path.join(directories['dropbox-folder'], directories['analyzed-eeg-dir'])

    # read in the csv file with subject information ("eetemp_bad_channels_and_epochs.csv")
    info_fname = os.path.join(base_dir, 'eetemp_bad_channels_and_epochs.csv')
    if not os.path.exists(info_fname):
        print(info_fname + " does not exist!")

    # read in using pandas because it plays nicely with csv files
    df = pandas.read_csv(info_fname)
    print(type(df))
    print("column names are: " + str(list(df)))

    # based on: https://stackoverflow.com/questions/16476924/how-to-iterate-over-rows-in-a-dataframe-in-pandas/16476974
    for index, row in df.iterrows():
        subj_str = "s%s" % row['SUBJECT']

        extract_and_save_cols(analyzed_eeg_dir, subj_str, row, 'ERP', '_BLINK_COMPONENTS')
        # don't worry about converting channels from numeric to string, this is handled in matlab ('interpolate_channels.m')
        extract_and_save_cols(analyzed_eeg_dir, subj_str, row, 'ERP', '_BAD_CHANNELS')
        extract_and_save_cols(analyzed_eeg_dir, subj_str, row, 'ERP', '_BAD_EPOCHS')
        extract_and_save_cols(analyzed_eeg_dir, subj_str, row, 'TF', '_BLINK_COMPONENTS')
        extract_and_save_cols(analyzed_eeg_dir, subj_str, row, 'TF', '_BAD_CHANNELS')
        extract_and_save_cols(analyzed_eeg_dir, subj_str, row, 'TF', '_BAD_EPOCHS')

    # figure out how to drop entire blocks (if all columns have an NA, maybe use this? or add a separate column to input csv file?)
    # could also have a separate list of subjects to exclude (maybe as its own .yml file?), this would be nice because could read into all scripts
