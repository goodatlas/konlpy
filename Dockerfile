FROM kcrong/python3.6

RUN apt-get install -y default-jdk
RUN apt-get install -y libmecab-dev

ADD requirements-py3.txt /requirements-py3.txt
RUN python3.6 -m pip install -r requirements-py3.txt

ADD . /konlpy

WORKDIR /konlpy

RUN python3.6 setup.py build
RUN python3.6 setup.py install

WORKDIR /konlpy/requirements/mecab-ko
RUN ./configure
RUN make
RUN make check
RUN make install

WORKDIR /konlpy/requirements/mecab-ko-dic
RUN ./configure
RUN make
RUN make install

RUN python3.6 -m pip install mecab-python3

WORKDIR /konlpy