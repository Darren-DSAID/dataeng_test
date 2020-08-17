FROM python:3.6.8-slim-jessie
COPY . /app
WORKDIR /app
ENV function_file=None input_folder=None obs_folder=None
#RUN pip install --upgrade setuptools
RUN pip install --trusted-host pypi.python.org -r requirements.txt
CMD ["sh","-c","python $function_file \
    --input_folder=$input_folder \
    --obs_folder=$obs_folder"]

