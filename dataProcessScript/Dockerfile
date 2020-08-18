FROM python:3.6.8-slim-jessie
RUN mkdir -p ~/data
COPY . /app
WORKDIR /app
ENV function_file=None data_folder=None
#RUN pip install --upgrade setuptools
RUN pip install --trusted-host pypi.python.org -r requirements.txt
CMD ["sh","-c","python $function_file \
--data_folder=$data_folder"]
