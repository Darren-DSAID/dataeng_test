from absl import app
from absl import flags
from os import listdir,rename,makedirs
from os.path import isfile, join, basename, exists
import re
import csv
import logging
FLAGS = flags.FLAGS
flags.DEFINE_string("data_folder","./data",
    "data folder")
def processSingleFile(origFileName, resultFileName, errorFileName,processedFileName):
    prefix_tobe_removed = '(^[A-Z][a-z]{1,3}\. )|(Miss) ' #to replace salutation like Mr. Dr. ... and Miss

    with open(origFileName, newline='') as origFile, open(resultFileName,'w+') as resultFile, open(errorFileName,'w+') as errorFile :

        resultReader = csv.reader(origFile, delimiter=',')
        resultWriter = csv.writer(resultFile, delimiter=',')
        errorWriter = csv.writer(errorFile, delimiter=',')
        #write data header to file
        resultWriter.writerow(['first_name','last_name','price','above_100'])
        errorWriter.writerow(['name','price','error'])
        for i,row in enumerate(resultReader):
            try:
                if(i==0):
                    continue
                name = row[0]
                price = float(row[1])
                above_100 = True if price>100 else False
                name=re.sub(prefix_tobe_removed,"",name).strip()
                if not name:
                    #do nothing
                    print(name)
                first_name,last_name=name.split(" ")[0],name.split(" ")[1] # after substitute the salutation, checked all names' len are either 2 or 3. Take the first two is ok
                # write data to file
                resultWriter.writerow([first_name,last_name,price,above_100])
            except Exception as e:
                row.append(e)
                errorWriter.writerow(e)
        #move original file to processed directory
        rename(origFileName, processedFileName)

        logging.info("Processed file {} success".format(origFileName))

def processFile(data_folder):
    #assume original data is located in folder pre_processed
    if not exists(join(data_folder,'result')):
        makedirs(join(data_folder,'result'))
    if not exists(join(data_folder,'errors')):
        makedirs(join(data_folder,'errors'))
    if not exists(join(data_folder,'processed')):
        makedirs(join(data_folder,'processed'))
    originalFiles = onlyfiles = [f for f in listdir(join(data_folder,"pre_processed/")) if isfile(join(data_folder,"pre_processed", f))]
    for originalFile in originalFiles:
        fileName = basename(originalFile)
        originalFileName= join(data_folder,"pre_processed",originalFile)
        resultFile = join(data_folder,"result", fileName)
        errorFile = join(data_folder,"errors", fileName)
        processedFile = join(data_folder,"processed", fileName)
        processSingleFile(originalFileName, resultFile, errorFile, processedFile)
    logging.info("All done")



def main(_):
    data_folder=FLAGS.data_folder
    processFile(data_folder)

if __name__ == "__main__":

    app.run(main)
