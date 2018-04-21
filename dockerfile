FROM python
RUN git clone https://github.com/xiaodongluo/test-image-ci && python test-image-ci/helloworld.py
