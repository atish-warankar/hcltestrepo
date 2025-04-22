FROM python

COPY helloworld.py ./
CMD [ "helloworld.handler" ]