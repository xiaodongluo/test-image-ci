FROM python
RUN git clone https://github.com/xiaodongluo/test-image-ci && git checkout -b img-test origin/img-test && python test-image-ci/helloworld.py
