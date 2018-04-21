FROM python
RUN git clone https://github.com/xiaodongluo/test-image-ci && cd test-image-ci && git checkout -b img-test origin/img-test && python helloworld.py
